#!/usr/bin/env python3
"""DAENAMU ground-truth extractor.

This is not the final agent and it does not patch README.md.
It is a small helper that extracts verifiable facts from the local repository so
an orchestrator agent can compare those facts against the full README.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
REPORT_DIR = ROOT / "agent" / "reports"
MARKDOWN_REPORT = REPORT_DIR / "latest-ground-truth.md"
JSON_REPORT = REPORT_DIR / "latest-ground-truth.json"
HELM_VALUES = ROOT / "infra" / "helm" / "daenamu" / "values.yaml"
TERRAFORM_ROOT = ROOT / "infra" / "terraform"


@dataclass(frozen=True)
class ServiceInfo:
    directory: str
    app_name: str
    port: str
    controller: str
    properties: str
    apis: tuple[str, ...]
    downstream: str


@dataclass(frozen=True)
class HelmServiceInfo:
    name: str
    image: str
    service_port: str
    target_port: str
    env: dict[str, str]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def parse_properties(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for line in read_text(path).splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in stripped:
            continue
        key, value = stripped.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def annotation_value(source: str, annotation: str) -> str:
    pattern = rf"@{annotation}(?:\(\s*(?:value\s*=\s*)?\"([^\"]*)\"\s*\))?"
    match = re.search(pattern, source)
    if not match:
        return ""
    return match.group(1) or ""


def method_mappings(source: str) -> list[tuple[str, str]]:
    mapping_to_method = {
        "GetMapping": "GET",
        "PostMapping": "POST",
        "PutMapping": "PUT",
        "PatchMapping": "PATCH",
        "DeleteMapping": "DELETE",
    }
    mappings: list[tuple[str, str]] = []
    for annotation, method in mapping_to_method.items():
        pattern = rf"@{annotation}(?:\(\s*(?:value\s*=\s*)?\"([^\"]*)\"\s*\))?"
        for match in re.finditer(pattern, source):
            mappings.append((method, match.group(1) or ""))
    return mappings


def join_paths(base: str, child: str) -> str:
    if not child:
        return base
    return f"{base.rstrip('/')}/{child.lstrip('/')}"


def extract_apis(controller: Path) -> tuple[str, ...]:
    source = read_text(controller)
    base = annotation_value(source, "RequestMapping")
    return tuple(f"{method} {join_paths(base, child)}" for method, child in method_mappings(source))


def downstream_for(properties: dict[str, str]) -> str:
    for key in properties:
        match = re.match(r"daenamu\.([^.]+)\.base-url", key)
        if match:
            return match.group(1)
    return "-"


def discover_services() -> list[ServiceInfo]:
    services: list[ServiceInfo] = []
    backend = ROOT / "backend"
    if not backend.exists():
        return services

    for service_dir in sorted(backend.iterdir()):
        if not service_dir.is_dir():
            continue
        properties_path = service_dir / "src" / "main" / "resources" / "application.properties"
        controller_dir = service_dir / "src" / "main" / "java" / "com" / "daenamu" / service_dir.name / "controller"
        controllers = sorted(controller_dir.glob("*Controller.java"))
        if not properties_path.exists() or not controllers:
            continue

        props = parse_properties(properties_path)
        controller = controllers[0]
        services.append(
            ServiceInfo(
                directory=service_dir.name,
                app_name=props.get("spring.application.name", service_dir.name),
                port=props.get("server.port", "?"),
                controller=str(controller.relative_to(ROOT)),
                properties=str(properties_path.relative_to(ROOT)),
                apis=extract_apis(controller),
                downstream=downstream_for(props),
            )
        )

    return sorted(services, key=lambda item: int(item.port) if item.port.isdigit() else 9999)


def clean_value(value: str) -> str:
    return value.strip().strip("\"'")


def discover_helm_services() -> list[HelmServiceInfo]:
    if not HELM_VALUES.exists():
        return []

    services: list[HelmServiceInfo] = []
    registry = ""
    project = ""
    current: str | None = None
    section: str | None = None
    data: dict[str, dict[str, object]] = {}

    for raw_line in read_text(HELM_VALUES).splitlines():
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue

        stripped = raw_line.strip()
        indent = len(raw_line) - len(raw_line.lstrip(" "))

        if indent == 2 and stripped.startswith("imageRegistry:"):
            registry = clean_value(stripped.split(":", 1)[1])
            continue
        if indent == 2 and stripped.startswith("imageProject:"):
            project = clean_value(stripped.split(":", 1)[1])
            continue

        if indent == 2 and stripped.endswith(":"):
            name = stripped[:-1]
            if name not in {"image", "service", "env"}:
                current = name
                section = None
                data[current] = {"env": {}}
            continue

        if current is None:
            continue

        if indent == 4 and stripped.endswith(":"):
            section = stripped[:-1]
            continue

        if indent >= 6 and ":" in stripped and section:
            key, value = stripped.split(":", 1)
            key = key.strip()
            value = clean_value(value)
            if section == "image":
                data[current][f"image_{key}"] = value
            elif section == "service":
                data[current][f"service_{key}"] = value
            elif section == "env":
                env = data[current].setdefault("env", {})
                if isinstance(env, dict):
                    env[key] = value

    for name, service in data.items():
        repository = str(service.get("image_repository", name))
        tag = str(service.get("image_tag", "local"))
        image = f"{registry}/{project}/{repository}:{tag}" if registry and project else f"{repository}:{tag}"
        services.append(
            HelmServiceInfo(
                name=name,
                image=image,
                service_port=str(service.get("service_port", "?")),
                target_port=str(service.get("service_targetPort", "?")),
                env=dict(service.get("env", {})),
            )
        )

    return services


def discover_terraform_files() -> list[str]:
    if not TERRAFORM_ROOT.exists():
        return []
    return [str(path.relative_to(ROOT)) for path in sorted(TERRAFORM_ROOT.rglob("*.tf"))]


def render_markdown(services: list[ServiceInfo]) -> str:
    helm_services = discover_helm_services()
    terraform_files = discover_terraform_files()
    lines = [
        "Ground Truth 추출 결과",
        "",
        "서비스 정보:",
    ]
    for service in services:
        lines.append(
            f"- {service.app_name}: port {service.port}, APIs {', '.join(service.apis)}, downstream {service.downstream}"
        )

    topology = "frontend -> " + " -> ".join(service.app_name for service in services)
    lines.extend(["", "호출 흐름:", f"- {topology}", "", "근거 파일:"])
    for service in services:
        lines.append(f"- {service.controller}")
        lines.append(f"- {service.properties}")

    if helm_services:
        lines.extend(["", "Helm 배포 정보:"])
        for service in helm_services:
            lines.append(
                f"- {service.name}: image {service.image}, service port {service.service_port}, targetPort {service.target_port}"
            )
    else:
        lines.extend(["", "불확실한 항목:", "- infra/helm/daenamu chart가 없어 Helm 배포 값 검증은 수행하지 못함"])

    if terraform_files:
        lines.extend(["", "Terraform 구성 파일:"])
        lines.extend(f"- {path}" for path in terraform_files)

    return "\n".join(lines)


def payload(services: list[ServiceInfo]) -> dict[str, object]:
    helm_services = discover_helm_services()
    terraform_files = discover_terraform_files()
    missing = []
    if not helm_services:
        missing.append("infra/helm/daenamu chart가 없어 Helm 배포 값 검증은 수행하지 못함")

    return {
        "services": [asdict(service) for service in services],
        "helm": [asdict(service) for service in helm_services],
        "terraform": terraform_files,
        "topology": "frontend -> " + " -> ".join(service.app_name for service in services),
        "uncertain": missing,
    }


def write_reports(services: list[ServiceInfo]) -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    MARKDOWN_REPORT.write_text(render_markdown(services) + "\n", encoding="utf-8")
    JSON_REPORT.write_text(json.dumps(payload(services), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract DAENAMU repository ground truth.")
    parser.add_argument("--json", action="store_true", help="print machine-readable JSON")
    parser.add_argument("--no-write", action="store_true", help="do not write agent/reports files")
    args = parser.parse_args()

    services = discover_services()
    if not services:
        raise SystemExit("backend 서비스 정보를 찾지 못했습니다.")

    if not args.no_write:
        write_reports(services)

    if args.json:
        print(json.dumps(payload(services), ensure_ascii=False, indent=2))
        return 0

    print(render_markdown(services))
    if not args.no_write:
        print()
        print("리포트 파일:")
        print(f"- {MARKDOWN_REPORT.relative_to(ROOT)}")
        print(f"- {JSON_REPORT.relative_to(ROOT)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

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


@dataclass(frozen=True)
class ServiceInfo:
    directory: str
    app_name: str
    port: str
    controller: str
    properties: str
    apis: tuple[str, ...]
    downstream: str


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


def render_markdown(services: list[ServiceInfo]) -> str:
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

    if not (ROOT / "infra" / "k8s" / "base").exists():
        lines.extend(["", "불확실한 항목:", "- infra/k8s/base 디렉터리가 없어 Kubernetes manifest 검증은 수행하지 못함"])

    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract DAENAMU repository ground truth.")
    parser.add_argument("--json", action="store_true", help="print machine-readable JSON")
    args = parser.parse_args()

    services = discover_services()
    if not services:
        raise SystemExit("backend 서비스 정보를 찾지 못했습니다.")

    if args.json:
        print(json.dumps({"services": [asdict(service) for service in services]}, ensure_ascii=False, indent=2))
    else:
        print(render_markdown(services))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

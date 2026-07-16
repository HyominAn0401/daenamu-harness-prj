#!/usr/bin/env python3
"""Deterministic README drift agent for DAENAMU.

The agent observes repository ground truth, compares it with README.md, decides
whether documentation drift exists, and writes a reviewable report. It avoids
guessing and does not patch README.md automatically.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path

from extract_ground_truth import ROOT, payload, discover_services


README = ROOT / "README.md"
REPORT_DIR = ROOT / "agent" / "reports"
JSON_REPORT = REPORT_DIR / "latest-readme-drift-agent.json"
MARKDOWN_REPORT = REPORT_DIR / "latest-readme-drift-agent.md"


@dataclass(frozen=True)
class Finding:
    severity: str
    category: str
    message: str
    expected: str
    evidence: str


@dataclass(frozen=True)
class AgentResult:
    agent: str
    status: str
    findings: list[Finding]
    checked_files: list[str]


class ReadmeDriftAgent:
    """A small observe-decide-report agent for README drift checks."""

    def __init__(self, readme_path: Path = README) -> None:
        self.readme_path = readme_path

    def observe(self) -> tuple[dict[str, object], str]:
        services = discover_services()
        ground_truth = payload(services)
        readme_text = self.readme_path.read_text(encoding="utf-8")
        return ground_truth, readme_text

    def decide(self, ground_truth: dict[str, object], readme_text: str) -> list[Finding]:
        findings: list[Finding] = []
        self._check_topology(ground_truth, readme_text, findings)
        self._check_services(ground_truth, readme_text, findings)
        self._check_helm(ground_truth, readme_text, findings)
        self._check_stale_terms(readme_text, findings)
        return findings

    def report(self, result: AgentResult, *, json_output: bool) -> None:
        REPORT_DIR.mkdir(parents=True, exist_ok=True)
        JSON_REPORT.write_text(
            json.dumps(
                {
                    **asdict(result),
                    "findings": [asdict(finding) for finding in result.findings],
                },
                ensure_ascii=False,
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )
        MARKDOWN_REPORT.write_text(self._render_markdown(result), encoding="utf-8")

        if json_output:
            print(JSON_REPORT.read_text(encoding="utf-8"), end="")
        else:
            print(self._render_console(result))
            print()
            print("Reports:")
            print(f"- {JSON_REPORT.relative_to(ROOT)}")
            print(f"- {MARKDOWN_REPORT.relative_to(ROOT)}")

    def run(self, *, json_output: bool) -> AgentResult:
        ground_truth, readme_text = self.observe()
        findings = self.decide(ground_truth, readme_text)
        status = "drift_found" if findings else "ok"
        result = AgentResult(
            agent="readme-drift-agent",
            status=status,
            findings=findings,
            checked_files=[
                str(README.relative_to(ROOT)),
                "agent/reports/latest-ground-truth.json",
                "backend/*/src/main/resources/application.properties",
                "backend/*/src/main/java/**/controller/*Controller.java",
                "infra/helm/daenamu/values.yaml",
            ],
        )
        self.report(result, json_output=json_output)
        return result

    def _check_topology(
        self,
        ground_truth: dict[str, object],
        readme_text: str,
        findings: list[Finding],
    ) -> None:
        topology = str(ground_truth.get("topology", ""))
        if topology and topology not in readme_text:
            findings.append(
                Finding(
                    severity="high",
                    category="topology",
                    message="README does not contain the current service call topology.",
                    expected=topology,
                    evidence="agent/reports/latest-ground-truth.json",
                )
            )

    def _check_services(
        self,
        ground_truth: dict[str, object],
        readme_text: str,
        findings: list[Finding],
    ) -> None:
        for service in ground_truth.get("services", []):
            if not isinstance(service, dict):
                continue
            name = str(service.get("app_name", ""))
            port = str(service.get("port", ""))
            if name and name not in readme_text:
                findings.append(
                    Finding(
                        severity="high",
                        category="service",
                        message=f"README does not mention service name {name}.",
                        expected=name,
                        evidence=str(service.get("properties", "")),
                    )
                )
            if port and port not in readme_text:
                findings.append(
                    Finding(
                        severity="medium",
                        category="port",
                        message=f"README does not mention port {port} for {name}.",
                        expected=port,
                        evidence=str(service.get("properties", "")),
                    )
                )
            for api in service.get("apis", []):
                api_text = str(api)
                if api_text and api_text not in readme_text:
                    findings.append(
                        Finding(
                            severity="medium",
                            category="api",
                            message=f"README does not contain API {api_text}.",
                            expected=api_text,
                            evidence=str(service.get("controller", "")),
                        )
                    )

    def _check_helm(
        self,
        ground_truth: dict[str, object],
        readme_text: str,
        findings: list[Finding],
    ) -> None:
        for service in ground_truth.get("helm", []):
            if not isinstance(service, dict):
                continue
            name = str(service.get("name", ""))
            image = str(service.get("image", ""))
            if image and image not in readme_text:
                findings.append(
                    Finding(
                        severity="medium",
                        category="helm",
                        message=f"README does not contain Helm image reference for {name}.",
                        expected=image,
                        evidence="infra/helm/daenamu/values.yaml",
                    )
                )

    def _check_stale_terms(self, readme_text: str, findings: list[Finding]) -> None:
        stale_terms = {
            "stream-service": "Current services are catalog, episode, playback, and frontend.",
            "drama-service": "Current catalog service name is catalog.",
            "AWS EKS": "Current infra target is local KinD, not AWS EKS.",
            "IRSA": "Current infra does not configure IRSA.",
            "Istio": "Current tracing uses OpenTelemetry Java Agent, not Istio.",
            "Envoy sidecar": "Current tracing does not use Envoy sidecars.",
        }
        for term, expected in stale_terms.items():
            if term in readme_text:
                findings.append(
                    Finding(
                        severity="high",
                        category="stale-term",
                        message=f"README contains stale term {term}.",
                        expected=expected,
                        evidence="AGENTS.md and current source tree",
                    )
                )

    def _render_markdown(self, result: AgentResult) -> str:
        lines = [
            "# README Drift Agent Report",
            "",
            f"- Agent: `{result.agent}`",
            f"- Status: `{result.status}`",
            "",
            "## Checked files",
        ]
        lines.extend(f"- `{path}`" for path in result.checked_files)
        lines.extend(["", "## Findings"])
        if not result.findings:
            lines.append("- No README drift found.")
        else:
            for finding in result.findings:
                lines.append(
                    f"- [{finding.severity}] {finding.category}: {finding.message} "
                    f"Expected `{finding.expected}`. Evidence: `{finding.evidence}`"
                )
        return "\n".join(lines) + "\n"

    def _render_console(self, result: AgentResult) -> str:
        if not result.findings:
            return "README drift agent: OK - no drift found."

        lines = [f"README drift agent: {len(result.findings)} finding(s)"]
        for finding in result.findings:
            lines.append(f"- [{finding.severity}] {finding.message}")
            lines.append(f"  expected: {finding.expected}")
            lines.append(f"  evidence: {finding.evidence}")
        return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the DAENAMU README drift agent.")
    parser.add_argument("--json", action="store_true", help="print JSON report")
    parser.add_argument(
        "--fail-on-drift",
        action="store_true",
        help="exit with status 2 when README drift is found",
    )
    args = parser.parse_args()

    result = ReadmeDriftAgent().run(json_output=args.json)
    if args.fail_on_drift and result.findings:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

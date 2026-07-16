param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Request,

    [string] $CodexBin = $env:CODEX_BIN,

    [string] $PythonBin = $env:PYTHON_BIN
)

$ErrorActionPreference = "Stop"

$RootDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$PromptFile = Join-Path $RootDir "agent/orchestrator/daenamu_agent_prompt.md"
$ReportDir = Join-Path $RootDir "agent/reports"

Set-Location $RootDir

if (-not $CodexBin) {
    $CodexBin = "codex"
}

$UserRequest = ($Request -join " ").Trim()
if (-not $UserRequest) {
    $UserRequest = (Read-Host "DAENAMU agent request").Trim()
}

if (-not $UserRequest) {
    Write-Error "No request provided."
    exit 2
}

if (-not (Get-Command $CodexBin -ErrorAction SilentlyContinue)) {
    Write-Error "Codex CLI not found: $CodexBin. Install Codex CLI or set CODEX_BIN."
    exit 127
}

function Invoke-PythonScript {
    param([string] $ScriptPath)

    if ($PythonBin) {
        & $PythonBin $ScriptPath
        return
    }

    foreach ($Candidate in @("python3", "python")) {
        if (Get-Command $Candidate -ErrorAction SilentlyContinue) {
            & $Candidate $ScriptPath
            return
        }
    }

    if (Get-Command "py" -ErrorAction SilentlyContinue) {
        & py -3 $ScriptPath
        return
    }

    Write-Error "Python not found. Install Python or set PYTHON_BIN."
    exit 127
}

Write-Host "[DAENAMU Agent] Observing repository ground truth"
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null
& git -c "safe.directory=$RootDir" diff -- . ':!agent/reports/latest-git-diff.patch' |
    Set-Content -Encoding UTF8 (Join-Path $ReportDir "latest-git-diff.patch")
& git -c "safe.directory=$RootDir" diff --cached -- . ':!agent/reports/latest-git-diff.patch' |
    Set-Content -Encoding UTF8 (Join-Path $ReportDir "latest-git-diff-staged.patch")
Invoke-PythonScript "agent/orchestrator/extract_ground_truth.py"

$BasePrompt = Get-Content $PromptFile -Raw
$CombinedPrompt = @"
$BasePrompt

## User request

$UserRequest
"@

Write-Host ""
Write-Host "[DAENAMU Agent] Running LLM agent"
Write-Host "- runner: $CodexBin"
Write-Host "- request: $UserRequest"
Write-Host ""

& $CodexBin exec --full-auto $CombinedPrompt

Write-Host ""
Write-Host "[DAENAMU Agent] Finished"
Write-Host "Review changes with:"
Write-Host "git diff -- README.md agent/reports"

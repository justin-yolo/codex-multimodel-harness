param(
    [string]$Prompt,
    [string]$PromptFile,
    [string]$ClaudeModel = $env:HARNESS_CLAUDE_MODEL,
    [string]$GeminiModel = $env:HARNESS_GEMINI_MODEL
)

if ([string]::IsNullOrWhiteSpace($ClaudeModel)) {
    $ClaudeModel = "claude-opus-4-6"
}

if ([string]::IsNullOrWhiteSpace($GeminiModel)) {
    $GeminiModel = "gemini-3.1-pro-preview"
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$failures = New-Object System.Collections.Generic.List[string]

function Invoke-ReviewHelper {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    try {
        & $Command
    } catch {
        $failures.Add($Name) | Out-Null
        [Console]::Error.WriteLine("[dual-review] $Name failed: $($_.Exception.Message)")
    }
}

if ($PromptFile) {
    Write-Host "===== Gemini 비판적 리뷰 ====="
    Invoke-ReviewHelper "Gemini" { & (Join-Path $scriptRoot "run_gemini_review.ps1") -PromptFile $PromptFile -Model $GeminiModel }

    Write-Host ""
    Write-Host "===== Claude 리드 리뷰 ====="
    Invoke-ReviewHelper "Claude" { & (Join-Path $scriptRoot "run_claude_review.ps1") -PromptFile $PromptFile -Model $ClaudeModel }
} elseif ($Prompt) {
    Write-Host "===== Gemini 비판적 리뷰 ====="
    Invoke-ReviewHelper "Gemini" { & (Join-Path $scriptRoot "run_gemini_review.ps1") -Prompt $Prompt -Model $GeminiModel }

    Write-Host ""
    Write-Host "===== Claude 리드 리뷰 ====="
    Invoke-ReviewHelper "Claude" { & (Join-Path $scriptRoot "run_claude_review.ps1") -Prompt $Prompt -Model $ClaudeModel }
} else {
    $pipelineText = @($input) -join [Environment]::NewLine
    if ([string]::IsNullOrWhiteSpace($pipelineText)) {
        if ([Console]::IsInputRedirected) {
            $payload = [Console]::In.ReadToEnd()
        }
    } else {
        $payload = $pipelineText
    }

    if ([string]::IsNullOrWhiteSpace($payload)) {
        throw "프롬프트 내용이 없습니다. -Prompt, -PromptFile 또는 stdin을 사용하세요."
    }

    Write-Host "===== Gemini 비판적 리뷰 ====="
    Invoke-ReviewHelper "Gemini" { & (Join-Path $scriptRoot "run_gemini_review.ps1") -Prompt $payload -Model $GeminiModel }

    Write-Host ""
    Write-Host "===== Claude 리드 리뷰 ====="
    Invoke-ReviewHelper "Claude" { & (Join-Path $scriptRoot "run_claude_review.ps1") -Prompt $payload -Model $ClaudeModel }
}

if ($failures.Count -gt 0) {
    [Console]::Error.WriteLine("[dual-review] Failed review(s): $($failures -join ', ')")
    throw "Dual review failed."
}

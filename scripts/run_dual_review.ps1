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

if ($PromptFile) {
    Write-Host "===== Gemini 비판적 리뷰 ====="
    & (Join-Path $scriptRoot "run_gemini_review.ps1") -PromptFile $PromptFile -Model $GeminiModel

    Write-Host ""
    Write-Host "===== Claude 리드 리뷰 ====="
    & (Join-Path $scriptRoot "run_claude_review.ps1") -PromptFile $PromptFile -Model $ClaudeModel
} elseif ($Prompt) {
    Write-Host "===== Gemini 비판적 리뷰 ====="
    & (Join-Path $scriptRoot "run_gemini_review.ps1") -Prompt $Prompt -Model $GeminiModel

    Write-Host ""
    Write-Host "===== Claude 리드 리뷰 ====="
    & (Join-Path $scriptRoot "run_claude_review.ps1") -Prompt $Prompt -Model $ClaudeModel
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
    $payload | & (Join-Path $scriptRoot "run_gemini_review.ps1") -Model $GeminiModel

    Write-Host ""
    Write-Host "===== Claude 리드 리뷰 ====="
    $payload | & (Join-Path $scriptRoot "run_claude_review.ps1") -Model $ClaudeModel
}

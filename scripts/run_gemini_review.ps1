param(
    [string]$Prompt,
    [string]$PromptFile,
    [string]$Model = $env:HARNESS_GEMINI_MODEL
)

if ([string]::IsNullOrWhiteSpace($Model)) {
    $Model = "gemini-3.1-pro-preview"
}

$gemini = Get-Command "gemini" -All -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandType -eq "Application" } |
    Select-Object -First 1

if (-not $gemini) {
    $gemini = Get-Command "gemini" -ErrorAction SilentlyContinue
}

if (-not $gemini) {
    throw "PATH에서 Gemini CLI를 찾지 못했습니다."
}

if ($PromptFile) {
    $payload = Get-Content -LiteralPath $PromptFile -Raw -Encoding UTF8
} elseif ($Prompt) {
    $payload = $Prompt
} else {
    $pipelineText = @($input) -join [Environment]::NewLine
    if ([string]::IsNullOrWhiteSpace($pipelineText)) {
        $payload = [Console]::In.ReadToEnd()
    } else {
        $payload = $pipelineText
    }
}

if ([string]::IsNullOrWhiteSpace($payload)) {
    throw "프롬프트 내용이 없습니다. -Prompt, -PromptFile 또는 stdin을 사용하세요."
}

# Keep the real prompt on stdin so long or multiline prompts do not hit Windows
# command-line length and quoting limits.
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$payload | & $gemini.Source --prompt " " --model $Model --approval-mode plan --output-format text

if ($LASTEXITCODE -ne 0) {
    throw "Gemini CLI exited with code $LASTEXITCODE."
}

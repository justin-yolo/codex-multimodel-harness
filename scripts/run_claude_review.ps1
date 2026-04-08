param(
    [string]$Prompt,
    [string]$PromptFile,
    [string]$Model = $env:HARNESS_CLAUDE_MODEL
)

if ([string]::IsNullOrWhiteSpace($Model)) {
    $Model = "claude-opus-4-6"
}

$claude = Get-Command "claude" -ErrorAction SilentlyContinue
if (-not $claude) {
    throw "PATH에서 Claude CLI를 찾지 못했습니다."
}

if ($PromptFile) {
    $payload = Get-Content -LiteralPath $PromptFile -Raw -Encoding UTF8
} elseif ($Prompt) {
    $payload = $Prompt
} else {
    $pipelineText = @($input) -join [Environment]::NewLine
    if ([string]::IsNullOrWhiteSpace($pipelineText)) {
        if ([Console]::IsInputRedirected) {
            $payload = [Console]::In.ReadToEnd()
        }
    } else {
        $payload = $pipelineText
    }
}

if ([string]::IsNullOrWhiteSpace($payload)) {
    throw "프롬프트 내용이 없습니다. -Prompt, -PromptFile 또는 stdin을 사용하세요."
}

# PowerShell pipeline stdin mangles Korean text for claude.exe on Windows.
# Write the prompt directly to the child process stdin instead.
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $claude.Source
$psi.Arguments = "-p --model `"$Model`" --tools `"`" --permission-mode plan --output-format text"
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true

$process = [System.Diagnostics.Process]::Start($psi)
$process.StandardInput.Write($payload)
$process.StandardInput.Close()

$stdout = $process.StandardOutput.ReadToEnd()
$stderr = $process.StandardError.ReadToEnd()
$process.WaitForExit()

if (-not [string]::IsNullOrWhiteSpace($stdout)) {
    [Console]::Out.Write($stdout)
}

if ($process.ExitCode -ne 0) {
    if (-not [string]::IsNullOrWhiteSpace($stderr)) {
        [Console]::Error.Write($stderr)
    }
    throw "Claude CLI exited with code $($process.ExitCode)."
}

if (-not [string]::IsNullOrWhiteSpace($stderr)) {
    [Console]::Error.Write($stderr)
}

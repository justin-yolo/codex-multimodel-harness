Write-Host "===== Gemini 스모크 테스트 ====="
powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "run_gemini_review.ps1") -Prompt "Return exactly: GEMINI_SMOKE_OK"

Write-Host ""
Write-Host "===== Claude 스모크 테스트 ====="
powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "run_claude_review.ps1") -Prompt "Return exactly: CLAUDE_SMOKE_OK"

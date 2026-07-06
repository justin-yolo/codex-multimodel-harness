function Invoke-SmokeReview {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        [Parameter(Mandatory = $true)]
        [string]$Sentinel
    )

    Write-Host "===== $Name smoke test ====="
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" -Prompt `"Return exactly: $Sentinel`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $process = [System.Diagnostics.Process]::Start($psi)
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    $exitCode = $process.ExitCode
    $outputText = (($stdout, $stderr) -join [Environment]::NewLine).Trim()
    if (-not [string]::IsNullOrWhiteSpace($outputText)) {
        Write-Host $outputText
    }

    $passed = $exitCode -eq 0 -and $outputText.Contains($Sentinel)
    if ($passed) {
        Write-Host "$Name smoke: PASS"
    } else {
        Write-Host "$Name smoke: FAIL"
    }

    [PSCustomObject]@{
        Name = $Name
        Passed = $passed
        ExitCode = $exitCode
    }
}

$results = @(
    Invoke-SmokeReview -Name "Gemini" -ScriptPath (Join-Path $PSScriptRoot "run_gemini_review.ps1") -Sentinel "GEMINI_SMOKE_OK"
    Invoke-SmokeReview -Name "Claude" -ScriptPath (Join-Path $PSScriptRoot "run_claude_review.ps1") -Sentinel "CLAUDE_SMOKE_OK"
)

$failed = @($results | Where-Object { -not $_.Passed })
if ($failed) {
    $details = ($failed | ForEach-Object { "$($_.Name) exit $($_.ExitCode)" }) -join ", "
    throw "Smoke test failed: $details"
}

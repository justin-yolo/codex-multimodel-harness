function Get-ToolInfo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        return [PSCustomObject]@{
            Name = $Name
            Found = $false
            Path = $null
            Version = $null
        }
    }

    $version = $null
    try {
        $version = (& $cmd.Source --version 2>$null | Select-Object -First 1)
    } catch {
        $version = "버전 확인 실패"
    }

    [PSCustomObject]@{
        Name = $Name
        Found = $true
        Path = $cmd.Source
        Version = $version
    }
}

$tools = @(
    Get-ToolInfo -Name "claude"
    Get-ToolInfo -Name "gemini"
)

$tools | Format-Table -AutoSize

$missing = $tools | Where-Object { -not $_.Found }
if ($missing) {
    throw "필수 CLI가 없습니다: $($missing.Name -join ', ')"
}

Write-Host "=== System Health Check ==="

Get-PSDrive -PSProvider FileSystem

$threshold = 50

Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    if ($_.Free -lt $threshold) {
        Write-Host "WARNING: Drive $($_.Name) has low free space: $($_.Free) GB" -ForegroundColor Red
    }
}


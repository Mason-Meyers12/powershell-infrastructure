Write-Host "=== System Health Check ==="

Get-PSDrive -PSProvider FileSystem

$threshold = 50

Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    if ($_.Free -lt $threshold) {
        Write-Host "WARNING: Drive $($_.Name) has low free space: $($_.Free) GB" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Memory Check ==="

$vmStat = vm_stat

$pageSize = ($vmStat | Select-String "page size of").ToString().Split(" ")[-2]
$pageSize = [int]$pageSize

$pagesFree = [int](($vmStat | Select-String "Pages free").ToString().Split(":")[1].Trim())
$pagesInactive = [int](($vmStat | Select-String "Pages inactive").ToString().Split(":")[1].Trim())
$pagesSpeculative = [int](($vmStat | Select-String "Pages speculative").ToString().Split(":")[1].Trim())

$availablePages = $pagesFree + $pagesInactive + $pagesSpeculative
$availableMemoryGB = [math]::Round(($availablePages * $pageSize) / 1GB, 2)

Write-Host "Available Memory: $availableMemoryGB GB"

if ($availableMemoryGB -lt 4) {
    Write-Host "WARNING: Low available memory!" -ForegroundColor Red
}


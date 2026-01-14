function Check-DiskSpace {
    Write-Host ""
    Write-Host "=== Disk Space Check ==="

    $threshold = 50

    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        if ($_.Free -lt $threshold) {
            Write-Host "WARNING: Drive $($_.Name) has low free space: $($_.Free) GB" -ForegroundColor Red
        }
    }
}


function Check-Memory {
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
}


function Check-CPU {
    Write-Host ""
    Write-Host "=== CPU Check ==="

    $cpuData = ps -A -o %cpu | Select-Object -Skip 1
    $cpuLoad = [math]::Round(($cpuData | Measure-Object -Average).Average, 2)

    Write-Host "Average CPU Load: $cpuLoad %"

    if ($cpuLoad -gt 80) {
        Write-Host "WARNING: High CPU usage detected!" -ForegroundColor Red
    }
}


Write-Host "=== System Health Check ==="

Check-DiskSpace
Check-Memory
Check-CPU

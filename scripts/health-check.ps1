function Check-DiskSpace {
    Write-Log ""
    Write-Log "=== Disk Space Check ==="

    $threshold = 50

    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        if ($_.Free -lt $threshold) {
            Write-Log "WARNING: Drive $($_.Name) has low free space: $($_.Free) GB"
        }
    }
}


function Check-Memory {
    Write-Log ""
    Write-Log "=== Memory Check ==="

    $vmStat = vm_stat

    $pageSize = ($vmStat | Select-String "page size of").ToString().Split(" ")[-2]
    $pageSize = [int]$pageSize

    $pagesFree = [int](($vmStat | Select-String "Pages free").ToString().Split(":")[1].Trim())
    $pagesInactive = [int](($vmStat | Select-String "Pages inactive").ToString().Split(":")[1].Trim())
    $pagesSpeculative = [int](($vmStat | Select-String "Pages speculative").ToString().Split(":")[1].Trim())

    $availablePages = $pagesFree + $pagesInactive + $pagesSpeculative
    $availableMemoryGB = [math]::Round(($availablePages * $pageSize) / 1GB, 2)

    Write-Log "Available Memory: $availableMemoryGB GB"

    if ($availableMemoryGB -lt 4) {
        Write-Log "WARNING: Low available memory!"
    }
}


function Check-CPU {
    Write-Log ""
    Write-Log "=== CPU Check ==="

    $cpuData = ps -A -o %cpu | Select-Object -Skip 1
    $cpuLoad = [math]::Round(($cpuData | Measure-Object -Average).Average, 2)

    Write-Log "Average CPU Load: $cpuLoad %"

    if ($cpuLoad -gt 80) {
        Write-Log "WARNING: High CPU usage detected!"
    }
}


function Write-Log {
    param (
        [string]$Message
    )

    # Timestamp the message
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"

    # Define project-root logs folder and log file
    $projectRoot = (Get-Location)  # assumes you run script from project root
    $logFolder = Join-Path -Path $projectRoot -ChildPath "logs"
    $logPath = Join-Path -Path $logFolder -ChildPath "health-check.log"

    # Ensure the logs folder exists
    if (-not (Test-Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
    }

    # Append message to log (creates file if it doesn't exist)
    Add-Content -Path $logPath -Value $logMessage

    # Also print to console
    Write-Host $Message
}


Write-Host "=== System Health Check ==="

Check-DiskSpace
Check-Memory
Check-CPU

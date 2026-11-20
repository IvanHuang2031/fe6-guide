# watch-and-push.ps1: 監控資料夾變更並自動同步至 GitHub
$watchPath = $PSScriptRoot
$filter = "*.*"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " 🚀 攻略自動同步監控中..." -ForegroundColor Green
Write-Host " 監控路徑: $watchPath" -ForegroundColor Gray
Write-Host " 只要存檔或有檔案變更，將自動 push 到 GitHub！" -ForegroundColor Gray
Write-Host " 按 Ctrl+C 可停止監控。" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchPath
$watcher.Filter = $filter
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$lastChange = [DateTime]::MinValue
$debounceSeconds = 5
$pendingSync = $false

$action = {
    $path = $Event.SourceEventArgs.FullPath
    if ($path -like "*\.git*") { return }
    $script:lastChange = [DateTime]::Now
    $script:pendingSync = $true
}

Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null
Register-ObjectEvent $watcher "Created" -Action $action | Out-Null
Register-ObjectEvent $watcher "Deleted" -Action $action | Out-Null
Register-ObjectEvent $watcher "Renamed" -Action $action | Out-Null

try {
    while ($true) {
        Start-Sleep -Seconds 1
        if ($script:pendingSync) {
            $elapsed = ([DateTime]::Now - $script:lastChange).TotalSeconds
            if ($elapsed -ge $debounceSeconds) {
                $script:pendingSync = $false
                Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] 偵測到檔案變動，準備自動同步..." -ForegroundColor Yellow
                & "$PSScriptRoot\sync.ps1" -CommitMessage "Auto sync changes"
            }
        }
    }
}
finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Get-EventSubscriber | Unregister-Event
    Write-Host "已停止監控。" -ForegroundColor Yellow
}

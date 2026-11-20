# sync.ps1: 同步攻略至 GitHub Pages
param (
    [string]$CommitMessage = "Update guide content"
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Set-Location $root

if (Test-Path ".\FE6_封印の剣_速查表.html") {
    Copy-Item ".\FE6_封印の剣_速查表.html" ".\index.html" -Force
}

git add .
$status = git status --porcelain
if ($status) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    git commit -m "$CommitMessage ($timestamp)"
    git push origin main
    Write-Host "✅ 攻略已成功推送到 GitHub Pages！" -ForegroundColor Green
} else {
    Write-Host "ℹ️ 沒有偵測到任何檔案變更，無需推送。" -ForegroundColor Yellow
}

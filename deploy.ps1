# ==============================
#  Hugo + PaperMod Safe Deployer
#  For GitHub Pages (gh-pages)
# ==============================

Write-Host "Starting Hugo deployment..." -ForegroundColor Cyan

# 1️ Go to project root
Set-Location $PSScriptRoot

# 2️ Make sure we're on main branch for source files
git checkout main | Out-Null

# 3️ Clean public folder safely (keep .git)
Write-Host "Cleaning public folder (preserving .git)..."
Get-ChildItem .\public -Force | Where-Object { $_.Name -ne '.git' } | Remove-Item -Recurse -Force

# 4️ Build the site
Write-Host "Running Hugo build..."
hugo --ignoreCache

# 5️ Switch to gh-pages worktree
Set-Location .\public

# 6️ Stage, commit, and push
Write-Host "Committing and pushing changes..."
git add -A
$commitMsg = "Deploy site on $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git commit -m $commitMsg
git push origin gh-pages

# 7️ Back to project root
Set-Location ..

# 8️⃣ Open the GitHub Pages site
$siteUrl = "https://antonyflores88.github.io/my-lab-blog/"
Write-Host "Opening website at $siteUrl" -ForegroundColor Cyan

Start-Process $siteUrl
Write-Host "Deployment complete!" -ForegroundColor Green
# This script adds execute permissions to shell scripts
# It works on both Windows (Git Bash) and WSL environments

# Attempt via Git Bash if available
if (Get-Command "git" -ErrorAction SilentlyContinue) {
    Write-Host "Setting execute permissions using Git..."
    git update-index --chmod=+x compile.sh
    git update-index --chmod=+x compile_all.sh
    git update-index --chmod=+x watch.sh
    
    # Commit the permission changes
    Write-Host "Committing permission changes..."
    git add compile.sh compile_all.sh watch.sh
    git commit -m "Set execute permissions on shell scripts" --no-verify
}

# For WSL users, also attempt via WSL
if (Get-Command "wsl" -ErrorAction SilentlyContinue) {
    Write-Host "Setting execute permissions using WSL..."
    wsl chmod +x compile.sh compile_all.sh watch.sh
}

Write-Host "Done. You may need to push these changes to GitHub."

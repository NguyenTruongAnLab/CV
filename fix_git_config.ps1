# Script to diagnose and fix Git global configuration issues

Write-Host "Current environment variables:" -ForegroundColor Cyan
Write-Host "HOME: $env:HOME" 
Write-Host "USERPROFILE: $env:USERPROFILE"
Write-Host "HOMEDRIVE: $env:HOMEDRIVE"
Write-Host "HOMEPATH: $env:HOMEPATH"

# Check where Git thinks the config file should be
Write-Host "`nGit config locations:" -ForegroundColor Cyan
git config --list --show-origin | Select-String "user.name" -ErrorAction SilentlyContinue

Write-Host "`nChecking existing global Git configuration:" -ForegroundColor Cyan
$globalConfig = git config --global --list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error reading global Git config: $globalConfig" -ForegroundColor Red
} else {
    Write-Host $globalConfig
}

# Fix the HOME environment variable for the current session
Write-Host "`nSetting HOME environment variable for this session:" -ForegroundColor Yellow
$env:HOME = $env:USERPROFILE
Write-Host "HOME is now set to: $env:HOME"

# Try to set global Git configuration
Write-Host "`nAttempting to set global Git configuration:" -ForegroundColor Yellow
$gitName = "Nguyen Truong An"
$gitEmail = "truongan.hcmut@gmail.com"

try {
    git config --global user.name "$gitName" 2>&1
    git config --global user.email "$gitEmail" 2>&1
    
    # Check if the config was set successfully
    $setName = git config --global user.name
    $setEmail = git config --global user.email
    
    if ($setName -eq $gitName -and $setEmail -eq $gitEmail) {
        Write-Host "Successfully set Git global configuration:" -ForegroundColor Green
        Write-Host "user.name: $setName"
        Write-Host "user.email: $setEmail"
        
        Write-Host "`nTo make this fix permanent, add the following to your PowerShell profile:" -ForegroundColor Cyan
        Write-Host '$env:HOME = $env:USERPROFILE'
        Write-Host "`nYour PowerShell profile is typically at: $PROFILE"
    } else {
        Write-Host "Failed to set global Git configuration." -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host "`nWould you like to create/update your PowerShell profile with the HOME variable fix? (y/n)" -ForegroundColor Yellow
$choice = Read-Host

if ($choice -eq "y") {
    # Ensure the directory exists
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }
    
    # Add the HOME variable fix to the profile if it doesn't already exist
    $profileContent = ""
    if (Test-Path $PROFILE) {
        $profileContent = Get-Content $PROFILE -Raw
    }
    
    if ($profileContent -notmatch '\$env:HOME\s*=\s*\$env:USERPROFILE') {
        Add-Content -Path $PROFILE -Value "`n# Fix Git HOME directory`n`$env:HOME = `$env:USERPROFILE"
        Write-Host "Added fix to PowerShell profile at: $PROFILE" -ForegroundColor Green
        Write-Host "The changes will take effect when you restart PowerShell or run: . `$PROFILE" -ForegroundColor Green
    } else {
        Write-Host "Fix already exists in PowerShell profile." -ForegroundColor Green
    }
}

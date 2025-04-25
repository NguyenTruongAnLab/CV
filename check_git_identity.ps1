# Script to check and fix Git identity issues

# Check and fix HOME environment variable if needed
if (-not $env:HOME -or $env:HOME -ne $env:USERPROFILE) {
    Write-Host "Setting HOME environment variable for this session..." -ForegroundColor Yellow
    $env:HOME = $env:USERPROFILE
    Write-Host "HOME is now set to: $env:HOME" -ForegroundColor Green
}

# Show current Git configuration
Write-Host "Current local Git identity:" -ForegroundColor Cyan
git config --local user.name
git config --local user.email

Write-Host "`nCurrent global Git identity:" -ForegroundColor Cyan
git config --global user.name
git config --global user.email

# Show commit history with author information
Write-Host "`nRecent commit authors:" -ForegroundColor Cyan
git log -5 --pretty=format:"%h %an <%ae> - %s"

Write-Host "`n"
$choice = Read-Host "Do you want to update your local Git identity? (y/n)"

if ($choice -eq "y") {
    $name = Read-Host "Enter your name (press Enter to keep current)"
    $email = Read-Host "Enter your email (press Enter to keep current)"
    
    if ($name) {
        git config --local user.name "$name"
        Write-Host "Local name updated to: $name" -ForegroundColor Green
    }
    
    if ($email) {
        git config --local user.email "$email"  
        Write-Host "Local email updated to: $email" -ForegroundColor Green
    }
}

# Option to update global Git identity
Write-Host "`nDo you want to update your global Git identity? (y/n)" -ForegroundColor Cyan
$globalChoice = Read-Host

if ($globalChoice -eq "y") {
    $globalName = Read-Host "Enter your global name (press Enter to keep current)"
    $globalEmail = Read-Host "Enter your global email (press Enter to keep current)"
    
    if ($globalName) {
        git config --global user.name "$globalName"
        Write-Host "Global name updated to: $globalName" -ForegroundColor Green
    }
    
    if ($globalEmail) {
        git config --global user.email "$globalEmail"  
        Write-Host "Global email updated to: $globalEmail" -ForegroundColor Green
    }
}

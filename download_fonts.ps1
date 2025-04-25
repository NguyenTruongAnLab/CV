# PowerShell script to download Latin Modern fonts for the CV project
Write-Host "Downloading Latin Modern fonts for your CV..." -ForegroundColor Cyan

# Create temporary directory
$tempDir = "$env:TEMP\cv-fonts"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Download Latin Modern fonts
$fontsUrl = "https://www.gust.org.pl/projects/e-foundry/latin-modern/download/lm2.004otf.zip"
$fontsZip = "$tempDir\lm-fonts.zip"

Write-Host "Downloading fonts from $fontsUrl..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $fontsUrl -OutFile $fontsZip -UseBasicParsing
}
catch {
    Write-Host "Failed to download fonts. Error: $_" -ForegroundColor Red
    exit 1
}

# Extract the fonts
Write-Host "Extracting fonts..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $fontsZip -DestinationPath "$tempDir\fonts" -Force
}
catch {
    Write-Host "Failed to extract fonts. Error: $_" -ForegroundColor Red
    exit 1
}

# Set up project fonts directory
$projectFontDir = "styles\default\fonts"
if (-not (Test-Path $projectFontDir)) {
    New-Item -ItemType Directory -Force -Path $projectFontDir | Out-Null
}

# Copy required font files to the project
Write-Host "Installing fonts to project directory..." -ForegroundColor Yellow

# Copy the specific font files we need
Copy-Item -Path "$tempDir\fonts\lm\otf\lmroman10-regular.otf" -Destination "$projectFontDir\" -Force
Copy-Item -Path "$tempDir\fonts\lm\otf\lmroman10-bold.otf" -Destination "$projectFontDir\" -Force
Copy-Item -Path "$tempDir\fonts\lm\otf\lmroman10-italic.otf" -Destination "$projectFontDir\" -Force

# Cleanup temporary files
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "Fonts installed successfully!" -ForegroundColor Green
Write-Host "Run .\run_local_windows.ps1 to generate your CV with LaTeX fonts" -ForegroundColor Cyan
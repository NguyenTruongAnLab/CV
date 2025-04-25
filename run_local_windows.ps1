#!/usr/bin/env pwsh
<#
.SYNOPSIS
Simple Windows script to generate HTML and PDF resumés from Markdown files.

.DESCRIPTION
This script converts Markdown files to HTML and PDF using Pandoc with the RStudio-bundled version.
It's designed for Windows users who want a simple way to generate their CV without complex setup.

.PARAMETER InputFile
Path to the Markdown file to convert. Defaults to "NguyenTruongAn_CV.md" if not specified.

.PARAMETER Style
Style name to use (must be a folder name in the styles directory). Defaults to "default".

.EXAMPLE
.\run_local_windows.ps1
Converts src\NguyenTruongAn_CV.md using the default style

.EXAMPLE
.\run_local_windows.ps1 -InputFile "src\my-resume.md" 
Converts src\my-resume.md using the default style

.EXAMPLE
.\run_local_windows.ps1 -InputFile "src\my-resume.md" -Style "empty"
Converts src\my-resume.md using the "empty" style
#>
param (
    [string]$InputFile = "src\NguyenTruongAn_CV.md",
    [string]$Style = "default"
)

# Define the exact path to Pandoc (from installation)
$pandocPath = "pandoc"

# If pandoc is not found at the RStudio path, try looking in the system PATH
if (-not (Test-Path $pandocPath)) {
    Write-Host "Pandoc not found. Checking system PATH..." -ForegroundColor Yellow
    $pandocInPath = Get-Command pandoc -ErrorAction SilentlyContinue
    
    if ($pandocInPath) {
        $pandocPath = $pandocInPath.Source
        Write-Host "Found Pandoc in PATH: $pandocPath" -ForegroundColor Green
    } else {
        Write-Host "Pandoc not found. Please install Pandoc or RStudio." -ForegroundColor Red
        Write-Host "Install with: choco install pandoc -y" -ForegroundColor Yellow
        exit 1
    }
}

# Check for local font files, download them if not present
$fontDir = Join-Path $PSScriptRoot "styles" $Style "fonts"
$requiredFonts = @(
    "lmroman10-regular.otf",
    "lmroman10-bold.otf", 
    "lmroman10-italic.otf"
)

$fontsPresent = $true
foreach ($font in $requiredFonts) {
    if (-not (Test-Path (Join-Path $fontDir $font))) {
        $fontsPresent = $false
        break
    }
}

if (-not $fontsPresent) {
    Write-Host "Required fonts not found. Running font download script..." -ForegroundColor Yellow
    & "$PSScriptRoot\download_fonts.ps1"
    
    # Verify fonts were downloaded
    $fontsPresent = $true
    foreach ($font in $requiredFonts) {
        if (-not (Test-Path (Join-Path $fontDir $font))) {
            $fontsPresent = $false
            Write-Host "Font $font still missing after download attempt." -ForegroundColor Red
            break
        }
    }
    
    if (-not $fontsPresent) {
        Write-Host "Unable to download required fonts. Your CV may not display with the correct typography." -ForegroundColor Yellow
    }
}

# Validate input file
if (-not (Test-Path $InputFile)) {
    Write-Error "Input file not found: $InputFile"
    exit 1
}

# Setup paths
$outputDir = Join-Path $PSScriptRoot "output"
$styleDir = Join-Path $PSScriptRoot "styles" $Style
$cssFiles = Get-ChildItem -Path $styleDir -Filter "*.css" | ForEach-Object { "-c", $_.FullName }

# Validate style
if (-not (Test-Path $styleDir)) {
    Write-Host "Style directory not found: $styleDir. Using default style." -ForegroundColor Yellow
    $Style = "default"
    $styleDir = Join-Path $PSScriptRoot "styles" $Style
    $cssFiles = Get-ChildItem -Path $styleDir -Filter "*.css" | ForEach-Object { "-c", $_.FullName }
}

# Ensure output directory exists
if (-not (Test-Path $outputDir -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "Created output directory: $outputDir" -ForegroundColor Green
}

# Get the base filename (without path and extension)
$baseFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)

Write-Host "Converting $InputFile using $Style style..." -ForegroundColor Cyan

# Generate HTML
Write-Host "Generating HTML version..."
$htmlOutPath = Join-Path $outputDir "$baseFileName.html"
& $pandocPath -s --embed-resources --standalone $cssFiles $InputFile -o $htmlOutPath
if ($LASTEXITCODE -eq 0) {
    Write-Host "HTML generated successfully: $htmlOutPath" -ForegroundColor Green
} else {
    Write-Host "HTML generation failed" -ForegroundColor Red
}

# Generate PDF with redirected error output to hide URL schema warnings
Write-Host "`nGenerating PDF version..."
$pdfOutPath = Join-Path $outputDir "$baseFileName.pdf"

# Create a temporary file for error output
$errorLogFile = Join-Path $env:TEMP "cv_pdf_errors.log"

# Run pandoc with error output redirected
$processInfo = New-Object System.Diagnostics.ProcessStartInfo
$processInfo.FileName = $pandocPath
$processInfo.Arguments = "-s --embed-resources --standalone --resource-path=`"$PSScriptRoot;$styleDir`" " + 
                        ($cssFiles -join " ") + " `"$InputFile`" -o `"$pdfOutPath`" " +
                        "--pdf-engine=wkhtmltopdf --pdf-engine-opt=--enable-local-file-access"
$processInfo.RedirectStandardError = $true
$processInfo.UseShellExecute = $false
$processInfo.CreateNoWindow = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $processInfo
$process.Start() | Out-Null
$stderr = $process.StandardError.ReadToEnd()
$process.WaitForExit()

# Only show errors that aren't the URL schema warnings
$filteredErrors = $stderr -split "`n" | Where-Object { $_ -notmatch "URL has no schema set, use file:// for files" }
if ($filteredErrors) {
    $filteredErrors | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
}

if ($process.ExitCode -eq 0) {
    Write-Host "PDF generated successfully: $pdfOutPath" -ForegroundColor Green
} else {
    Write-Host "PDF generation failed" -ForegroundColor Red
    # Show all errors if the process failed
    $stderr -split "`n" | ForEach-Object { Write-Host $_ -ForegroundColor Red }
}

# Open the output directory
Write-Host "`nOpening output directory..."
Start-Process $outputDir
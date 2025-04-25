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

# Define the exact path to Pandoc (from RStudio installation)
$pandocPath = "pandoc"

# If pandoc is not found at the RStudio path, try looking in the system PATH
if (-not (Test-Path $pandocPath)) {
    Write-Host "RStudio Pandoc not found. Checking system PATH..." -ForegroundColor Yellow
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

# Validate input file
if (-not (Test-Path $InputFile)) {
    Write-Error "Input file not found: $InputFile"
    exit 1
}

# Setup paths
$outputDir = Join-Path $PSScriptRoot "output"
$styleDir = Join-Path $PSScriptRoot "styles" $Style
$cssFile = Join-Path $styleDir "main.css"

# Validate style
if (-not (Test-Path $styleDir)) {
    Write-Host "Style directory not found: $styleDir. Using default style." -ForegroundColor Yellow
    $Style = "default"
    $styleDir = Join-Path $PSScriptRoot "styles" $Style
    $cssFile = Join-Path $styleDir "main.css"
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
& $pandocPath -s --embed-resources --standalone -c $cssFile $InputFile -o $htmlOutPath
if ($LASTEXITCODE -eq 0) {
    Write-Host "HTML generated successfully: $htmlOutPath" -ForegroundColor Green
} else {
    Write-Host "HTML generation failed" -ForegroundColor Red
}

# Generate PDF
Write-Host "`nGenerating PDF version..."
$pdfOutPath = Join-Path $outputDir "$baseFileName.pdf"
& $pandocPath -s --embed-resources --standalone -c $cssFile $InputFile -o $pdfOutPath --pdf-engine=wkhtmltopdf --pdf-engine-opt=--enable-local-file-access
if ($LASTEXITCODE -eq 0) {
    Write-Host "PDF generated successfully: $pdfOutPath" -ForegroundColor Green
} else {
    Write-Host "PDF generation failed" -ForegroundColor Red
}

# Open the output directory
Write-Host "`nOpening output directory..."
Start-Process $outputDir
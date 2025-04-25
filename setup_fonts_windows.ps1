# PowerShell script to setup font rendering for Windows
# Run this as Administrator

# Create temporary directory
$tempDir = "$env:TEMP\latex-fonts"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Download Latin Modern fonts
$fontsUrl = "https://www.gust.org.pl/projects/e-foundry/latin-modern/download/lm2.004otf.zip"
$fontsZip = "$tempDir\lm-fonts.zip"
Invoke-WebRequest -Uri $fontsUrl -OutFile $fontsZip

# Extract the fonts
Expand-Archive -Path $fontsZip -DestinationPath "$tempDir\fonts" -Force

# Create fonts directory if it doesn't exist
$fontsDir = "$env:SYSTEMROOT\Fonts"

# Copy fonts to the system fonts directory
Get-ChildItem -Path "$tempDir\fonts" -Filter "*.otf" -Recurse | ForEach-Object {
    $fontPath = $_.FullName
    $fontName = $_.Name
    
    Write-Host "Installing font: $fontName"
    
    # Copy the font to the fonts directory
    Copy-Item -Path $fontPath -Destination "$fontsDir\$fontName" -Force
    
    # Register the font in the registry
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $fontName -Value $fontName -PropertyType String -Force
}

Write-Host "Fonts installed successfully. You may need to restart your applications to use the new fonts."

# Cleanup temporary files
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "To run pandoc with the new fonts on Windows, use the following command:"
Write-Host "pandoc -s --self-contained -t html -c styles/default/fonts.css -c styles/default/main.css src/NguyenTruongAn_CV.md -o output/NguyenTruongAn_CV.pdf --pdf-engine=wkhtmltopdf --pdf-engine-opt=--enable-local-file-access"
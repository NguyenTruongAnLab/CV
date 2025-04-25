# Markdown Resume

Hello, this repo stores the academic CV of Nguyen Truong An which build from markdown file and create the PDF and HTML file as a website. You are welcome to adapt to your CV.

## Getting Started

### Quick Start - Windows

1. Make sure you have either:
   * Pandoc and wkhtmltopdf installed (via Chocolatey: `choco install pandoc wkhtmltopdf -y`)
   * **OR** RStudio installed (comes with Pandoc)

2. Run the PowerShell script to generate your CV:
   ```powershell
   # Generate NguyenTruongAn_CV CV
   .\run_local_windows.ps1

   # Generate a specific CV file
   .\run_local_windows.ps1 -InputFile "src\my-resume.md" -Style "default"
   ```

3. Your HTML and PDF files will be created in the `output` directory, which will open automatically.

### Quick Start - Linux/macOS

1. Install the required dependencies:
   ```bash
   # Ubuntu/Debian
   sudo apt update && sudo apt install pandoc wkhtmltopdf make

   # macOS with Homebrew
   brew install pandoc wkhtmltopdf make
   ```

2. Make sure shell scripts have execute permissions:
   ```bash
   chmod +x compile.sh compile_all.sh watch.sh
   ```

3. Run the build script:
   ```bash
   # Build all Markdown files in src/
   ./compile_all.sh
   
   # Or for a specific file
   ./compile.sh src/my-resume.md pdf
   ./compile.sh src/my-resume.md html
   ```

4. Find the output in the `output/` folder.

### Creating Your CV

1. Place your Markdown CV in the `src/` folder, or modify the example:
   ```markdown
   ---
   title: Your Name - CV
   style: default  # or any other style folder name in styles/
   margin-left: 1.5cm
   margin-right: 1.8cm
   margin-top: 2cm
   margin-bottom: 1.5cm
   papersize: a4
   ---

   ## Contact

   Your Name, PhD
   email@example.com
   
   ## Education
   
   ### PhD in Something
   University Name
   ```

2. For publication lists, use standard Markdown ordered list syntax with `1.` for all items to enable automatic numbering:
   ```markdown
   ## Publications

   1. Most recent publication (2025)
   1. Next most recent publication (2024)
   1. Older publication (2023)
   ```

## Customization

### Styles

To customize the appearance of your resume:

1. Create a new folder in the `styles/` directory
2. Add CSS files to the folder
3. Reference the style in your Markdown front matter with `style: your-style-name`

## Advanced Usage

### Docker

Build without installing dependencies (works on any platform with Docker):

```bash
# Build the Docker image
docker build -t markdown-resume .

# Generate PDFs and HTMLs
docker run -it --rm -v "${PWD}/src:/mdr/src" -v "${PWD}/output:/mdr/output" markdown-resume
```

### GitHub Actions and Automatic Releases

This repository includes a GitHub Actions workflow that:

1. **Automatically builds your CV** on every push to the main/master branch
2. **Creates a date-based release** (format: DD-Month-YYYY) with each push
3. **Attaches PDF and HTML files** to each release for easy download
4. **Deploys HTML to GitHub Pages** for web viewing

#### Accessing Your CV

After pushing changes to your repository:

1. **Download PDF/HTML files:**
   - Go to the "Releases" section in your repository
   - Find the latest release (named with the current date)
   - Download the attached PDF and HTML files

2. **View Online:**
   - Your CV is automatically published to GitHub Pages
   - Access it at: `https://[your-username].github.io/[repo-name]/CV.html`

#### Manual Release Creation

If needed, you can manually trigger a release:
1. Go to the "Actions" tab in your repository
2. Click on the "Build and Test" workflow
3. Click "Run workflow"
4. Optionally provide a custom release date
5. Click "Run workflow"

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.



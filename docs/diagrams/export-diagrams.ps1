# PowerShell Script to Export Mermaid Diagrams
# Run this script to automatically export all diagrams to multiple formats

Write-Host "🎨 Sustaina Health Diagram Export Tool" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check if mermaid-cli is installed
$mermaidInstalled = Get-Command mmdc -ErrorAction SilentlyContinue
if (-not $mermaidInstalled) {
    Write-Host "❌ Mermaid CLI not found. Installing..." -ForegroundColor Red
    Write-Host "Please run: npm install -g @mermaid-js/mermaid-cli" -ForegroundColor Yellow
    Write-Host "Then run this script again." -ForegroundColor Yellow
    exit 1
}

# Create exports directory
$exportDir = "docs\diagrams\exports"
if (-not (Test-Path $exportDir)) {
    New-Item -ItemType Directory -Path $exportDir -Force
    Write-Host "📁 Created exports directory: $exportDir" -ForegroundColor Blue
}

# Define diagram files and their descriptions
$diagrams = @{
    "feature_architecture.mmd" = "🏗️ Feature Architecture Overview"
    "data_flow_architecture.mmd" = "🔄 Data Flow & Service Architecture" 
    "mcp_integration_flow.mmd" = "💬 MCP Chat Integration Flow"
    "hybrid_storage.mmd" = "💾 Hybrid Storage Strategy"
    "tech_stack.mmd" = "🔧 Technology Stack Overview"
}

Write-Host "🚀 Starting diagram export process..." -ForegroundColor Cyan

foreach ($diagram in $diagrams.Keys) {
    $description = $diagrams[$diagram]
    $inputFile = "docs\diagrams\$diagram"
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($diagram)
    
    if (Test-Path $inputFile) {
        Write-Host "📊 Processing: $description" -ForegroundColor Yellow
        
        # Export to PNG (High resolution for presentations)
        $pngOutput = "$exportDir\$baseName.png"
        try {
            & mmdc -i $inputFile -o $pngOutput --width 1920 --height 1080 --backgroundColor white
            Write-Host "  ✅ PNG exported: $pngOutput" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ PNG export failed: $_" -ForegroundColor Red
        }
        
        # Export to SVG (Scalable for web)
        $svgOutput = "$exportDir\$baseName.svg"
        try {
            & mmdc -i $inputFile -o $svgOutput --backgroundColor white
            Write-Host "  ✅ SVG exported: $svgOutput" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ SVG export failed: $_" -ForegroundColor Red
        }
        
        # Export to PDF (Print ready)
        $pdfOutput = "$exportDir\$baseName.pdf"
        try {
            & mmdc -i $inputFile -o $pdfOutput --width 1920 --height 1080
            Write-Host "  ✅ PDF exported: $pdfOutput" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ PDF export failed: $_" -ForegroundColor Red
        }
        
        Write-Host ""
    } else {
        Write-Host "⚠️  File not found: $inputFile" -ForegroundColor Yellow
    }
}

Write-Host "🎉 Export process completed!" -ForegroundColor Green
Write-Host "📁 Check the exports folder: $exportDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔗 Next Steps:" -ForegroundColor Blue
Write-Host "  1. Use PNG files for PowerPoint presentations" -ForegroundColor White
Write-Host "  2. Use SVG files for web documentation" -ForegroundColor White  
Write-Host "  3. Use PDF files for print materials" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tip: Open mermaid.live and copy-paste .mmd content for online editing" -ForegroundColor Magenta

# Open the exports folder
if (Get-Command explorer -ErrorAction SilentlyContinue) {
    $choice = Read-Host "Open exports folder now? (y/n)"
    if ($choice -eq "y" -or $choice -eq "Y") {
        explorer $exportDir
    }
}

# Quick Setup Script for Diagram Tools
# This script helps you set up the tools needed for professional diagram creation

Write-Host "🛠️  Sustaina Health Diagram Tools Setup" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Check if Node.js is installed
$nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
if ($nodeInstalled) {
    $nodeVersion = node --version
    Write-Host "✅ Node.js installed: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Node.js not found" -ForegroundColor Red
    Write-Host "📥 Download from: https://nodejs.org" -ForegroundColor Yellow
    Write-Host "   Install Node.js first, then run this script again." -ForegroundColor White
    $openNodeJS = Read-Host "Open Node.js download page? (y/n)"
    if ($openNodeJS -eq "y" -or $openNodeJS -eq "Y") {
        Start-Process "https://nodejs.org"
    }
    exit 1
}

# Check if npm is available
$npmInstalled = Get-Command npm -ErrorAction SilentlyContinue
if ($npmInstalled) {
    $npmVersion = npm --version
    Write-Host "✅ NPM installed: $npmVersion" -ForegroundColor Green
} else {
    Write-Host "❌ NPM not found (comes with Node.js)" -ForegroundColor Red
    exit 1
}

# Install Mermaid CLI
Write-Host ""
Write-Host "🔧 Installing Mermaid CLI..." -ForegroundColor Cyan
try {
    npm install -g @mermaid-js/mermaid-cli
    Write-Host "✅ Mermaid CLI installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install Mermaid CLI: $_" -ForegroundColor Red
    Write-Host "💡 Try running PowerShell as Administrator" -ForegroundColor Yellow
}

# Verify installation
$mermaidInstalled = Get-Command mmdc -ErrorAction SilentlyContinue
if ($mermaidInstalled) {
    Write-Host "✅ Mermaid CLI ready to use!" -ForegroundColor Green
} else {
    Write-Host "❌ Mermaid CLI installation verification failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "🌐 Recommended Online Tools:" -ForegroundColor Blue
Write-Host "  • Mermaid Live Editor: https://mermaid.live" -ForegroundColor White
Write-Host "  • Draw.io: https://app.diagrams.net" -ForegroundColor White
Write-Host "  • Lucidchart: https://lucidchart.com" -ForegroundColor White

Write-Host ""
Write-Host "📊 Available Diagram Files:" -ForegroundColor Magenta
$diagramFiles = Get-ChildItem "docs\diagrams\*.mmd" -ErrorAction SilentlyContinue
if ($diagramFiles) {
    foreach ($file in $diagramFiles) {
        Write-Host "  • $($file.Name)" -ForegroundColor White
    }
} else {
    Write-Host "  No .mmd files found in docs\diagrams\" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Green
Write-Host "  1. Run .\export-diagrams.ps1 to export all diagrams" -ForegroundColor White
Write-Host "  2. Or copy .mmd content to mermaid.live for online editing" -ForegroundColor White
Write-Host "  3. Use exports for presentations and documentation" -ForegroundColor White

$choice = Read-Host "Run diagram export now? (y/n)"
if ($choice -eq "y" -or $choice -eq "Y") {
    if (Test-Path ".\export-diagrams.ps1") {
        & .\export-diagrams.ps1
    } else {
        Write-Host "❌ export-diagrams.ps1 not found in current directory" -ForegroundColor Red
    }
}

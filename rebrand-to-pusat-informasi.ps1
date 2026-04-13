# REBRAND SCRIPT: Arah Berita to Pusat Informasi
# Comprehensive branding, color, and metadata update

$ErrorActionPreference = "Stop"

# Define replacements - order matters, process from most specific to most general
$replacements = @(
    @{ "twitter.com/arahberita" = "twitter.com/pusatinformasi" }
    @{ "facebook.com/arahberita" = "facebook.com/pusatinformasi" }
    @{ "instagram.com/arahberita" = "instagram.com/pusatinformasi" }
    @{ "youtube.com/@arahberita" = "youtube.com/@pusatinformasi" }
    @{ "linkedin.com/company/arahberita" = "linkedin.com/company/pusatinformasi" }
    @{ "arahberita@gmail.com" = "pusatinformasi@gmail.com" }
    @{ "info@arahberita.com" = "info@pusatinformasi.com" }
    @{ "#1D4ED8" = "#F59E0B" }
    @{ "#7F2F4F" = "#5F1F7F" }
    @{ "#1E3A8A" = "#78350F" }
    @{ "ArahBerita" = "PusatInformasi" }
    @{ "Arah Berita" = "Pusat Informasi" }
    @{ "arahberita" = "pusatinformasi" }
    @{ "ARAH" = "PUSAT" }
)

# Setup paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir
$backupDir = Join-Path $scriptDir "rebrand-backups"

if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

# Backup articles.json
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$articlesPath = Join-Path $scriptDir "articles.json"
if (Test-Path $articlesPath) {
    Copy-Item $articlesPath "$backupDir\articles.json.bak.$timestamp" -Force
    Write-Host "[BACKUP] articles.json saved"
}

$stats = @{
    htmlFiles    = 0
    cssFiles     = 0
    jsonFiles    = 0
    docFiles     = 0
    jsFiles      = 0
}

Write-Host ""
Write-Host "=========================================="
Write-Host "REBRAND: ARAH BERITA -> PUSAT INFORMASI"
Write-Host "=========================================="
Write-Host ""

# Helper function to replace text
function ReplaceInFile {
    param(
        [string]$filePath,
        $replacements
    )
    
    if (-not (Test-Path $filePath)) { return $false }
    
    $content = Get-Content -Path $filePath -Encoding UTF8 -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $false }
    
    $original = $content
    
    # Handle both array and hashtable formats
    if ($replacements -is [array]) {
        foreach ($map in $replacements) {
            foreach ($old in $map.Keys) {
                $new = $map[$old]
                $content = $content -replace [regex]::Escape($old), $new
            }
        }
    } else {
        foreach ($old in $replacements.Keys) {
            $new = $replacements[$old]
            $content = $content -replace [regex]::Escape($old), $new
        }
    }
    
    if ($content -ne $original) {
        Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
        return $true
    }
    return $false
}

# Phase 1: Update main HTML files
Write-Host "[PHASE 1] Main HTML Pages..."
$htmlFiles = Get-ChildItem -Filter "*.html" -ErrorAction SilentlyContinue | Where-Object { -not ($_.Name -like "*.bak*") }
foreach ($file in $htmlFiles) {
    if (ReplaceInFile $file.FullName $replacements) {
        $stats.htmlFiles++
        Write-Host "  [OK] $($file.Name)"
    }
}

# Phase 2: Update article HTML files
Write-Host "[PHASE 2] Article Pages..."
$articleDir = Join-Path $scriptDir "article"
if (Test-Path $articleDir) {
    $articles = @(Get-ChildItem $articleDir -Filter "*.html" -ErrorAction SilentlyContinue)
    $articleCount = $articles.Count
    foreach ($article in $articles) {
        if (ReplaceInFile $article.FullName $replacements) {
            $stats.htmlFiles++
        }
    }
    Write-Host "  [OK] Updated $articleCount article files"
}

# Phase 3: Update CSS files
Write-Host "[PHASE 3] CSS Files..."
$cssDir = Join-Path $scriptDir "css"
if (Test-Path $cssDir) {
    $cssFiles = @(Get-ChildItem $cssDir -Filter "*.css" -ErrorAction SilentlyContinue)
    foreach ($css in $cssFiles) {
        if (ReplaceInFile $css.FullName $replacements) {
            $stats.cssFiles++
            Write-Host "  [OK] $($css.Name)"
        }
    }
}

# Phase 4: Update package.json files
Write-Host "[PHASE 4] Package JSON Files..."
$pkgFiles = @("package.json", "tools\package.json")
foreach ($pkg in $pkgFiles) {
    if (ReplaceInFile $pkg $replacements) {
        $stats.jsonFiles++
        Write-Host "  [OK] $pkg"
    }
}

# Phase 5: Update documentation files
Write-Host "[PHASE 5] Documentation Files..."
$docFiles = @("AUTOMATION_README.md", "GOOGLE_DRIVE_GUIDE.md", "GOOGLE_DRIVE_IMAGES_GUIDE.md", "netlify.toml", "PERBAIKAN_STATUS.md")
foreach ($doc in $docFiles) {
    if (ReplaceInFile $doc $replacements) {
        $stats.docFiles++
        Write-Host "  [OK] $doc"
    }
}

# Phase 5B: Update tools files
Write-Host "[PHASE 5B] Tools Files..."
$toolsDir = Join-Path $scriptDir "tools"
if (Test-Path $toolsDir) {
    $toolsFiles = @(Get-ChildItem $toolsDir -Include "*.json", "*.html" -ErrorAction SilentlyContinue)
    foreach ($toolFile in $toolsFiles) {
        if (ReplaceInFile $toolFile.FullName $replacements) {
            $stats.jsFiles++
            Write-Host "  [OK] $($toolFile.Name)"
        }
    }
}

# Phase 6: Update JavaScript files
Write-Host "[PHASE 6] JavaScript Files..."
$jsFiles = @(Get-ChildItem -Recurse -Filter "*.js" -ErrorAction SilentlyContinue | 
    Where-Object { -not ($_.FullName -like "*node_modules*") })
foreach ($js in $jsFiles) {
    if (ReplaceInFile $js.FullName $replacements) {
        $stats.jsFiles++
    }
}

# Phase 7: Verify
Write-Host "[PHASE 7] Verification..."
$patterns = @("arahberita", "Arah Berita")
$foundOld = 0
foreach ($pattern in $patterns) {
    $matches = @(Get-ChildItem -Recurse -Include "*.html", "*.css", "*.js", "*.json" -ErrorAction SilentlyContinue |
        Select-String -Pattern $pattern -ErrorAction SilentlyContinue |
        Where-Object { -not ($_.Path -like "*node_modules*") -and -not ($_.Path -like "*.bak*") })
    
    if ($matches.Count -gt 0) {
        $foundOld += $matches.Count
        Write-Host "  [WARN] Found '$pattern' in $($matches.Count) location(s)"
    }
}

if ($foundOld -eq 0) {
    Write-Host "  [OK] No old branding strings found"
}

# Generate final report
Write-Host ""
Write-Host "=========================================="
Write-Host "REBRAND COMPLETE REPORT"
Write-Host "=========================================="
Write-Host ""
Write-Host "Files Updated:"
Write-Host "  - Main HTML Pages: $($stats.htmlFiles)"
Write-Host "  - CSS Files: $($stats.cssFiles)"
Write-Host "  - Package Files: $($stats.jsonFiles)"
Write-Host "  - Documentation: $($stats.docFiles)"
Write-Host "  - JavaScript: $($stats.jsFiles)"
Write-Host ""
Write-Host "Color Changes:"
Write-Host "  - Primary: #1D4ED8 -> #F59E0B"
Write-Host "  - Dark: #1E3A8A -> #78350F"
Write-Host "  - Secondary: #7F2F4F -> #5F1F7F"
Write-Host ""
Write-Host "Branding Changes:"
Write-Host "  [OK] Brand: Arah Berita -> Pusat Informasi"
Write-Host "  [OK] Email: arahberita@gmail.com -> pusatinformasi@gmail.com"
Write-Host "  [OK] Social: arahberita -> pusatinformasi"
Write-Host "  [OK] Package names updated"
Write-Host ""

if ($foundOld -eq 0) {
    Write-Host "Rebrand Pusat Informasi selesai [OK]"
} else {
    Write-Host "Rebrand selesai dengan $foundOld old strings masih ditemukan"
}

Write-Host ""
Write-Host "Backup location: $backupDir"
Write-Host "=========================================="
Write-Host ""

# Create summary log
$logFile = "rebrand-pusat-informasi-$timestamp.log"
$content = @"
REBRAND LOG: Arah Berita -> Pusat Informasi
Date: $(Get-Date)

FILES UPDATED:
- HTML: $($stats.htmlFiles)
- CSS: $($stats.cssFiles)
- JSON: $($stats.jsonFiles)
- Docs: $($stats.docFiles)
- JS: $($stats.jsFiles)

COLORS:
- Primary: #1D4ED8 -> #F59E0B
- Dark: #1E3A8A -> #78350F
- Secondary: #7F2F4F -> #5F1F7F

BACKUP: $backupDir
"@

Set-Content -Path $logFile -Value $content -Encoding UTF8
Write-Host "Log saved: $logFile"

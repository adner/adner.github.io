<#
.SYNOPSIS
    Optimizes blog images using ImageMagick for a specific date folder.

.DESCRIPTION
    Processes all images in a date-based folder within /images/, resizing to max
    width 800px and optimizing for web. Replaces original files.

    Supports PNG, WebP, and GIF formats with format-specific optimization:
    - PNG: Strip metadata, progressive encoding, compression level 9
    - WebP: Re-encode at quality 85%, strip metadata
    - GIF: Layer optimization (preserves animations)

.PARAMETER DateFolder
    The date folder to process (e.g., "251226" for /images/251226/)

.PARAMETER MaxWidth
    Maximum width in pixels (default: 800)

.PARAMETER Quality
    Image quality percentage for lossy formats (default: 85)

.PARAMETER DryRun
    Preview changes without modifying files

.PARAMETER CreateBackup
    Create a timestamped backup folder before processing

.EXAMPLE
    .\Optimize-BlogImages.ps1 -DateFolder 251226
    Optimizes all images in /images/251226/

.EXAMPLE
    .\Optimize-BlogImages.ps1 -DateFolder 251226 -DryRun
    Preview what would be optimized without making changes

.EXAMPLE
    .\Optimize-BlogImages.ps1 -DateFolder 251226 -MaxWidth 1200 -Quality 90
    Use custom width and quality settings

.EXAMPLE
    .\Optimize-BlogImages.ps1 -DateFolder 251226 -CreateBackup
    Create a backup before optimizing
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true, HelpMessage="Date folder to process (e.g., 251226)")]
    [string]$DateFolder,

    [Parameter(Mandatory=$false)]
    [ValidateRange(100, 3000)]
    [int]$MaxWidth = 800,

    [Parameter(Mandatory=$false)]
    [ValidateRange(1, 100)]
    [int]$Quality = 85,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$CreateBackup
)

# Helper function to format file sizes
function Format-FileSize {
    param([long]$Bytes)

    if ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    } elseif ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    } elseif ($Bytes -ge 1KB) {
        return "{0:N2} KB" -f ($Bytes / 1KB)
    } else {
        return "$Bytes bytes"
    }
}

# Print header
Write-Host ""
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  Blog Image Optimization Script" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Check if ImageMagick is installed
Write-Host "Checking prerequisites..." -ForegroundColor Cyan
try {
    $magickVersion = & magick -version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "ImageMagick not found"
    }
    $versionLine = ($magickVersion | Select-Object -First 1) -replace 'Version: ImageMagick ', ''
    Write-Host "  ✓ Found ImageMagick $versionLine" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "ERROR: ImageMagick is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install ImageMagick from:" -ForegroundColor Yellow
    Write-Host "  https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "During installation, make sure to check:" -ForegroundColor Yellow
    Write-Host "  'Add application directory to your system path'" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Validate folder exists
$scriptRoot = Split-Path -Parent $PSScriptRoot
$imagesRoot = Join-Path $scriptRoot "images"
$targetFolder = Join-Path $imagesRoot $DateFolder

if (-not (Test-Path $targetFolder)) {
    Write-Host ""
    Write-Host "ERROR: Folder not found: $targetFolder" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available date folders:" -ForegroundColor Yellow
    Get-ChildItem -Path $imagesRoot -Directory | Where-Object { $_.Name -match '^\d{6}$' } | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Gray
    }
    Write-Host ""
    exit 1
}

Write-Host "  ✓ Target folder: $targetFolder" -ForegroundColor Green
Write-Host ""

# Scan for image files
Write-Host "Scanning for images..." -ForegroundColor Cyan
$imageFiles = @{
    PNG = @(Get-ChildItem -Path $targetFolder -Filter "*.png" -File)
    WebP = @(Get-ChildItem -Path $targetFolder -Filter "*.webp" -File)
    GIF = @(Get-ChildItem -Path $targetFolder -Filter "*.gif" -File)
}

$totalFiles = ($imageFiles.PNG.Count + $imageFiles.WebP.Count + $imageFiles.GIF.Count)

if ($totalFiles -eq 0) {
    Write-Host "  No image files found in $targetFolder" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host "  Found $totalFiles image(s):" -ForegroundColor White
if ($imageFiles.PNG.Count -gt 0) {
    Write-Host "    PNG:  $($imageFiles.PNG.Count)" -ForegroundColor Gray
}
if ($imageFiles.WebP.Count -gt 0) {
    Write-Host "    WebP: $($imageFiles.WebP.Count)" -ForegroundColor Gray
}
if ($imageFiles.GIF.Count -gt 0) {
    Write-Host "    GIF:  $($imageFiles.GIF.Count)" -ForegroundColor Gray
}
Write-Host ""

# Show settings
Write-Host "Optimization settings:" -ForegroundColor Cyan
Write-Host "  Max width: ${MaxWidth}px" -ForegroundColor White
Write-Host "  Quality: ${Quality}%" -ForegroundColor White
if ($DryRun) {
    Write-Host "  Mode: DRY RUN (no changes will be made)" -ForegroundColor Yellow
} else {
    Write-Host "  Mode: LIVE (files will be modified)" -ForegroundColor White
}
Write-Host ""

# Create backup if requested
if ($CreateBackup -and -not $DryRun) {
    $backupFolder = Join-Path $targetFolder "_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "Creating backup..." -ForegroundColor Cyan
    try {
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        Get-ChildItem -Path $targetFolder -Include "*.png","*.webp","*.gif" -File | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $backupFolder
        }
        Write-Host "  ✓ Backup created: $backupFolder" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "  ERROR: Failed to create backup: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to optimize a single image file
function Optimize-ImageFile {
    param(
        [System.IO.FileInfo]$File,
        [string]$Format,
        [int]$MaxWidth,
        [int]$Quality,
        [bool]$IsDryRun
    )

    $sizeBefore = $File.Length

    if ($IsDryRun) {
        # In dry run mode, just show what would be done
        $sizeStr = Format-FileSize $sizeBefore
        Write-Host "    [DRY RUN] $($File.Name) ($sizeStr)" -ForegroundColor Yellow
        return @{
            Success = $true
            Before = $sizeBefore
            After = $sizeBefore
            Saved = 0
        }
    }

    # Build ImageMagick command based on format
    $resizeArg = "${MaxWidth}x${MaxWidth}>"

    switch ($Format) {
        "PNG" {
            # PNG: Strip metadata, progressive encoding, max compression
            $args = @(
                "mogrify"
                "-resize"
                $resizeArg
                "-strip"
                "-interlace"
                "Plane"
                "-quality"
                $Quality
                "-define"
                "png:compression-level=9"
                "`"$($File.FullName)`""
            )
        }
        "WebP" {
            # WebP: Re-encode with quality setting, strip metadata
            $args = @(
                "mogrify"
                "-resize"
                $resizeArg
                "-strip"
                "-quality"
                $Quality
                "`"$($File.FullName)`""
            )
        }
        "GIF" {
            # GIF: Optimize layers (preserves animations)
            $args = @(
                "mogrify"
                "-resize"
                $resizeArg
                "-layers"
                "optimize"
                "`"$($File.FullName)`""
            )
        }
    }

    # Execute ImageMagick
    try {
        $cmd = "magick $($args -join ' ')"
        Invoke-Expression $cmd 2>&1 | Out-Null

        if ($LASTEXITCODE -ne 0) {
            throw "ImageMagick returned error code $LASTEXITCODE"
        }

        # Get new file size
        $File.Refresh()
        $sizeAfter = $File.Length
        $saved = $sizeBefore - $sizeAfter

        # Calculate percentage saved
        if ($sizeBefore -gt 0) {
            $savedPercent = [math]::Round(($saved / $sizeBefore) * 100, 1)
        } else {
            $savedPercent = 0
        }

        # Format output
        $beforeStr = Format-FileSize $sizeBefore
        $afterStr = Format-FileSize $sizeAfter

        if ($saved -gt 0) {
            Write-Host "    ✓ $($File.Name): $beforeStr → $afterStr (saved $savedPercent%)" -ForegroundColor Green
        } elseif ($saved -lt 0) {
            Write-Host "    ✓ $($File.Name): $beforeStr → $afterStr (increased)" -ForegroundColor Yellow
        } else {
            Write-Host "    ✓ $($File.Name): $beforeStr (no change)" -ForegroundColor Gray
        }

        return @{
            Success = $true
            Before = $sizeBefore
            After = $sizeAfter
            Saved = $saved
        }

    } catch {
        Write-Host "    ✗ $($File.Name): Failed - $_" -ForegroundColor Red
        return @{
            Success = $false
            Before = $sizeBefore
            After = $sizeBefore
            Saved = 0
        }
    }
}

# Track totals
$totalSizeBefore = 0
$totalSizeAfter = 0
$totalSaved = 0
$successCount = 0
$failCount = 0

# Process each format
foreach ($format in @('PNG', 'WebP', 'GIF')) {
    if ($imageFiles[$format].Count -gt 0) {
        Write-Host "Processing $($imageFiles[$format].Count) $format file(s)..." -ForegroundColor Cyan

        foreach ($file in $imageFiles[$format]) {
            $result = Optimize-ImageFile -File $file -Format $format -MaxWidth $MaxWidth -Quality $Quality -IsDryRun:$DryRun

            $totalSizeBefore += $result.Before
            $totalSizeAfter += $result.After
            $totalSaved += $result.Saved

            if ($result.Success) {
                $successCount++
            } else {
                $failCount++
            }
        }

        Write-Host ""
    }
}

# Final summary
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "  Mode: DRY RUN - No files were modified" -ForegroundColor Yellow
} else {
    Write-Host "  Files processed: $successCount" -ForegroundColor White
    if ($failCount -gt 0) {
        Write-Host "  Files failed: $failCount" -ForegroundColor Red
    }
}

Write-Host "  Total size before: $(Format-FileSize $totalSizeBefore)" -ForegroundColor White

if (-not $DryRun) {
    Write-Host "  Total size after: $(Format-FileSize $totalSizeAfter)" -ForegroundColor White

    if ($totalSaved -gt 0) {
        $totalSavedPercent = [math]::Round(($totalSaved / $totalSizeBefore) * 100, 1)
        Write-Host "  Total saved: $(Format-FileSize $totalSaved) ($totalSavedPercent%)" -ForegroundColor Green
    } elseif ($totalSaved -lt 0) {
        $totalIncreasedPercent = [math]::Round(((-$totalSaved) / $totalSizeBefore) * 100, 1)
        Write-Host "  Total change: Increased by $(Format-FileSize (-$totalSaved)) ($totalIncreasedPercent%)" -ForegroundColor Yellow
    } else {
        Write-Host "  Total saved: No change" -ForegroundColor Gray
    }
}

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Exit with appropriate code
if ($failCount -gt 0) {
    exit 1
} else {
    exit 0
}

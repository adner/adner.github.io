# Blog Image Optimization Scripts

PowerShell scripts to optimize images in date-based folders using ImageMagick.

## Prerequisites

### Install ImageMagick on Windows

1. **Download ImageMagick:**
   - Visit: https://imagemagick.org/script/download.php#windows
   - Download the latest Windows installer (e.g., `ImageMagick-7.1.x-x-Q16-HDRI-x64-dll.exe`)

2. **Run the installer:**
   - During installation, **check these options:**
     - ✅ "Add application directory to your system path"
     - ✅ "Install legacy utilities (e.g., convert)" (optional)

3. **Verify installation:**
   - Restart PowerShell after installation
   - Run: `magick -version`
   - You should see version information displayed

### Set PowerShell Execution Policy (if needed)

If you get an error about script execution being disabled:

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Script: Optimize-BlogImages.ps1

Optimizes all images in a specific date folder (e.g., `/images/251226/`).

### Features

- **Resize**: Resizes images to max width 800px (maintains aspect ratio)
- **Format-specific optimization:**
  - **PNG**: Strips metadata, progressive encoding, compression level 9
  - **WebP**: Re-encodes at quality 85%, strips metadata
  - **GIF**: Layer optimization (preserves animations)
- **Safety**: Dry-run mode to preview changes before modifying files
- **Backup**: Optional backup creation before processing
- **Reporting**: Shows before/after file sizes and total space saved

### Basic Usage

Navigate to the scripts folder:

```powershell
cd scripts
```

**Process a date folder:**

```powershell
.\Optimize-BlogImages.ps1 -DateFolder 251226
```

**Preview changes (dry run):**

```powershell
.\Optimize-BlogImages.ps1 -DateFolder 251226 -DryRun
```

### Advanced Usage

**Custom width and quality:**

```powershell
# Use 1200px max width and 90% quality
.\Optimize-BlogImages.ps1 -DateFolder 251226 -MaxWidth 1200 -Quality 90
```

**Create backup before optimizing:**

```powershell
.\Optimize-BlogImages.ps1 -DateFolder 251226 -CreateBackup
```

**Combine options:**

```powershell
.\Optimize-BlogImages.ps1 -DateFolder 251226 -MaxWidth 1000 -Quality 88 -CreateBackup
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-DateFolder` | Yes | - | Date folder to process (e.g., `251226`) |
| `-MaxWidth` | No | 800 | Maximum width in pixels (100-3000) |
| `-Quality` | No | 85 | Image quality percentage (1-100) |
| `-DryRun` | No | False | Preview changes without modifying files |
| `-CreateBackup` | No | False | Create timestamped backup before processing |

### What It Does

1. **Checks prerequisites**: Verifies ImageMagick is installed
2. **Validates folder**: Ensures the target date folder exists
3. **Scans images**: Finds all PNG, WebP, and GIF files
4. **Creates backup** (if requested): Copies files to `_backup_YYYYMMDD_HHMMSS/`
5. **Optimizes images**: Applies format-specific optimization
6. **Reports results**: Shows file-by-file and total savings

### Expected Results

For a typical screenshot-heavy blog post folder:

- **File size reduction**: 50-70%
- **Visual quality**: Imperceptible difference
- **Processing time**: 10-30 seconds for 20-30 images

Example:
```
Before:  6.9 MB (34 images)
After:   2.1 MB (34 images)
Saved:   4.8 MB (69.6%)
```

## Recommended Workflow

### For New Blog Posts

When creating a new blog post with images:

1. **Create date folder** (if needed):
   ```powershell
   mkdir images/260106
   ```

2. **Add your screenshots** to the folder

3. **Preview optimization** (dry run):
   ```powershell
   cd scripts
   .\Optimize-BlogImages.ps1 -DateFolder 260106 -DryRun
   ```

4. **Optimize images**:
   ```powershell
   .\Optimize-BlogImages.ps1 -DateFolder 260106
   ```

5. **Reference images in your blog post**:
   ```markdown
   ![Description](/images/260106/screenshot.png)
   ```

6. **Commit to repository**:
   ```powershell
   git add images/260106/
   git commit -m "Add optimized images for blog post"
   ```

### For Existing Folders

To optimize images in an existing folder:

1. **Always dry-run first**:
   ```powershell
   .\Optimize-BlogImages.ps1 -DateFolder 251226 -DryRun
   ```

2. **Review the preview** to ensure expected results

3. **Optionally create backup**:
   ```powershell
   .\Optimize-BlogImages.ps1 -DateFolder 251226 -CreateBackup
   ```

4. **Commit optimized images**:
   ```powershell
   git add images/251226/
   git commit -m "Optimize images in 251226 folder - reduced 6.9MB to 2.1MB"
   ```

## Optimization Settings

### Quality Settings

The default quality of **85%** is the industry standard sweet spot:

- ✅ **80-90%**: Imperceptible quality loss to human eye
- ⚠️ **Below 80%**: May show visible compression artifacts
- ⚠️ **Above 90%**: Minimal gains for increased file size

### Width Settings

The default max width of **800px** is suitable for most blog content:

- **800px**: Good for simple blogs, maximum file size reduction
- **1200px**: Better balance for modern screens, moderate reduction
- **1600px**: High quality for large screens, minimal reduction

Images smaller than the specified max width are not enlarged.

### Format-Specific Behavior

**PNG Files:**
- Lossless compression (no quality degradation)
- Metadata stripped (EXIF, color profiles)
- Progressive encoding for better web loading
- Compression level 9 (maximum)

**WebP Files:**
- Lossy re-encoding at specified quality
- Metadata stripped
- Already efficient format, moderate gains

**GIF Files:**
- Layer optimization only
- Preserves animations
- No quality loss
- Smaller gains (typically 10-30%)

## Troubleshooting

### "ImageMagick is not installed or not in PATH"

**Solution:**
1. Install ImageMagick from the official website
2. During installation, check "Add application directory to your system path"
3. Restart PowerShell
4. Verify with: `magick -version`

### "Folder not found"

**Solution:**
- Ensure the date folder exists in the `/images/` directory
- Check the folder name matches the format (e.g., `251226`, not `2025-12-26`)
- The script will list available date folders if the specified one doesn't exist

### "Script execution is disabled"

**Solution:**
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Images look blurry after optimization

**Solution:**
- Increase the `-Quality` parameter: `-Quality 90`
- Increase the `-MaxWidth` parameter: `-MaxWidth 1200`
- For critical images, use `-Quality 95 -MaxWidth 1600`

### No space saved / Files increased in size

**Possible causes:**
- Images were already optimized
- Original images were smaller than max width
- WebP files may have been poorly encoded originally

**Solution:**
- Use `-DryRun` first to preview
- Check original image dimensions
- Consider using different quality settings

## Tips and Best Practices

1. **Always dry-run first**: Use `-DryRun` to preview changes
2. **Git is your backup**: You can always revert changes with git
3. **Start conservative**: Use default settings (800px, 85% quality) first
4. **Process incrementally**: Optimize folders as you work on posts
5. **Visual check**: After optimizing, view images in a browser to verify quality
6. **Commit separately**: Commit optimized images separately from content changes

## Advanced: Batch Processing All Folders

To optimize all date folders at once:

```powershell
# Get all date folders and process them
Get-ChildItem ../images -Directory | Where-Object { $_.Name -match '^\d{6}$' } | ForEach-Object {
    Write-Host "Processing $($_.Name)..." -ForegroundColor Cyan
    .\Optimize-BlogImages.ps1 -DateFolder $_.Name
}
```

**Warning**: This will process ALL date folders. Always dry-run first:

```powershell
# Dry run for all folders
Get-ChildItem ../images -Directory | Where-Object { $_.Name -match '^\d{6}$' } | ForEach-Object {
    .\Optimize-BlogImages.ps1 -DateFolder $_.Name -DryRun
}
```

## Examples

### Example 1: Standard Workflow

```powershell
PS> cd scripts
PS> .\Optimize-BlogImages.ps1 -DateFolder 251226 -DryRun

======================================================================
  Blog Image Optimization Script
======================================================================

Checking prerequisites...
  ✓ Found ImageMagick 7.1.1-28 Q16-HDRI x64
  ✓ Target folder: C:\blog\images\251226

Scanning for images...
  Found 34 image(s):
    PNG:  31
    GIF:  3

Optimization settings:
  Max width: 800px
  Quality: 85%
  Mode: DRY RUN (no changes will be made)

Processing 31 PNG file(s)...
    [DRY RUN] image-1.png (193 KB)
    [DRY RUN] image-2.png (158 KB)
    ...

Processing 3 GIF file(s)...
    [DRY RUN] movie1.gif (1.2 MB)
    ...

======================================================================
  SUMMARY
======================================================================
  Mode: DRY RUN - No files were modified
  Total size before: 6.9 MB
======================================================================

PS> .\Optimize-BlogImages.ps1 -DateFolder 251226

[Optimizes all images and shows results]
```

### Example 2: High-Quality Images

```powershell
# For images where quality is critical
PS> .\Optimize-BlogImages.ps1 -DateFolder 251226 -MaxWidth 1600 -Quality 92
```

### Example 3: With Backup

```powershell
# Create backup before optimizing
PS> .\Optimize-BlogImages.ps1 -DateFolder 251226 -CreateBackup

Creating backup...
  ✓ Backup created: C:\blog\images\251226\_backup_20260106_143022

[Continues with optimization]
```

## Support

For issues or questions:
- Check the [ImageMagick documentation](https://imagemagick.org/script/command-line-processing.php)
- Review this README for troubleshooting steps
- Test with `-DryRun` to diagnose issues

## License

This script is part of the blog repository and follows the same license.

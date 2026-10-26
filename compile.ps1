<#
.SYNOPSIS
    Compiles both the English and French CV templates to small PDFs.

.DESCRIPTION
    Runs pdflatex on eng/template.tex and fr/template.tex and leaves just the
    two PDFs behind.

    The profile photo (the only thing that makes the PDFs large) is downsampled
    and re-encoded in a temporary copy of the project before compiling, so the
    PDFs are a small fraction of the size with an identical render at print
    size. Your source files and original photo are never modified.

.PARAMETER ImageWidth
    Max pixel width of the profile photo (default 800). The photo prints at
    5 cm wide, so 800 px is about 400 dpi, sharper than print needs. Lower =
    smaller file, higher = sharper when zoomed.

.PARAMETER ImageQuality
    JPEG quality 1-100 of the profile photo (default 85).

.EXAMPLE
    .\compile.ps1

.EXAMPLE
    .\compile.ps1 -ImageWidth 500 -ImageQuality 75
#>

[CmdletBinding()]
param(
    [ValidateRange(100, 4000)][int]$ImageWidth = 800,
    [ValidateRange(1, 100)][int]$ImageQuality = 85
)

$root = $PSScriptRoot

function New-CompressedImage {
    param(
        [string]$Source,
        [string]$Destination
    )

    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromFile($Source)
    try {
        $w = [Math]::Min($imageWidth, $img.Width)
        $h = [int][Math]::Round($img.Height * $w / $img.Width)

        $bmp = New-Object System.Drawing.Bitmap $w, $h
        try {
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $g.DrawImage($img, 0, 0, $w, $h)
            $g.Dispose()

            $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
            $encParams = New-Object System.Drawing.Imaging.EncoderParameters 1
            $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([long]$imageQuality)
            $bmp.Save($Destination, $codec, $encParams)
        }
        finally {
            $bmp.Dispose()
        }
    }
    finally {
        $img.Dispose()
    }
}

# Builds a temp copy of the project with the photo downsampled, so the original stays untouched.
function Initialize-Staging {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("cv-compile-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path (Join-Path $dir "shared") | Out-Null
    Copy-Item -Path (Join-Path $root "shared\*") -Destination (Join-Path $dir "shared") -Recurse

    $original = Join-Path $root "shared\ProfilePicture.jpg"
    if (Test-Path $original) {
        $photo = Join-Path $dir "shared\ProfilePicture.jpg"
        New-CompressedImage -Source $original -Destination $photo
        $before = [Math]::Round((Get-Item $original).Length / 1KB)
        $after = [Math]::Round((Get-Item $photo).Length / 1KB)
        Write-Host "Profile photo: $before KB -> $after KB" -ForegroundColor DarkGray
    }
    return $dir
}

function Compile-Template {
    param(
        [string]$Dir
    )

    $texFile = "template.tex"
    $pdfFile = "template.pdf"
    $logFile = "compile-output.log"
    $realDir = Join-Path $root $Dir
    $workDir = Join-Path $staging $Dir

    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
    Copy-Item -Path (Join-Path $realDir "*.tex") -Destination $workDir

    Write-Host "Compiling $Dir/$texFile..." -ForegroundColor Cyan

    Push-Location $workDir
    try {
        & pdflatex -interaction=nonstopmode -halt-on-error $texFile *> $logFile
        $exitCode = $LASTEXITCODE
        $ok = ($exitCode -eq 0) -and (Test-Path $pdfFile)

        if (-not $ok) {
            Write-Host "  FAILED: $Dir/$texFile did not compile. See $Dir/$logFile for details." -ForegroundColor Red
            Copy-Item -Path $logFile -Destination (Join-Path $realDir $logFile) -Force
            return $false
        }

        Copy-Item -Path $pdfFile -Destination (Join-Path $realDir $pdfFile) -Force
        $sizeKb = [Math]::Round((Get-Item (Join-Path $realDir $pdfFile)).Length / 1KB)
        Write-Host "  OK: $Dir/$pdfFile ($sizeKb KB)" -ForegroundColor Green
        return $true
    }
    finally {
        Pop-Location
    }
}

if (-not (Get-Command pdflatex -ErrorAction SilentlyContinue)) {
    Write-Host "pdflatex was not found on PATH. Install a LaTeX distribution (e.g. MiKTeX) or add it to PATH first." -ForegroundColor Red
    exit 1
}

$staging = $null
try {
    $staging = Initialize-Staging
    $engOk = Compile-Template -Dir "eng"
    $frOk = Compile-Template -Dir "fr"
}
finally {
    if ($staging -and (Test-Path $staging)) {
        Remove-Item -Path $staging -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($engOk -and $frOk) {
    Write-Host "Both CVs compiled successfully." -ForegroundColor Green
    exit 0
}
else {
    exit 1
}

<#
.SYNOPSIS
    Compiles both the English and French CV templates to PDF.

.DESCRIPTION
    Runs pdflatex on eng/template.tex and fr/template.tex (each from its own
    directory, so the ../shared/cv.cls and ../shared/ProfilePicture.jpg
    relative paths resolve correctly), then removes the intermediate build
    files (.aux/.log/.out/.synctex) and leaves just the two PDFs behind.

.EXAMPLE
    .\compile.ps1
#>

$root = $PSScriptRoot

function Compile-Template {
    param(
        [string]$Dir
    )

    $texFile = "template.tex"
    $pdfFile = "template.pdf"
    $logFile = "compile-output.log"
    $fullDir = Join-Path $root $Dir

    Write-Host "Compiling $Dir/$texFile..." -ForegroundColor Cyan

    Push-Location $fullDir
    try {
        & pdflatex -interaction=nonstopmode -halt-on-error $texFile *> $logFile
        $exitCode = $LASTEXITCODE
        $ok = ($exitCode -eq 0) -and (Test-Path $pdfFile)

        if (-not $ok) {
            Write-Host "  FAILED: $Dir/$texFile did not compile. See $Dir/$logFile for details." -ForegroundColor Red
            Remove-Item -Path "*.aux", "*.out", "template.synctex(busy)" -ErrorAction SilentlyContinue
            return $false
        }

        Remove-Item -Path "*.aux", "*.log", "*.out", "template.synctex(busy)" -ErrorAction SilentlyContinue
        Write-Host "  OK: $Dir/$pdfFile" -ForegroundColor Green
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

$engOk = Compile-Template -Dir "eng"
$frOk = Compile-Template -Dir "fr"

if ($engOk -and $frOk) {
    Write-Host "Both CVs compiled successfully." -ForegroundColor Green
    exit 0
}
else {
    exit 1
}

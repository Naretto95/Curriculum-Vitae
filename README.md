# Curriculum Vitae

My personal résumé, written in LaTeX, with English and French versions built from one shared class.

## Structure

```
.
├── eng/
│   └── template.tex       English CV
├── fr/
│   └── template.tex       French CV
├── shared/
│   ├── cv.cls              Shared LaTeX class: layout, colors, macros
│   └── ProfilePicture.jpg  Profile photo used by both versions
└── compile.ps1             Compiles both CVs to PDF
```

Both templates depend on `shared/cv.cls` and `shared/ProfilePicture.jpg` via relative paths (`../shared/...`), so they must stay in this layout.

## Requirements

A LaTeX distribution with `pdflatex` on your `PATH` — [MiKTeX](https://miktex.org/download) or [TeX Live](https://www.tug.org/texlive/). MiKTeX will install any missing packages automatically on first compile.

## Compiling

From the repo root, in PowerShell:

```powershell
.\compile.ps1
```

This compiles both `eng/template.tex` and `fr/template.tex`, leaving a small `template.pdf` in each directory (about 170 KB instead of about 6 MB, same visual render). The profile photo is downsampled in a temporary copy before compiling, so your source files and original photo are never modified, and no build files are left behind.

The photo size is tunable if you want a smaller or sharper result (defaults shown):

```powershell
.\compile.ps1 -ImageWidth 800 -ImageQuality 85
```

To compile just one manually (full-size photo, so a much bigger PDF):

```powershell
cd eng
pdflatex template.tex
```

## License

All rights reserved — see [LICENSE](LICENSE).

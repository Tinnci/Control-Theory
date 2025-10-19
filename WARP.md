# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a LaTeX-based repository containing comprehensive Control Theory notes in Chinese. The main document covers both classical and modern control theory concepts, structured as an academic reference with mathematical formulations, diagrams, and detailed explanations.

## Architecture

### Main Components

- **control_theory_notes.tex**: The primary LaTeX document containing all control theory content
  - Part 1: Classical Control Theory (经典控制理论) - covers fundamental concepts, transfer functions, stability analysis, frequency domain methods
  - Part 2: Modern Control Theory (现代控制理论) - covers state-space representation, controllability, observability, pole placement

### Document Structure

The document follows academic formatting with:
- Uses `ctex` package for Chinese typesetting
- Mathematical packages: `amsmath`, `amsfonts`, `amssymb`
- Graphics support: `tikz`, `pgfplots` for control system diagrams
- Custom commands for Laplace (`\laplace`) and Fourier (`\fourier`) transforms
- Professional formatting with `fancyhdr` for headers/footers

## Common Development Commands

### Building the Document

```bash
lualatex control_theory_notes.tex
```

### Cleaning Build Artifacts

```bash
# Remove auxiliary files (listed in .gitignore)
rm -f *.aux *.log *.out *.toc *.synctex.gz

# On Windows PowerShell
Remove-Item -Path "*.aux", "*.log", "*.out", "*.toc", "*.synctex.gz"
```

## Content Areas

### Classical Control Theory Topics
- Control system fundamentals and classification
- Laplace transforms and transfer functions  
- Block diagrams and signal flow graphs
- Time domain analysis (first and second-order systems)
- Stability analysis using Routh criterion
- Steady-state error calculations
- Root locus methods (180° and 0°)
- Frequency domain analysis (Nyquist, Bode plots)
- Compensation design (lead/lag controllers)

### Modern Control Theory Topics  
- State-space representation
- Controllability and observability analysis
- State feedback and pole placement
- Observer design and separation theorem
- Lyapunov stability methods
- System realizations and canonical forms

## Key Mathematical Notation

The document uses standard control theory notation:
- `s`: Laplace variable
- `G(s)`: Transfer function  
- `ωn`: Natural frequency
- `ζ`: Damping ratio
- `A, B, C, D`: State-space matrices
- Custom commands: `\laplace{}`, `\fourier{}`, `\jw` for jω

## LaTeX Dependencies

Required packages (automatically handled by modern LaTeX distributions):
- `ctex` - Chinese typesetting
- `amsmath`, `amsfonts`, `amssymb` - Mathematical symbols
- `graphicx` - Image inclusion  
- `tikz`, `pgfplots` - Technical diagrams
- `geometry`, `fancyhdr` - Page layout
- `hyperref` - Cross-references and links
- `xcolor` - Color support

### Specialized Control System Plotting Packages
- `bodeplot` - For generating Bode plots (magnitude/phase) via ZPK or TF coefficients
- `tfplots` - For s-domain pole-zero plots and root locus diagrams  
- `rootlocus` - Specialized root locus plotting with customizable styles
- TikZ `control` library - Integrated control system diagram support

## File Organization

- Source: `control_theory_notes.tex` (single comprehensive document)
- Output: PDF generated during compilation (gitignored)
- Auxiliary files: Automatically generated during compilation (gitignored)

## Control System Diagram Examples

The document includes practical LaTeX examples for:

### Bode Plots
- Magnitude and phase frequency response plots using `bodeplot` package
- Semi-log axis formatting with proper grid and labeling
- Examples integrated into relevant theoretical sections

### Pole-Zero Plots  
- s-domain pole-zero distribution diagrams using `tfplots`
- Proper mathematical symbol marking (× for poles, ○ for zeros)
- Complex plane visualization with grid overlay

### Root Locus Diagrams
- Root locus plotting using `rootlocus` and `tfplots` packages
- Asymptote lines and critical point annotations
- Parameter sweep visualization (K from 0 to ∞)

### Nyquist Plots
- Complex plane frequency response using `bodeplot` Nyquist functionality  
- Critical point (-1,j0) marking and stability assessment
- Directional arrows for frequency sweep indication

## Development Notes

- The document is structured for academic/educational use with numbered sections and comprehensive coverage
- Mathematical formulations follow standard control engineering conventions
- Professional control system diagrams integrated throughout using specialized LaTeX packages
- Chinese text requires XeLaTeX or LuaLaTeX for proper font handling
- Cross-references and equation numbering are used extensively throughout
- All plotting examples use consistent styling and mathematical notation

# 控制理论笔记 - 快速编译脚本
# PowerShell 版本

param(
    [switch]$Clean,      # 清理辅助文件
    [switch]$Full,       # 完整编译（两次）
    [switch]$Quick,      # 快速编译（一次）
    [switch]$Open        # 编译后打开PDF
)

$ErrorActionPreference = "Stop"
$MainFile = "control_theory_notes"
$OutputPDF = "$MainFile.pdf"

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   控制理论笔记 - LaTeX 编译工具       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 清理函数
function Clean-AuxFiles {
    Write-Host "🧹 清理辅助文件..." -ForegroundColor Yellow
    $extensions = @("*.aux", "*.log", "*.out", "*.toc", "*.bbl", "*.blg", 
                   "*.fls", "*.fdb_latexmk", "*.synctex.gz", "*.nav", 
                   "*.snm", "*.vrb", "*.lof", "*.lot")
    
    foreach ($ext in $extensions) {
        Get-ChildItem -Path . -Filter $ext -Recurse -ErrorAction SilentlyContinue | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
    Write-Host "   ✓ 清理完成" -ForegroundColor Green
}

# 编译函数
function Compile-LaTeX {
    param([int]$Times = 1)
    
    for ($i = 1; $i -le $Times; $i++) {
        Write-Host "📝 编译中 ($i/$Times)..." -ForegroundColor Yellow
        
        $output = lualatex -interaction=nonstopmode -file-line-error -shell-escape "$MainFile.tex" 2>&1
        
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 1) {
            Write-Host "   ✗ 编译失败！" -ForegroundColor Red
            $output | Select-String "^!" | Select-Object -First 5
            return $false
        }
        
        Write-Host "   ✓ 第 $i 次编译完成" -ForegroundColor Green
    }
    return $true
}

# 主流程
try {
    # 清理模式
    if ($Clean) {
        Clean-AuxFiles
        if (-not ($Full -or $Quick)) {
            Write-Host "`n✨ 清理完成！" -ForegroundColor Green
            exit 0
        }
    }
    
    # 编译
    $compileSuccess = $false
    if ($Full) {
        Write-Host "🚀 开始完整编译（两次以生成目录）..." -ForegroundColor Cyan
        $compileSuccess = Compile-LaTeX -Times 2
    }
    elseif ($Quick -or (-not $Clean)) {
        Write-Host "⚡ 快速编译..." -ForegroundColor Cyan
        $compileSuccess = Compile-LaTeX -Times 1
    }
    
    if (-not $compileSuccess) {
        exit 1
    }
    
    # 检查PDF
    if (Test-Path $OutputPDF) {
        $pdfInfo = Get-Item $OutputPDF
        $sizeKB = [math]::Round($pdfInfo.Length / 1KB, 2)
        
        # 提取页数
        $logContent = Get-Content "$MainFile.log" -Raw
        if ($logContent -match "Output written.*\((\d+) page") {
            $pages = $Matches[1]
        }
        else {
            $pages = "?"
        }
        
        Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║          ✨ 编译成功！               ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host "📄 文件: $OutputPDF" -ForegroundColor White
        Write-Host "📊 大小: $sizeKB KB" -ForegroundColor White
        Write-Host "📖 页数: $pages 页" -ForegroundColor White
        Write-Host "🕐 时间: $($pdfInfo.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
        
        # 自动清理（保留PDF和源文件）
        Write-Host "`n🧹 自动清理辅助文件..." -ForegroundColor Yellow
        Clean-AuxFiles
        
        # 打开PDF
        if ($Open) {
            Write-Host "`n📖 打开PDF..." -ForegroundColor Cyan
            Start-Process $OutputPDF
        }
        
        Write-Host "`n✨ 完成！" -ForegroundColor Green
    }
    else {
        Write-Host "`n✗ PDF文件未生成！" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "`n✗ 发生错误: $_" -ForegroundColor Red
    exit 1
}

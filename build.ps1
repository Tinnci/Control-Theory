# 控制理论笔记 - 快速编译脚本
# PowerShell 版本

param(
    [switch]$Clean,      # 清理辅助文件
    [switch]$Full,       # 完整编译（两次）
    [switch]$Quick,      # 快速编译（一次）
    [switch]$Open,       # 编译后打开PDF
    [switch]$KeepLog    # 保留日志文件（不自动清理）
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
        
        # 检查退出代码
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 1) {
            Write-Host "   ✗ 编译失败（退出代码: $LASTEXITCODE）！" -ForegroundColor Red
            $output | Select-String "^!" | Select-Object -First 10
            return $false
        }
        
        # 检查log文件中的严重错误
        if (Test-Path "$MainFile.log") {
            $logContent = Get-Content "$MainFile.log" -Raw
            
            # 检查致命错误模式
            $fatalErrors = @(
                "File ended while scanning",
                "Emergency stop",
                "Fatal error",
                "! LaTeX Error:",
                "Package pgf Error:"
            )
            
            $foundFatalError = $false
            foreach ($pattern in $fatalErrors) {
                if ($logContent -match $pattern) {
                    Write-Host "   ✗ 发现致命错误：$pattern" -ForegroundColor Red
                    # 显示错误上下文
                    $logContent -split "`n" | Select-String -Pattern $pattern -Context 2,2 | 
                        Select-Object -First 3 | ForEach-Object { Write-Host $_.Line -ForegroundColor Red }
                    $foundFatalError = $true
                    break
                }
            }
            
            if ($foundFatalError) {
                Write-Host "`n💡 提示：检查 $MainFile.log 获取详细错误信息" -ForegroundColor Yellow
                return $false
            }
            
            # 统计警告（Overfull/Underfull）
            $overfullCount = ([regex]::Matches($logContent, "Overfull")).Count
            $underfullCount = ([regex]::Matches($logContent, "Underfull")).Count
            
            if ($overfullCount -gt 0 -or $underfullCount -gt 0) {
                Write-Host "   ⚠️  警告：Overfull($overfullCount) Underfull($underfullCount)" -ForegroundColor Yellow
            }
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
        if (-not $KeepLog) {
            Write-Host "`n🧹 自动清理辅助文件..." -ForegroundColor Yellow
            Clean-AuxFiles
        }
        else {
            Write-Host "`n📋 保留日志文件（使用 -KeepLog 参数）" -ForegroundColor Cyan
        }
        
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

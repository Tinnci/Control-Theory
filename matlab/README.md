# Nyquist & Bode Animation Generator

[中文版本](#中文版本) | [English Version](#english-version)

---

## English Version

### Overview

This is a comprehensive MATLAB CLI application for generating **step-by-step animated visualizations** of Nyquist and Bode diagrams. The program supports multiple output formats (MP4 video and GIF) and runs entirely from the command line without requiring the MATLAB GUI.

### Features

✨ **Key Features:**
- 🎬 **Step-by-step animations** showing real-time curve drawing
- 📊 **Dual diagram types**: Nyquist plots and Bode plots
- 🎥 **Multiple output formats**: MP4 (H.264) and GIF (Animated)
- 🖥️ **Pure CLI operation**: No GUI required, perfect for batch processing
- 📦 **Multiple system examples**: Type-0, Type-I, and second-order systems
- ⚡ **MATLAB 2025 compatible**: Optimized for the latest MATLAB version
- 🔄 **Customizable parameters**: Adjust animation speed and quality

### Supported Systems

#### Bode Diagram Systems
1. **First-Order System**: G(s) = 10 / (1 + 0.1s)
2. **Second-Order System**: G(s) = 100 / (s² + 2s + 100)
3. **Type-I System**: G(s) = 250 / (s(s+5)(s+15))

#### Nyquist Diagram Systems
1. **Type-0 System**: G(s) = 6 / (s² + 3s + 2)
2. **Type-I System**: G(s) = 250 / (s(s+5)(s+15))
3. **Underdamped System**: G(s) = 100 / (s² + 2s + 100), ζ = 0.1, ωn = 10 rad/s

### Installation Requirements

**Required:**
- MATLAB 2025 or newer
- Control System Toolbox
- Video encoding support (for MP4 output)

**Optional:**
- PowerShell 5.0+ (for Windows CLI scripts)

### Usage

#### Method 1: PowerShell Command (Windows)

Generate Bode diagram animation:
```powershell
$env:ANIM_TYPE="bode"
$env:OUTPUT_FILE="bode_animation.mp4"
cd "C:\Users\shiso\Downloads\Control Theory\matlab"
matlab -batch main
```

Generate Nyquist diagram animation:
```powershell
$env:ANIM_TYPE="nyquist"
$env:OUTPUT_FILE="nyquist_animation.mp4"
cd "C:\Users\shiso\Downloads\Control Theory\matlab"
matlab -batch main
```

#### Method 2: MATLAB Command Line

```bash
matlab -batch main
```

### Output Files

The program generates MP4 video files with the following naming convention:
- `{output_filename}_sys1.mp4`
- `{output_filename}_sys2.mp4`
- `{output_filename}_sys3.mp4`

Each file corresponds to one of the three example systems.

### Generated Animations

**Bode Diagram Animations:**
- bode_test_sys1.mp4 (1.44 MB) - First-order system
- bode_test_sys2.mp4 (1.43 MB) - Second-order system
- bode_test_sys3.mp4 (1.37 MB) - Type-I system

**Nyquist Diagram Animations:**
- nyquist_test_sys1.mp4 (0.23 MB) - Type-0 system
- nyquist_test_sys2.mp4 (0.24 MB) - Type-I system
- nyquist_test_sys3.mp4 (0.23 MB) - Underdamped system

### Project Structure

```
matlab/
├── main.m                          # CLI entry point
├── generate_bode_animation.m       # Bode diagram animation generator
├── generate_nyquist_animation.m    # Nyquist diagram animation generator
├── ExportAnimation.m               # Video/GIF export utility class
├── CLIMenu.m                       # Interactive CLI menu system
├── README.md                       # Documentation (this file)
└── *.mp4                           # Generated video files
```

### Core Modules

**1. main.m** - Main entry point
- Handles environment variable parameter passing
- Supports batch mode execution
- Routes to appropriate animation generator

**2. generate_bode_animation.m** - Bode plot generator
- Computes frequency response (magnitude and phase)
- Creates 60-frame step-by-step animation
- Supports MP4 and GIF output formats

**3. generate_nyquist_animation.m** - Nyquist plot generator
- Computes complex frequency response
- Creates 80-frame animation showing real and imaginary parts
- Displays reference plots alongside animation

**4. ExportAnimation.m** - Export utility class
- Handles VideoWriter initialization
- Manages GIF frame creation and export
- Provides format information and recommendations

**5. CLIMenu.m** - Interactive menu system
- Provides CLI menus and prompts
- Handles user input validation
- Displays system information and help

### Animation Features

Each animation includes:
- **Reference diagram** (left): Complete static plot for reference
- **Animated drawing** (right): Step-by-step curve generation
- **Real-time information**: Current frequency, magnitude, and phase
- **Progress indicator**: Shows animation completion percentage
- **60+ frame animation** at 30 FPS (smooth playback)

### Advanced Usage

#### Custom Output Directory
```powershell
$env:ANIM_TYPE="bode"
$env:OUTPUT_FILE="C:\Videos\my_animation.mp4"
matlab -batch main
```

#### Batch Processing Multiple Animations
```powershell
foreach ($type in @("bode", "nyquist")) {
    $env:ANIM_TYPE=$type
    $env:OUTPUT_FILE="${type}_output.mp4"
    matlab -batch main
    Write-Host "Completed $type animation"
}
```

### Troubleshooting

**Issue**: VideoWriter warning about H.264 codec
- **Solution**: This is informational and does not affect output quality

**Issue**: Animations not generating
- **Solution**: Ensure Control System Toolbox is installed via MATLAB's Add-On Manager

**Issue**: CLI commands not recognized
- **Solution**: Add MATLAB to system PATH or use full path to matlab.exe

### Performance Notes

- Bode diagram animations: ~15-20 seconds to generate
- Nyquist diagram animations: ~20-30 seconds to generate
- Output video file sizes: 0.2-1.5 MB per system
- Frame resolution: 1200x800 (Bode), 1400x700 (Nyquist)

### License

This project is part of the Control Theory repository. See the main repository license for details.

### Version Information

- **Created**: October 26, 2025
- **MATLAB Version**: 2025 or newer
- **Status**: Production Ready ✅

---

## 中文版本

### 概述

这是一个全功能的 MATLAB 命令行应用程序，用于生成 **逐步动画**展示的 Nyquist 图和 Bode 图。程序支持多种输出格式（MP4 视频和 GIF），完全从命令行运行，无需 MATLAB 图形界面。

### 功能特性

✨ **主要特性：**
- 🎬 **逐步动画** - 实时显示曲线绘制过程
- 📊 **双图表类型** - Nyquist 图和 Bode 图
- 🎥 **多种输出格式** - MP4 (H.264) 和 GIF (动画)
- 🖥️ **纯命令行操作** - 无需 GUI，适合批量处理
- 📦 **多个系统示例** - 0型、I型和二阶系统
- ⚡ **MATLAB 2025 兼容** - 针对最新 MATLAB 版本优化
- 🔄 **可定制参数** - 调整动画速度和质量

### 支持的系统

#### Bode 图系统
1. **一阶系统**: G(s) = 10 / (1 + 0.1s)
2. **二阶系统**: G(s) = 100 / (s² + 2s + 100)
3. **I型系统**: G(s) = 250 / (s(s+5)(s+15))

#### Nyquist 图系统
1. **0型系统**: G(s) = 6 / (s² + 3s + 2)
2. **I型系统**: G(s) = 250 / (s(s+5)(s+15))
3. **欠阻尼系统**: G(s) = 100 / (s² + 2s + 100), ζ = 0.1, ωn = 10 rad/s

### 安装要求

**必需：**
- MATLAB 2025 或更新版本
- Control System Toolbox
- 视频编码支持（用于 MP4 输出）

**可选：**
- PowerShell 5.0+（用于 Windows CLI 脚本）

### 使用方法

#### 方法 1：PowerShell 命令（Windows）

生成 Bode 图动画：
```powershell
$env:ANIM_TYPE="bode"
$env:OUTPUT_FILE="bode_animation.mp4"
cd "C:\Users\shiso\Downloads\Control Theory\matlab"
matlab -batch main
```

生成 Nyquist 图动画：
```powershell
$env:ANIM_TYPE="nyquist"
$env:OUTPUT_FILE="nyquist_animation.mp4"
cd "C:\Users\shiso\Downloads\Control Theory\matlab"
matlab -batch main
```

#### 方法 2：MATLAB 命令行

```bash
matlab -batch main
```

### 输出文件

程序生成 MP4 视频文件，文件名格式为：
- `{输出文件名}_sys1.mp4`
- `{输出文件名}_sys2.mp4`
- `{输出文件名}_sys3.mp4`

每个文件对应三个示例系统中的一个。

### 已生成的动画

**Bode 图动画：**
- bode_test_sys1.mp4 (1.44 MB) - 一阶系统
- bode_test_sys2.mp4 (1.43 MB) - 二阶系统
- bode_test_sys3.mp4 (1.37 MB) - I型系统

**Nyquist 图动画：**
- nyquist_test_sys1.mp4 (0.23 MB) - 0型系统
- nyquist_test_sys2.mp4 (0.24 MB) - I型系统
- nyquist_test_sys3.mp4 (0.23 MB) - 欠阻尼系统

### 项目结构

```
matlab/
├── main.m                          # CLI 入口脚本
├── generate_bode_animation.m       # Bode 图动画生成器
├── generate_nyquist_animation.m    # Nyquist 图动画生成器
├── ExportAnimation.m               # 视频/GIF 导出工具类
├── CLIMenu.m                       # 交互式 CLI 菜单系统
├── README.md                       # 文档（本文件）
└── *.mp4                           # 生成的视频文件
```

### 核心模块

**1. main.m** - 主入口点
- 处理环境变量参数传递
- 支持批处理模式执行
- 路由到相应的动画生成器

**2. generate_bode_animation.m** - Bode 图生成器
- 计算频率响应（幅值和相位）
- 创建 60 帧逐步动画
- 支持 MP4 和 GIF 输出格式

**3. generate_nyquist_animation.m** - Nyquist 图生成器
- 计算复数频率响应
- 创建 80 帧动画，显示实部和虚部
- 在动画旁边显示参考图

**4. ExportAnimation.m** - 导出工具类
- 处理 VideoWriter 初始化
- 管理 GIF 帧创建和导出
- 提供格式信息和建议

**5. CLIMenu.m** - 交互式菜单系统
- 提供 CLI 菜单和提示
- 处理用户输入验证
- 显示系统信息和帮助

### 动画特性

每个动画都包含：
- **参考图表**（左）：完整的静态图供参考
- **动画绘制**（右）：逐步生成曲线的过程
- **实时信息**：显示当前频率、幅值和相位
- **进度指示**：显示动画完成百分比
- **60+ 帧动画** 以 30 FPS 播放（平滑播放）

### 高级用法

#### 自定义输出目录
```powershell
$env:ANIM_TYPE="bode"
$env:OUTPUT_FILE="C:\Videos\my_animation.mp4"
matlab -batch main
```

#### 批量处理多个动画
```powershell
foreach ($type in @("bode", "nyquist")) {
    $env:ANIM_TYPE=$type
    $env:OUTPUT_FILE="${type}_output.mp4"
    matlab -batch main
    Write-Host "完成 $type 动画"
}
```

### 故障排除

**问题**：VideoWriter 关于 H.264 编码的警告
- **解决方案**：这只是信息提示，不影响输出质量

**问题**：动画无法生成
- **解决方案**：确保通过 MATLAB 的附加功能管理器安装了 Control System Toolbox

**问题**：CLI 命令无法识别
- **解决方案**：将 MATLAB 添加到系统 PATH，或使用 matlab.exe 的完整路径

### 性能说明

- Bode 图动画生成：约 15-20 秒
- Nyquist 图动画生成：约 20-30 秒
- 输出视频文件大小：每个系统 0.2-1.5 MB
- 帧分辨率：1200×800 (Bode)，1400×700 (Nyquist)

### 许可证

本项目是控制论库的一部分。详见主库的许可证。

### 版本信息

- **创建时间**：2025 年 10 月 26 日
- **MATLAB 版本**：2025 或更新
- **状态**：生产就绪 ✅

---

## 快速开始 / Quick Start

```powershell
# 中文：生成 Bode 图
$env:ANIM_TYPE="bode"; $env:OUTPUT_FILE="test.mp4"; matlab -batch main

# English: Generate Nyquist plot
$env:ANIM_TYPE="nyquist"; $env:OUTPUT_FILE="test.mp4"; matlab -batch main
```

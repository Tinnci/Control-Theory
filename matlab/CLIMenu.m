%% CLI Menu and Interactive System
% 提供完整的交互式命令行菜单和帮助

classdef CLIMenu
    % CLIMenu 提供交互式命令行菜单功能
    
    methods(Static)
        
        %% 显示欢迎信息
        function welcome()
            fprintf('\n');
            fprintf('╔═══════════════════════════════════════════════════════╗\n');
            fprintf('║                                                       ║\n');
            fprintf('║  Nyquist & Bode Animation Generator v1.0              ║\n');
            fprintf('║  MATLAB 2025 CLI Interactive Version                 ║\n');
            fprintf('║                                                       ║\n');
            fprintf('║  Support: MP4 (MPEG-4) / GIF (Animated GIF)          ║\n');
            fprintf('║                                                       ║\n');
            fprintf('╚═══════════════════════════════════════════════════════╝\n');
            fprintf('\n');
        end
        
        %% 显示主菜单
        function choice = main_menu()
            fprintf('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
            fprintf('【主菜单】请选择要执行的操作:\n');
            fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n');
            fprintf('  [1] 生成 Bode 图动画\n');
            fprintf('  [2] 生成 Nyquist 图动画\n');
            fprintf('  [3] 两者都生成\n');
            fprintf('  [4] 显示帮助\n');
            fprintf('  [5] 设置参数\n');
            fprintf('  [6] 退出\n');
            fprintf('\n');
            
            choice = CLIMenu.get_user_input('请输入选择 (1-6) [默认: 1]: ', 1);
        end
        
        %% 显示帮助信息
        function help_menu()
            fprintf('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
            fprintf('【帮助】\n');
            fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n');
            
            fprintf('【命令行使用】\n');
            fprintf('  基本用法:\n');
            fprintf('    matlab -nodisplay -nosplash -r "main()"\n\n');
            
            fprintf('  指定动画类型:\n');
            fprintf('    matlab -nodisplay -nosplash -r "main(''bode'')"\n');
            fprintf('    matlab -nodisplay -nosplash -r "main(''nyquist'')"\n\n');
            
            fprintf('  指定输出文件:\n');
            fprintf('    matlab -nodisplay -nosplash -r "main(''bode'', ''output.mp4'')"\n');
            fprintf('    matlab -nodisplay -nosplash -r "main(''bode'', ''output.gif'')"\n\n');
            
            fprintf('【支持的输出格式】\n');
            fprintf('  .mp4  - MPEG-4 视频 (推荐，压缩比高)\n');
            fprintf('  .gif  - 动画 GIF (网页友好)\n\n');
            
            fprintf('【系统示例】\n');
            fprintf('  Bode 图:\n');
            fprintf('    - 一阶系统\n');
            fprintf('    - 二阶系统\n');
            fprintf('    - I型系统\n\n');
            
            fprintf('  Nyquist 图:\n');
            fprintf('    - 0型系统\n');
            fprintf('    - I型系统\n');
            fprintf('    - 二阶欠阻尼系统\n\n');
            
            fprintf('【更多信息】\n');
            fprintf('  输出文件默认保存在当前工作目录\n');
            fprintf('  文件格式会自动在输出文件名中标记系统号\n\n');
        end
        
        %% 显示参数设置菜单
        function params = parameters_menu()
            fprintf('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
            fprintf('【参数设置】\n');
            fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n');
            
            % 动画参数
            fprintf('【动画参数】\n');
            frame_rate = CLIMenu.get_user_input('帧率 (FPS) [默认: 30]: ', 30);
            fprintf('\n');
            
            % 输出格式
            fprintf('【输出格式】\n');
            fprintf('  [1] MP4 (MPEG-4) - 推荐\n');
            fprintf('  [2] GIF (Animated GIF)\n');
            fprintf('\n');
            format_choice = CLIMenu.get_user_input('请选择格式 (1-2) [默认: 1]: ', 1);
            
            if format_choice == 1
                format_ext = '.mp4';
            else
                format_ext = '.gif';
            end
            fprintf('\n');
            
            % 质量设置
            fprintf('【输出质量】\n');
            quality = CLIMenu.get_user_input('质量等级 (0-100) [默认: 95]: ', 95);
            fprintf('\n');
            
            % 输出目录
            output_dir = input('输出目录 [默认: 当前目录]: ', 's');
            if isempty(output_dir)
                output_dir = pwd;
            end
            fprintf('\n');
            
            % 返回参数结构体
            params.frame_rate = frame_rate;
            params.format = format_ext;
            params.quality = quality;
            params.output_dir = output_dir;
        end
        
        %% 获取用户输入（自动类型转换）
        function value = get_user_input(prompt, default_value)
            % 支持非交互模式
            if ~isempty(getenv('MATLAB_BATCH'))
                value = default_value;
                return;
            end
            
            % 获取用户输入
            input_str = input(prompt, 's');
            
            if isempty(input_str)
                value = default_value;
            else
                % 尝试转换为数字
                numeric_val = str2double(input_str);
                if ~isnan(numeric_val)
                    value = numeric_val;
                else
                    value = input_str;
                end
            end
        end
        
        %% 显示进度条
        function progress_bar(current, total, width)
            if nargin < 3
                width = 50;
            end
            
            percent = current / total;
            filled = round(width * percent);
            empty = width - filled;
            
            bar = ['[' repmat('█', 1, filled) repmat('░', 1, empty) ']'];
            fprintf('\r%s %.0f%%', bar, percent * 100);
            
            if current == total
                fprintf('\n');
            end
        end
        
        %% 显示成功消息
        function success(message)
            fprintf('[✓ SUCCESS] %s\n', message);
        end
        
        %% 显示信息消息
        function info(message)
            fprintf('[ℹ INFO] %s\n', message);
        end
        
        %% 显示警告消息
        function warning_msg(message)
            fprintf('[⚠ WARNING] %s\n', message);
        end
        
        %% 显示错误消息
        function error_msg(message)
            fprintf('[✗ ERROR] %s\n', message);
        end
        
        %% 显示状态消息
        function status(step, total, message)
            fprintf('[%d/%d] %s\n', step, total, message);
        end
        
        %% 等待用户确认
        function confirmed = confirm(prompt)
            if nargin < 1
                prompt = '是否继续? (y/n) [默认: y]: ';
            end
            
            if ~isempty(getenv('MATLAB_BATCH'))
                confirmed = true;
                return;
            end
            
            response = input(prompt, 's');
            if isempty(response) || strcmpi(response, 'y') || strcmpi(response, 'yes')
                confirmed = true;
            else
                confirmed = false;
            end
        end
        
        %% 显示系统信息
        function show_system_info()
            fprintf('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
            fprintf('【系统信息】\n');
            fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n');
            
            fprintf('MATLAB 版本: %s\n', version('-release'));
            fprintf('工作目录: %s\n', pwd);
            fprintf('平台: %s\n', computer());
            fprintf('\n');
            
            % 检查工具箱
            v = ver;
            tb_list = {v.Name};
            
            if any(strcmp(tb_list, 'Control System Toolbox'))
                fprintf('[✓] Control System Toolbox: 已安装\n');
            else
                fprintf('[✗] Control System Toolbox: 未安装\n');
            end
            fprintf('\n');
        end
    end
end

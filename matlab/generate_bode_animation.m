%% Generate Bode Diagram Animation - Simplified Stable Version
% 优化版本: 增强配色、对比度、系统参数显示
% 输出格式: MP4

function generate_bode_animation(output_file)
    % 默认输出文件
    if nargin < 1 || isempty(output_file)
        output_file = 'bode_animation.mp4';
    end
    
    % 确保输出目录存在
    [output_dir, ~, ~] = fileparts(output_file);
    if isempty(output_dir)
        output_dir = pwd;
        output_file = fullfile(output_dir, output_file);
    end
    
    fprintf('[INFO] 输出文件: %s\n', output_file);
    
    % 创建示例系统
    fprintf('[STEP 1] 创建示例系统...\n');
    systems = create_bode_systems();
    
    % 为每个系统生成动画
    for i = 1:length(systems)
        fprintf('[STEP 2] 处理系统 %d/%d: %s\n', i, length(systems), systems(i).name);
        
        % 生成输出文件名
        [~, name, ext] = fileparts(output_file);
        current_output = fullfile(output_dir, sprintf('%s_sys%d%s', name, i, ext));
        
        % 创建 Bode 图动画
        create_bode_animation_frame(systems(i), current_output);
    end
    
    fprintf('[SUCCESS] 所有动画已生成！\n');
end

%% 创建示例系统
function systems = create_bode_systems()
    systems = struct();
    
    % 系统 1: 一阶惯性系统
    systems(1).name = '一阶惯性系统 (First-Order)';
    systems(1).description = 'G(s) = 10/(1+0.1s)';
    systems(1).sys = tf([10], [0.1, 1]);
    systems(1).K = 10;
    systems(1).type = 0;
    systems(1).params = {'τ = 0.1 s', 'ωc = 10 rad/s'};
    
    % 系统 2: 二阶欠阻尼系统
    systems(2).name = '二阶欠阻尼系统 (Underdamped)';
    systems(2).description = 'G(s) = 100/(s²+2s+100)';
    systems(2).sys = tf([100], [1, 2, 100]);
    systems(2).K = 100;
    systems(2).type = 0;
    systems(2).params = {'ωn = 10 rad/s', 'ζ = 0.1 (低阻尼)'};
    
    % 系统 3: I型系统
    systems(3).name = 'I型系统 (Type-I System)';
    systems(3).description = 'G(s) = 250/[s(s+5)(s+15)]';
    systems(3).sys = tf([250], [1, 20, 75, 0]);
    systems(3).K = 250;
    systems(3).type = 1;
    systems(3).params = {'积分环节', '低频: -20 dB/dec'};
end

%% 创建 Bode 图动画帧
function create_bode_animation_frame(system, output_file)
    fprintf('[PROCESS] 创建 Bode 图: %s\n', system.name);
    
    % ===== 配色方案（专业设计）=====
    Color_BG = [0.97 0.97 0.98];           % 淡灰蓝背景
    Color_Magnitude = [0 102 204]/255;     % 深蓝（幅度曲线）
    Color_Phase = [204 51 0]/255;          % 深橙（相位曲线）
    Color_Text_Dark = [0.1 0.1 0.15];      % 深灰文字
    
    % 频率范围
    wmin = 0.01;
    wmax = 1000;
    num_points = 500;
    w = logspace(log10(wmin), log10(wmax), num_points);
    
    % 计算频率响应
    [mag, phase, ~] = bode(system.sys, w);
    mag = squeeze(mag);
    phase = squeeze(phase);
    
    % 创建视频写入器
    fprintf('[INFO] 输出格式: MP4\n');
    v = VideoWriter(output_file, 'MPEG-4');
    v.FrameRate = 30;
    v.Quality = 95;
    open(v);
    
    % 创建图形窗口
    fig = figure('Visible', 'off', 'Position', [0, 0, 1300, 850]);
    fig.Color = Color_BG;
    set(fig, 'PaperPositionMode', 'auto');
    
    % 动画帧数
    num_frames = 70;
    points_per_frame = num_points / num_frames;
    
    fprintf('[ANIMATE] 生成帧 [');
    
    for frame = 1:num_frames
        % 计算当前显示的点数
        end_idx = min(round(frame * points_per_frame), num_points);
        progress = end_idx / num_points;
        
        % 清空图形
        clf(fig);
        fig.Color = Color_BG;
        
        % 创建子图
        ax1 = subplot(2, 1, 1, 'Parent', fig);
        ax2 = subplot(2, 1, 2, 'Parent', fig);
        
        % ========== 幅频特性图 ==========
        hold(ax1, 'on');
        ax1.Color = Color_BG;
        
        % 绘制参考曲线（虚线）
        if end_idx > 1
            h_ref = semilogx(ax1, w(end_idx:end), 20*log10(mag(end_idx:end)), ...
                '--', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
            set(h_ref, 'Color', [0.7 0.7 0.7 0.5]);
        end
        
        % 绘制动画曲线（实线）
        semilogx(ax1, w(1:end_idx), 20*log10(mag(1:end_idx)), ...
            '-', 'Color', Color_Magnitude, 'LineWidth', 2.5);
        
        % 添加网格（不使用grid函数，改用line）
        set(ax1, 'XScale', 'log');
        ax1.XMinorGrid = 'on';
        ax1.YMinorGrid = 'on';
        ax1.GridLineStyle = '-';
        ax1.GridAlpha = 0.15;
        ax1.GridColor = [0.5 0.5 0.5];
        
        xlabel(ax1, '频率 ω (rad/s)', 'FontSize', 12, 'Color', Color_Text_Dark, 'FontWeight', 'bold');
        ylabel(ax1, '幅度 (dB)', 'FontSize', 12, 'Color', Color_Text_Dark, 'FontWeight', 'bold');
        title_str = sprintf('Bode 幅频特性 - %s (进度: %d%%)', system.name, round(progress*100));
        title(ax1, title_str, 'FontSize', 13, 'FontWeight', 'bold', 'Color', Color_Text_Dark);
        
        % 美化轴线
        ax1.XColor = Color_Text_Dark;
        ax1.YColor = Color_Text_Dark;
        ax1.LineWidth = 1.2;
        ax1.Box = 'on';
        
        % ========== 相频特性图 ==========
        hold(ax2, 'on');
        ax2.Color = Color_BG;
        
        % 绘制参考曲线（虚线）
        if end_idx > 1
            h_ref2 = semilogx(ax2, w(end_idx:end), phase(end_idx:end), ...
                '--', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
            set(h_ref2, 'Color', [0.7 0.7 0.7 0.5]);
        end
        
        % 绘制动画曲线（实线）
        semilogx(ax2, w(1:end_idx), phase(1:end_idx), ...
            '-', 'Color', Color_Phase, 'LineWidth', 2.5);
        
        % 添加网格
        set(ax2, 'XScale', 'log');
        ax2.XMinorGrid = 'on';
        ax2.YMinorGrid = 'on';
        ax2.GridLineStyle = '-';
        ax2.GridAlpha = 0.15;
        ax2.GridColor = [0.5 0.5 0.5];
        
        xlabel(ax2, '频率 ω (rad/s)', 'FontSize', 12, 'Color', Color_Text_Dark, 'FontWeight', 'bold');
        ylabel(ax2, '相位 (°)', 'FontSize', 12, 'Color', Color_Text_Dark, 'FontWeight', 'bold');
        title(ax2, sprintf('Bode 相频特性 (进度: %d%%)', round(progress*100)), ...
            'FontSize', 13, 'FontWeight', 'bold', 'Color', Color_Text_Dark);
        
        % 美化轴线
        ax2.XColor = Color_Text_Dark;
        ax2.YColor = Color_Text_Dark;
        ax2.LineWidth = 1.2;
        ax2.Box = 'on';
        
        % ========== 系统信息（在底部添加简洁信息）==========
        if end_idx > 1
            w_current = w(end_idx);
            mag_current = mag(end_idx);
            phase_current = phase(end_idx);
            
            % 在图形下方添加文本信息
            info_text = sprintf('系统: %s | Type-%d | K=%.1f  |  ω=%.3f rad/s | |G|=%.2f dB | ∠=%.1f° | 进度=%d%%', ...
                system.name, system.type, system.K, w_current, 20*log10(mag_current), phase_current, round(progress*100));
            
            % 添加注释在图形下方
            annotation(fig, 'textbox', [0.1 0.01 0.8 0.04], ...
                'String', info_text, ...
                'FontSize', 9, 'HorizontalAlignment', 'left', ...
                'BackgroundColor', [1 1 1], 'EdgeColor', Color_Magnitude, ...
                'LineWidth', 1, 'Margin', 3, 'Interpreter', 'none');
        end
        
        % 获取帧
        drawnow;
        frame_data = getframe(fig);
        
        % 写入视频
        writeVideo(v, frame_data);
        
        % 显示进度
        if mod(frame, 7) == 0
            fprintf('█');
        end
    end
    
    fprintf(']\n');
    
    % 关闭视频写入
    close(v);
    fprintf('[SUCCESS] 视频已保存: %s\n', output_file);
    
    close(fig);
end

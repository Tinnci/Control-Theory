%% Generate Nyquist Diagram Animation - Simplified Stable Version
% 优化版本: 增强配色、对比度、系统参数显示
% 输出格式: MP4

function generate_nyquist_animation(output_file)
    % 默认输出文件
    if nargin < 1 || isempty(output_file)
        output_file = 'nyquist_animation.mp4';
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
    systems = create_nyquist_systems();
    
    % 为每个系统生成动画
    for i = 1:length(systems)
        fprintf('[STEP 2] 处理系统 %d/%d: %s\n', i, length(systems), systems(i).name);
        
        % 生成输出文件名
        [~, name, ext] = fileparts(output_file);
        current_output = fullfile(output_dir, sprintf('%s_sys%d%s', name, i, ext));
        
        % 创建 Nyquist 图动画
        create_nyquist_animation_frame(systems(i), current_output);
    end
    
    fprintf('[SUCCESS] 所有动画已生成！\n');
end

%% 创建示例系统
function systems = create_nyquist_systems()
    systems = struct();
    
    % 系统 1: 0型系统
    systems(1).name = '0型系统 (Type-0)';
    systems(1).description = 'G(s) = 6/(s²+3s+2)';
    systems(1).sys = tf([6], [1, 3, 2]);
    systems(1).type = 0;
    systems(1).K = 6;
    systems(1).params = {'稳定系统', '起点: (3, 0)'};
    systems(1).stability_note = '不包围 (-1,0)';
    
    % 系统 2: I型系统
    systems(2).name = 'I型系统 (Type-I)';
    systems(2).description = 'G(s) = 250/[s(s+5)(s+15)]';
    systems(2).sys = tf([250], [1, 20, 75, 0]);
    systems(2).type = 1;
    systems(2).K = 250;
    systems(2).params = {'积分环节', '低频渐近线'};
    systems(2).stability_note = '有垂直渐近线';
    
    % 系统 3: 二阶欠阻尼系统
    systems(3).name = '二阶欠阻尼系统 (Underdamped)';
    systems(3).description = 'G(s) = 100/(s²+2s+100)';
    systems(3).sys = tf([100], [1, 2, 100]);
    systems(3).type = 0;
    systems(3).K = 100;
    systems(3).params = {'谐振峰值系统', 'ζ = 0.1 (低阻尼)'};
    systems(3).stability_note = '过阻尼/欠阻尼';
end

%% 创建 Nyquist 图动画帧
function create_nyquist_animation_frame(system, output_file)
    fprintf('[PROCESS] 创建 Nyquist 图: %s\n', system.name);
    
    % ===== 配色方案（专业设计）=====
    Color_BG = [0.97 0.97 0.98];           % 淡灰蓝背景
    Color_Reference = [0.7 0.7 0.72];      % 参考曲线（浅灰）
    Color_Animated = [30 120 255]/255;     % 动画曲线（亮蓝）
    Color_Critical = [255 0 51]/255;       % 临界点（亮红）
    Color_Start = [0 180 90]/255;          % 起点（绿色）
    Color_CurrentPt = [255 140 0]/255;     % 当前点（橙色）
    Color_Text_Dark = [0.1 0.1 0.15];      % 深灰文字
    
    % 频率范围
    wmin = 0.001;
    wmax = 10000;
    num_points = 800;
    w = logspace(log10(wmin), log10(wmax), num_points);
    
    % 计算频率响应
    [mag, phase, ~] = bode(system.sys, w);
    mag = squeeze(mag);
    phase = squeeze(phase);
    
    % 转换为实部和虚部
    phase_rad = phase * pi / 180;
    real_part = mag .* cos(phase_rad);
    imag_part = mag .* sin(phase_rad);
    
    % 创建视频写入器
    fprintf('[INFO] 输出格式: MP4\n');
    v = VideoWriter(output_file, 'MPEG-4');
    v.FrameRate = 30;
    v.Quality = 95;
    open(v);
    
    % 创建图形窗口
    fig = figure('Visible', 'off', 'Position', [0, 0, 1500, 750]);
    fig.Color = Color_BG;
    set(fig, 'PaperPositionMode', 'auto');
    
    % 动画帧数
    num_frames = 85;
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
        ax1 = subplot(1, 2, 1, 'Parent', fig);
        ax2 = subplot(1, 2, 2, 'Parent', fig);
        
        % 计算坐标范围
        axis_limit = max(abs([real_part; imag_part])) + 0.5;
        
        % ========== 子图1: 完整参考 Nyquist 图 ==========
        hold(ax1, 'on');
        ax1.Color = Color_BG;
        
        % 添加网格
        ax1.XMinorGrid = 'on';
        ax1.YMinorGrid = 'on';
        ax1.GridLineStyle = '-';
        ax1.GridAlpha = 0.15;
        ax1.GridColor = [0.5 0.5 0.5];
        
        % 绘制完整曲线（参考，虚线）
        h_ref1 = plot(ax1, real_part, imag_part, '--', 'Color', Color_Reference, ...
            'LineWidth', 1.2);
        set(h_ref1, 'Color', [Color_Reference 0.8]);
        h_ref2 = plot(ax1, real_part, -imag_part, '--', 'Color', Color_Reference, ...
            'LineWidth', 1.2);
        set(h_ref2, 'Color', [Color_Reference 0.8]);
        
        % 绘制临界点
        plot(ax1, -1, 0, 'o', 'MarkerSize', 14, 'LineWidth', 2.5, ...
            'Color', Color_Critical);
        
        % 标记起点
        plot(ax1, real_part(1), imag_part(1), 's', 'MarkerSize', 11, ...
            'Color', Color_Start, 'LineWidth', 2);
        
        % 添加坐标轴
        line(ax1, [-axis_limit, axis_limit], [0, 0], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.8);
        line(ax1, [0, 0], [-axis_limit, axis_limit], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.8);
        
        xlabel(ax1, 'Re[G(jω)]', 'FontSize', 12, 'Color', Color_Text_Dark, 'FontWeight', 'bold');
        ylabel(ax1, 'Im[G(jω)]', 'FontSize', 12, 'Color', Color_Text_Dark, 'FontWeight', 'bold');
        title(ax1, sprintf('Nyquist 参考图 - %s', system.name), ...
            'FontSize', 13, 'FontWeight', 'bold', 'Color', Color_Text_Dark);
        
        axis(ax1, 'equal');
        xlim(ax1, [-axis_limit, axis_limit]);
        ylim(ax1, [-axis_limit, axis_limit]);
        ax1.XAxisLocation = 'origin';
        ax1.YAxisLocation = 'origin';
        ax1.XColor = Color_Text_Dark;
        ax1.YColor = Color_Text_Dark;
        ax1.LineWidth = 1.2;
        ax1.Box = 'on';
        
        % ========== 子图2: 实时动画绘制 ==========
        hold(ax2, 'on');
        ax2.Color = Color_BG;
        
        % 添加网格
        ax2.XMinorGrid = 'on';
        ax2.YMinorGrid = 'on';
        ax2.GridLineStyle = '-';
        ax2.GridAlpha = 0.15;
        ax2.GridColor = [0.5 0.5 0.5];
        
        % 绘制临界点
        plot(ax2, -1, 0, 'o', 'MarkerSize', 14, 'LineWidth', 2.5, ...
            'Color', Color_Critical);
        
        % 添加坐标轴
        line(ax2, [-axis_limit, axis_limit], [0, 0], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.8);
        line(ax2, [0, 0], [-axis_limit, axis_limit], 'Color', [0.3 0.3 0.3], 'LineWidth', 0.8);
        
        if end_idx > 1
            % 绘制已生成的曲线（动画，实线）
            plot(ax2, real_part(1:end_idx), imag_part(1:end_idx), ...
                '-', 'Color', Color_Animated, 'LineWidth', 2.8);
            
            % 绘制当前点（橙色）
            plot(ax2, real_part(end_idx), imag_part(end_idx), 'o', ...
                'MarkerSize', 12, 'Color', Color_CurrentPt, 'LineWidth', 2);
            
            % 标记起点
            plot(ax2, real_part(1), imag_part(1), 's', 'MarkerSize', 11, ...
                'Color', Color_Start, 'LineWidth', 2);
        end
        
        xlabel(ax2, 'Re[G(jω)]', 'FontSize', 12, 'Color', Color_Text_Dark, 'FontWeight', 'bold');
        ylabel(ax2, 'Im[G(jω)]', 'FontSize', 12, 'Color', Color_Text_Dark, 'FontWeight', 'bold');
        title(ax2, sprintf('Nyquist 动画 - 进度: %d%%', round(progress*100)), ...
            'FontSize', 13, 'FontWeight', 'bold', 'Color', Color_Text_Dark);
        
        axis(ax2, 'equal');
        xlim(ax2, [-axis_limit, axis_limit]);
        ylim(ax2, [-axis_limit, axis_limit]);
        ax2.XAxisLocation = 'origin';
        ax2.YAxisLocation = 'origin';
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
            info_text = sprintf('系统: %s | Type-%d | K=%.1f  |  ω=%.3f rad/s | |G|=%.3f | ∠=%.1f° | Re=%.3f | Im=%.3f | 进度=%d%%', ...
                system.name, system.type, system.K, w_current, mag_current, phase_current, ...
                real_part(end_idx), imag_part(end_idx), round(progress*100));
            
            % 添加注释在图形下方
            annotation(fig, 'textbox', [0.1 0.01 0.8 0.04], ...
                'String', info_text, ...
                'FontSize', 8.5, 'HorizontalAlignment', 'left', ...
                'BackgroundColor', [1 1 1], 'EdgeColor', Color_Animated, ...
                'LineWidth', 1, 'Margin', 3, 'Interpreter', 'none');
        end
        
        % 获取帧
        drawnow;
        frame_data = getframe(fig);
        
        % 写入视频
        writeVideo(v, frame_data);
        
        % 显示进度
        if mod(frame, 9) == 0
            fprintf('█');
        end
    end
    
    fprintf(']\n');
    
    % 关闭视频写入
    close(v);
    fprintf('[SUCCESS] 视频已保存: %s\n', output_file);
    
    close(fig);
end

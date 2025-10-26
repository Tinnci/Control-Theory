%% Generate Nyquist Diagram Animation
% 支持逐步动画和视频输出
% 输出格式: MP4 或 GIF

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
    systems(1).description = 'G(s) = 6 / (s^2 + 3s + 2)';
    systems(1).sys = tf([6], [1, 3, 2]);
    
    % 系统 2: I型系统
    systems(2).name = 'I型系统 (Type-I)';
    systems(2).description = 'G(s) = 250 / (s(s+5)(s+15))';
    systems(2).sys = tf([250], [1, 20, 75, 0]);
    
    % 系统 3: 二阶欠阻尼系统
    systems(3).name = '二阶欠阻尼系统 (Underdamped)';
    systems(3).description = 'G(s) = 100 / (s^2 + 2s + 100)';
    systems(3).sys = tf([100], [1, 2, 100]);
end

%% 创建 Nyquist 图动画帧
function create_nyquist_animation_frame(system, output_file)
    fprintf('[PROCESS] 创建 Nyquist 图: %s\n', system.name);
    
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
    [~, name, ext] = fileparts(output_file);
    is_gif = strcmpi(ext, '.gif');
    
    if is_gif
        fprintf('[INFO] 输出格式: GIF\n');
        gif_frames = [];
    else
        fprintf('[INFO] 输出格式: MP4\n');
        v = VideoWriter(output_file, 'MPEG-4');
        v.FrameRate = 30;
        v.Quality = 95;
        open(v);
    end
    
    % 创建图形窗口
    fig = figure('Visible', 'off', 'Position', [0, 0, 1400, 700]);
    
    % 动画帧数
    num_frames = 80;
    points_per_frame = num_points / num_frames;
    
    fprintf('[ANIMATE] Generating frames [');
    
    for frame = 1:num_frames
        % 计算当前显示的点数
        end_idx = min(round(frame * points_per_frame), num_points);
        progress = end_idx / num_points;
        
        % 清空图形
        clf(fig);
        
        % 创建子图
        ax1 = subplot(1, 2, 1, 'Parent', fig);
        ax2 = subplot(1, 2, 2, 'Parent', fig);
        
        % ========== 子图1: 完整 Nyquist 图 ==========
        hold(ax1, 'on');
        grid(ax1, 'on');
        
        % 绘制临界点
        plot(ax1, -1, 0, 'ro', 'MarkerSize', 12, 'LineWidth', 2);
        
        % 绘制完整曲线（参考）
        plot(ax1, real_part, imag_part, 'b--', 'LineWidth', 1, ...
            'Color', [0.7, 0.7, 0.7]);
        plot(ax1, real_part, -imag_part, 'b--', 'LineWidth', 1, ...
            'Color', [0.7, 0.7, 0.7]);
        
        % 标记起点和终点
        plot(ax1, real_part(1), imag_part(1), 'go', 'MarkerSize', 10, 'LineWidth', 2);
        plot(ax1, real_part(end), imag_part(end), 'mo', 'MarkerSize', 10, 'LineWidth', 2);
        
        xlabel(ax1, 'Real Part Re', 'FontSize', 11);
        ylabel(ax1, 'Imaginary Part Im', 'FontSize', 11);
        title(ax1, sprintf('Nyquist Diagram (Reference) - %s', system.name), ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        axis(ax1, 'equal');
        axis_limit = max(abs([real_part; imag_part])) + 0.5;
        xlim(ax1, [-axis_limit, axis_limit]);
        ylim(ax1, [-axis_limit, axis_limit]);
        ax1.XAxisLocation = 'origin';
        ax1.YAxisLocation = 'origin';
        
        % ========== 子图2: 动画绘制 ==========
        hold(ax2, 'on');
        grid(ax2, 'on');
        
        % 绘制临界点
        plot(ax2, -1, 0, 'ro', 'MarkerSize', 12, 'LineWidth', 2);
        
        if end_idx > 0
            % 绘制已生成的曲线
            plot(ax2, real_part(1:end_idx), imag_part(1:end_idx), ...
                'b-', 'LineWidth', 2.5);
            
            % 绘制当前点
            plot(ax2, real_part(end_idx), imag_part(end_idx), ...
                'go', 'MarkerSize', 10, 'LineWidth', 2);
            
            % 显示频率信息
            info_text = sprintf(['Frequency: %.4f rad/s\n' ...
                'Magnitude: %.4f\n' ...
                'Phase: %.2f deg\n' ...
                'Real: %.4f\n' ...
                'Imag: %.4f\n' ...
                '\nProgress: %.0f%%'], ...
                w(end_idx), mag(end_idx), phase(end_idx), ...
                real_part(end_idx), imag_part(end_idx), progress*100);
            
            t = text(0.02, 0.98, info_text, 'Units', 'normalized', ...
                'FontSize', 10, 'VerticalAlignment', 'top', ...
                'BackgroundColor', [1 1 0.8]);
        end
        
        xlabel(ax2, 'Real Part Re', 'FontSize', 11);
        ylabel(ax2, 'Imaginary Part Im', 'FontSize', 11);
        title(ax2, sprintf('Nyquist Animation (%.0f%%)', progress*100), ...
            'FontSize', 12, 'FontWeight', 'bold');
        
        axis(ax2, 'equal');
        xlim(ax2, [-axis_limit, axis_limit]);
        ylim(ax2, [-axis_limit, axis_limit]);
        ax2.XAxisLocation = 'origin';
        ax2.YAxisLocation = 'origin';
        
        % 获取帧
        frame_data = getframe(fig);
        
        if is_gif
            % 保存为 GIF 帧
            im = frame_data.cdata;
            [X, map] = rgb2ind(im, 256);
            if frame == 1
                gif_frames = cat(3, X);
                gif_colormap = map;
            else
                gif_frames = cat(4, gif_frames, X);
            end
        else
            % 写入视频
            writeVideo(v, frame_data);
        end
        
        % 显示进度
        if mod(frame, 8) == 0
            fprintf('█');
        end
    end
    
    fprintf(']\n');
    
    % 关闭视频写入
    if ~is_gif
        close(v);
        fprintf('[SUCCESS] Video saved: %s\n', output_file);
    else
        % 保存 GIF - 使用更简单的方法
        for i = 1:num_frames
            if i == 1
                imwrite(gif_frames(:,:,i), gif_colormap, output_file, ...
                    'gif', 'LoopCount', inf, 'DelayTime', 1/30);
            else
                imwrite(gif_frames(:,:,i), gif_colormap, output_file, ...
                    'gif', 'WriteMode', 'append', 'DelayTime', 1/30);
            end
        end
        fprintf('[SUCCESS] GIF saved: %s\n', output_file);
    end
    
    close(fig);
end

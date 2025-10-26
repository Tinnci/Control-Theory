%% Generate Bode Diagram Animation
% 支持逐步动画和视频输出
% 输出格式: MP4 或 GIF

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
    
    % 系统 1: 一阶系统
    systems(1).name = '一阶系统 (First-Order)';
    systems(1).description = 'G(s) = 10 / (1 + 0.1s)';
    systems(1).sys = tf([10], [0.1, 1]);
    
    % 系统 2: 二阶系统
    systems(2).name = '二阶系统 (Second-Order)';
    systems(2).description = 'G(s) = 100 / (s^2 + 2s + 100)';
    systems(2).sys = tf([100], [1, 2, 100]);
    
    % 系统 3: I型系统
    systems(3).name = 'I型系统 (Type-I)';
    systems(3).description = 'G(s) = 250 / (s(s+5)(s+15))';
    systems(3).sys = tf([250], [1, 20, 75, 0]);
end

%% 创建 Bode 图动画帧
function create_bode_animation_frame(system, output_file)
    fprintf('[PROCESS] 创建 Bode 图: %s\n', system.name);
    
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
    fig = figure('Visible', 'off', 'Position', [0, 0, 1200, 800]);
    
    % 动画帧数
    num_frames = 60;
    points_per_frame = num_points / num_frames;
    
    fprintf('[ANIMATE] 生成帧 [');
    
    for frame = 1:num_frames
        % 计算当前显示的点数
        end_idx = min(round(frame * points_per_frame), num_points);
        progress = end_idx / num_points;
        
        % 清空图形
        clf(fig);
        
        % 创建子图
        ax1 = subplot(2, 1, 1, 'Parent', fig);
        ax2 = subplot(2, 1, 2, 'Parent', fig);
        
        % 绘制幅频特性
        hold(ax1, 'on');
        semilogx(ax1, w(1:end_idx), 20*log10(mag(1:end_idx)), ...
            'b-', 'LineWidth', 2.5);
        grid(ax1, 'on');
        xlabel(ax1, '频率 ω (rad/s)', 'FontSize', 11);
        ylabel(ax1, '幅度 (dB)', 'FontSize', 11);
        title(ax1, sprintf('Bode 幅频特性 - %s (%d%%)', ...
            system.name, round(progress*100)), 'FontSize', 12, 'FontWeight', 'bold');
        axis(ax1, 'tight');
        
        % 绘制相频特性
        hold(ax2, 'on');
        semilogx(ax2, w(1:end_idx), phase(1:end_idx), ...
            'r-', 'LineWidth', 2.5);
        grid(ax2, 'on');
        xlabel(ax2, '频率 ω (rad/s)', 'FontSize', 11);
        ylabel(ax2, '相位 (度)', 'FontSize', 11);
        title(ax2, sprintf('Bode 相频特性 (%d%%)', round(progress*100)), ...
            'FontSize', 12, 'FontWeight', 'bold');
        axis(ax2, 'tight');
        
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
        if mod(frame, 6) == 0
            fprintf('█');
        end
    end
    
    fprintf(']\n');
    
    % 关闭视频写入
    if ~is_gif
        close(v);
        fprintf('[SUCCESS] 视频已保存: %s\n', output_file);
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
        fprintf('[SUCCESS] GIF 已保存: %s\n', output_file);
    end
    
    close(fig);
end

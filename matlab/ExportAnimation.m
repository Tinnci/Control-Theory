%% Animation Export Utilities
% 通用的视频和 GIF 导出函数库

classdef ExportAnimation
    % ExportAnimation 提供通用的动画导出功能
    
    methods(Static)
        
        %% 初始化视频导出器
        function writer = init_video_writer(output_file, frame_rate, quality)
            % 参数检查
            if nargin < 2
                frame_rate = 30;
            end
            if nargin < 3
                quality = 95;
            end
            
            % 检查文件类型
            [~, ~, ext] = fileparts(output_file);
            
            if strcmpi(ext, '.mp4')
                writer = VideoWriter(output_file, 'MPEG-4');
                writer.FrameRate = frame_rate;
                writer.Quality = quality;
                open(writer);
            elseif strcmpi(ext, '.avi')
                writer = VideoWriter(output_file, 'Uncompressed AVI');
                writer.FrameRate = frame_rate;
                open(writer);
            else
                error('不支持的视频格式: %s', ext);
            end
        end
        
        %% 保存 GIF 动画
        function save_gif(frames, output_file, delay_time, loop_count)
            % frames: 帧数组 [H, W, C, NumFrames]
            % output_file: 输出文件路径
            % delay_time: 每帧延迟时间 (秒)
            % loop_count: 循环次数 (inf 为无限循环)
            
            if nargin < 3
                delay_time = 1/30;
            end
            if nargin < 4
                loop_count = inf;
            end
            
            % 转换每个帧为索引图像
            num_frames = size(frames, 4);
            
            for i = 1:num_frames
                frame_img = frames(:, :, :, i);
                [X, cmap] = rgb2ind(frame_img, 256);
                
                if i == 1
                    imwrite(X, cmap, output_file, 'gif', ...
                        'LoopCount', loop_count, 'DelayTime', delay_time);
                else
                    imwrite(X, cmap, output_file, 'gif', ...
                        'WriteMode', 'append', 'DelayTime', delay_time);
                end
            end
        end
        
        %% 获取当前帧
        function frame_data = capture_frame(fig)
            % 捕获当前图形窗口的帧
            frame_data = getframe(fig);
        end
        
        %% 将 RGB 图像转换为可用的 GIF 帧
        function gif_frame = convert_to_gif_frame(rgb_image, colormap_size)
            if nargin < 2
                colormap_size = 256;
            end
            
            [gif_frame, ~] = rgb2ind(rgb_image, colormap_size);
        end
        
        %% 批量帧处理
        function process_frames(frames, output_file, format)
            % frames: 帧数组
            % output_file: 输出文件
            % format: 'mp4', 'gif', 'avi'
            
            if nargin < 3
                [~, ~, ext] = fileparts(output_file);
                format = ext(2:end);  % 去掉点号
            end
            
            switch lower(format)
                case 'gif'
                    ExportAnimation.save_gif(frames, output_file);
                    
                case 'mp4'
                    % MP4 需要逐帧写入
                    v = ExportAnimation.init_video_writer(output_file, 30, 95);
                    num_frames = size(frames, 4);
                    for i = 1:num_frames
                        writeVideo(v, frames(:, :, :, i));
                    end
                    close(v);
                    
                otherwise
                    error('不支持的格式: %s', format);
            end
        end
        
        %% 获取推荐的导出格式
        function format = get_recommended_format()
            % 返回推荐的导出格式
            format = 'mp4';
        end
        
        %% 获取格式信息
        function info = get_format_info(format)
            % 获取特定格式的信息
            info = struct();
            
            switch lower(format)
                case 'mp4'
                    info.name = 'MPEG-4 Video';
                    info.extension = '.mp4';
                    info.codec = 'H.264';
                    info.pros = {'高压缩比', '广泛兼容', '质量好'};
                    info.cons = {'编码时间长'};
                    
                case 'gif'
                    info.name = 'Animated GIF';
                    info.extension = '.gif';
                    info.codec = 'GIF87a/89a';
                    info.pros = {'网页友好', '无需播放器', '支持透明'};
                    info.cons = {'文件较大', '颜色限制256色'};
                    
                case 'avi'
                    info.name = 'Audio Video Interleave';
                    info.extension = '.avi';
                    info.codec = 'Uncompressed';
                    info.pros = {'无损质量', '编码快'};
                    info.cons = {'文件很大', '兼容性差'};
                    
                otherwise
                    error('未知的格式: %s', format);
            end
        end
    end
end

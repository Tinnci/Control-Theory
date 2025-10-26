%% Main Entry Point - Nyquist & Bode Animation CLI
% This is the main entry point for the CLI program
% Supports command-line parameters or interactive menu
% Usage examples:
%   matlab -batch "run_animation('bode', 'bode_test.mp4')"
%   matlab -batch "run_animation('nyquist', 'nyquist_test.gif')"

% Main execution starts here when script is run
clear variables; close all; clc;
addpath(pwd);

% Get animation type from environment or use default
anim_type = getenv('ANIM_TYPE');
if isempty(anim_type)
    anim_type = 'bode';  % Default
end

output_filename = getenv('OUTPUT_FILE');
if isempty(output_filename)
    output_filename = '';  % Auto-generate
end

print_header();

fprintf('[INFO] Animation type: %s\n', anim_type);
fprintf('[INFO] Output file: %s\n', output_filename);

% Execute corresponding animation generation
switch lower(anim_type)
    case 'bode'
        fprintf('[INFO] Generating Bode Diagram Animation...\n');
        generate_bode_animation(output_filename);
        
    case 'nyquist'
        fprintf('[INFO] Generating Nyquist Diagram Animation...\n');
        generate_nyquist_animation(output_filename);
        
    otherwise
        fprintf('[ERROR] Unknown animation type: %s\n', anim_type);
        exit(1);
end

fprintf('\n[SUCCESS] Program execution completed!\n');
exit(0);

%% Print header
function print_header()
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('  Nyquist & Bode Animation Generator\n');
    fprintf('  MATLAB 2025 CLI Version\n');
    fprintf('  Output: MP4 / GIF\n');
    fprintf('========================================\n');
    fprintf('\n');
end

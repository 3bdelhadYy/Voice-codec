%% Voice Codec Testing Script with Robust Figure Saving
% Fixed version with proper figure handling

clear all;
close all;
clc;

%% Configuration
audio_file = 'input_audio.wav'; % Replace with your audio file
test_duration = 20; % seconds
output_dir = 'codec_outputs';
figures_dir = 'report_figures';

% Create directories
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
if ~exist(figures_dir, 'dir')
    mkdir(figures_dir);
end

%% Improved Figure Saving Function
function saveCurrentFigure(figures_dir, figure_name)
    % Get all open figures
    figHandles = findobj('Type', 'figure');
    
    if ~isempty(figHandles)
        % Get the most recent figure
        current_fig = figHandles(1);
        
        % Set figure name and save
        set(current_fig, 'Name', figure_name);
        saveas(current_fig, fullfile(figures_dir, [figure_name '.png']));
        
        % Close the figure if needed
        close(current_fig);
    else
        warning('No figure to save for: %s', figure_name);
    end
end

%% Test 1: Noise-free tests
disp('=== Running Test 1: Noise-free tests ===');

% Parameters
fs_test1 = [40000, 20000, 5000];
L_test1 = [4, 8, 64];
encoding_types = {'unipolar', 'polar'};

% Load audio
[input_audio, Fs_orig] = audioread(audio_file);
input_audio = mean(input_audio, 2);
input_audio = input_audio(1:min(test_duration*Fs_orig, length(input_audio)));

for fs_idx = 1:length(fs_test1)
    for L_idx = 1:length(L_test1)
        for enc_type = 1:length(encoding_types)
            fprintf('\nTesting fs=%dHz, L=%d, %s encoding\n', ...
                fs_test1(fs_idx), L_test1(L_idx), encoding_types{enc_type});
            
            %% [1] Sampling
            [time_vector, sampled_signal, Fs] = sampler(input_audio, fs_test1(fs_idx), Fs_orig);
            saveCurrentFigure(figures_dir, sprintf('Sampling_fs%dHz', fs_test1(fs_idx)));
            
            %% [2] Quantization
            quantization_mode = 1;
            [quantized_signal, mse, bit_stream, mp_max, mp_min, R] = ...
                quantizer(sampled_signal, time_vector, L_test1(L_idx), quantization_mode);
            saveCurrentFigure(figures_dir, sprintf('Quantization_fs%dHz_L%d', fs_test1(fs_idx), L_test1(L_idx)));
            
            disp('First 10 bits:');
            disp(bit_stream(1:10));
            
            %% [3] Encoding
            A = 2;
            bit_rate = Fs * R;
            n = 10;
            [encoded_signal, enc_time_vector] = encoder(bit_stream, enc_type-1, A, bit_rate, R, Fs, n);
            saveCurrentFigure(figures_dir, sprintf('Encoding_fs%dHz_L%d_%s', fs_test1(fs_idx), L_test1(L_idx), encoding_types{enc_type}));
            
            %% [4] Decoding
            [restored_bit_stream, restored_quantized_signal] = decoder(...
                time_vector, encoded_signal, mp_max, mp_min, L_test1(L_idx), ...
                quantization_mode, enc_type-1, n, A);
            saveCurrentFigure(figures_dir, sprintf('Decoding_fs%dHz_L%d_%s', fs_test1(fs_idx), L_test1(L_idx), encoding_types{enc_type}));
            
            % Save audio
            output_filename = sprintf('%s/test1_fs%d_L%d_%s.wav', ...
                output_dir, fs_test1(fs_idx), L_test1(L_idx), encoding_types{enc_type});
            audiowrite(output_filename, restored_quantized_signal, Fs);
            
            fprintf('MSE: %.4f\n', mse);
        end
    end
end

%% Test 2: Noisy channel tests
disp('=== Running Test 2: Noisy channel tests ===');

fs_test2 = 40000;
L_test2 = 64;
N0_values = [1, 4, 16];
A_test2 = 2;

for enc_type = 1:length(encoding_types)
    for N0_idx = 1:length(N0_values)
        fprintf('\nTesting %s encoding with N0=%d\n', encoding_types{enc_type}, N0_values(N0_idx));
        
        %% [1] Sampling
        [time_vector, sampled_signal, Fs] = sampler(input_audio, fs_test2, Fs_orig);
        
        %% [2] Quantization
        quantization_mode = 1;
        [quantized_signal, mse, bit_stream, mp_max, mp_min, R] = ...
            quantizer(sampled_signal, time_vector, L_test2, quantization_mode);
        
        %% [3] Encoding
        bit_rate = Fs * R;
        n = 10;
        [encoded_signal, enc_time_vector] = encoder(bit_stream, enc_type-1, A_test2, bit_rate, R, Fs, n);
        
        %% [4] Noise Addition
        noisy_signal = AWGN(enc_time_vector, encoded_signal, N0_values(N0_idx), n);
        saveCurrentFigure(figures_dir, sprintf('NoisySignal_%s_N0%d', encoding_types{enc_type}, N0_values(N0_idx)));
        
        %% [5] Regeneration
        regenerated_signal = regenerator(noisy_signal, A_test2);
        saveCurrentFigure(figures_dir, sprintf('Regeneration_%s_N0%d', encoding_types{enc_type}, N0_values(N0_idx)));
        
        %% [6] Decoding
        [restored_bit_stream, restored_quantized_signal] = decoder(...
            time_vector, regenerated_signal, mp_max, mp_min, L_test2, ...
            quantization_mode, enc_type-1, n, A_test2);
        saveCurrentFigure(figures_dir, sprintf('NoisyDecoding_%s_N0%d', encoding_types{enc_type}, N0_values(N0_idx)));
        
        % Save audio
        output_filename = sprintf('%s/test2_%s_N0%d.wav', ...
            output_dir, encoding_types{enc_type}, N0_values(N0_idx));
        audiowrite(output_filename, restored_quantized_signal, Fs);
        
        fprintf('MSE: %.4f\n', mse);
    end
end

disp('=== All tests completed ===');
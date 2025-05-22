%% Decoder 
% Quantization mode
% 0 => Mid rise
% 1 => Mid tread
% Line codes
% 0 => NRZ Unipolar
% 1 => NRZ Polar

function [restored_bit_stream, restored_quantized_signal] = decoder(t, PCM_signal, mp_max, mp_min, L, quantization_mode, line_code, n, pulse_amplitude)

    % [1] Decoding the PCM -> bit stream
    restored_bit_stream = correlator_receiver(PCM_signal, n, line_code, pulse_amplitude);

    % [2] Dequantization
    delta = (mp_max - mp_min) / L;
    bit_frame_size = ceil(log2(L));

    if quantization_mode == 0  % Mid-rise
        min_q_level = mp_min + delta/2;
        max_q_level = mp_max - delta/2;
        quantization_levels = min_q_level : delta : max_q_level;

    elseif quantization_mode == 1  % Mid-tread
        min_q_level = mp_min + delta;
        max_q_level = mp_max;
        quantization_levels = min_q_level : delta : max_q_level;

    else
        error('Invalid quantization mode!');
    end  

    restored_q_levels_indices = bit2int(restored_bit_stream', bit_frame_size)' + 1;
    restored_quantized_signal = quantization_levels(restored_q_levels_indices);

    t_restored = linspace(t(1), t(end), length(restored_quantized_signal));
    figure;
    plot(t_restored, restored_quantized_signal);
    xlabel('t [sec]');
    ylabel('Amplitude');
    title('The Restored Quantized Signal');
    legend('Decoder Output');
end

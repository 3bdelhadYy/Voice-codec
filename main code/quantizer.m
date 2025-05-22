function [quantized_signal, mse, bit_stream, mp_max, mp_min, R] = quantizer(input_signal, t, L, quantization_mode)
    % QUANTIZER Quantizes input signal according to specified mode
    %
    % Inputs:
    %   input_signal      - The signal to be quantized
    %   t                 - Time vector for plotting
    %   L                 - Number of quantization levels
    %   quantization_mode - 0 for mid-rise, 1 for mid-tread
    %
    % Outputs:
    %   quantized_signal   - The quantized version of input signal
    %   mean_sqr_q_error   - Mean square quantization error
    %   bit_stream         - Binary representation of quantized signal
    %   mp_max             - Maximum amplitude (for decoder)
    %   mp_min             - Minimum amplitude (for decoder)
    %   R                  - Number of bits per sample
    
    mp_max = max(input_signal);
    mp_min = min(input_signal);   
    delta = (mp_max-mp_min)/L;

    if(quantization_mode == 0)  %mid rise

        min_q_level = mp_min + delta/2;
        max_q_level = mp_max - delta/2;
        quantization_levels = min_q_level : delta : max_q_level;
        
        modified_input_signal = max(min_q_level, min(input_signal,max_q_level));
        modified_input_signal = modified_input_signal + delta/2;
        
        index = indexLevels(modified_input_signal, delta);
        
    elseif (quantization_mode == 1)  %Mid tread
        min_q_level = mp_min+delta;
        max_q_level = mp_max;
        quantization_levels = min_q_level : delta : max_q_level;
        
        modified_input_signal = max(min_q_level, min(input_signal,max_q_level));
        
        index = indexLevels(modified_input_signal, delta);
    else
        error('Not valid');        
    end
    
    quantized_signal = quantization_levels(index); % quantized signal

    %figure of input signal and the quantized signal
    figure;
    plot(t, input_signal);
    hold on
    stairs(t,quantized_signal);
    legend('Input Signal', 'Quantized Signal');
    xlabel('t[sec]');
    ylabel('Amplitude');
    title('input signal vs. quantized signal');

    %the mean square quantization error
    % taking a ranged part from the signal for computational power
    mse = mean((input_signal(1:100) - quantized_signal(1:100)).^2);


    index = index-1;
    R = ceil(log2(L));

    bit_stream = int2bit(index,R);
    bit_stream = reshape(bit_stream, 1, numel(bit_stream));
    
    disp('First 10 bits of the bit stream:');
    display(bit_stream(1:10));
end

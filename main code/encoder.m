function [encoded_signal, time_vector] = encoder(bit_stream, encoding_type, A, bit_rate, R, fs, n)
%{
ENCODER PCM encoder using NRZ signaling.

Inputs:
    bit_stream      : Binary bit stream (vector of 0s and 1s)
    encoding_type   : 0 -> 'unipolar' or 1 -> 'polar'
    A               : Amplitude of the NRZ pulse
    bit_duration    : Duration of each bit (seconds)
    bit_rate        : frequency of bits
    R               : number bits
    fs              : sampling frequency
    n               : number of samples for each bit # samples/bits

Outputs:
    encoded_signal  : Encoded PCM signal
    time_vector     : Time axis of encoded signal
%}

    % n = #samples/bit (number of samples representing each bit)
    Tb = 1/bit_rate;    % Bit duration
    Ts = 1/fs;          % Sampling period

    if (Ts < R*Tb)
        warning("Not valid! The sampling period must be larger than the bit frame total duration!");
    end

    t_total = length(bit_stream) * Tb;  % Total time duration of all bits
    n_total = n * length(bit_stream);
    t_step = Tb / n;
    time_vector = 0 : t_step : t_total - t_step;
    
    encoded_signal = zeros(1, n_total);

    if(encoding_type == 0)  % NRZ Unipolar
        for i = 1:length(bit_stream)
            if (bit_stream(i) == 1)
                encoded_signal((i-1)*n + 1 : i*n) = A;  % '1' represented by A
            else
                encoded_signal((i-1)*n + 1 : i*n) = 0;  % '0' represented by 0
            end
        end
        figure_title = 'NRZ Unipolar Signal';
    
    elseif(encoding_type == 1)  % NRZ Polar
        for i = 1:length(bit_stream)
            if (bit_stream(i) == 1)
                encoded_signal((i-1)*n + 1 : i*n) = A;   % '1' represented by +A
            else
                encoded_signal((i-1)*n + 1 : i*n) = -A;  % '0' represented by -A
            end
        end
        figure_title = 'NRZ Polar Signal';
    end

    % Plot the first 20 bits
    figure;
    plot(time_vector(1:20*n), encoded_signal(1:20*n));
    xlabel('Time [sec]');
    ylabel('Amplitude');
    title(strcat(figure_title, ' (first 20 bits)'));
    legend('Encoder output');
    grid on;
end
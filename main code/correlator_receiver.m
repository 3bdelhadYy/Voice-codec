function [restored_bit_stream] = correlator_receiver(PCM_signal, n, line_code, pulse_amplitude)
    A = pulse_amplitude;
    num_bits = length(PCM_signal) / n;
    restored_bit_stream = zeros(1, num_bits);

    for i = 1 : n : length(PCM_signal) - n + 1
        pulse = PCM_signal(i:i+n-1);
        index = floor(i/n) + 1;

        avg_val = mean(pulse);

        if line_code == 0  % NRZ Unipolar
            if avg_val > A/2
                restored_bit_stream(index) = 1;
            else
                restored_bit_stream(index) = 0;
            end

        elseif line_code == 1  % NRZ Polar
            if avg_val > 0
                restored_bit_stream(index) = 1;
            else
                restored_bit_stream(index) = 0;
            end

        else
            error('Invalid line code!');
        end
    end
end

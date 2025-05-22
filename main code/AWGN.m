function [noisy_signal] = AWGN(t, signal, N0, n)
    signal_power = pow2db(mean(abs(signal).^2));

    snr = signal_power/N0;
    noisy_signal = awgn(signal,snr,signal_power);

    figure;
    plot(t(1: 10*n), noisy_signal(1 : 10*n));
    hold on
    xlabel('t [sec]');
    ylabel('Amplitude');
    title('Noisy PCM signal first 20 bits');
    legend('Channel output');
end
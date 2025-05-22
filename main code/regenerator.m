function [regenerated_signal] = regenerator(noisy_signal, pulse_amplitude)
% REGENERATOR Regenerates clean PCM signal from noisy NRZ signal.
%
% Inputs:
%   noisy_signal     : Noisy NRZ signal (vector)
%   pulse_amplitude  : Amplitude used in the original signal
%
% Output:
%   regenerated_signal : Cleaned up NRZ signal

    threshold = pulse_amplitude / 2;

    regenerated_signal = zeros(size(noisy_signal));
    regenerated_signal(noisy_signal > threshold) = pulse_amplitude;
    regenerated_signal(noisy_signal < -threshold) = -pulse_amplitude;

    % Plot
    figure;
    subplot(2,1,1);
    plot(noisy_signal(1:1000));
    title('Noisy Signal');

    subplot(2,1,2);
    plot(regenerated_signal(1:1000));
    title('Regenerated Signal');
end
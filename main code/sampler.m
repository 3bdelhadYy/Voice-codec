function [time_vector, sampled_signal, Fs] = sampler(input, fs, fm)
%{ 
SAMPLER Summary:
   Inputs : 
    input -> (Audio file)
    fs -> (sampling frequency)
    fm -> message frequency
   
   Outputs : 
    time_vector -> array from zero to signal time sampled at Ts = 1/Fs
    sampled_signal -> sampled signal using the sampling frequency
    Fs -> new sampling frequency
    

   Description:
    - The function takes the audio signal and splits into samples taken at
    a new sampling freq. ( Fs = fs/n ) where n is the downsampling factor
    (n= fm/fs). 
%}

    % downsample -> takes the input signals and samples it at fm/fs -> n
    n = round(fm/fs);
    sampled_signal = downsample(input,n);
    
    Fs = fm/n;

    duration = length(sampled_signal)/Fs;
    time_vector = linspace(0, duration, length(sampled_signal));
    

     % Plot original vs sampled (for report)
    figure;
    subplot(2,1,1);
    t_orig = linspace(0, length(sampled_signal)/Fs, length(input));
    plot(t_orig, input);
    title('Original Signal');
    xlabel('Time (s)'); ylabel('Amplitude');
    %xlim([1 1.44]);
    
    subplot(2,1,2);
    plot(time_vector, sampled_signal, Color="b");
    title(sprintf('Sampled at %d Hz', fs));
    xlabel('Time (s)'); ylabel('Amplitude');
    %xlim([1 1.44]);
end
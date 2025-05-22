function [level_indices] = indexLevels(input_signal, delta)
    % indexLevel - Uniform quantizer that maps amplitudes to level indices
    %
    % Inputs:
    %   input_signal - Array of input amplitudes to quantize
    %   delta        - Quantization step size (must be positive)
    %
    % Output:
    %   level_indices - Array of quantization level indices (1, 2, 3...)
    
    
    % Calculate initial thresholds
    threshold_steps = fix(input_signal / (delta/2));
    
    % Convert threshold crossings to level indices:
    % Odd steps are adjusted to even steps (quantization levels)
    is_odd = mod(threshold_steps, 2) ~= 0;
    threshold_steps(is_odd) = threshold_steps(is_odd) + sign(threshold_steps(is_odd));
    
    % Convert to sequential level indices (1, 2, 3...)
    level_indices = threshold_steps/2;  % Now all even numbers
    min_index = min(level_indices);
    
    % Ensure indices start at 1 if any were non-positive
    if min_index <= 0
        level_indices = level_indices - min_index + 1;
    end
    
    % Convert to integer type (more efficient for downstream processing)
    level_indices = int32(level_indices);
end
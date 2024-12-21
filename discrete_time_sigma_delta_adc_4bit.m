function [output, ax] = sigma_delta_adc_4bit(input, fs, N, V_max, pr, do_plot)
% input: input signal, handle or array
% fs: sampling rate
% N: number of sampling points
% V_max: maximum voltage to accept
% do_plot: logic value, whether to get 

if isa(input, "function_handle")
    % If a handle, produce a vector at the sampling rate of fs
    t = (0:N-1) / fs;
    input_signal = input(t);
else
    % If a vector, directly use it. Make sure to give a proper fs
    t = length(input); % We consider it has been sampled
    input_signal = input;
end

if nargin < 5
    pr = [1, length(input_signal)];
end
if nargin < 6
    do_plot = true; 
end

% Preallocation
integration = zeros(1, N);
quantization = zeros(1, N);
feedback = 0;
integration(1) = 0;

num_levels = 16;
level_width = 2 * V_max / num_levels; 

for n = 2:N
    integration(n) = integration(n-1) + input_signal(n) - feedback;

    level = floor(integration(n) / level_width);
    level = mod(level + 8, num_levels) - 8;

    quantization(n) = level; % Store the quantized level
    feedback = level * level_width; % Update feedback based on the quantization level
end

output = quantization; 

if do_plot
    ax = tiledlayout(5, 1);
    subplot(4, 1, 1);
    set(gcf, "position", [100, 25, 1000, 800])
    plot(t(pr(1):pr(2)), input_signal(pr(1):pr(2)));
    xlabel("Time");
    ylabel("Amplitude");
    title("Input Signal");
    ax_1 = gca;
    ax_1.TickLabelInterpreter = 'latex';

    subplot(4, 1, 2);
    plot(t(pr(1):pr(2)), integration(pr(1):pr(2)));
    xlabel("Time");
    ylabel("Amplitude");
    title("Integrator Output");
    ax_2 = gca;
    ax_2.TickLabelInterpreter = 'latex';

    subplot(4, 1, 3);
    stairs(t(pr(1):pr(2)), quantization(pr(1):pr(2)));
    xlabel("Time");
    ylabel("Quantization Level");
    title("Quantizer Output (4-bit)");    
    ax_3 = gca;
    ax_3.TickLabelInterpreter = 'latex';

    N_q = length(quantization);
    F_q = fftshift(fft(quantization)); % Calculate the FFT and shift
    f = linspace(-fs/2, fs/2 - fs/N_q, N_q);

    subplot(4, 1, 4);
    plot(f, abs(F_q) / length(F_q)); 
    xlabel("Frequency");
    ylabel("Amplitude");
    title("Output Spectrum");
    xticks(-fs/2:fs/8:fs/2)
    xticklabels(["$-\frac{1}{2}f_s$", "$-\frac{3}{8}f_s$", "$-\frac{1}{4}f_s$", "$-\frac{1}{8}f_s$", "0",...
                 "$\frac{1}{8}fs$", "$\frac{1}{4}fs$", "$\frac{3}{8}fs$", "$\frac{1}{2}fs$"]);
    ax_4 = gca;
    ax_4.TickLabelInterpreter = 'latex';
end
end

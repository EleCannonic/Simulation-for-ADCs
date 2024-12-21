function [output, ax] = sigma_delta_adc_1bit(input, fs, N, Vref, do_plot, plot_range)
% input: input signal, handle or array
% fs: sampling rate
% N: number of sampling points
% Vref: reference voltage
% do_plot: logic value, whether to get 

% Check the input parameters, give default value for reference voltage and
% define whether to plot the figures.
if nargin < 4 
    Vref = 0; % default voltage 0.
end
if nargin < 5
    do_plot = true; % default plotting
end
if nargin < 6
    plot_range = [1, N];
end

% Check the data type of the input signal.
if isa(input, "function_handle")
    % If a handle, produce a vector at the sampling rate of fs
    t = (0:N-1) / fs;
    input_signal = input(t);
else
    % If a vector, directly use it. Make sure to give a proper fs
    input_signal = input;
end

% preallocation
integration = zeros(1, N);
quantization = zeros(1, N);
feedback = 0;
integration(1) = Vref; % Initial value of integrator

for n = 2:N
    % sigma-delta modulation
    integration(n) = integration(n-1) + input_signal(n) - feedback;

    % quantization
    if integration(n) >= Vref
        quantization(n) = 1;
    else
        quantization(n) = 0;
    end
    
    % update the feedback to the latest value(quantizer output)
    feedback = quantization(n);
end

output = quantization;

if do_plot
    ax = figure;
    % set a larger size to make the figure clearer
    set(gcf, "position", [100, 50, 800, 600])
    subplot(4, 1, 1);
    plot(t(plot_range(1), plot_range(2)), input_signal(plot_range(1), plot_range(2)));
    xlabel("Sampling Points");
    ylabel("Amplitude");
    title("Input Signal");

    subplot(4, 1, 2);
    plot(t(plot_range(1), plot_range(2)), integration(plot_range(1), plot_range(2)));
    xlabel("Time");
    ylabel("Amplitude");
    title("Integrator Output");

    subplot(4, 1, 3);
    plot(t(plot_range(1), plot_range(2)), quantization(plot_range(1), plot_range(2)));
    xlabel("Time");
    ylabel("Amplitude");
    title("Quantizer Output");    

    N_q = length(quantization);
    F_q = fftshift(fft(quantization)); % Calculate the FFT and shift
    f = linspace(-fs/2, fs/2 - fs/N_q, N_q);

    subplot(4, 1, 4);
    plot(f, abs(F_q) / (fs/2));  % normalize the amplitude
    xlabel("Frequency");
    ylabel("Amplitude");
    title("Quantizer Output Spectrum");   
end
end

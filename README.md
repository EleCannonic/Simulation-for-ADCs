# Simulation-for-Sigma-Delta-ADCs

The files in this project simulates the behavior of discrete and continuous time sigma-delta analog to digital converters (ADC). 

For discrete time, we provided one-bit and 4-bit versions. If you need more bits, just modify the variable `num_levels` to $2^N$ ($N$ for your expected number of bits) in the function; For continuous time we only provided a multi-bit (5-bit) version. 

Please notice that these codes only achieve basic functions of ADC. High-level functions (including barrel shift DEM, phase/frequency detector, etc.) are not achieved in these functions. Besides, the only noise considered is the quantization noise. We have to emphasize that this project is just a brief introduction to the principles of sigma-delta ADC. For more details, you should read papers and try by yourself to deep dive into this field.

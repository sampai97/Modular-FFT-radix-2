clc;
clear;
close all;

N = 64;
omega = exp(-1i * 2 * pi / N);
delete twiddle_re.txt;
twiddle_fre = fopen("twiddle_re","wt");
delete twiddle_im.txt;
twiddle_fim = fopen("twiddle_im","wt");
for p = 1 : stages	%same cycles of an FFT but taking only twiddle factor
    for index = 0 : (N / (2^(p - 1))) : (N - 1)
        for n = 0 : M - 1
            print_twiddle = real(fi(omega^((2^(p - 1) * n)),1,15,13));
            fprintf(twiddle_fre,'"%s",\n',print_twiddle.bin);
            print_twiddle = imag(fi(omega^((2^(p - 1) * n)),1,15,13));
            fprintf(twiddle_fim,'"%s",\n',print_twiddle.bin);
        end
    end
    M = M / 2;
end

fclose(twiddle_fre);
fclose(twiddle_fim);

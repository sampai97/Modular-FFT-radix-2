clc;
clear;
close all;

fs = 20000;	%sampling frequency
f = fs/16;	%wave frequency
punti = 64;
sequenze = punti*157;  %random sequence duration
delete 'your_path/vhdl/wave_samples';
wave = fopen("your_path/vhdl/wave_samples","wt");
n = linspace(0,sequenze-1,sequenze);
xre = fi(exp(2i*pi*n*f/fs),1,15,13); %wave example

for i = 1:length(xre)
    re = real(xre(i));
    im = imag(xre(i));
    fprintf(wave,'%s\n%s\n',re.bin,im.bin); %real part and after immaginary part
end
fclose(wave);

function [pd1i,pd2i,p1i,p2i] = SIFT_code(y)
Y = fft(y);
Y_shift = fftshift(Y);
H = zeros(1,length(Y));
k = length(Y)*2/5;
H(length(Y_shift+1)/2-k:length(Y_shift+1)/2+k) = 1;
Y = Y_shift.*H';
out = ifft(Y);
for i = 1:length(out)
out(i) = real(out(i)*((-1)^i));
end
y1 = resample(out,1,5);
%y1 = y(1:10000; 
imf = 1;
L = 45;
R = 22;
% L = 1800;
% R = 450;
[pd1i,pd2i,p1i,p2i] = pitch_detect_lpc_shift(y1,2205,imf,L,R);
end
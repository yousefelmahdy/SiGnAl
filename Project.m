clc;
clear;

% m(t) = x1(t)cos(w1t) + x2(t)cos(w2t) + x3(t)sin(w2t) %
% instead of using three w i use two only by using cos and sin %
% read the signals with 20 seconds %
[x1, Fs1] = audioread('../Audios/Eftakart.wav');
[x2, Fs2] = audioread('../Audios/test2.wav');
[x3, Fs3] = audioread('../Audios/test.wav');

Fc1 = 1 * 1e4;
Fc2 = 1 * 5e3;
% To avoid aliasing, the value of Fs must satisfy Fs > 2(Fc + BW) %
Fs = 1 * 1e4 * 5;

% Modulation %

[y1, t1] = Modulation(x1, Fs, Fc1, 1);
[y2, t2] = Modulation(x2, Fs, Fc2, 1);
[y3, t3] = Modulation(x3, Fs, Fc2, 0);

y2(numel(y1)) = 0;
y3(numel(y1)) = 0;

% Get the modulated signal and plot it %

m = y1 + y2 + y3;

dt = 1/Fs;
t = (0:dt:(length(m)*dt)-dt)';

plot(t, m)
xlabel('Time')
ylabel('Modulated signal')
title('Modulated signal (time domain)')

plotSignalFreq(m, t, Fs,'b')
ylabel('Magnitude')
xlabel('Freq (in hertz)');
title('Modulated signal (frequency domain)');  

% Step (2): Demodulation % 

[num1,den1] = butter(10, Fc1*2/Fs);
[num2,den2] = butter(10, Fc2*2/Fs);

[z1, z2, z3] = demodulateSignals(y1, y2, y3, Fc1, Fc2, Fs, num1, den1, num2, den2, 0);
% sound(z1,Fs1)
%plotSignalFreq(x1, t1, Fs1,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('first original signal');  
%plotSignalFreq(x2, t2, Fs2,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('second original signal');  
%plotSignalFreq(x3, t3, Fs3,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('third original signal');  

%plotSignalFreq(z1, t, Fs1,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('first demodulated signal');  
%plotSignalFreq(z2, t, Fs2,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('second demodulated signal');  
%plotSignalFreq(z3, t, Fs3,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('third demodulated signal');  

% Demodulation with phase shifting %

[z1_10] = demodulateSignal(y1, Fc1, Fs, num1, den1, 10*pi/180);
[z1_30] = demodulateSignal(y1, Fc1, Fs, num1, den1, 30*pi/180);
[z1_90] = demodulateSignal(y1, Fc1, Fs, num1, den1, 90*pi/180);
%plotSignalFreq(z1_10, t, Fs1,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('10 demodulated signal'); 
%plotSignalFreq(z1_30, t, Fs1,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('30 demodulated signal'); 
%plotSignalFreq(z1_90, t, Fs1,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('90 demodulated signal'); 

% Demodulation with frequency difference %
[z1_freq2] = demodulateSignal(y1, Fc1+2, Fs, num1, den1, 0);
%plotSignalFreq(z1_freq2, t, Fs1,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('2 freq demodulated signal'); 
[z1_freq10] = demodulateSignal(y1, Fc1+10, Fs, num1, den1, 0);
%sound(z2,Fs2)
%plotSignalFreq(z1_freq10, t, Fs1,'b')
%ylabel('Magnitude')
%xlabel('Freq (in hertz)');
%title('10 freq demodulated signal'); 
% Functions %

function [y, t] = Modulation(x, Fs, Fc, type)
    dt = 1/Fs;
    t = (0:dt:(length(x)*dt)-dt)';
    
    w = 2 * pi * Fc;   
    if type
        y = x(:, 1) .* cos(w * t);
    else
        y = x(:, 1) .* sin(w * t);
    end
end

function [] = plotSignalFreq(x, t, Fs, color)
    % Frequency domain %
    N = size(t,1);
    % Fourier Transform %
    X = fftshift(fft(x));
    dF = Fs / N;  
    f = -Fs/2:dF:Fs/2-dF;             
    % Plotting the spectrum %
    figure
    plot(f,abs(X)/N, color);
end
% demodulation of one signal %

function [z1] = demodulateSignal(y1, Fc1, Fs, num1, den1, phase)
    z1 = amdemod(y1, Fc1, Fs, phase, 0, num1, den1);
end
% demodulation of all signals %
function [z1, z2, z3] = demodulateSignals(y1, y2, y3, Fc1, Fc2, Fs, num1, den1, num2, den2, phase)
    z1 = amdemod(y1, Fc1, Fs, phase, 0, num1, den1);
    z2 = amdemod(y2, Fc2, Fs, phase, 0, num2, den2);
    z3 = amdemod(y3, Fc2, Fs, phase+pi/2, 0, num2, den2);
end
function [X] = beep2
% Play a sine wave
res = 22050;
len = 0.2 * res;
hz = 220;
X = []
X(1,:) = sin( hz*(2*pi*(0:len)/res)*1000 ), res;
X(2,:) = sin( hz*(2*pi*(0:len)/res)*10 ), res;

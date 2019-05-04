function gen_tone(freq,duration)

amp=10;
fs=freq*10; % sampling frequency
%duration=2;
%freq=30000;
values=0:1/fs:duration;
a=amp*sin(2*pi*freq*values);
sound(a,fs)

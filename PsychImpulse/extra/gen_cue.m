function t = gen_cue(delay_period)
f0 = 5587;
Fs = f0*10;                             % Sampling Frequency (Hz)
Tmax = delay_period;                               % Duration (sec)
t = linspace(0, Tmax, Tmax*(Fs));    
f1 = 100;
Fs = 1/mean(diff(t));
x = chirp(t,f0,t(end),f1);
sound(x,Fs);
figure(1)
plot(t,x)


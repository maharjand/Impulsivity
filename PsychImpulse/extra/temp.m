Fs = 1500;                             % Sampling Frequency (Hz)
Tmax = 15;                               % Duration (sec)
t = linspace(0, Tmax, Tmax*(Fs+1)); % + 1 to deal with indexing issue
A = 100;
omega = 2;
s_t = t.^2/1;
y_t = A*cos(omega*t + s_t);
sound(y_t,15000)
figure(1)
plot(t, y_t,'o')

function sweep_cue3(delay_period)

F = 192000;                             % Sampling Frequency (Hz)
Tmax = 15;                               % Duration (sec)
t = linspace(0, Tmax, Tmax*(F));  
f1 = 150;
f0 = 4000;
Fs = 1/mean(diff(t));
x = chirp(t,f0,t(end),f1,'logarithmic', -pi/2);
if delay_period == 15
    sound(x(1:2879817),Fs);
    %plot(t(1:100),x(1:100))
else
    start = 192000*(15-delay_period);
    searchArea = x(start:start+10000);
    goalNum = 0;
    dif = abs(searchArea-goalNum);
    idx = find(dif == min(dif));
    sound(x(start+idx-1:2879817),Fs);
    %plot(t(1:100),x(start+idx-1:start+idx+98))
end
pause(delay_period)
%beep2



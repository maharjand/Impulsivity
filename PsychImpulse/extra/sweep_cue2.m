function sweep_cue2(delay_period)

Fs = 5000*1e1;                             % Sampling Frequency (Hz)
Tmax = delay_period;                               % Duration (sec)
t = linspace(0, Tmax, Tmax*(Fs));  
% if delay_period == 1
%     f0 = 200;
% elseif delay_period == 2 
%     f0 = 493.8833;
% elseif delay_period == 3 
%     f0 = 593.8833;
% elseif delay_period == 4 
%     f0 = 693.8833;
% elseif delay_period == 5 
%     f0 = 893.8833;
% elseif delay_period == 6 
%     f0 = 1093.8833;
% elseif delay_period == 7 
%     f0 = 1293.8833;
% elseif delay_period == 8 
%     f0 = 1493.8833;
% elseif delay_period == 9 
%     f0 = 1693.8833;
% elseif delay_period == 10 
%     f0 = 1893.8833;
% elseif delay_period == 11 
%     f0 = 2093.8833;
% elseif delay_period == 12 
%     f0 = 2293.8833;
% elseif delay_period == 13 
%     f0 = 2493.8833;
% elseif delay_period == 14 
%     f0 = 2693.8833;
% end    
    

f1 = 100;
Fs = 1/mean(diff(t));
x = chirp(t,f0,t(end),f1,'logarithmic');
sound(x,Fs)
figure(1)
plot(t,x)


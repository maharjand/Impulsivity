function delay_tone(delay_period)

A2 = 110; B3 = 246.942; C5 = 523.251; D6 = 1174.659; E7 = 2637.021; F8 = 5587.652 ; G9 = 12543.855;

if delay_period == 2
    gen_tone(A2,1);
elseif delay_period == 4 
    gen_tone(B3,1);pause(2);gen_tone(A2,1);
elseif delay_period == 6 
    gen_tone(C5,1);pause(2);gen_tone(B3,1);pause(2);gen_tone(A2,1);
elseif delay_period == 8 
    gen_tone(D6,1);pause(2);gen_tone(C5,1);pause(2);gen_tone(B3,1);pause(2);gen_tone(A2,1);
elseif delay_period == 10 
    gen_tone(E7,1);pause(2);gen_tone(D6,1);pause(2);gen_tone(C5,1);pause(2);gen_tone(B3,1);pause(2);gen_tone(A2,1);
elseif delay_period == 12 
    gen_tone(F8,1);pause(2);gen_tone(E7,1);pause(2);gen_tone(D6,1);pause(2);gen_tone(C5,1);pause(2);gen_tone(B3,1);pause(2);gen_tone(A2,1);
elseif delay_period == 14 
    gen_tone(G9,1);pause(2);gen_tone(F8,1);pause(2);gen_tone(E7,1);pause(2);gen_tone(D6,1);pause(2);gen_tone(C5,1);pause(2);gen_tone(B3,1);pause(2);gen_tone(A2,1);    
end
end
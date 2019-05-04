function PsychImpulse_training

%% Execute the code to run the psychometric impulsivity task training.This includes ...
%the choice to run both the training and the complete task protocols
  

global BpodSystem
global TaskParameters
PsychToolboxSoundServer('init')
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))

    TaskParameters.GUI.RewardAmountRight = 60;
    TaskParameters.GUI.RewardAmountLeft = 60;
    TaskParameters.GUI.Trial_time = 15;  
    TaskParameters.GUI.waitTarget = 10;
    TaskParameters.GUI.WaitReq = 0.2;
    TaskParameters.GUI.waitMin = .005;
    TaskParameters.GUI.waitIncr = 0.2;
    TaskParameters.GUI.waitDecr = .010;
    TaskParameters.GUI.SignalVolume = 50;
    TaskParameters.GUI.TimeRangeMax = 10;
end


BpodParameterGUI('init', TaskParameters)
%% Data vectors

BpodSystem.Data.Custom.NoChoice = NaN;
BpodSystem.Data.Custom.impulsiveAction = NaN;
BpodSystem.Data.Custom.ChoiceRight = NaN;
BpodSystem.Data.Custom.ChoiceLeft = NaN;
BpodSystem.Data.Custom.Rewarded = NaN;
BpodSystem.Data.Custom.RewardMagnitude = 0;
BpodSystem.Data.Custom.Wait = TaskParameters.GUI.WaitReq;
BpodSystem.Data.Custom.RewardAmountLeft = NaN;
BpodSystem.Data.Custom.RewardAmountRight = NaN;
BpodSystem.Data.Custom.WaitReq = datasample(1:TaskParameters.GUI.TimeRangeMax,1);
BpodSystem.Data.Custom.CumReward = zeros(1,TaskParameters.GUI.TimeRangeMax);
BpodSystem.Data.Custom.TimeTrialTotal = zeros(1,TaskParameters.GUI.TimeRangeMax);
BpodSystem.Data.Custom.PropCorrect = zeros(1,TaskParameters.GUI.TimeRangeMax);

%% Initialize plots
%BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', [200 200 1000 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
%BpodSystem.GUIHandles.SideOutcomePlot = axes('Position', [.075 .3 .89 .6]);
%PlotSideOutcome(BpodSystem.GUIHandles.SideOutcomePlot,'init',BpodSystem.Data.Custom.Baited);
%BpodNotebook('init');

%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    sma = stateMatrix(TaskParameters);
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
    
    updateCustomDataFields(iTrial);
    iTrial = iTrial + 1;
    BpodSystem.GUIHandles = SessionSummary(BpodSystem.Data, BpodSystem.GUIHandles, iTrial);
    %PlotSideOutcome(BpodSystem.GUIHandles.SideOutcomePlot,'update',iTrial);

end
end



function sma = stateMatrix(TaskParameters)
global BpodSystem

if length(BpodSystem.Data.Custom.Rewarded)>10
    
    numLeft = sum(BpodSystem.Data.Custom.ChoiceLeft(1:end-1));
    numRight = sum(BpodSystem.Data.Custom.ChoiceRight(1:end-1));
    percLeft = numLeft/(numLeft+numRight);
    BpodSystem.Data.Custom.RewardAmountLeft(end)=(1-percLeft)*2*TaskParameters.GUI.RewardAmountLeft;
    BpodSystem.Data.Custom.RewardAmountRight(end)=percLeft*2*TaskParameters.GUI.RewardAmountRight;
else    
    BpodSystem.Data.Custom.RewardAmountLeft(end)=TaskParameters.GUI.RewardAmountLeft;
    BpodSystem.Data.Custom.RewardAmountRight(end)=TaskParameters.GUI.RewardAmountRight;
end  
LValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountLeft(end), 1);
RValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountRight(end), 3);
%BpodSystem.Data.Custom.WaitReq(end) = datasample(1:TaskParameters.GUI.TimeRangeMax,1);
%Waveform1 = sweep(BpodSystem.Data.Custom.Wait(end));
Waveform1 = sweep(BpodSystem.Data.Custom.WaitReq(end));
grace=0.25;

Beep = beep2;
BpodSystem.Data.Custom.RewardAmountLeft(end+1) = nan;
BpodSystem.Data.Custom.RewardAmountRight(end+1) = nan;   
clear ValveTimes

PsychToolboxSoundServer('load', 1, Waveform1);
PsychToolboxSoundServer('load', 2, Beep);
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,TaskParameters.GUI.Trial_time);
%sma = SetGlobalTimer(sma,2,BpodSystem.Data.Custom.Wait(end));
sma = SetGlobalTimer(sma,2,BpodSystem.Data.Custom.WaitReq(end));
sma = AddState(sma, 'Name', 'state_0',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'center_hold'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'center_hold',...
    'Timer', 0,...
    'StateChangeConditions', {'Port2In', 'hassle'},...
    'OutputActions',{'PWM2',255});
sma = AddState(sma, 'Name', 'hassle',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'poke_in'},...
    'OutputActions',{'GlobalTimerTrig', 1});
sma = AddState(sma, 'Name', 'poke_in',...
    'Timer',0,... 
    'StateChangeConditions', {'Port2Out','grace_period','GlobalTimer2_End','choose_reward'},...
    'OutputActions',{'SoftCode', 1,'GlobalTimerTrig', 2}); 
sma = AddState(sma, 'Name', 'grace_period',...
    'Timer',grace,... 
    'StateChangeConditions', {'Port2In','recover','GlobalTimer2_End','choose_reward','Tup','break_hold'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'recover',...
    'Timer',0,... 
    'StateChangeConditions', {'GlobalTimer2_End','choose_reward','Port2Out','grace_period'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'choose_reward',...
    'Timer',0,...
    'StateChangeConditions', {'Port3In','water_R', 'Port1In','water_L','GlobalTimer1_End', 'exit'},...
    'OutputActions',{'SoftCode',2 ,'PWM3',255,'PWM1',255}); 
sma = AddState(sma, 'Name', 'break_hold',...
    'Timer',0,...
    'StateChangeConditions',{'Port1In','impulsive_action','Port3In', 'impulsive_action','GlobalTimer1_End', 'exit'},...
    'OutputActions',{'SoftCode', 255}); 
sma = AddState(sma, 'Name', 'impulsive_action',...
    'Timer',0,...
    'StateChangeConditions',{'GlobalTimer1_End', 'exit'},...
    'OutputActions',{'SoftCode', 255}); 
sma = AddState(sma, 'Name', 'end_game',...
    'Timer',20,...
    'StateChangeConditions',{'GlobalTimer1_End', 'exit'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'water_L',...
    'Timer', LValveTime,...
    'StateChangeConditions', {'Tup','end_game','GlobalTimer1_End', 'exit'},...
    'OutputActions', {'ValveState', 1,'SoftCode', 255});
sma = AddState(sma, 'Name', 'water_R',...
    'Timer', RValveTime,...
    'StateChangeConditions', {'Tup','end_game','GlobalTimer1_End', 'exit'},...
    'OutputActions', {'ValveState', 4});
end
%%
function signal = sweep(delay_period)

global BpodSystem %we need this for volume adjustment
global TaskParameters
%% abbreviate variable names and clip impossible values for better handling

F = 192000;                             % Sampling Frequency (Hz)
Tmax = 15;                               % Duration (sec)
t = linspace(0, Tmax, Tmax*(F));  
f1 = 10000;  %Min Freq
f0 = 15000;   % Max Freq
freqvec= linspace(f0, f1, Tmax*(F));
x = chirp(t,f0,t(end),f1,'logarithmic', -pi/2); % shifted to start x=0, prevent the 'pop' sound in the beginnning
    if delay_period == 15
        start = 1;
        idx = 1;

    else
        start = 192000*(15-delay_period); 
        searchArea = x(start:start+1000);
        goalNum = 0;
        dif = abs(searchArea-goalNum);
        idx = find(dif == min(dif)); % finding index to the nearest approx x=0 near the corresponding index for the given delay

        %sound(x(start+idx-1:749953),Fs);
    end
    
 waveform = x(start+idx-1:end);
 signal= [waveform;waveform];
    
    %adjust signal volume
    SoundCal = BpodSystem.CalibrationTables.SoundCal;
    if(isempty(SoundCal))
        disp('Error: no sound calibration file specified');
        return
    end
    if size(SoundCal,2)<2
        disp('Error: no two speaker sound calibration file specified');
        return
    end
    
    for s=1:2 %loop over two speakers
        toneAtt = polyval(SoundCal(1,s).Coefficient,freqvec);%Frequency dependent attenuation factor with less attenuation for higher frequency (based on calibration polynomial)
        %toneAtt = [polyval(SoundCal(1,1).Coefficient,toneFreq)' polyval(SoundCal(1,2).Coefficient,toneFreq)']; in Torben's script
        diffSPL = TaskParameters.GUI.SignalVolume - [SoundCal(1,s).TargetSPL];
        attFactor = sqrt(10.^(diffSPL./10)); %sqrt(10.^(diffSPL./10)) in Torben's script WHY sqrt?
        att = toneAtt.*attFactor;%this is the value for multiplying signal scaled/clipped to [-1 to 1]
        att = att(start+idx-1:end);
        signal(s,:)=signal(s,:).*att; %should the two speakers dB be added?
    end





end

function X = beep2
global BpodSystem
global TaskParameters
% Play a sine wave
res = 22050;
len = 5 * res;
hz = 320;
X = [];
X(1,:) = sin( hz*(2*pi*(0:len)/res)*100);
X(2,:) = sin( hz*(2*pi*(0:len)/res));
freqvec = 320*(ones(1,length(X)));

    
%adjust signal volume
     SoundCal = BpodSystem.CalibrationTables.SoundCal;
     if(isempty(SoundCal))
         disp('Error: no sound calibration file specified');
         return
     end
     if size(SoundCal,2)<2
         disp('Error: no two speaker sound calibration file specified');
         return
     end
%     
     for s=1:2 %loop over two speakers
         toneAtt = polyval(SoundCal(1,s).Coefficient,freqvec);%Frequency dependent attenuation factor with less attenuation for higher frequency (based on calibration polynomial)
%         %toneAtt = [polyval(SoundCal(1,1).Coefficient,toneFreq)' polyval(SoundCal(1,2).Coefficient,toneFreq)']; in Torben's script
         diffSPL = TaskParameters.GUI.SignalVolume - [SoundCal(1,s).TargetSPL];
         attFactor = sqrt(10.^(diffSPL./10)); %sqrt(10.^(diffSPL./10)) in Torben's script WHY sqrt?
         att = toneAtt.*attFactor;%this is the value for multiplying signal scaled/clipped to [-1 to 1]
         X(s,:)=X(s,:).*att; %should the two speakers dB be added?
     end
     end
     

function updateCustomDataFields(iTrial,WaitReq)
global BpodSystem
global TaskParameters
%% OutcomeRecord

statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});
finalState = statesThisTrial(end);
if any(strcmp('choose_reward',finalState))||any(strcmp('break_hold',finalState))
    BpodSystem.Data.Custom.NoChoice(end) = 1;
else
    BpodSystem.Data.Custom.NoChoice(end) = 0;
end

if any(strcmp('impulsive_action',statesThisTrial))
    BpodSystem.Data.Custom.impulsiveAction(end) = 1;
else
    BpodSystem.Data.Custom.impulsiveAction(end) = 0;
end

if any(strcmp('water_R',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceRight(end) = 1;
    BpodSystem.Data.Custom.ChoiceLeft(end) = 0; 
    BpodSystem.Data.Custom.Rewarded(end) = 1;
    BpodSystem.Data.Custom.RewardMagnitude = BpodSystem.Data.Custom.RewardMagnitude + BpodSystem.Data.Custom.RewardAmountRight(end-1);
elseif any(strcmp('water_L',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceRight(end) = 0;
    BpodSystem.Data.Custom.ChoiceLeft(end) = 1;  
    BpodSystem.Data.Custom.Rewarded(end) = 1;
    BpodSystem.Data.Custom.RewardMagnitude = BpodSystem.Data.Custom.RewardMagnitude + BpodSystem.Data.Custom.RewardAmountLeft(end-1);
else
    BpodSystem.Data.Custom.ChoiceRight(end) = 0;
    BpodSystem.Data.Custom.ChoiceLeft(end) = 0;  
    BpodSystem.Data.Custom.Rewarded(end) = 0;
end

%% Waiting (fixation) time
if any(strcmp('end_game',statesThisTrial))
    BpodSystem.Data.Custom.Wait(end+1) = BpodSystem.Data.Custom.Wait(end)+TaskParameters.GUI.waitIncr;
    BpodSystem.Data.Custom.Wait(end) = min(BpodSystem.Data.Custom.Wait(end),TaskParameters.GUI.waitTarget);
else
    BpodSystem.Data.Custom.Wait(end+1) = BpodSystem.Data.Custom.Wait(end)-TaskParameters.GUI.waitDecr;
    BpodSystem.Data.Custom.Wait(end) = max(BpodSystem.Data.Custom.Wait(end),0);
   
end

if BpodSystem.Data.Custom.Rewarded(end) == 1
    BpodSystem.Data.Custom.WaitReq(end+1) =  datasample(1:TaskParameters.GUI.TimeRangeMax,1);
else
    BpodSystem.Data.Custom.WaitReq(end+1) = BpodSystem.Data.Custom.WaitReq(end);
end
BpodSystem.Data.Custom.NoChoice(end+1) = nan;
BpodSystem.Data.Custom.impulsiveAction(end+1) = NaN;
BpodSystem.Data.Custom.ChoiceRight(end+1) = NaN;
BpodSystem.Data.Custom.ChoiceLeft(end+1) = nan;
BpodSystem.Data.Custom.Rewarded(end+1) = nan;

end
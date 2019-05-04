function PsychImpulse

%% Execute the code to run the psychometric impulsivity task.This includes ...
%the choice to run both the training and the complete task protocols
  

global BpodSystem
global TaskParameters
PsychToolboxSoundServer('init')
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))

    TaskParameters.GUI.RewardAmountRight = 4;
    TaskParameters.GUI.RewardAmountLeft = 1;
    TaskParameters.GUI.Trial_time = 20;  
    
end

BpodParameterGUI('init', TaskParameters);
%% Data vectors

BpodSystem.Data.Custom.NoChoice = NaN;
BpodSystem.Data.Custom.impulsiveAction = NaN;
BpodSystem.Data.Custom.ChoiceRight = NaN;
BpodSystem.Data.Custom.ChoiceLeft = NaN;
BpodSystem.Data.Custom.Rewarded = NaN;
BpodSystem.Data.Custom.RewardMagnitude = 0;

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

end
end


function sma = stateMatrix(iTrial)
global BpodSystem
global TaskParameters
LValveTime  = GetValveTimes(TaskParameters.GUI.RewardAmountRight, 3);
RValveTime  = GetValveTimes(TaskParameters.GUI.RewardAmountLeft, 1);
WaitReq = datasample([1 2 3 4 5 6 7 8 9 10 11 12 13 14],1);
Waveform1 = sweep(WaitReq);
Beep = beep2;
clear ValveTimes

PsychToolboxSoundServer('load', 1, Waveform1);
PsychToolboxSoundServer('load', 2, Beep);
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,TaskParameters.GUI.Trial_time);
sma = AddState(sma, 'Name', 'state_0',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'center_ready'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'center_ready',...
    'Timer', 0,...
    'StateChangeConditions', {'Port2In', 'center_hold'},...
    'OutputActions', {'PWM2',255});
sma = AddState(sma, 'Name', 'center_hold',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'side_ready'},...
    'OutputActions',{'SoftCode', 1});
sma = AddState(sma, 'Name', 'side_ready',...
    'Timer',WaitReq,... % added lag time
    'StateChangeConditions', {'Port1In','water_L','Port2Out','break_hold','Tup' 'choose_reward'},...
    'OutputActions',{'PWM1',255,'GlobalTimerTrig', 1}); % Add stimuli sounds here
sma = AddState(sma, 'Name', 'choose_reward',...
    'Timer',0,...
    'StateChangeConditions', {'Port3In','water_R', 'Port1In','water_L','GlobalTimer1_End', 'exit'},...
    'OutputActions',{'SoftCode',2 ,'PWM3',255,'PWM1',255}); % Add go tone
sma = AddState(sma, 'Name', 'break_hold',...
    'Timer',0,...
    'StateChangeConditions',{'Port1In','water_L','Port3In', 'impulsive_action','GlobalTimer1_End', 'exit'},...
    'OutputActions',{'PWM1',255,'SoftCode', 255}); 
sma = AddState(sma, 'Name', 'impulsive_action',...
    'Timer',0,...
    'StateChangeConditions',{'GlobalTimer1_End', 'exit'},...
    'OutputActions',{'SoftCode', 255}); 
sma = AddState(sma, 'Name', 'end_game',...
    'Timer',0,...
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
function waveform = sweep(delay_period)

F = 192000;                             % Sampling Frequency (Hz)
Tmax = 15;                               % Duration (sec)
t = linspace(0, Tmax, Tmax*(F));  
f1 = 150;
f0 = 4000;
x = chirp(t,f0,t(end),f1,'logarithmic', -pi/2); % shifted to start x=0, prevent the 'pop' sound in the beginnning
    if delay_period == 15
        waveform = x(1:2879817);
     %    sound(x,Fs);
    else
        start = 192000*(15-delay_period); 
        searchArea = x(start:start+1000);
        goalNum = 0;
        dif = abs(searchArea-goalNum);
        idx = find(dif == min(dif)); % finding index to the nearest approx x=0 near the corresponding index for the given delay
        waveform = x(start+idx-1:2879817);
        %sound(x(start+idx-1:749953),Fs);
    end
end

function X = beep2
% Play a sine wave
res = 22050;
len = 5 * res;
hz = 420;
X = [];
X(1,:) = sin( hz*(2*pi*(0:len)/res)*10000);
X(2,:) = sin( hz*(2*pi*(0:len)/res));
end

function updateCustomDataFields(iTrial)
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
    BpodSystem.Data.Custom.RewardMagnitude = BpodSystem.Data.Custom.RewardMagnitude + TaskParameters.GUI.RewardAmountRight;
elseif any(strcmp('water_L',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceRight(end) = 0;
    BpodSystem.Data.Custom.ChoiceLeft(end) = 1;  
    BpodSystem.Data.Custom.Rewarded(end) = 1;
    BpodSystem.Data.Custom.RewardMagnitude = BpodSystem.Data.Custom.RewardMagnitude + TaskParameters.GUI.RewardAmountLeft;
else
    BpodSystem.Data.Custom.ChoiceRight(end) = 0;
    BpodSystem.Data.Custom.ChoiceLeft(end) = 0;
    BpodSystem.Data.Custom.Rewarded(end) = 0;
end


BpodSystem.Data.Custom.NoChoice(end+1) = nan;
BpodSystem.Data.Custom.impulsiveAction(end+1) = NaN;
BpodSystem.Data.Custom.ChoiceRight(end+1) = NaN;
BpodSystem.Data.Custom.ChoiceLeft(end+1) = nan;
BpodSystem.Data.Custom.Rewarded(end+1) = NaN;


end
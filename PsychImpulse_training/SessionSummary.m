function GUIHandles = SessionSummary(Data, GUIHandles, iTrial)

global BpodSystem
global TaskParameters

nTrialsToShow = 90; %default
Rewarded = Data.Custom.Rewarded;
if iTrial == 2
%% Outcome plot

    GUIHandles.Figs.MainFig = figure('Position', [200 200 1000 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    GUIHandles.Axes.OutcomePlot.MainHandle = axes('Position', [.06 .15 .91 .3]);
    GUIHandles.Axes.TrialRate.MainHandle = axes('Position', [[1 0]*[.06;.12] .6 .12 .3]);
    GUIHandles.Axes.ChoiceProp.MainHandle = axes('Position', [[2 1]*[.06;.12] .6 .12 .3]);
    axes(GUIHandles.Axes.OutcomePlot.MainHandle)
    GUIHandles.Axes.OutcomePlot.CurrentTrialCircle = line(-1,0.5, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.CurrentTrialCross = line(-1,0.5, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.CurrentWaitDuration = text(1,0.5, 'BpodSystem.Data.Custom.WaitReq(end)'+'ml', 'verticalalignment','bottom','horizontalalignment','center');
    GUIHandles.Axes.OutcomePlot.LeftReward = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.RightReward = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.NoResponse = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.impulsiveAction = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','none', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
    set(GUIHandles.Axes.OutcomePlot.MainHandle,'TickDir', 'out','YLim', [-1, 2],'XLim',[0,nTrialsToShow], 'YTick', [0 1],'YTickLabel', {'Right','Left'}, 'FontSize', 16);
    xlabel(GUIHandles.Axes.OutcomePlot.MainHandle, 'Trial#', 'FontSize', 18);
    hold(GUIHandles.Axes.OutcomePlot.MainHandle, 'on');
    
    %% Trial rate
    hold(GUIHandles.Axes.TrialRate.MainHandle,'on')
    GUIHandles.Axes.TrialRate.TrialRate = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color','k','Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.TrialRateL = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[254,178,76]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.TrialRateR = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[49,163,84]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.MainHandle.XLabel.String = 'Time (min)';
    GUIHandles.Axes.TrialRate.MainHandle.YLabel.String = 'nTrials';
    GUIHandles.Axes.TrialRate.MainHandle.Title.String = 'Trial rate';
    
    %% Choice Proportions 
    hold(GUIHandles.Axes.ChoiceProp.MainHandle,'on')
    GUIHandles.Axes.ChoiceProp.ChoiceProp = line(GUIHandles.Axes.ChoiceProp.MainHandle,[0 1],[0 1], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6);
    GUIHandles.Axes.ChoiceProp.Boundary = line(GUIHandles.Axes.ChoiceProp.MainHandle,[0 1],[0 1], 'LineStyle','--','Color','k','Visible','on','linewidth',3);
    GUIHandles.Axes.ChoiceProp.Boundary.XData = 1:10;
    GUIHandles.Axes.ChoiceProp.Boundary.YData = ones(1,10)*0.75;
    GUIHandles.Axes.ChoiceProp.MainHandle.XLabel.String = 'Trial Time (sec)';
    GUIHandles.Axes.ChoiceProp.MainHandle.YLabel.String = 'Prop Correct';
    GUIHandles.Axes.ChoiceProp.MainHandle.Title.String = 'Correct Choice Proportion';
    set(GUIHandles.Axes.ChoiceProp.MainHandle,'YLim', [0,1],'XLim',[0,10]);
end
% Outcome
[mn, ~] = rescaleX(GUIHandles.Axes.OutcomePlot.MainHandle,iTrial,nTrialsToShow); % recompute xlim
    
set(GUIHandles.Axes.OutcomePlot.CurrentTrialCircle, 'xdata', iTrial, 'ydata', 0.5);
set(GUIHandles.Axes.OutcomePlot.CurrentTrialCross, 'xdata', iTrial, 'ydata', 0.5);
set(GUIHandels.Axes.OutcomePlot.CurrentWaitDuration, 'position',[iTrail+3 0.5], 'string', [BpodSystem.Data.Custom.WaitReq(end) ' sec']);     
    %Plot past trials
    ChoiceLeft = Data.Custom.ChoiceLeft;
    ChoiceRight = Data.Custom.ChoiceRight;
    impulsiveAction = Data.Custom.impulsiveAction;
    NoChoice = Data.Custom.NoChoice;
    if ~isempty(Rewarded)
        indxToPlot = mn:iTrial-1;
        
        ndxRwd = ChoiceLeft(indxToPlot) == 1;
        Xdata = indxToPlot(ndxRwd);
        Ydata = ChoiceLeft(indxToPlot); Ydata = Ydata(ndxRwd);
        set(GUIHandles.Axes.OutcomePlot.LeftReward, 'xdata', Xdata, 'ydata', Ydata);
        
        ndxRwd = ChoiceRight(indxToPlot) == 1;
        Xdata = indxToPlot(ndxRwd);
        Ydata = ChoiceLeft(indxToPlot); Ydata = Ydata(ndxRwd);
        set(GUIHandles.Axes.OutcomePlot.RightReward, 'xdata', Xdata, 'ydata', Ydata);
        
        ndxUrwd = impulsiveAction(indxToPlot) == 1;
        Xdata = indxToPlot(ndxUrwd);
        Ydata = ones(size(Xdata))*.5;
        set(GUIHandles.Axes.OutcomePlot.impulsiveAction, 'xdata', Xdata, 'ydata', Ydata);
        
        ndxNocho = NoChoice(indxToPlot)== 1 ;
        Xdata = indxToPlot(ndxNocho);
        Ydata = ones(size(Xdata))*.5;
        set(GUIHandles.Axes.OutcomePlot.NoResponse, 'xdata', Xdata, 'ydata', Ydata);
        
    end

    %Cumulative Reward Amount
    R = Data.Custom.RewardMagnitude;
    %ndxRwd = Data.Custom.Rewarded;
    %C = zeros(size(R)); C(Data.Custom.ChoiceLeft==1&ndxRwd,1) = 1; C(Data.Custom.ChoiceLeft==0&ndxRwd,2) = 1;
    %R = R.*C;
    set(GUIHandles.Axes.OutcomePlot.CumRwd, 'position', [iTrial+1 1], 'string', ...
        [num2str(R/1000) ' mL']);
    clear R 
    
%% Trial rate
    GUIHandles.Axes.TrialRate.TrialRate.XData = (Data.TrialStartTimestamp-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRate.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRate.XData);
    ndxCho = Data.Custom.ChoiceLeft(:)==1;
    GUIHandles.Axes.TrialRate.TrialRateL.XData = (Data.TrialStartTimestamp(ndxCho)-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRateL.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRateL.XData);
    ndxCho = Data.Custom.ChoiceLeft(:)==0;
    GUIHandles.Axes.TrialRate.TrialRateR.XData = (Data.TrialStartTimestamp(ndxCho)-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRateR.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRateR.XData);
    
%% ChoiceProp

    BpodSystem.Data.Custom.CumReward(BpodSystem.Data.Custom.WaitReq(end-1)) = BpodSystem.Data.Custom.CumReward(BpodSystem.Data.Custom.WaitReq(end-1)) + BpodSystem.Data.Custom.Rewarded(end-1);
    BpodSystem.Data.Custom.TimeTrialTotal(BpodSystem.Data.Custom.WaitReq(end-1)) = BpodSystem.Data.Custom.TimeTrialTotal(BpodSystem.Data.Custom.WaitReq(end-1)) +1;
    BpodSystem.Data.Custom.PropCorrect(BpodSystem.Data.Custom.WaitReq(end-1)) = BpodSystem.Data.Custom.CumReward(BpodSystem.Data.Custom.WaitReq(end-1))./BpodSystem.Data.Custom.TimeTrialTotal(Data.Custom.WaitReq(end-1));
    GUIHandles.Axes.ChoiceProp.ChoiceProp.XData = 1:TaskParameters.GUI.TimeRangeMax;
    GUIHandles.Axes.ChoiceProp.ChoiceProp.YData = Data.Custom.PropCorrect;
    
end
function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end

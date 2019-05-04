function GUIHandles = SessionSummary(Data, GUIHandles, iTrial)

global BpodSystem
global TaskParameters

nTrialsToShow = 90; %default
Rewarded = Data.Custom.Rewarded;
if iTrial == 2
%% Outcome plot
    GUIHandles.Figs.MainFig = figure('Position', [200 200 1000 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    GUIHandles.Axes.OutcomePlot.MainHandle = axes('Position', [.075 .3 .89 .6]);
    axes(GUIHandles.Axes.OutcomePlot.MainHandle)
    GUIHandles.Axes.OutcomePlot.CurrentTrialCircle = line(-1,0.5, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.CurrentTrialCross = line(-1,0.5, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.LeftReward = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.RightReward = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.NoResponse = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.impulsiveAction = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','none', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
    set(GUIHandles.Axes.OutcomePlot.MainHandle,'TickDir', 'out','YLim', [-1, 2],'XLim',[0,nTrialsToShow], 'YTick', [0 1],'YTickLabel', {'Right','Left'}, 'FontSize', 16);
    xlabel(GUIHandles.Axes.OutcomePlot.MainHandle, 'Trial#', 'FontSize', 18);
    hold(GUIHandles.Axes.OutcomePlot.MainHandle, 'on');
end
    
% Outcome
[mn, ~] = rescaleX(GUIHandles.Axes.OutcomePlot.MainHandle,iTrial,nTrialsToShow); % recompute xlim
    
set(GUIHandles.Axes.OutcomePlot.CurrentTrialCircle, 'xdata', iTrial, 'ydata', 0.5);
set(GUIHandles.Axes.OutcomePlot.CurrentTrialCross, 'xdata', iTrial, 'ydata', 0.5);
    
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
        Ydata = ChoiceLeft(indxToPlot); Ydata = Ydata(ndxUrwd);
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
        [num2str(sum(R(:))/1000) ' mL']);
    clear R 
end
function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end

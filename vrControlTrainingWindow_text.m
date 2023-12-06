classdef vrControlTrainingWindow < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        TotalRewardEditField           matlab.ui.control.NumericEditField
        TotalRewardEditFieldLabel      matlab.ui.control.Label
        elapsedTime                    matlab.ui.control.EditField
        ElapsedTimeEditFieldLabel      matlab.ui.control.Label
        totalDistance                  matlab.ui.control.NumericEditField
        TotalDistancecmEditFieldLabel  matlab.ui.control.Label
        TrialParametersPanel           matlab.ui.container.Panel
        maxTrialDuration               matlab.ui.control.NumericEditField
        MDurEditFieldLabel             matlab.ui.control.Label
        environmentSelection           matlab.ui.control.DropDown
        EnvironmentDropDownLabel       matlab.ui.control.Label
        trialNumber                    matlab.ui.control.NumericEditField
        envIdx                         matlab.ui.control.NumericEditField
        minimumITI                     matlab.ui.control.NumericEditField
        startButton                    matlab.ui.control.Button
        envLength                      matlab.ui.control.NumericEditField
        mvmtGain                       matlab.ui.control.NumericEditField
        rewardPosition                 matlab.ui.control.NumericEditField
        rewardTolerance                matlab.ui.control.NumericEditField
        probReward                     matlab.ui.control.NumericEditField
        rewardAvailable                matlab.ui.control.NumericEditField
        minimumITILabel                matlab.ui.control.Label
        rewardAvailableLabel           matlab.ui.control.Label
        probRewardLabel                matlab.ui.control.Label
        movementGainLabel              matlab.ui.control.Label
        rewardToleranceLabel           matlab.ui.control.Label
        rewardPositionLabel            matlab.ui.control.Label
        envLengthLabel                 matlab.ui.control.Label
        envIdxLabel                    matlab.ui.control.Label
        trialNumberLabel               matlab.ui.control.Label
        ActiveLickingPanel             matlab.ui.container.Panel
        lickIndicator                  matlab.ui.control.Lamp
        lickIndicatorLabel             matlab.ui.control.Label
        lickRequired                   matlab.ui.control.Switch
        lickPerformed                  matlab.ui.control.Lamp
        lickPerformedLabel             matlab.ui.control.Label
        ActiveStoppingPanel            matlab.ui.container.Panel
        stopDuration                   matlab.ui.control.NumericEditField
        stopDurationLabel              matlab.ui.control.Label
        stopRequired                   matlab.ui.control.Switch
        stopPerformed                  matlab.ui.control.Lamp
        stopPerformedLabel             matlab.ui.control.Label
        mousePositionPanel             matlab.ui.container.Panel
        rewardZone                     matlab.ui.control.EditField
        mousePosition                  matlab.ui.control.LinearGauge
        environmentPreviewPanel        matlab.ui.container.Panel
        environmentPreview             matlab.ui.control.UIAxes
        mouseSpeedPanel                matlab.ui.container.Panel
        speedConstant                  matlab.ui.control.NumericEditField
        SpeedConstantEditFieldLabel    matlab.ui.control.Label
        mouseSpeed                     matlab.ui.control.LinearGauge
    end

    
    properties (Access = private)
        rigInfo
        rewardZoneBasePosition = [7, 0, 581, 58];
        lampOffColor = [1,0,0];
        lampOnColor = [0,1,0];
        lampInactiveColor = 0.3*[1,1,1];
        rewardZoneActiveColor = 0.3*[1,1,1];
        rewardZoneDeliveredColor = [0,1,0];
        valuesUpdated = false; % flag that becomes true if anything changes - false again when reset on next trial
        elapsedTimer
        speedEstimate
        speedEstTime = 0 % Description
    end

    properties (Access = public)
        timelineActive = false;
    end
    
    methods (Access = public)
        
        function enableStart(app)
            app.startButton.Text = 'start';
            app.startButton.Enable = "on";
            app.startButton.BackgroundColor = 'y';
            app.timelineActive = false;
            drawnow();
        end

        function disenableStart(app)
            app.startButton.Enable = "off";
            app.startButton.BackgroundColor = 'w';
            app.startButton.Text = 'active';
            drawnow();
        end

        function showRewardZone(app, pos, tol)
            rewZoneFeatures = [pos-tol 2*tol];
            rewZoneRelative = rewZoneFeatures / app.envLength.Value;
            rewZonePosition = app.rewardZoneBasePosition(1) + rewZoneRelative*diff(app.rewardZoneBasePosition([1 3]));
            app.rewardZone.Position([1 3]) = rewZonePosition;
            app.rewardZone.Visible = "on";
            drawnow()
        end

        function clearRewardZone(app)
            app.rewardZone.Visible = "off";
            app.mousePositionPanel.Title = 'Mouse Position (cm) - No Reward Available';
            drawnow()
        end

        function rewardState(app, delivered)
            if delivered
                app.rewardZone.BackgroundColor = app.rewardZoneDeliveredColor;
                app.mousePositionPanel.Title = 'Mouse Position (cm) - Reward Delivered';
            else
                app.rewardZone.BackgroundColor = app.rewardZoneActiveColor;
                app.mousePositionPanel.Title = 'Mouse Position (cm) - Reward Available';
            end
            drawnow()
        end
        
        function printPreview(app, image)
            imSize = size(image); % assume it's in y,x,color
            centerIndex = round(imSize(2)*[1/3 2/3]);
            xlims = centerIndex + [-0.5 0.5];
            ylims = [0.5 imSize(1)+0.5];
            imagesc(app.environmentPreview, image);
            app.environmentPreview.XLim = xlims;
            app.environmentPreview.YLim = ylims;
            drawnow()
        end

        function clearPreview(app)
            xlims = app.environmentPreview.XLim;
            ylims = app.environmentPreview.YLim;
            imagesc(app.environmentPreview, 255*ones(ylims(2)-0.5,xlims(2)-0.5,3,'uint8'));
            drawnow()
        end
        
        function updateLickLamp(app, state)
            if app.lickRequired.Value
                if state
                    app.lickPerformed.Color = app.lampOnColor;
                else
                    app.lickPerformed.Color = app.lampOffColor;
                end
            else
                app.lickPerformed.Color = app.lampInactiveColor;
            end
            drawnow()
        end

        function updateStopLamp(app, state)
            if app.stopRequired.Value
                if state
                    app.stopPerformed.Color = app.lampOnColor;
                else
                    app.stopPerformed.Color = app.lampOffColor;
                end
            else
                app.stopPerformed.Color = app.lampInactiveColor;
            end
            drawnow()
        end

        function updateLickIndicator(app, state)
            if state
                app.lickIndicator.Color = 'g';
            else
                app.lickIndicator.Color = 'k';
            end
        end

        function updatePosition(app, position, movement)
            app.mousePosition.Value = position;
            app.totalDistance.Value = app.totalDistance.Value + movement;
            drawnow();
        end

        function updateSpeed(app, speed)
            app.speedEstimate = speed;
%             ctime = toc(app.elapsedTimer);
%             if (ctime - app.speedEstTime) > app.speedConstant
%                 app.speedEstimate = speed;
%             else
%                 changeEstimate = (ctime - app.speedEstTime) / app.speedConstant.Value * (speed - app.speedEstimate);
%                 app.speedEstimate = app.speedEstimate + changeEstimate;
%             end
%             app.speedEstTime = ctime;
            app.mouseSpeed.Value = app.speedEstimate;
            drawnow();
        end
        
        function updateTrial(app)
            elTime = seconds(toc(app.elapsedTimer));
            elTime.Format = 'mm:ss';
            app.elapsedTime.Value = sprintf('%s',elTime);
            
            updateLickLamp(app,0);
            updateStopLamp(app,0);
            app.mousePosition.Limits = [0 app.envLength.Value];
            app.mousePosition.MajorTicks = linspace(0, app.envLength.Value, 11);
            app.mousePosition.Value = 0; 
            app.mouseSpeed.Value = 0;
            if app.rewardAvailable.Value
                showRewardZone(app, app.rewardPosition.Value, app.rewardTolerance.Value)
                rewardState(app, 0)
            else
                clearRewardZone(app)
            end
            updateLickIndicator(app, 0)
            drawnow()
        end
        
        function valueUpdated(app, flag)
            app.valuesUpdated = flag;
            if flag
                app.TrialParametersPanel.Title = 'Trial Parameters -- Values Changed, Will Update On Next Trial'; 
                app.TrialParametersPanel.BackgroundColor = [0.98, 0.84, 0.84];
                app.ActiveLickingPanel.BackgroundColor = [0.98, 0.84, 0.84];
                app.ActiveStoppingPanel.BackgroundColor = [0.98, 0.84, 0.84];
            else
                app.TrialParametersPanel.Title = 'Trial Parameters'; 
                app.TrialParametersPanel.BackgroundColor = [1, 1, 1];
                app.ActiveLickingPanel.BackgroundColor = [1, 1, 1];
                app.ActiveStoppingPanel.BackgroundColor = [1, 1, 1];
            end                
        end
        
        function setAvailableEnvironments(app, envIndex, getEnvNames)
            numEnvironments = length(envIndex);
            app.environmentSelection.Items = repmat({''}, numEnvironments, 1);
            app.environmentSelection.ItemsData = envIndex; 
            for ne = 1:numEnvironments
                app.environmentSelection.Items{ne} = getEnvNames(envIndex);
            end
        end
        
        function setCurrentTrial(app, trialNumber)
            app.trialNumber.Value = trialNumber;
        end
        
        function setRewardAvailable(app, rewAvailable)
            app.rewardAvailable.Value = rewAvailable; 
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.rigInfo = vrControlRigParameters();
            app.UIFigure.Position([1 2]) = app.rigInfo.localFigurePosition; 

            clearRewardZone(app);
            app.environmentPreview.XTick = [];
            app.environmentPreview.YTick = [];
            app.environmentPreview.XColor = 'none';
            app.environmentPreview.YColor = 'none';
            app.environmentPreview.Position = [1 1 299 173];
            
            app.totalDistance.Value = 0;
            app.elapsedTimer = tic;
        end

        % Button pushed function: startButton
        function startButtonPushed(app, event)
            app.timelineActive = true;
            disenableStart(app);
        end

        % Value changed function: envIdx
        function envIdxValueChanged(app, event)
            if ~ismember(event.Value, app.environmentSelection.ItemsData)
                app.envIdx.Value = event.PreviousValue; 
            end
            app.environmentSelection.Value = app.envIdx.Value; 
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end

        % Value changed function: minimumITI
        function minimumITIValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end

        % Value changed function: environmentSelection
        function environmentSelectionValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
            app.envIdx.Value = app.environmentSelection.Value; 
        end

        % Value changed function: envLength
        function envLengthValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
            app.rewardPosition.Limits = [0, app.envLength.Value];
            app.rewardTolerance.Limits = [0, app.envLength.Value];
        end

        % Value changed function: mvmtGain
        function mvmtGainValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end

        % Value changed function: rewardPosition
        function rewardPositionValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end

        % Value changed function: rewardTolerance
        function rewardToleranceValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end

        % Value changed function: probReward
        function probRewardValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end

        % Value changed function: lickRequired
        function lickRequiredValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end

        % Value changed function: stopRequired
        function stopRequiredValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end

        % Value changed function: stopDuration
        function stopDurationValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end

        % Value changed function: maxTrialDuration
        function maxTrialDurationValueChanged(app, event)
            if event.Value ~= event.PreviousValue
                valueUpdated(app, true);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [577 328 603 350];
            app.UIFigure.Name = 'MATLAB App';

            % Create mouseSpeedPanel
            app.mouseSpeedPanel = uipanel(app.UIFigure);
            app.mouseSpeedPanel.Title = '            Mouse Speed (cm/s)';
            app.mouseSpeedPanel.BackgroundColor = [1 1 1];
            app.mouseSpeedPanel.Position = [301 97 301 61];

            % Create mouseSpeed
            app.mouseSpeed = uigauge(app.mouseSpeedPanel, 'linear');
            app.mouseSpeed.Position = [0 0 301 42];

            % Create SpeedConstantEditFieldLabel
            app.SpeedConstantEditFieldLabel = uilabel(app.mouseSpeedPanel);
            app.SpeedConstantEditFieldLabel.HorizontalAlignment = 'right';
            app.SpeedConstantEditFieldLabel.FontSize = 10;
            app.SpeedConstantEditFieldLabel.Position = [171 40 74 22];
            app.SpeedConstantEditFieldLabel.Text = 'SpeedConstant';

            % Create speedConstant
            app.speedConstant = uieditfield(app.mouseSpeedPanel, 'numeric');
            app.speedConstant.Limits = [0 Inf];
            app.speedConstant.FontSize = 10;
            app.speedConstant.Position = [252 44 48 16];
            app.speedConstant.Value = 0.1;

            % Create environmentPreviewPanel
            app.environmentPreviewPanel = uipanel(app.UIFigure);
            app.environmentPreviewPanel.TitlePosition = 'centertop';
            app.environmentPreviewPanel.Title = 'Current Frame (middle third)';
            app.environmentPreviewPanel.BackgroundColor = [1 1 1];
            app.environmentPreviewPanel.Position = [301 157 301 192];

            % Create environmentPreview
            app.environmentPreview = uiaxes(app.environmentPreviewPanel);
            zlabel(app.environmentPreview, 'Z')
            app.environmentPreview.Toolbar.Visible = 'off';
            app.environmentPreview.XColor = 'none';
            app.environmentPreview.XTick = [];
            app.environmentPreview.YColor = 'none';
            app.environmentPreview.YTick = [];
            app.environmentPreview.Position = [13 20 275 146];

            % Create mousePositionPanel
            app.mousePositionPanel = uipanel(app.UIFigure);
            app.mousePositionPanel.TitlePosition = 'centertop';
            app.mousePositionPanel.Title = 'Mouse Position (cm) - Green Patch Indicates Reward Zone';
            app.mousePositionPanel.BackgroundColor = [1 1 1];
            app.mousePositionPanel.Position = [2 21 600 77];

            % Create mousePosition
            app.mousePosition = uigauge(app.mousePositionPanel, 'linear');
            app.mousePosition.MajorTicks = [0 10 20 30 40 50 60 70 80 90 100];
            app.mousePosition.Position = [1 2 600 58];

            % Create rewardZone
            app.rewardZone = uieditfield(app.mousePositionPanel, 'text');
            app.rewardZone.Editable = 'off';
            app.rewardZone.BackgroundColor = [0 1 0];
            app.rewardZone.Enable = 'off';
            app.rewardZone.Position = [7 2 581 58];

            % Create ActiveStoppingPanel
            app.ActiveStoppingPanel = uipanel(app.UIFigure);
            app.ActiveStoppingPanel.TitlePosition = 'centertop';
            app.ActiveStoppingPanel.Title = 'Active Stopping';
            app.ActiveStoppingPanel.BackgroundColor = [1 1 1];
            app.ActiveStoppingPanel.Position = [2 97 300 53];

            % Create stopPerformedLabel
            app.stopPerformedLabel = uilabel(app.ActiveStoppingPanel);
            app.stopPerformedLabel.Position = [130 8 31 22];
            app.stopPerformedLabel.Text = 'Valid';

            % Create stopPerformed
            app.stopPerformed = uilamp(app.ActiveStoppingPanel);
            app.stopPerformed.Position = [107 9 20 20];
            app.stopPerformed.Color = [1 0 0];

            % Create stopRequired
            app.stopRequired = uiswitch(app.ActiveStoppingPanel, 'slider');
            app.stopRequired.Items = {'No', 'Yes'};
            app.stopRequired.ItemsData = [0 1];
            app.stopRequired.ValueChangedFcn = createCallbackFcn(app, @stopRequiredValueChanged, true);
            app.stopRequired.Position = [27 9 45 20];
            app.stopRequired.Value = 0;

            % Create stopDurationLabel
            app.stopDurationLabel = uilabel(app.ActiveStoppingPanel);
            app.stopDurationLabel.HorizontalAlignment = 'right';
            app.stopDurationLabel.Position = [169 8 79 22];
            app.stopDurationLabel.Text = 'Stop Duration';

            % Create stopDuration
            app.stopDuration = uieditfield(app.ActiveStoppingPanel, 'numeric');
            app.stopDuration.Limits = [0 Inf];
            app.stopDuration.ValueChangedFcn = createCallbackFcn(app, @stopDurationValueChanged, true);
            app.stopDuration.Position = [251 8 44 22];

            % Create ActiveLickingPanel
            app.ActiveLickingPanel = uipanel(app.UIFigure);
            app.ActiveLickingPanel.TitlePosition = 'centertop';
            app.ActiveLickingPanel.Title = 'Active Licking';
            app.ActiveLickingPanel.BackgroundColor = [1 1 1];
            app.ActiveLickingPanel.Position = [2 149 300 53];

            % Create lickPerformedLabel
            app.lickPerformedLabel = uilabel(app.ActiveLickingPanel);
            app.lickPerformedLabel.Position = [130 8 31 22];
            app.lickPerformedLabel.Text = 'Valid';

            % Create lickPerformed
            app.lickPerformed = uilamp(app.ActiveLickingPanel);
            app.lickPerformed.Position = [107 9 20 20];
            app.lickPerformed.Color = [1 0 0];

            % Create lickRequired
            app.lickRequired = uiswitch(app.ActiveLickingPanel, 'slider');
            app.lickRequired.Items = {'No', 'Yes'};
            app.lickRequired.ItemsData = [0 1];
            app.lickRequired.ValueChangedFcn = createCallbackFcn(app, @lickRequiredValueChanged, true);
            app.lickRequired.Position = [27 9 45 20];
            app.lickRequired.Value = 0;

            % Create lickIndicatorLabel
            app.lickIndicatorLabel = uilabel(app.ActiveLickingPanel);
            app.lickIndicatorLabel.HorizontalAlignment = 'right';
            app.lickIndicatorLabel.Position = [188 8 76 22];
            app.lickIndicatorLabel.Text = 'Lick Indicator';

            % Create lickIndicator
            app.lickIndicator = uilamp(app.ActiveLickingPanel);
            app.lickIndicator.Position = [271 8 20 20];
            app.lickIndicator.Color = [0.149 0.149 0.149];

            % Create TrialParametersPanel
            app.TrialParametersPanel = uipanel(app.UIFigure);
            app.TrialParametersPanel.TitlePosition = 'centertop';
            app.TrialParametersPanel.Title = 'Trial Parameters';
            app.TrialParametersPanel.BackgroundColor = [1 1 1];
            app.TrialParametersPanel.Position = [2 201 300 148];

            % Create trialNumberLabel
            app.trialNumberLabel = uilabel(app.TrialParametersPanel);
            app.trialNumberLabel.Position = [5 103 28 22];
            app.trialNumberLabel.Text = 'Trial';

            % Create envIdxLabel
            app.envIdxLabel = uilabel(app.TrialParametersPanel);
            app.envIdxLabel.HorizontalAlignment = 'right';
            app.envIdxLabel.Position = [65 103 46 22];
            app.envIdxLabel.Text = 'Env Idx';

            % Create envLengthLabel
            app.envLengthLabel = uilabel(app.TrialParametersPanel);
            app.envLengthLabel.Position = [5 53 94 22];
            app.envLengthLabel.Text = 'Env Length (cm)';

            % Create rewardPositionLabel
            app.rewardPositionLabel = uilabel(app.TrialParametersPanel);
            app.rewardPositionLabel.HorizontalAlignment = 'right';
            app.rewardPositionLabel.Position = [9 28 120 22];
            app.rewardPositionLabel.Text = 'Reward Position (cm)';

            % Create rewardToleranceLabel
            app.rewardToleranceLabel = uilabel(app.TrialParametersPanel);
            app.rewardToleranceLabel.HorizontalAlignment = 'right';
            app.rewardToleranceLabel.Position = [1 7 129 22];
            app.rewardToleranceLabel.Text = 'Reward Tolerance (cm)';

            % Create movementGainLabel
            app.movementGainLabel = uilabel(app.TrialParametersPanel);
            app.movementGainLabel.HorizontalAlignment = 'right';
            app.movementGainLabel.Position = [153 53 90 22];
            app.movementGainLabel.Text = 'Movement Gain';

            % Create probRewardLabel
            app.probRewardLabel = uilabel(app.TrialParametersPanel);
            app.probRewardLabel.HorizontalAlignment = 'right';
            app.probRewardLabel.Position = [175 28 79 22];
            app.probRewardLabel.Text = 'Prob. Reward';

            % Create rewardAvailableLabel
            app.rewardAvailableLabel = uilabel(app.TrialParametersPanel);
            app.rewardAvailableLabel.HorizontalAlignment = 'right';
            app.rewardAvailableLabel.Position = [171 7 83 22];
            app.rewardAvailableLabel.Text = 'Rew. Available';

            % Create minimumITILabel
            app.minimumITILabel = uilabel(app.TrialParametersPanel);
            app.minimumITILabel.HorizontalAlignment = 'right';
            app.minimumITILabel.Position = [147 103 42 22];
            app.minimumITILabel.Text = 'Min ITI';

            % Create rewardAvailable
            app.rewardAvailable = uieditfield(app.TrialParametersPanel, 'numeric');
            app.rewardAvailable.Editable = 'off';
            app.rewardAvailable.Position = [257 7 39 22];

            % Create probReward
            app.probReward = uieditfield(app.TrialParametersPanel, 'numeric');
            app.probReward.Limits = [0 1];
            app.probReward.ValueChangedFcn = createCallbackFcn(app, @probRewardValueChanged, true);
            app.probReward.Position = [257 28 39 22];

            % Create rewardTolerance
            app.rewardTolerance = uieditfield(app.TrialParametersPanel, 'numeric');
            app.rewardTolerance.Limits = [0 Inf];
            app.rewardTolerance.ValueChangedFcn = createCallbackFcn(app, @rewardToleranceValueChanged, true);
            app.rewardTolerance.Position = [132 7 40 22];
            app.rewardTolerance.Value = 5;

            % Create rewardPosition
            app.rewardPosition = uieditfield(app.TrialParametersPanel, 'numeric');
            app.rewardPosition.Limits = [0 Inf];
            app.rewardPosition.ValueChangedFcn = createCallbackFcn(app, @rewardPositionValueChanged, true);
            app.rewardPosition.Position = [132 28 40 22];
            app.rewardPosition.Value = 75;

            % Create mvmtGain
            app.mvmtGain = uieditfield(app.TrialParametersPanel, 'numeric');
            app.mvmtGain.ValueChangedFcn = createCallbackFcn(app, @mvmtGainValueChanged, true);
            app.mvmtGain.Position = [246 53 50 22];
            app.mvmtGain.Value = 1;

            % Create envLength
            app.envLength = uieditfield(app.TrialParametersPanel, 'numeric');
            app.envLength.Limits = [1 Inf];
            app.envLength.ValueChangedFcn = createCallbackFcn(app, @envLengthValueChanged, true);
            app.envLength.Position = [99 53 49 22];
            app.envLength.Value = 100;

            % Create startButton
            app.startButton = uibutton(app.TrialParametersPanel, 'push');
            app.startButton.ButtonPushedFcn = createCallbackFcn(app, @startButtonPushed, true);
            app.startButton.BackgroundColor = [1 1 1];
            app.startButton.Enable = 'off';
            app.startButton.Position = [242 103 55 22];
            app.startButton.Text = 'start';

            % Create minimumITI
            app.minimumITI = uieditfield(app.TrialParametersPanel, 'numeric');
            app.minimumITI.Limits = [0 Inf];
            app.minimumITI.ValueChangedFcn = createCallbackFcn(app, @minimumITIValueChanged, true);
            app.minimumITI.Editable = 'off';
            app.minimumITI.Position = [194 103 40 22];
            app.minimumITI.Value = 1;

            % Create envIdx
            app.envIdx = uieditfield(app.TrialParametersPanel, 'numeric');
            app.envIdx.Limits = [1 Inf];
            app.envIdx.RoundFractionalValues = 'on';
            app.envIdx.ValueChangedFcn = createCallbackFcn(app, @envIdxValueChanged, true);
            app.envIdx.Position = [116 103 30 22];
            app.envIdx.Value = 1;

            % Create trialNumber
            app.trialNumber = uieditfield(app.TrialParametersPanel, 'numeric');
            app.trialNumber.Editable = 'off';
            app.trialNumber.Position = [33 103 32 22];
            app.trialNumber.Value = 1;

            % Create EnvironmentDropDownLabel
            app.EnvironmentDropDownLabel = uilabel(app.TrialParametersPanel);
            app.EnvironmentDropDownLabel.Position = [5 78 73 22];
            app.EnvironmentDropDownLabel.Text = 'Environment';

            % Create environmentSelection
            app.environmentSelection = uidropdown(app.TrialParametersPanel);
            app.environmentSelection.Items = {'Env 1', 'Env 2'};
            app.environmentSelection.ItemsData = {'1', '2'};
            app.environmentSelection.ValueChangedFcn = createCallbackFcn(app, @environmentSelectionValueChanged, true);
            app.environmentSelection.Position = [85 78 129 22];
            app.environmentSelection.Value = '1';

            % Create MDurEditFieldLabel
            app.MDurEditFieldLabel = uilabel(app.TrialParametersPanel);
            app.MDurEditFieldLabel.HorizontalAlignment = 'right';
            app.MDurEditFieldLabel.Position = [213 78 38 22];
            app.MDurEditFieldLabel.Text = 'M.Dur';

            % Create maxTrialDuration
            app.maxTrialDuration = uieditfield(app.TrialParametersPanel, 'numeric');
            app.maxTrialDuration.ValueChangedFcn = createCallbackFcn(app, @maxTrialDurationValueChanged, true);
            app.maxTrialDuration.Position = [257 78 40 22];

            % Create TotalDistancecmEditFieldLabel
            app.TotalDistancecmEditFieldLabel = uilabel(app.UIFigure);
            app.TotalDistancecmEditFieldLabel.HorizontalAlignment = 'right';
            app.TotalDistancecmEditFieldLabel.Position = [3 0 108 22];
            app.TotalDistancecmEditFieldLabel.Text = 'Total Distance (cm)';

            % Create totalDistance
            app.totalDistance = uieditfield(app.UIFigure, 'numeric');
            app.totalDistance.Editable = 'off';
            app.totalDistance.Position = [126 0 71 22];

            % Create ElapsedTimeEditFieldLabel
            app.ElapsedTimeEditFieldLabel = uilabel(app.UIFigure);
            app.ElapsedTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.ElapsedTimeEditFieldLabel.Position = [410 0 78 22];
            app.ElapsedTimeEditFieldLabel.Text = 'Elapsed Time';

            % Create elapsedTime
            app.elapsedTime = uieditfield(app.UIFigure, 'text');
            app.elapsedTime.Editable = 'off';
            app.elapsedTime.Position = [503 0 100 22];

            % Create TotalRewardEditFieldLabel
            app.TotalRewardEditFieldLabel = uilabel(app.UIFigure);
            app.TotalRewardEditFieldLabel.HorizontalAlignment = 'right';
            app.TotalRewardEditFieldLabel.Position = [209 0 76 22];
            app.TotalRewardEditFieldLabel.Text = 'Total Reward';

            % Create TotalRewardEditField
            app.TotalRewardEditField = uieditfield(app.UIFigure, 'numeric');
            app.TotalRewardEditField.Editable = 'off';
            app.TotalRewardEditField.Position = [300 0 100 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = vrControlTrainingWindow

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
classdef vrControlGUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        topBox                          matlab.ui.control.TextArea
        vrenvInUseLabel                 matlab.ui.control.Label
        vrenvInUse                      matlab.ui.control.ListBox
        vrenvOptionsLabel               matlab.ui.control.Label
        vrenvOptions                    matlab.ui.control.ListBox
        printenvironmentinfoButton      matlab.ui.control.Button
        envActive                       matlab.ui.control.StateButton
        envOrderLabel                   matlab.ui.control.Label
        envOrder                        matlab.ui.control.DropDown
        rewardToleranceLabel            matlab.ui.control.Label
        rewardTolerance                 matlab.ui.control.NumericEditField
        rewardPositionLabel             matlab.ui.control.Label
        rewardPosition                  matlab.ui.control.NumericEditField
        dsFactorLabel                   matlab.ui.control.Label
        dsFactor                        matlab.ui.control.NumericEditField
        envLengthLabel                  matlab.ui.control.Label
        envLength                       matlab.ui.control.NumericEditField
        envSettingsLabel                matlab.ui.control.Label
        envSettings                     matlab.ui.control.DropDown
        environmentBlockTab             matlab.ui.container.TabGroup
        InitialTab                      matlab.ui.container.Tab
        initEnvironmentLabel            matlab.ui.control.Label
        initEnvironment                 matlab.ui.control.DropDown
        initNumTrialsLabel              matlab.ui.control.Label
        initNumTrials                   matlab.ui.control.NumericEditField
        initActive                      matlab.ui.control.CheckBox
        PresetTab                       matlab.ui.container.Tab
        presetTrialsList                matlab.ui.control.ListBox
        envTrialsLabel                  matlab.ui.control.Label
        envTrials                       matlab.ui.control.NumericEditField
        evenTrialsPerEnv                matlab.ui.control.StateButton
        presetBlocks                    matlab.ui.control.CheckBox
        RandomTab                       matlab.ui.container.Tab
        randomMeanList                  matlab.ui.control.ListBox
        randomLengthMeanLabel           matlab.ui.control.Label
        randomLengthMean                matlab.ui.control.NumericEditField
        randomDistribution              matlab.ui.control.DropDown
        evenRandMeanPerEnv              matlab.ui.control.StateButton
        randomBlocks                    matlab.ui.control.CheckBox
        EnvironmentBlockStructureLabel  matlab.ui.control.Label
        messagestouserTextAreaLabel     matlab.ui.control.Label
        messagestouserTextArea          matlab.ui.control.TextArea
        trialSettingsTabs               matlab.ui.container.TabGroup
        ConditionalTrialTypesTab        matlab.ui.container.Tab
        removeButton                    matlab.ui.control.Button
        addnewButton                    matlab.ui.control.Button
        condMvmtGain                    matlab.ui.control.StateButton
        condActiveStop                  matlab.ui.control.StateButton
        condActiveLick                  matlab.ui.control.StateButton
        condProbRew                     matlab.ui.control.StateButton
        condFreqSettingLabel            matlab.ui.control.Label
        condFreqSetting                 matlab.ui.control.NumericEditField
        condMvmtGainSettingLabel        matlab.ui.control.Label
        condMvmtGainSetting             matlab.ui.control.NumericEditField
        condActiveStopDurationLabel     matlab.ui.control.Label
        condActiveStopDuration          matlab.ui.control.NumericEditField
        condActiveLickSettingLabel      matlab.ui.control.Label
        condActiveLickSetting           matlab.ui.control.NumericEditField
        condProbRewSettingLabel         matlab.ui.control.Label
        condProbRewSetting              matlab.ui.control.NumericEditField
        condTrialList                   matlab.ui.control.ListBox
        updatetrialtypeButton           matlab.ui.control.Button
        IndependentPRActiveLickingStoppingMovementGainTab  matlab.ui.container.Tab
        stopDurationLabel               matlab.ui.control.Label
        stopDuration                    matlab.ui.control.NumericEditField
        activeStopping                  matlab.ui.control.CheckBox
        activeLicking                   matlab.ui.control.CheckBox
        rewProbRemove                   matlab.ui.control.Button
        rewProbAddNew                   matlab.ui.control.Button
        rewProbNewFreqLabel             matlab.ui.control.Label
        rewProbNewFreq                  matlab.ui.control.NumericEditField
        rewProbNewProbLabel             matlab.ui.control.Label
        rewProbNewProb                  matlab.ui.control.NumericEditField
        customProbRewardGenerator       matlab.ui.control.EditField
        customProbReward                matlab.ui.control.CheckBox
        rewProbList                     matlab.ui.control.ListBox
        randRewardWindow                matlab.ui.control.DropDown
        randReward                      matlab.ui.control.CheckBox
        customGainGenerator             matlab.ui.control.EditField
        customGain                      matlab.ui.control.CheckBox
        maxGainLabel                    matlab.ui.control.Label
        maxGain                         matlab.ui.control.NumericEditField
        minGainLabel                    matlab.ui.control.Label
        minGain                         matlab.ui.control.NumericEditField
        randGainWindow                  matlab.ui.control.DropDown
        randGain                        matlab.ui.control.CheckBox
        movementGainLabel               matlab.ui.control.Label
        movementGain                    matlab.ui.control.NumericEditField
        IntertrialTimingsPanel          matlab.ui.container.Panel
        distributionITI                 matlab.ui.control.DropDown
        randomMeanITILabel              matlab.ui.control.Label
        randomMeanITI                   matlab.ui.control.NumericEditField
        randomizeITI                    matlab.ui.control.CheckBox
        minimumITILabel                 matlab.ui.control.Label
        minimumITI                      matlab.ui.control.NumericEditField
        lickEncoderAvailable            matlab.ui.control.CheckBox
        useUpdateWindow                 matlab.ui.control.CheckBox
        settingsNameLabel               matlab.ui.control.Label
        settingsName                    matlab.ui.control.EditField
        maxTrialDurationLabel           matlab.ui.control.Label
        maxTrialDuration                matlab.ui.control.NumericEditField
        maxTrialNumberLabel             matlab.ui.control.Label
        maxTrialNumber                  matlab.ui.control.NumericEditField
        sessionOffsetLabel              matlab.ui.control.Label
        sessionOffset                   matlab.ui.control.NumericEditField
        animalNameLabel                 matlab.ui.control.Label
        animalName                      matlab.ui.control.EditField
        vrDirectoryLabel                matlab.ui.control.Label
        fileextensionforenvironmentsLabel  matlab.ui.control.Label
        vrExtension                     matlab.ui.control.EditField
        updateDirectory                 matlab.ui.control.Button
        vrDirectory                     matlab.ui.control.EditField
        runExperiment                   matlab.ui.control.Button
        previewExperiment               matlab.ui.control.Button
        printrigparametersButton        matlab.ui.control.Button
        saveSettings                    matlab.ui.control.Button
        loadSettings                    matlab.ui.control.Button
        backwardsMovementSwitch         matlab.ui.control.CheckBox
    end

    
    properties (Access = public)
        userMessages = cell(0,2);
    end
    
    properties (Access = private)
        validDirectory = false; % boolean variable, flips when there's a valid vrDirectory
        environmentInfo = zeros(0,9); % #Frames, RewardPosition, RewardPosType, Order
        vrLength
        vrFrames
        vrFramesDS
        vrDSFactor
        vrRewPos
        vrRewTol
        vrOrder
        vrActive
        vrNumPresetTrials % Array of number of trials in block for each environment (length=numEnvActive, value=numTrialsPerEnvironment)
        vrNumRandTrials % Array of random mean of block length for each environment
        envBaseNames = cell(0); % base names for each environment (filename)
        envRichNames = cell(0); % rich names for each environment
        envOptionsLastClick = -inf*ones(1,6); % time of last click on vrEnv option (for double click)
        envOptionsLastSelection = nan; % index of last click on vrEnv option
        envInUseLastClick = -inf*ones(1,6); % time of last click on vrEnv in use
        envInUseLastSelection = nan; % index of last click on vrEnv in use
        doubleClickTime = 0.5; % Time elapsed to consider something a double click
        randRewardArray = [0, 1; 1, 1]; % numeric array of possible reward probabilities (first column P(rew), second Freq)
        rigInfo; % structure containing all rig information (loaded in startup with vrControlRigParameters()
        condTrialReward = [1 1 0]; % Array containing P(rew) for conditional trials
        condTrialActiveLicking = [1 0 0]; % Array containing active licking mode for conditional trials
        condTrialActiveStopping = [0 0 0]; % Array containing active stopping mode for conditional trials
        condTrialGain = [1 1 1]; % Array containing movement gain for conditional trials
        condTrialFreq = [65 25 10]; % Array containing frequency for each conditional trial type
    end
    
    methods (Access = private)
        
        function validateVrDirectory(app,newDirectory,startupSwitch)
            figure(app.UIFigure);
            if nargin<3, startupSwitch = false; end
            if isempty(newDirectory), return; end
            if exist(newDirectory, 'dir')
                % Make sure vrDirectory ends in fileseparator
                if ~strcmp(newDirectory(end),filesep)
                    newDirectory(end+1) = filesep; 
                end
                app.validDirectory = true;
                app.vrDirectory.Value = vrControlPersistent('vrDirectory', newDirectory);
                activateEnvironmentOptions(app) % this activates all environment options from vrDirectory
                presentMessage(app, 'New vrDirectory selected, options reset throughout app.', 1)
            elseif startupSwitch
                app.validDirectory = false; 
                app.vrDirectory.Value = vrControlPersistent('vrDirectory', '');
            else
                app.validDirectory = false;
                app.vrDirectory.Value = '';
                clearEnvironmentOptions(app) % clear all environment options 
                presentMessage(app, 'Invalid vrDirectory requested, all options disabled.', 2)
            end
        end

        function activateEnvironmentOptions(app)
            if ~app.validDirectory
                presentMessage(app, 'can''t activate environment without valid directory', 2); 
                clearEnvironmentOptions(app)
                return
            end
            % Look for vr environment files and populate menu
            vrExt = standardizeExtension(app);
            vrList = dir(fullfile(app.vrDirectory.Value,['*',vrExt]));
            numEnv = length(vrList);

            % Build Environment Info Array
            app.vrLength = environmentDefaults(app,'length') * ones(numEnv,1);
            app.vrFrames = zeros(numEnv,1);
            app.vrFramesDS = zeros(numEnv,1);
            app.vrDSFactor = environmentDefaults(app,'dsfactor') * ones(numEnv,1);
            app.vrRewPos = environmentDefaults(app,'rewpos') * ones(numEnv,1);
            app.vrRewTol = environmentDefaults(app,'rewtol') * ones(numEnv,1);
            app.vrOrder = environmentDefaults(app,'order') * ones(numEnv,1);
            app.vrActive = environmentDefaults(app,'active') * ones(numEnv,1);
            app.vrNumPresetTrials = app.envTrials.Value * ones(numEnv,1);
            app.vrNumRandTrials = app.randomLengthMean.Value * ones(numEnv,1);
            for vrenv = 1:numEnv
                cpath = fullfile(app.vrDirectory.Value,vrList(vrenv).name);
                ctifinfo = imfinfo(cpath);
                numFrames = length(ctifinfo);
                app.vrFrames(vrenv) = numFrames;
                app.vrFramesDS(vrenv) = numFrames;
            end

            % Update UI
            app.vrenvOptions.Value = {}; % deselect everything
            app.vrenvOptions.Items = repmat({''},numEnv,1);
            app.vrenvOptions.ItemsData = 1:numEnv; 
            app.vrenvInUse.Value = {}; % Deselect everything
            app.vrenvInUse.Items = {'none selected'};
            app.vrenvInUse.ItemsData = nan;
            app.envSettings.Items = repmat({''},numEnv,1);
            app.envSettings.ItemsData = 1:numEnv;
            updateOrderMenu(app,0); % reset order menu
            for vrenv = 1:numEnv
                [~,cname] = fileparts(vrList(vrenv).name);
                app.envBaseNames{vrenv} = cname;
                app.envRichNames{vrenv} = constructRichName(app, vrenv);
                app.vrenvOptions.Items{vrenv} = sprintf('%d - %s',vrenv,cname);
                app.envSettings.Items{vrenv} = cname;
            end

            % Enable user interface for environment settings
            app.vrenvOptions.Enable = "on";
            app.vrenvOptionsLabel.Enable = "on";
            app.vrenvInUse.Enable = "on";
            app.vrenvInUseLabel.Enable = "on";
            app.envSettings.Enable = "on";
            app.envSettingsLabel.Enable = "on";
            app.envLength.Enable = "on";
            app.envLengthLabel.Enable = "on";
            app.dsFactor.Enable = "on";
            app.dsFactorLabel.Enable = "on";
            app.rewardPosition.Enable = "on";
            app.rewardPositionLabel.Enable = "on";
            app.rewardTolerance.Enable = "on";
            app.rewardToleranceLabel.Enable = "on";
            app.envOrder.Enable = "on";
            app.envOrderLabel.Enable = "on";
            app.envActive.Enable = "on";

            updateInitialBlockMenu(app)
            updatePresetTrialsList(app)
            updateRandomTrialsList(app)
        end


        function loadEnvironmentOptions(app)
            % When loading settings, this loads environment options to GUI
            % after loading all the settings data into the app
            numEnv = length(app.vrLength);
            activeEnvironments = any(app.vrActive); 
            
            if activeEnvironments
                app.vrenvOptions.Enable = "on";
                app.vrenvInUse.Enable = "on";
            else
                app.vrenvOptions.Enable = "off";
                app.vrenvInUse.Enable = "off";
            end

            % Update UI
            app.vrenvOptions.Value = {}; % deselect everything
            app.vrenvOptions.Items = repmat({''},numEnv,1);
            app.vrenvOptions.ItemsData = 1:numEnv; 
            app.vrenvInUse.Value = {}; % Deselect everything
            app.envSettings.Items = repmat({''},numEnv,1);
            app.envSettings.ItemsData = 1:numEnv;
            for vrenv = 1:numEnv
                cname = app.envBaseNames{vrenv};
                app.envRichNames{vrenv} = constructRichName(app, vrenv);
                app.vrenvOptions.Items{vrenv} = sprintf('(%i)- %s',vrenv,cname);
                app.envSettings.Items{vrenv} = cname;
            end
            if activeEnvironments
                idxActive = vrControlReturnOrder(app.vrOrder, app.vrActive);
                app.vrenvInUse.Items = app.envRichNames(idxActive);
                app.vrenvInUse.ItemsData = idxActive;
            else
                app.vrenvInUse.Items = {'none selected'};
                app.vrenvInUse.ItemsData = nan;
            end
            updateOrderMenu(app, activeEnvironments);
            updateSettingsMenus(app,1); % default to selecting first environment (out of options) from settings menu
        end

        function clearEnvironmentOptions(app)
            app.vrLength = [];
            app.vrFrames = [];
            app.vrFramesDS = [];
            app.vrDSFactor = [];
            app.vrRewPos = [];
            app.vrRewTol = [];
            app.vrOrder = [];
            app.vrActive = [];
            app.vrenvOptions.Items = {'path not defined'}; 
            app.vrenvOptions.ItemsData = nan;
            app.vrenvInUse.Items = {'path not defined'};
            app.vrenvOptions.ItemsData = nan;
            app.envSettings.Items = {'path not defined'};
            app.envSettings.ItemsData = nan;
            app.vrenvOptions.Enable = "off";
            app.envSettings.Enable = "off";
            app.envSettingsLabel.Enable = "off";
            app.envLength.Enable = "off";
            app.envLengthLabel.Enable = "off";
            app.envLength.Value = environmentDefaults(app, 'length');
            app.dsFactor.Enable = "off";
            app.dsFactorLabel.Enable = "off";
            app.dsFactor.Value = environmentDefaults(app, 'dsfactor');
            app.rewardPosition.Enable = "off";
            app.rewardPositionLabel.Enable = "off";
            app.rewardPosition.Value = environmentDefaults(app,'rewpos');
            app.rewardTolerance.Enable = "off";
            app.rewardToleranceLabel.Enable = "off";
            app.rewardTolerance.Value = environmentDefaults(app, 'rewtol');
            updateOrderMenu(app, 0)
            app.envOrder.Enable = "off";
            app.envOrderLabel.Enable = "off";
            app.envActive.Enable = "off";
            app.envActive.Value = false;
            updateInitialBlockMenu(app)
        end

        function richEnvName = constructRichName(app, envidx)
            baseName = app.envBaseNames{envidx};
            lengthString = sprintf('Length=%icm',app.vrLength(envidx));
            framesString = sprintf('%i frames -(ds)-> %i',app.vrFrames(envidx),app.vrFramesDS(envidx));
            rewardUnit = 'cm';
            rewardString = sprintf('Reward Position=%.1f +/- %.1f%s', app.vrRewPos(envidx), app.vrRewTol(envidx), rewardUnit);
            richEnvName = [sprintf('(%i)-',envidx),strjoin({baseName,lengthString,framesString,rewardString},' || ')];
        end
        
        function addEnvironment(app,envidx)
            % after environment is double clicked on the options column,
            % this function adds it to the inUse column (if not already)
            if ismember(envidx, app.vrenvInUse.ItemsData)
                presentMessage(app, sprintf('Environment %d is already in use!',envidx),1)
                return
            end
            if any(app.vrActive)
                newIdx = length(app.vrenvInUse.Items) + 1;
            else
                newIdx = 1;
            end
            app.vrOrder(envidx) = newIdx;
            app.vrActive(envidx) = 1;
            updateOrderMenu(app,1);
            app.envRichNames{envidx} = constructRichName(app,envidx);
            app.vrenvInUse.Items{newIdx} = app.envRichNames{envidx};
            app.vrenvInUse.ItemsData(newIdx) = envidx;
            updateInitialBlockMenu(app); 
            updateSettingsMenus(app,envidx); % update settings menus and enable
            presentMessage(app, sprintf('Environment %d now in use.',envidx),1)
        end

        function removeEnvironment(app,envidx)
            % after environment is double clicked on inUse column or
            % envActive toggled, remove environment from everything
            if ~ismember(envidx, app.vrenvInUse.ItemsData)
                error('Environment (%d) is being removed but it is not currently active',envidx); 
            end
            app.vrOrder(envidx) = environmentDefaults(app,'order');
            app.vrActive(envidx) = false;
            updateOrderMenu(app,1);

            activeEnvironments = any(app.vrActive); % reset if last environment
            app.envRichNames{envidx} = constructRichName(app,envidx); % update it's rich name
            if activeEnvironments
                % If there remain active environments, then:
                % Reset order of remaining environments
                idxActive = find(app.vrActive);
                pOrder = app.vrOrder(idxActive);
                [~,pOrdIdx] = sort(pOrder);
                app.vrOrder(idxActive) = pOrdIdx;

                % Repopulate vrenvInUse array with correct order
                app.vrenvInUse.Items = {};
                app.vrenvInUse.ItemsData = [];
                for eidx = 1:length(idxActive)
                    cenv = idxActive(pOrdIdx(eidx));
                    app.envRichNames{cenv} = constructRichName(app,cenv);
                    app.vrenvInUse.Items{eidx} = app.envRichNames{cenv};
                    app.vrenvInUse.ItemsData(eidx) = cenv;
                end
            else
                % Otherwise, clear vrenvInUse section
                app.vrenvInUse.Items = {};
                app.vrenvInUse.ItemsData = [];
            end
            updateInitialBlockMenu(app); 
            updateSettingsMenus(app,envidx); % update settings menus and enable
            presentMessage(app, sprintf('Environment %d is no longer in use.',envidx),1)
        end
        
        function updateSettingsMenus(app,envidx)
            % - length(1)
            % - frames(2) / dsFrames(3) /dsFactor(4)
            % - rewardPosition(5) / rewardTolerance(6) / rewardUnits(7)
            % - order in block(8)
            % - active(9)
            % -- code for updating all the settings menus when the dropdown
            % value changes or when a new environment is selected --
            if app.vrActive(envidx)
                enableString = "on";
                app.envSettings.Value = envidx;
                app.envLength.Value = app.vrLength(envidx);
                app.dsFactor.Value = app.vrDSFactor(envidx);
                app.rewardPosition.Value = 0;
                app.rewardTolerance.Value = 0;
                app.rewardPosition.Limits = [0 app.vrLength(envidx)];
                app.rewardTolerance.Limits = [0 app.vrLength(envidx)];
                app.rewardPosition.Value = app.vrRewPos(envidx);
                app.rewardTolerance.Value = app.vrRewTol(envidx);
                updateOrderMenu(app,1)
                app.envOrder.Value = app.vrOrder(envidx);
                app.envActive.Value = app.vrActive(envidx);
            else
                enableString = "off";
                app.envSettings.Value = envidx;
                app.envLength.Value = environmentDefaults(app,'length'); % default
                app.dsFactor.Value = environmentDefaults(app,'dsfactor');
                app.rewardPosition.Value = 0;
                app.rewardTolerance.Value = 0;
                app.rewardPosition.Limits = [0 environmentDefaults(app,'length')];
                app.rewardTolerance.Limits = [0 environmentDefaults(app,'length')];                    
                app.rewardPosition.Value = environmentDefaults(app,'rewpos');
                app.rewardTolerance.Value = environmentDefaults(app,'rewtol');
                updateOrderMenu(app,0)
                app.envOrder.Value = environmentDefaults(app,'order');
                app.envActive.Value = environmentDefaults(app,'active');
            end
            app.envSettings.Enable = enableString;
            app.envSettingsLabel.Enable = enableString;
            app.envLength.Enable = enableString;
            app.envLengthLabel.Enable = enableString;
            app.dsFactor.Enable = enableString;
            app.dsFactorLabel.Enable = enableString;
            app.rewardPosition.Enable = enableString;
            app.rewardPositionLabel.Enable = enableString;
            app.rewardTolerance.Enable = enableString;
            app.rewardToleranceLabel.Enable = enableString;
            app.envOrder.Enable = enableString;
            app.envOrderLabel.Enable = enableString;
            app.envActive.Enable = enableString;
        end

        function vrExtension = standardizeExtension(app)
            % This makes sure that the extension has a leading period
            vrExtension = app.vrExtension.Value;
            if vrExtension(1)~='.'
                vrExtension = ['.',vrExtension]; 
            end
        end

        function changeBlockStructure(app, newType)
            % This is called every time a different block structure is
            % selected. It enables all settings within the current block
            % structure and disenables all settings from other block
            % structures.
            
            if strcmpi(newType, 'preset')
                % If we've switched to the Even Block Structure --
            
                % Enable even block settings
                app.PresetTab.Title = '*Preset*';
                app.presetBlocks.Value = true;
                app.presetBlocks.Enable = "off";
                app.envTrials.Enable = "on";
                app.envTrialsLabel.Enable = "on";
                app.presetTrialsList.Enable = "on";
                app.evenTrialsPerEnv.Enable = "on";
                
                % Disenable random block settings
                app.RandomTab.Title = 'Random';
                app.randomBlocks.Value = false; 
                app.randomBlocks.Enable = "on";
                app.randomLengthMean.Enable = "off";
                app.randomLengthMeanLabel.Enable = "off";
                app.randomDistribution.Enable = "off";            
                app.randomMeanList.Enable = "off";
                app.evenRandMeanPerEnv.Enable = "off";
                
            elseif strcmpi(newType, 'random')
                % If we've switched to the Random Block Structure --

                % Enable even block settings
                app.PresetTab.Title = 'Preset';
                app.presetBlocks.Value = false;
                app.presetBlocks.Enable = "on";
                app.envTrials.Enable = "off";
                app.envTrialsLabel.Enable = "off";
                app.presetTrialsList.Enable = "off";
                app.evenTrialsPerEnv.Enable = "off";
                
                % Disenable random block settings
                app.RandomTab.Title = '*Random*';
                app.randomBlocks.Value = true; 
                app.randomBlocks.Enable = "off"; 
                app.randomLengthMean.Enable = "on";
                app.randomLengthMeanLabel.Enable = "on";
                app.randomDistribution.Enable = "on";
                app.randomMeanList.Enable = "on";
                app.evenRandMeanPerEnv.Enable = "on";
                
            else
                error('changeBlockStructure received unknown type!');
            end

            presentMessage(app, sprintf('Block structure changed to %s.',newType), 1);
        end
        
        function presentMessage(app,message,type)
            app.messagestouserTextArea.Value = message;
            if type==1, app.messagestouserTextArea.FontColor = 'k'; end
            if type==2, app.messagestouserTextArea.FontColor = 'r'; end
            messageNumber = size(app.userMessages,1) + 1;
            app.userMessages{messageNumber,1} = message;
            app.userMessages{messageNumber,2} = type;
        end
        
        function envSettingsChanged(app,envidx)
            % Construct rich environment name again
            app.envRichNames{envidx} = constructRichName(app,envidx);
            % If environment is active, then it should be in the inuseList
            % and we need to update the string associated with it
            if app.vrActive(envidx)
                app.vrenvInUse.Items{app.vrOrder(envidx)} = app.envRichNames{envidx};
            end
            
        end
        
        function value = environmentDefaults(~,feature)
            switch lower(feature)
                case 'length', value = 250; % 250cm default length
                case 'dsfactor', value = 1; % default ds factor = no downsampling
                case 'rewpos', value = 200; % in cm
                case 'rewtol', value = 10; % in cm
                case 'rewunit', value = 2; % 1=%, 2=cm
                case 'order', value = -1;
                case 'active', value = 0;
                case 'abslimits', value = [0 2000];
                case 'perlimits', value = [0 100];
                otherwise, error('feature string not recognized!!');
            end            
        end
        
        function updateOrderMenu(app,setting)
            numActive = sum(app.vrActive);
            if logical(setting) && numActive
                app.envOrder.Items = cellfun(@(idx) sprintf('%i',idx), num2cell(1:numActive), 'uni', 0);
                app.envOrder.ItemsData = 1:numActive;
            else
                app.envOrder.Items = {'n/a'};
                app.envOrder.ItemsData = -1;
            end
        end
        
        function updateInitialBlockMenu(app)
            idxActive = find(app.vrActive);
            pValue = app.initEnvironment.Value; % Store previous value
            if ~ismember(app.initEnvironment.Value, idxActive)
                app.initActive.Value = false; 
            end
            if ~isempty(idxActive)
                app.initEnvironment.Items = cellfun(@(eidx) sprintf('%i',eidx), num2cell(idxActive), 'uni', 0);
                app.initEnvironment.ItemsData = idxActive;
            else
                app.initEnvironment.Items = {'n/a'};
                app.initEnvironment.ItemsData = -1;
                app.initEnvironment.Value = -1;
                app.initActive.Value = false;
            end
            if ismember(pValue, idxActive)
                app.initEnvironment.Value = pValue; 
            end

            if app.initNumTrials.Value==0
                app.initActive.Value = false; 
            end

            if app.initActive.Value
                app.InitialTab.Title = '*Initial*';
            else
                app.InitialTab.Title = 'Initial';
            end
        end
        
        function generateRewardProbList(app)
            rewProb = app.randRewardArray(:,1);
            rewFreq = app.randRewardArray(:,2);
            rewPerc = rewFreq / sum(rewFreq) * 100;
            numRew = size(rewProb,1);
            app.rewProbList.Items = repmat({''}, numRew, 1);
            app.rewProbList.ItemsData = 1:numRew;
            for rew = 1:numRew
                rewString = sprintf('P(R)=%.2f, %.1f%%, F=%d',rewProb(rew),rewPerc(rew),rewFreq(rew));
                app.rewProbList.Items{rew} = rewString;
            end
        end

        function out = generateOutputStructure(app)
            % Meta Parameters
            out.vrDirectory = app.vrDirectory.Value; 
            out.vrExtension = app.vrExtension.Value;
            out.animalName = app.animalName.Value; 
            out.sessionOffset = app.sessionOffset.Value; 
            out.maxTrialNumber = app.maxTrialNumber.Value;
            out.maxTrialDuration = app.maxTrialDuration.Value; 
            out.settingsName = app.settingsName.Value;
            out.useUpdateWindow = app.useUpdateWindow.Value;
            
            % VR Directory, Options, & In Use + Settings
            idxActive = vrControlReturnOrder(app.vrOrder, app.vrActive);
            out.vrOptions = app.envBaseNames;
            out.vrInUse = app.envBaseNames(idxActive); % Names of environments in use in order
            out.vrLength = app.vrLength;
            out.vrFrames = app.vrFrames;
            out.vrFramesDS = app.vrFramesDS;
            out.vrDSFactor = app.vrDSFactor;
            out.vrRewPos = app.vrRewPos;
            out.vrRewTol = app.vrRewTol;
            out.vrOrder = app.vrOrder;
            out.vrActive = app.vrActive;
            
            % Intertrial Interval Settings
            out.minimumITI = app.minimumITI.Value; 
            out.randomITI = app.randomizeITI.Value; 
            if out.randomITI
                out.randomMeanITI = app.randomMeanITI.Value; 
                out.distributionITI = app.distributionITI.Value;
                out.distributionNameITI = app.distributionITI.Items{app.distributionITI.Value};
            else
                out.randomMeanITI = []; 
                out.distributionITI = [];
                out.distributionNameITI = '';
            end
            
            % Trial Structure Settings
            out.condReward = app.condProbRew.Value;
            out.condTrialReward = app.condTrialReward;
            if out.condReward
                out.randomReward = false;
                out.customRewardProb = false;
                out.customRewardFunction = '';
                out.randomRewardArray = [];
                out.randomRewardWindow = [];
                out.randomRewardWindowString = '';
            else
                out.randomReward = app.randReward.Value; 
                if out.randomReward
                    out.customRewardProb = app.customProbReward.Value; 
                    if out.customRewardProb
                        out.customRewardFunction = app.customProbRewardGenerator.Value;
                        out.randomRewardArray = [];
                        out.randomRewardWindow = [];
                        out.randomRewardWindowString = '';
                    else
                        out.customRewardFunction = '';
                        out.randomRewardArray = app.randRewardArray;
                        out.randomRewardWindow = app.randRewardWindow.Value;
                        out.randomRewardWindowString = app.randRewardWindow.Items{app.randRewardWindow.Value};
                    end
                else
                    out.customRewardProb = false;
                    out.customRewardFunction = '';
                    out.randomRewardArray = [];
                    out.randomRewardWindow = [];
                    out.randomRewardWindowString = '';
                end
            end
            
            % Backwards Movement control
            out.preventBackwardMovement = app.backwardsMovementSwitch.Value;
            
            % Trial Structure Active Licking
            out.condActiveLicking = app.condActiveLick.Value;
            out.condTrialActiveLicking = app.condTrialActiveLicking; 
            out.activeLicking = app.activeLicking.Value;
            
            % Handle Active Stopping
            out.condActiveStopping = app.condActiveStop.Value;
            out.condTrialActiveStopping = app.condTrialActiveStopping;
            out.activeStopping = app.activeStopping.Value;
            out.stopDuration = app.stopDuration.Value;

            % Trial Structure Movement Gain
            out.condGain = app.condMvmtGain.Value;
            out.condTrialGain = app.condTrialGain;
            if out.condGain
                out.movementGain = [];
                out.randomGain = false;
                out.customGain = false;
                out.customGainFunction = '';
                out.minGain = [];
                out.maxGain = [];
                out.randGainWindow = [];
                out.randGainWindowString = '';
            else
                out.movementGain = app.movementGain.Value;
                out.randomGain = app.randGain.Value;
                if out.randomGain
                    out.customGain = app.customGain.Value; 
                    if out.customGain
                        out.customGainFunction = app.customGainGenerator.Value;
                        out.minGain = [];
                        out.maxGain = [];
                        out.randGainWindow = [];
                        out.randGainWindowString = '';
                    else
                        out.customGainFunction = '';
                        out.minGain = app.minGain.Value;
                        out.maxGain = app.maxGain.Value;
                        out.randGainWindow = app.randGainWindow.Value;
                        out.randGainWindowString = app.randGainWindow.Items{app.randGainWindow.Value};
                    end
                else
                    out.customGain = false;
                    out.customGainFunction = '';
                    out.minGain = [];
                    out.maxGain = [];
                    out.randGainWindow = [];
                    out.randGainWindowString = '';
                end
            end
            
            % Trial Structure frequency of conditional trial types
            out.condTrialFreq = app.condTrialFreq;

            % Initial Block Settings
            out.initBlock = app.initActive.Value; 
            if out.initBlock
                out.initTrials = app.initNumTrials.Value;
                out.initEnvIdx = app.initEnvironment.Value; 
                out.initEnvName = app.envBaseNames{out.initEnvIdx};
            else
                out.initTrials = 0;
                out.initEnvIdx = []; 
                out.initEnvName = '';
            end

            % Block Structure Settings
            out.blockTypeNames = {'Preset','Random'};
            out.blockType = [app.presetBlocks.Value, app.randomBlocks.Value];
            if sum(out.blockType)~=1, error('Somehow the block type wasn''t clear. Multiple were selected.'); end
            % Initialize all possibilities, then set whatever is relevant
            out.blockTrialsPer = []; 
            out.evenTrialsPerEnv = [];
            out.blockRandomMean = [];
            out.evenRandMeanPerEnv = [];
            out.blockRandomDistribution = [];
            out.blockRandomDistributionName = '';
            if out.blockType(1)
                out.blockTrialsPer = app.vrNumPresetTrials; % List of num trials per environment in even blocks
                out.evenTrialsPerEnv = app.evenTrialsPerEnv.Value; % Toggle for whether we have even trial length blocks
            end
            if out.blockType(2)
                out.blockRandomMean = app.vrNumRandTrials; % List of random trial mean per environment in random blocks
                out.evenRandMeanPerEnv = app.evenRandMeanPerEnv.Value; % Toggle for whether random mean is same for each environment
                out.blockRandomDistribution = app.randomDistribution.Value;
                out.blockRandomDistributionName = app.randomDistribution.Items{app.randomDistribution.Value};
            end
        end
        
        function highlightComponent(app, component, property)
            if nargin < 3, property = 'BackgroundColor'; end
            if ~iscell(component), component = {component}; end
            numComponent = length(component);
            for nc = 1:numComponent
                cComponent = component{nc};
                if ~any(strcmp(fields(app),cComponent)), error('Requested component (%s) not a field of the app!', component{nc}); end
                if ~any(strcmp(fields(app.(cComponent)),property)), error('Requested component (%s) doesn''t have a %s!',component{nc}, property); end
            end
            timing = 0.05; % How long to wait before each flip
            numFlips = 3; % Number of flips to red
            gentleRed = [1,0.8,0.8]; % Red color to flip background to
            highlightColors = repmat({gentleRed},numComponent,2);
            for nc = 1:numComponent
                % Store previous color
                highlightColors{nc,1} = app.(component{nc}).(property);
            end
            for idx = 2:2*numFlips+1
                % Do flips
                for nc = 1:numComponent
                    app.(component{nc}).(property) = highlightColors{nc,mod(idx-1,2)+1};
                end
                pause(timing);
            end
        end

        function updateConditionalStructure(app)
            numTrialTypes = length(app.condTrialReward);
            if length(app.condTrialActiveLicking) ~= numTrialTypes || length(app.condTrialGain) ~= numTrialTypes || length(app.condTrialFreq) ~= numTrialTypes
                error('Conditional trial vectors don''t have same length...');
            end

            condRewardOn = app.condProbRew.Value;
            condActLickOn = app.condActiveLick.Value;
            condActStopOn = app.condActiveStop.Value;
            condGainOn = app.condMvmtGain.Value;
            if condRewardOn || condActLickOn || condActStopOn || condGainOn
                app.ConditionalTrialTypesTab.Title = '*Conditional Trial Types*';
            else
                app.ConditionalTrialTypesTab.Title = 'Conditional Trial Types';
            end

            if condRewardOn
                % Then turn off the independent control of p(reward)
                enableString = "off";
                app.rewProbNewFreq.Enable = enableString;
                app.rewProbNewProb.Enable = enableString;
                app.rewProbRemove.Enable = enableString;
                app.rewProbAddNew.Enable = enableString;
                app.rewProbNewFreqLabel.Enable = enableString;
                app.rewProbNewProbLabel.Enable = enableString;
                app.rewProbList.Enable = enableString;
                app.customProbReward.Enable = enableString;
                app.customProbRewardGenerator.Enable = enableString;
                app.randRewardWindow.Enable = enableString;
                app.randReward.Enable = enableString;
            else
                % Then turn on independent control of p(reward)
                app.randReward.Enable = "on";
                randRewardValueChanged(app)
                if app.randReward.Value
                    customProbRewardValueChanged(app)
                end
            end

            if condActLickOn
                % Turn off independent control of activeLicking
                app.activeLicking.Enable = "off";
            else
                % Turn on independent control of activeLicking
                app.activeLicking.Enable = "on";
            end
            
            if condActStopOn
                % Turn off independent control of activeStopping
                app.activeStopping.Enable = "off";
                app.stopDuration.Enable = "off";
                app.stopDurationLabel.Enable = "off";
            else
                % Turn on independent control of activeStopping
                app.activeStopping.Enable = "on";
                app.stopDuration.Enable = "on";
                app.stopDurationLabel.Enable = "on";
            end

            if condGainOn
                % Turn off independent control of movement gain
                enableString = "off";
                app.movementGain.Enable = enableString;
                app.movementGainLabel.Enable = enableString;
                app.maxGain.Enable = enableString;
                app.maxGainLabel.Enable = enableString;
                app.minGain.Enable = enableString;
                app.minGainLabel.Enable = enableString;
                app.customGainGenerator.Enable = enableString;
                app.customGain.Enable = enableString;
                app.randGainWindow.Enable = enableString;
                app.randGain.Enable = enableString;
            else
                % Turn on independent control of movement gain
                app.randGain.Enable = "on";
                app.movementGain.Enable = "on";
                app.movementGainLabel.Enable = "on";
                randGainValueChanged(app)
                if app.randGain.Value
                    customGainValueChanged(app)
                end
            end
            generateCondTrialList(app)
            condTrialListValueChanged(app)
        end
        
        function generateCondTrialList(app)
            condRewardOn = app.condProbRew.Value;
            condActLickOn = app.condActiveLick.Value;
            condActStopOn = app.condActiveStop.Value;
            condGainOn = app.condMvmtGain.Value;
            
            if condRewardOn || condActLickOn || condActStopOn || condGainOn

                condPerc = app.condTrialFreq / sum(app.condTrialFreq) * 100; 
                numCond = length(app.condTrialReward);
                app.condTrialList.Items = repmat({''}, numCond, 1);
                app.condTrialList.ItemsData = 1:numCond;
                for cond = 1:numCond
                    if condRewardOn
                        rewString = sprintf('P(R)=%.2f',app.condTrialReward(cond));
                        if condActLickOn || condActStopOn || condGainOn, rewPost = ', '; else, rewPost = ''; end
                    else
                        rewString = '';
                        rewPost = '';
                    end
                    if condActLickOn
                        actLickString = sprintf('AL=%d',app.condTrialActiveLicking(cond));
                        if condActStopOn || condGainOn, actLickPost = ', '; else, actLickPost = ''; end
                    else
                        actLickString = '';
                        actLickPost = '';
                    end
                    if condActStopOn
                        actStopString = sprintf('AS=%d',app.condTrialActiveStopping(cond));
                        if condGainOn, actStopPost = ', '; else, actStopPost = ''; end
                    else
                        actStopString = '';
                        actStopPost = '';
                    end
                    if condGainOn
                        gainString = sprintf('MG=%.2f',app.condTrialGain(cond));
                    else
                        gainString = sprintf('');
                    end
                    fullString = sprintf('%s%s%s%s%s%s%s, %.1f%%, F=%d',...
                        rewString,rewPost,actLickString,actLickPost,actStopString,actStopPost,gainString,condPerc(cond),app.condTrialFreq(cond));
                    app.condTrialList.Items{cond} = fullString;
                end
            else
                app.condTrialList.Items = {'conditional trial types off'};
                app.condTrialList.ItemsData = 1;
            end
        end
        
        function updatePresetTrialsList(app)
            numEnv = length(app.vrLength);
            app.presetTrialsList.Items = repmat({''},numEnv,1);
            app.presetTrialsList.ItemsData = 1:numEnv;
            if isempty(app.presetTrialsList.Value)
                app.presetTrialsList.Value = 1;
            end
            cindex = app.presetTrialsList.Value; 
            app.envTrials.Value = app.vrNumPresetTrials(cindex);
            for vrenv = 1:numEnv
                cEnvString = sprintf('%i - %s - #Trials:%d',vrenv, app.envBaseNames{vrenv}, app.vrNumPresetTrials(vrenv));
                app.presetTrialsList.Items{vrenv} = cEnvString;
            end
        end

        function updateRandomTrialsList(app)
            numEnv = length(app.vrLength);
            app.randomMeanList.Items = repmat({''},numEnv,1);
            app.randomMeanList.ItemsData = 1:numEnv;
            if isempty(app.randomMeanList.Value)
                app.randomMeanList.Value = 1;
            end
            cindex = app.randomMeanList.Value; 
            app.randomLengthMean.Value = app.vrNumRandTrials(cindex);
            for vrenv = 1:numEnv
                cEnvString = sprintf('%i - %s - #Trials:%d',vrenv, app.envBaseNames{vrenv}, app.vrNumRandTrials(vrenv));
                app.randomMeanList.Items{vrenv} = cEnvString;
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.rigInfo = vrControlRigParameters();
            app.UIFigure.Position([1 2]) = app.rigInfo.localFigurePosition; 
            app.lickEncoderAvailable.Value = app.rigInfo.lickEncoderAvailable; 

            % Do this upon startup to make sure it's consistent
            generateRewardProbList(app)
            generateCondTrialList(app)
            condTrialListValueChanged(app)
            validateVrDirectory(app, vrControlPersistent('vrDirectory'), true);
            app.animalName.Value = vrControlPersistent('animalName');
            app.settingsName.Value = vrControlPersistent('settingsName');
            app.useUpdateWindow.Value = vrControlPersistent('useUpdateWindow');
            loadSettingsButtonPushed(app)
        end

        % Value changed function: vrDirectory
        function vrDirectoryValueChanged(app, event)
            validateVrDirectory(app, app.vrDirectory.Value)
        end

        % Button pushed function: updateDirectory
        function updateDirectoryPushed(app, event)
            validateVrDirectory(app, uigetdir())
        end

        % Value changed function: vrExtension
        function vrExtensionValueChanged(app, event)
            genericExtensionSwitch = false;
            if genericExtensionSwitch
                app.vrExtension.Value = standardizeExtension(app); %#ok -- see string in presentMessage() in below else statement
                [~,~,fext] = fileparts(app.vrExtension.Value);
                if ~strcmp(fext, app.vrExtension.Value)
                    presentMessage(app,'Must provide valid file extension, reverting to default!',2);
                    app.vrExtension.Value = '.tif';
                    vrExtensionValueChanged(app,event) % Run again for certainty...
                end
            else
                app.vrExtension.Value = '.tif';
                presentMessage(app,'The only valid extension is .tif, will update to make generic in the future!', 1);
            end
        end

        % Value changed function: maxTrialNumber
        function maxTrialNumberValueChanged(app, event)
            app.initNumTrials.Limits = [0, app.maxTrialNumber.Value];
        end

        % Value changed function: envActive
        function envActiveValueChanged(app, event)
            envidx = app.envSettings.Value;
            app.vrActive(envidx) = app.envActive.Value;
            if app.vrActive(envidx)
                addEnvironment(app,envidx);
            else
                removeEnvironment(app,envidx);
            end
        end

        % Value changed function: vrenvOptions
        function vrenvOptionsValueChanged(app, event)
            clickTime = clock; % Time of selection
            selection = event.Value; % New list of values (should be a numeric index)
            updateSettingsMenus(app,selection)
            
            % If same option selected and double click, flip value
            timeSinceLast = clickTime - app.envOptionsLastClick;
            wasDoubleClick = ~any(timeSinceLast(1:5)) && timeSinceLast(6) < app.doubleClickTime;
            if selection==app.envOptionsLastSelection && wasDoubleClick
                addEnvironment(app,selection); % add environment to inUse listbox
            end

            % Deselect everything by default
            app.vrenvOptions.Value = []; 
            
            % Update Double Click Parameters
            app.envOptionsLastClick = clickTime;
            app.envOptionsLastSelection = selection;
        end

        % Value changed function: vrenvInUse
        function vrenvInUseValueChanged(app, event)
            clickTime = clock; % Time of selection
            selection = event.Value; % New list of values (should be a numeric index)
            updateSettingsMenus(app,selection)
            
            % If same option selected and double click, flip value
            timeSinceLast = clickTime - app.envInUseLastClick;
            wasDoubleClick = ~any(timeSinceLast(1:5)) && timeSinceLast(6) < app.doubleClickTime;
            if selection==app.envInUseLastSelection && wasDoubleClick
                removeEnvironment(app,selection); % add environment to inUse listbox
            end

            % Deselect everything by default
            app.vrenvInUse.Value = {}; 
            
            % Update Double Click Parameters
            app.envInUseLastClick = clickTime;
            app.envInUseLastSelection = selection;            
        end

        % Value changed function: envSettings
        function envSettingsValueChanged(app, event)
            updateSettingsMenus(app, event.Value);            
        end

        % Value changed function: envLength
        function envLengthValueChanged(app, event)
            envidx = app.envSettings.Value;
            pLength = app.vrLength(envidx);
            pPosition = app.vrRewPos(envidx);
            pTolerance = app.vrRewTol(envidx);
            nPosition = pPosition * app.envLength.Value / pLength;
            nTolerance = pTolerance * app.envLength.Value / pLength;
            app.vrRewPos(envidx) = nPosition;
            app.vrRewTol(envidx) = nTolerance;
            app.vrLength(envidx) = app.envLength.Value;
            updateSettingsMenus(app,envidx);
            envSettingsChanged(app,envidx) % propagate new setting throughout GUI
            presentMessage(app,sprintf('Length changed to %dcm for environment %d. Note that reward position & tolerance change relatively with length!',app.envLength.Value,envidx),1)
        end

        % Value changed function: dsFactor
        function dsFactorValueChanged(app, event)
            % first check if dsFactor leads to integer frames
            envidx = app.envSettings.Value;
            prevValue = event.PreviousValue;
            newValue = event.Value;
            frames = app.vrFrames(envidx);
            dsFrames = frames/newValue;
            if mod(dsFrames,1) ~= 0
                app.dsFactor.Value = prevValue;
                presentMessage(app,sprintf('dsFactor must divide %d frames for environment %d!',frames,envidx),2)
            else
                app.vrDSFactor(envidx) = newValue;
                app.vrFramesDS(envidx) = dsFrames;
                envSettingsChanged(app,envidx);
                presentMessage(app,sprintf('dsFactor changed to %d for environment %d, new frames=%d',newValue,envidx,dsFrames),1)
            end
        end

        % Value changed function: rewardPosition
        function rewardPositionValueChanged(app, event)
            envidx = app.envSettings.Value;
            app.vrRewPos(envidx) = app.rewardPosition.Value;
            envSettingsChanged(app,envidx);
            rewUnits = 'cm';
            presentMessage(app,sprintf('Reward position changed to %d%s for environment %d',app.rewardPosition.Value,rewUnits,envidx),1)
        end

        % Value changed function: rewardTolerance
        function rewardToleranceValueChanged(app, event)
            envidx = app.envSettings.Value;
            app.vrRewTol(envidx) = app.rewardTolerance.Value;
            envSettingsChanged(app,envidx);
            rewUnits = 'cm';
            presentMessage(app,sprintf('Reward tolerance changed to %d%s for environment %d',app.rewardTolerance.Value,rewUnits,envidx),1)
        end

        % Value changed function: envOrder
        function envOrderValueChanged(app, event)
            envidx = app.envSettings.Value; % current environment in settings 
            envorder = app.envOrder.Value; % new order for current environment

            idxActive = find(app.vrActive); % index of all active
            idxSelected = find(idxActive==envidx); % index of current environment among currently active
            prevOrder = app.vrOrder(idxActive); % previous order of all active
            
            newOrder = prevOrder; % setup new order array
            newOrder(idxSelected) = envorder; % update selected environment's order

            % Only one of these will happen...
            idxAboveOld = prevOrder>prevOrder(idxSelected) & prevOrder<=envorder;
            idxBelowOld = prevOrder<prevOrder(idxSelected) & prevOrder>=envorder;
            newOrder(idxAboveOld) = newOrder(idxAboveOld) - 1;
            newOrder(idxBelowOld) = newOrder(idxBelowOld) + 1;
            if any(idxAboveOld) && any(idxBelowOld)
                error('both these have trues!!');
            end

            % Update order!
            app.vrOrder(idxActive) = newOrder;
            if length(unique(app.vrOrder(idxActive))) < length(idxActive)
                error('order repeated somewhere');
            end
            
            % Update in use menu
            [~,newOrderIdx] = sort(newOrder);
            for env = 1:length(newOrderIdx)
                cenv = idxActive(newOrderIdx(env));
                app.vrenvInUse.Items{env} = app.envRichNames{cenv};
                app.vrenvInUse.ItemsData(env) = cenv;
            end

            % And update current environment's settings menu
            updateSettingsMenus(app,envidx) 
        end

        % Value changed function: presetBlocks
        function presetBlocksValueChanged(app, event)
            if app.presetBlocks.Value==0
                error('this should never be 0 after a user interaction');
            end
            changeBlockStructure(app, 'preset')
        end

        % Value changed function: randomBlocks
        function randomBlocksValueChanged(app, event)
            if app.randomBlocks.Value==0
                error('this should never be 0 after a user interaction');
            end
            changeBlockStructure(app, 'random')
        end

        % Button pushed function: printenvironmentinfoButton
        function printenvironmentinfoButtonPushed(app, event)
            filename = string(app.envBaseNames)';
            length = string(cellfun(@(length) sprintf('%dcm',length), num2cell(app.vrLength), 'uni', 0));
            rewPos = string(cellfun(@(rewpos) sprintf('%dcm',rewpos), num2cell(app.vrRewPos), 'uni', 0));
            rewTol = string(cellfun(@(rewtol) sprintf('%dcm',rewtol), num2cell(app.vrRewTol), 'uni', 0));
            
            frames = app.vrFrames;
            dsFrames = app.vrFramesDS;
            ds_factor = app.vrDSFactor;
            
            order = app.vrOrder;
            active = app.vrActive;
            tbl = table(filename,length,rewPos,rewTol,frames,dsFrames,ds_factor,order,active);
            disp(tbl);
        end

        % Callback function
        function printappvrDirectoryButtonPushed(app, event)
            display(app.vrDirectory.Value)
            [pth,name,ext] = fileparts(app.vrDirectory.Value);
            fprintf('Path: %s, name: %s, ext: %s \n', pth,name,ext);
        end

        % Value changed function: initActive
        function initActiveValueChanged(app, event)
           updateInitialBlockMenu(app)            
        end

        % Value changed function: initNumTrials
        function initNumTrialsValueChanged(app, event)
            updateInitialBlockMenu(app)
        end

        % Callback function
        function initBlockFeaturesButtonPushed(app, event)
            disp('activeValue');
            display(app.initActive.Value);
            disp('envValue');
            display(app.initEnvironment.Value);
            disp('envItems');
            display(app.initEnvironment.Items);
            disp('envItemsData')
            display(app.initEnvironment.ItemsData);
            disp('envNumTrials')
            display(app.initNumTrials.Value);
            disp('envNumTrialsLimits')
            display(app.initNumTrials.Limits);
        end

        % Value changed function: sessionOffset
        function sessionOffsetValueChanged(app, event)
            if round(app.sessionOffset.Value / 100) * 100 ~= app.sessionOffset.Value
                presentMessage(app, sprintf('Session offset set to %i. It''s a ~very~ good idea to set this to a multiple of 100!',app.sessionOffset.Value), 2);
            end
        end

        % Value changed function: randomizeITI
        function randomizeITIValueChanged(app, event)
            if app.randomizeITI.Value, enableString = "on"; else, enableString = "off"; end
            app.distributionITI.Enable = enableString;
            app.randomMeanITI.Enable = enableString;
            app.randomMeanITILabel.Enable = enableString;
        end

        % Value changed function: randGain
        function randGainValueChanged(app, event)
            if app.randReward.Value || app.randGain.Value
                app.IndependentPRActiveLickingStoppingMovementGainTab.Title = '*Independent P(R), Active Licking & Stopping, Movement Gain*';
            else
                app.IndependentPRActiveLickingStoppingMovementGainTab.Title = 'Independent P(R), Active Licking & Stopping, Movement Gain';
            end
            if app.randGain.Value, enableString = "on"; else, enableString = "off"; end
            app.maxGain.Enable = enableString;
            app.maxGainLabel.Enable = enableString;
            app.minGain.Enable = enableString;
            app.minGainLabel.Enable = enableString;
            app.randGainWindow.Enable = enableString;
            app.customGain.Enable = enableString;
            app.customGainGenerator.Enable = enableString;
        end

        % Value changed function: randReward
        function randRewardValueChanged(app, event)
            if app.randReward.Value || app.randGain.Value
                app.IndependentPRActiveLickingStoppingMovementGainTab.Title = '*Independent P(Reward) & Movement Gain*';
            else
                app.IndependentPRActiveLickingStoppingMovementGainTab.Title = 'Independent P(Reward) & Movement Gain';
            end
            if app.randReward.Value, enableString = "on"; else, enableString = "off"; end
            app.rewProbRemove.Enable = enableString;
            app.rewProbAddNew.Enable = enableString;
            app.rewProbList.Enable = enableString;
            app.rewProbNewFreq.Enable = enableString;
            app.rewProbNewFreqLabel.Enable = enableString;
            app.rewProbNewProb.Enable = enableString;
            app.rewProbNewProbLabel.Enable = enableString;
            app.randRewardWindow.Enable = enableString;
            app.customProbRewardGenerator.Enable = enableString;
            app.customProbReward.Enable = enableString;
        end

        % Callback function
        function probRewardArrayValueChanged(app, event)
            str = app.probRewardArray.Value;
            app.randRewardArray = str2double(strsplit(strjoin(regexp(str,'(-)?\d+(\.\d+)?(e(-|+)\d+)?','match'),' ')));
            if any(app.randRewardArray<0) || any(app.randRewardArray>0)
                presentMessage(app, 'Random reward probability array must contain numbers in the set [0,1]', 2);
                app.probRewardArray.Value = '';
                app.randRewardArray = [];
            end
        end

        % Value changed function: customGainGenerator
        function customGainGeneratorValueChanged(app, event)
            if ~isempty(which(app.customGainGenerator.Value))
                presentMessage(app, 'Custom gain generator function is on path, but there''s currently no way of validating it!', 1);
            else
                app.customGain.Value = false;
                app.customGainGenerator.Value = '';
                app.minGain.Enable = "on";
                app.minGainLabel.Enable = "on";
                app.maxGain.Enable = "on";
                app.maxGainLabel.Enable = "on";
                app.randGainWindow.Enable = "on";
                presentMessage(app, 'Must provide custom gain generator function that is on matlab path to use custom gain!', 2);
                highlightComponent(app,'customGainGenerator');
            end
        end

        % Value changed function: customProbRewardGenerator
        function customProbRewardGeneratorValueChanged(app, event)
            if ~isempty(which(app.customProbRewardGenerator.Value))
                presentMessage(app, 'Custom p(reward) generator function is on path, but there''s currently no way of validating it!', 1);
            else
                app.customProbReward.Value = false;
                app.customProbRewardGenerator.Value = '';
                enableString = "on";
                app.rewProbRemove.Enable = enableString;
                app.rewProbAddNew.Enable = enableString;
                app.rewProbList.Enable = enableString;
                app.rewProbNewFreq.Enable = enableString;
                app.rewProbNewFreqLabel.Enable = enableString;
                app.rewProbNewProb.Enable = enableString;
                app.rewProbNewProbLabel.Enable = enableString;
                app.randRewardWindow.Enable = enableString;
                presentMessage(app, 'Must provide custom p(reward) generator function that is on matlab path to use custom p(reward)!', 2);
                highlightComponent(app,'customProbRewardGenerator');
            end
        end

        % Value changed function: customGain
        function customGainValueChanged(app, event)
            if app.customGain.Value
                if ~isempty(which(app.customGainGenerator.Value))
                    presentMessage(app, 'Switching to custom gain generator', 1);
                    enableString = "off";
                else
                    app.customGain.Value = false;
                    presentMessage(app, 'Can''t switch to custom gain generator without function that is on matlab path', 2);
                    highlightComponent(app, 'customGainGenerator');
                    enableString = "on";
                end
            else
                presentMessage(app, 'Switching to random uniform gain', 1);
                enableString = "on";
            end
            app.minGain.Enable = enableString;
            app.minGainLabel.Enable = enableString;
            app.maxGain.Enable = enableString;
            app.maxGainLabel.Enable = enableString;
            app.randGainWindow.Enable = enableString;
        end

        % Value changed function: customProbReward
        function customProbRewardValueChanged(app, event)
            if app.customProbReward.Value
                if ~isempty(which(app.customProbRewardGenerator.Value))
                    presentMessage(app, 'Switching to custom p(reward) generator', 1);
                    enableString = "off";
                else
                    app.customProbReward.Value = false;
                    presentMessage(app, 'Can''t switch to custom p(reward) generator without function that is on matlab path', 2);
                    highlightComponent(app, 'customProbRewardGenerator');
                    enableString = "on";
                end
            else
                presentMessage(app, 'Switching to random p(reward) from array', 1);
                enableString = "on";
            end
            app.rewProbRemove.Enable = enableString;
            app.rewProbAddNew.Enable = enableString;
            app.rewProbList.Enable = enableString;
            app.rewProbNewFreq.Enable = enableString;
            app.rewProbNewFreqLabel.Enable = enableString;
            app.rewProbNewProb.Enable = enableString;
            app.rewProbNewProbLabel.Enable = enableString;
            app.randRewardWindow.Enable = enableString;
        end

        % Button pushed function: rewProbAddNew
        function rewProbAddNewButtonPushed(app, event)
            newProb = app.rewProbNewProb.Value; 
            newFreq = app.rewProbNewFreq.Value;
            if ismember(newProb,app.randRewardArray(:,1))
                % Then the requested reward probability is already in list
                % Default behavior is to add the frequency
                idxExisting = find(ismember(app.randRewardArray(:,1), newProb));
                app.randRewardArray(idxExisting,2) = app.randRewardArray(idxExisting,2) + newFreq;
                presentMessage(app, 'New reward probability already in list-- added to it''s frequency', 1);
            else
                app.randRewardArray(end+1,:) = [newProb newFreq];
                presentMessage(app, 'New reward probability option added to list', 1);
            end
            generateRewardProbList(app)
        end

        % Button pushed function: rewProbRemove
        function rewProbRemoveButtonPushed(app, event)
            cIndex = app.rewProbList.Value; 
            if isempty(cIndex)
                presentMessage(app, 'Can''t remove if none selected', 2);
                return
            end
            if size(app.randRewardArray,1) == 1
                presentMessage(app, 'Can''t remove last option', 2);
                return
            end
            app.randRewardArray(cIndex,:) = [];
            generateRewardProbList(app)
            presentMessage(app, 'Removed reward probability from list', 1);
        end

        % Button pushed function: saveSettings
        function saveSettingsPushed(app, event)
            if isempty(app.rigInfo.expSettingsDir)
                presentMessage(app, 'Can''t save settings without defined experiment settings path (stored in vrControlRigParameters())', 2);
                return
            end
            if isempty(app.settingsName.Value)
                presentMessage(app, 'Can''t save settings without defined name', 2);
                highlightComponent(app, 'settingsName');
                return
            end
            settings = generateOutputStructure(app);
            savePath = fullfile(app.rigInfo.expSettingsDir,sprintf('%s.mat',app.settingsName.Value));
            save(savePath, 'settings');
            presentMessage(app, sprintf('Settings saved at: %s', savePath), 1);
        end

        % Button pushed function: loadSettings
        function loadSettingsButtonPushed(app, event)
            % Load new expSettings into the app, then load it as if...
            newSettingsName = uigetfile(app.rigInfo.expSettingsDir);
            if ~newSettingsName, return, end % If none selected, abort load
            [~,app.settingsName.Value] = fileparts(newSettingsName);
            vrControlPersistent('settingsName',app.settingsName.Value);
            figure(app.UIFigure);
            loadPath = fullfile(app.rigInfo.expSettingsDir,sprintf('%s.mat',app.settingsName.Value));
            if ~exist(loadPath,'file')
                error('This is incorrect below here...');
                presentMessage(app, 'Animal settings does not exist at: %s, check animal save path and animal name!', 2); %#ok need to fix the error
                highlightComponent(app, 'animalName');
                return
            end
            loadedSettings = load(loadPath,'settings');
            settings = loadedSettings.settings;
            
            % Load settings from current GUI window
            defaultSettings = generateOutputStructure(app);
            for field = fields(defaultSettings)
                % If the GUI has been updated to include new things, but
                % the settings file hasn't reflected that yet, then add the
                % default settings to the loaded settings struct and notify
                % the user. 
                if ~isfield(settings,field)
                    settings.(field) = defaultSettings.(field);
                    fprintf(2,'GUI contains parameter not found in loaded settings. ParameterName:{%s}\n',field);
                end
            end
            app.vrDirectory.Value = vrControlPersistent('vrDirectory',settings.vrDirectory);
            app.vrExtension.Value = vrControlPersistent('vrExtension',settings.vrExtension);
            % app.animalName.Value = vrControlPersistent('animalName',settings.animalName);
            app.sessionOffset.Value = vrControlPersistent('sessionOffset',settings.sessionOffset);
            app.maxTrialNumber.Value = vrControlPersistent('maxTrialNumber',settings.maxTrialNumber);
            app.maxTrialDuration.Value = vrControlPersistent('maxTrialDuration',settings.maxTrialDuration);
            app.useUpdateWindow.Value = vrControlPersistent('useUpdateWindow',settings.useUpdateWindow);
            
            % - below this are things that I don't really need persistent -
            app.envBaseNames = settings.vrOptions;
            app.vrLength = settings.vrLength;
            app.vrFrames = settings.vrFrames;
            app.vrFramesDS = settings.vrFramesDS;
            app.vrDSFactor = settings.vrDSFactor;
            app.vrRewPos = settings.vrRewPos; 
            app.vrRewTol = settings.vrRewTol;
            app.vrOrder = settings.vrOrder;
            app.vrActive = settings.vrActive;
            if isfield(settings,'preventBackwardMovement')
                app.backwardsMovementSwitch.Value = settings.preventBackwardMovement;
            else
                app.backwardsMovementSwitch.Value = 1;
            end
            app.minimumITI.Value = settings.minimumITI;
            app.randomizeITI.Value = settings.randomITI;
            if settings.randomITI
                app.randomMeanITI.Value = settings.randomMeanITI;
                app.distributionITI.Value = settings.distributionITI;
            end
            

            % Trial Structure Loading
            app.condProbRew.Value = settings.condReward;
            if settings.condReward
                app.condTrialReward = settings.condTrialReward;
            else
                app.randReward.Value = settings.randomReward;
                if settings.randomReward
                    app.customProbReward.Value = settings.customRewardProb;
                    if settings.customRewardProb
                        app.customProbRewardGenerator.Value = settings.customRewardFunction;
                    else
                        app.randRewardArray = settings.randomRewardArray;
                        app.randRewardWindow.Value = settings.randomRewardWindow;
                        generateRewardProbList(app)
                    end
                end
            end

            app.condActiveLick.Value = settings.condActiveLicking;
            if settings.condActiveLicking
                app.condTrialActiveLicking = settings.condTrialActiveLicking;
            end
            app.activeLicking.Value = settings.activeLicking;
            
            app.condActiveStop.Value = settings.condActiveStopping;
            if settings.condActiveStopping
                app.condTrialActiveStopping = settings.condTrialActiveStopping;
            end
            app.activeStopping.Value = settings.activeStopping;
            app.stopDuration.Value = settings.stopDuration;

            app.condMvmtGain.Value = settings.condGain;
            if settings.condGain
                app.condTrialGain = settings.condTrialGain;
            else
                app.movementGain.Value = settings.movementGain;
                app.randGain.Value = settings.randomGain;
                if settings.randomGain
                    app.customGain.Value = settings.customGain;
                    if settings.customGain
                        app.customGainGenerator.Value = settings.customGainFunction;
                    else
                        app.minGain.Value = settings.minGain;
                        app.maxGain.Value = settings.maxGain;
                        app.randGainWindow.Value = settings.randGainWindow;
                    end
                end
            end

            % And get the frequencies if there are conditional trials
            if settings.condReward || settings.condActiveLicking || settings.condActiveStopping || settings.condGain
                app.condTrialFreq = settings.condTrialFreq;
                needLength = true;
                if needLength && settings.condReward
                    numCondTrial = length(settings.condTrialReward);
                    needLength = false;
                end
                if needLength && settings.condActiveLicking
                    numCondTrial = length(settings.condTrialActiveLicking);
                    needLength = false;
                end
                if needLength && settings.condActiveStopping
                    numCondTrial = length(settings.condTrialActiveStopping);
                    needLength = false;
                end
                if needLength && settings.condGain
                    numCondTrial = length(settings.condTrialGain);
                end
                if ~settings.condReward, app.condTrialReward = ones(1,numCondTrial); end
                if ~settings.condActiveLicking, app.condTrialActiveLicking = app.activeLicking.Value*ones(1,numCondTrial); end
                if ~settings.condActiveStopping, app.condTrialActiveStopping = app.activeStopping.Value*app.stopDuration.Value*ones(1,numCondTrial); end
                if ~settings.condGain, app.condTrialGain = ones(1,numCondTrial); end
                if length(app.condTrialFreq) ~= numCondTrial
                    error('Conditional trial frequency doesn''t have same length as other conditional trial vectors...'); 
                end
            end

            % Finally, update conditional structure (which takes care of
            % independent settings too)
            updateConditionalStructure(app)

            updateInitialBlockMenu(app)
            app.initActive.Value = settings.initBlock;
            if settings.initBlock
                app.initEnvironment.Value = settings.initEnvIdx;
                app.initNumTrials.Value = settings.initTrials;
            end
            updateInitialBlockMenu(app)
            
            blockType = settings.blockType;
            blockNames = {'Preset','Random'};
            app.presetBlocks.Value = blockType(1);
            app.randomBlocks.Value = blockType(2);
            app.vrNumPresetTrials = app.envTrials.Value*ones(length(app.vrLength),1);
            app.vrNumRandTrials = app.randomLengthMean.Value*ones(length(app.vrLength),1);
            if blockType(1)
                app.vrNumPresetTrials = settings.blockTrialsPer;
                app.evenTrialsPerEnv.Value = settings.evenTrialsPerEnv;
            end
            if blockType(2)
                app.vrNumRandTrials = settings.blockRandomMean;
                app.evenRandMeanPerEnv.Value = settings.evenRandMeanPerEnv;
                app.randomDistribution.Value = settings.blockRandomDistribution;
            end
            updatePresetTrialsList(app);
            updateRandomTrialsList(app);
            
            % Now that everything is loaded, resume GUI operation
            changeBlockStructure(app, blockNames{blockType});
            loadEnvironmentOptions(app)
            randomizeITIValueChanged(app)
            presentMessage(app, 'Previous settings loaded!', 1);
        end

        % Value changed function: animalName
        function animalNameValueChanged(app, event)
            vrControlPersistent('animalName', app.animalName.Value);
        end

        % Callback function
        function printusrmessagesButtonPushed(app, event)
            disp(app.userMessages)
        end

        % Button pushed function: printrigparametersButton
        function printrigparametersButtonPushed(app, event)
            disp(app.rigInfo)
        end

        % Button pushed function: previewExperiment
        function previewExperimentButtonPushed(app, event)
            settings = generateOutputStructure(app);
            trialStructure = vrControlTrialStructure(settings);
            
            % Generate trial output structure
            trialStructure.envName = string(cellfun(@(idx) ...
                trialStructure.getEnvName(idx), num2cell(trialStructure.envIndex), 'uni', 0));

            tbl = table(...
                (1:trialStructure.maxTrials)', ...
                trialStructure.envIndex, ...
                trialStructure.envName, ...
                trialStructure.roomLength, ...
                trialStructure.rewardPosition, ...
                trialStructure.rewardTolerance, ...
                trialStructure.probReward, ...
                trialStructure.activeLick, ...
                trialStructure.activeStop, ...
                trialStructure.mvmtGain, ...
                trialStructure.intertrialInterval, ...
                'variableNames',{'Trial #','EnvIdx','EnvName','Length','RewPos','RewTol','P(R)','Act.Lick','StopDuration','MvmtGain','ITI'});
            disp(tbl)

            fprintf('Note: any randomness will be resampled when the actual experiment is run!! \n\n'); 

            % then print to screen here...
            
            % Immediate To-Do!!!
            % trials.vrIndex
            % trials.rewardLocation
            % trials.rewardAvailable
            % trials.activeLicking...
            % so on...
        end

        % Value changed function: condTrialList
        function condTrialListValueChanged(app, event)
            cCondIdx = app.condTrialList.Value;
            app.condProbRewSetting.Value = app.condTrialReward(cCondIdx);
            app.condActiveLickSetting.Value = app.condTrialActiveLicking(cCondIdx);
            app.condActiveStopDuration.Value = app.condTrialActiveStopping(cCondIdx);
            app.condMvmtGainSetting.Value = app.condTrialGain(cCondIdx);
            app.condFreqSetting.Value = app.condTrialFreq(cCondIdx);
        end

        % Value changed function: condProbRew
        function condProbRew_Pushed(app, event)
            updateConditionalStructure(app);
        end

        % Value changed function: condMvmtGain
        function condMvmtGainValueChanged(app, event)
            updateConditionalStructure(app);
        end

        % Value changed function: condActiveLick
        function condActiveLickValueChanged(app, event)
            if app.condActiveLick.Value
                if ~app.lickEncoderAvailable.Value
                    presentMessage(app, 'Note: according to hardware info (in rigInfo), lick encoder not available, so this setting is permitted but ignored!!', 2);
                    highlightComponent(app, 'lickEncoderAvailable', 'FontColor');
                end
            end           
            updateConditionalStructure(app);
        end

        % Value changed function: condActiveStop
        function condActiveStopValueChanged(app, event)
            updateConditionalStructure(app);
        end

        % Button pushed function: addnewButton
        function addnewButtonPushed(app, event)
            newProb = app.condProbRewSetting.Value; 
            newActLick = app.condActiveLickSetting.Value; 
            newActStop = app.condActiveStopDuration.Value; 
            newGain = app.condMvmtGainSetting.Value; 
            newFreq = app.condFreqSetting.Value;
            compareReward = newProb==app.condTrialReward; 
            compareActLick = newActLick==app.condTrialActiveLicking;
            compareActStop = newActStop==app.condTrialActiveStopping;
            compareGain = newGain==app.condTrialGain;
            if ~app.condProbRew.Value, compareReward(:)=true; end
            if ~app.condActiveLick.Value, compareActLick(:)=true; end
            if ~app.condActiveStop.Value, compareActStop(:)=true; end
            if ~app.condMvmtGain.Value, compareGain(:)=true; end
            idxAlready = find(compareReward & compareActLick & compareActStop & compareGain); 
            if ~isempty(idxAlready)
                % Then the requested conditional trial type is already in list
                % Default behavior is to add the frequency
                updatedFreq = app.condTrialFreq(idxAlready) + newFreq;
                if updatedFreq<=0
                    presentMessage(app, 'Trial type frequencies must be positive...', 2);
                    return
                end
                app.condTrialFreq(idxAlready) = updatedFreq;
                presentMessage(app, 'New conditional trial type already in list-- added to it''s frequency', 1);
            elseif length(idxAlready) > 1
                error('Found multiple identical conditional trial types...');
            else
                if newFreq<=0
                    presentMessage(app, 'Trial type frequencies must be positive...', 2);
                    return
                end
                app.condTrialReward(end+1) = newProb;
                app.condTrialActiveLicking(end+1) = newActLick;
                app.condTrialActiveStopping(end+1) = newActStop;
                app.condTrialGain(end+1) = newGain;
                app.condTrialFreq(end+1) = newFreq;
                presentMessage(app, 'New conditional trial type added to list', 1);
            end
            generateCondTrialList(app)
            app.condTrialList.Value = length(app.condTrialReward);
            condTrialListValueChanged(app)
        end

        % Button pushed function: removeButton
        function removeButtonPushed(app, event)
            cIndex = app.condTrialList.Value; 
            if isempty(cIndex)
                presentMessage(app, 'Can''t remove if none selected', 2);
                return
            end
            if length(app.condTrialReward) == 1
                presentMessage(app, 'Can''t remove last option', 2);
                return
            end
            app.condTrialReward(cIndex)=[];
            app.condTrialActiveLicking(cIndex)=[];
            app.condTrialGain(cIndex)=[];
            app.condTrialFreq(cIndex)=[];
            generateCondTrialList(app)
            condTrialListValueChanged(app)
            presentMessage(app, 'Removed conditional trial type from list', 1);
        end

        % Button pushed function: updatetrialtypeButton
        function updatetrialtypeButtonPushed(app, event)
            cIndex = app.condTrialList.Value;
            if isempty(cIndex)
                presentMessage(app, 'Can''t update if none selected', 2);
                return
            end
            app.condTrialReward(cIndex) = app.condProbRewSetting.Value;
            app.condTrialActiveLicking(cIndex) = app.condActiveLickSetting.Value;
            app.condTrialActiveStopping(cIndex) = app.condActiveStopDuration.Value;
            app.condTrialGain(cIndex) = app.condMvmtGainSetting.Value;
            app.condTrialFreq(cIndex) = app.condFreqSetting.Value;
            generateCondTrialList(app);
            condTrialListValueChanged(app);
            msg = 'Updated conditional trial type.'; 
            msgType = 1; 
            if app.condActiveLickSetting.Value && ~app.lickEncoderAvailable.Value
                msg = ['Updated conditional trial type. ',...
                    'Note: according to hardware info (in rigInfo), lick encoder not available, so this setting is permitted but ignored!!'];
                msgType = 2; 
            end
            presentMessage(app, msg, msgType);
            if msgType==2, highlightComponent(app,'lickEncoderAvailable','FontColor'); end
        end

        % Button pushed function: runExperiment
        function runExperimentButtonPushed(app, event)
            settings = generateOutputStructure(app);
            delete(app)
            vrControlRunExperiment(settings);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            doThisNonsense = false;
            if doThisNonsense
                answer = questdlg('Choose an option:', ...
                    'Closing vrControl GUI', 'Run Experiment', 'Save settings & close', 'Close without saving', 'Close without saving'); %#ok
                switch answer
                    case 'Run Experiment'
                        runExperimentButtonPushed(app);
                    case 'Save settings & close'
                        saveSettingsPushed(app);
                    case 'Close without saving'
                end
            end
            delete(app)
        end

        % Callback function
        function stopDurationValueChanged(app, event)
            if app.stopDuration.Value==0
                app.activeStopping.Value = false;
                app.stopDuration.Enable = "off";
                app.stopDurationLabel.Enable = "off";
            end
        end

        % Callback function
        function activeStoppingValueChanged(app, event)
            if app.activeStopping.Value
                app.stopDuration.Enable = "on";
                app.stopDurationLabel.Enable = "on";
                if app.stopDuration.Value == 0
                    % Make sure it's a valid value if stopping is on
                    app.stopDuration.Value = 1;
                end
            else
                app.stopDuration.Enable = "off";
                app.stopDurationLabel.Enable = "off";
            end
        end

        % Value changed function: envTrials
        function envTrialsValueChanged(app, event)
            if app.evenTrialsPerEnv.Value
                app.vrNumPresetTrials(:) = app.envTrials.Value;
            else
                cEnvIdx = app.presetTrialsList.Value;
                app.vrNumPresetTrials(cEnvIdx) = app.envTrials.Value;
            end
            updatePresetTrialsList(app);
        end

        % Value changed function: presetTrialsList
        function presetTrialsListValueChanged(app, event)
            cEnvIdx = app.presetTrialsList.Value;
            app.envTrials.Value = app.vrNumPresetTrials(cEnvIdx);
            updatePresetTrialsList(app);
        end

        % Value changed function: evenTrialsPerEnv
        function evenTrialsPerEnvValueChanged(app, event)
            if app.evenTrialsPerEnv.Value % If even for all -- set it to the currently displayed value
                app.vrNumPresetTrials(:) = app.envTrials.Value;
            end
            updatePresetTrialsList(app);
        end

        % Value changed function: randomLengthMean
        function randomLengthMeanValueChanged(app, event)
            if app.evenRandMeanPerEnv.Value
                app.vrNumRandTrials(:) = app.randomLengthMean.Value;
            else
                cEnvIdx = app.randomMeanList.Value;
                app.vrNumRandTrials(cEnvIdx) = app.randomLengthMean.Value;
            end
            updateRandomTrialsList(app);
        end

        % Value changed function: randomMeanList
        function randomMeanListValueChanged(app, event)
            cEnvIdx = app.randomMeanList.Value;
            app.randomLengthMean.Value = app.vrNumRandTrials(cEnvIdx);
            updateRandomTrialsList(app);
        end

        % Value changed function: evenRandMeanPerEnv
        function evenRandMeanPerEnvValueChanged(app, event)
            if app.evenRandMeanPerEnv.Value
                app.vrNumRandTrials(:) = app.randomLengthMean.Value;
            end
            updateRandomTrialsList(app);
        end

        % Value changed function: activeLicking
        function activeLickingValueChanged(app, event)
            if app.activeLicking.Value && ~app.lickEncoderAvailable.Value
                presentMessage(app, 'Note: according to hardware info (in rigInfo), lick encoder not available, so this setting is permitted but ignored!!', 2);
                highlightComponent(app, 'lickEncoderAvailable', 'FontColor');
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 200 900 520];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create topBox
            app.topBox = uitextarea(app.UIFigure);
            app.topBox.FontSize = 16;
            app.topBox.FontWeight = 'bold';
            app.topBox.Tooltip = {'Control a linear track experiment using pre-rendered movies.'};
            app.topBox.Position = [1 446 900 75];
            app.topBox.Value = {'vrControl'};

            % Create vrenvInUseLabel
            app.vrenvInUseLabel = uilabel(app.UIFigure);
            app.vrenvInUseLabel.HorizontalAlignment = 'center';
            app.vrenvInUseLabel.Position = [439 145 309 22];
            app.vrenvInUseLabel.Text = 'Virtual Environments In Use - Double Click to Deactivate';

            % Create vrenvInUse
            app.vrenvInUse = uilistbox(app.UIFigure);
            app.vrenvInUse.Items = {'path not defined'};
            app.vrenvInUse.Multiselect = 'on';
            app.vrenvInUse.ValueChangedFcn = createCallbackFcn(app, @vrenvInUseValueChanged, true);
            app.vrenvInUse.Enable = 'off';
            app.vrenvInUse.Tooltip = {'select virtual environments to use in session, these are from the directory selected above in "virtual environment path"'};
            app.vrenvInUse.Position = [285 1 616 145];
            app.vrenvInUse.Value = {};

            % Create vrenvOptionsLabel
            app.vrenvOptionsLabel = uilabel(app.UIFigure);
            app.vrenvOptionsLabel.HorizontalAlignment = 'center';
            app.vrenvOptionsLabel.Position = [1 145 278 22];
            app.vrenvOptionsLabel.Text = 'VR Options - Double Click to Activate';

            % Create vrenvOptions
            app.vrenvOptions = uilistbox(app.UIFigure);
            app.vrenvOptions.Items = {'path not defined'};
            app.vrenvOptions.Multiselect = 'on';
            app.vrenvOptions.ValueChangedFcn = createCallbackFcn(app, @vrenvOptionsValueChanged, true);
            app.vrenvOptions.Enable = 'off';
            app.vrenvOptions.Tooltip = {'select virtual environments to use in session, these are from the directory selected above in "virtual environment path"'};
            app.vrenvOptions.Position = [1 1 285 145];
            app.vrenvOptions.Value = {};

            % Create printenvironmentinfoButton
            app.printenvironmentinfoButton = uibutton(app.UIFigure, 'push');
            app.printenvironmentinfoButton.ButtonPushedFcn = createCallbackFcn(app, @printenvironmentinfoButtonPushed, true);
            app.printenvironmentinfoButton.Position = [767 153 131 22];
            app.printenvironmentinfoButton.Text = 'print environment info';

            % Create envActive
            app.envActive = uibutton(app.UIFigure, 'state');
            app.envActive.ValueChangedFcn = createCallbackFcn(app, @envActiveValueChanged, true);
            app.envActive.Enable = 'off';
            app.envActive.Tooltip = {'toggle to activate environment (redundant with item selection in listbox)'};
            app.envActive.Text = 'env active';
            app.envActive.Position = [810 186 88 22];

            % Create envOrderLabel
            app.envOrderLabel = uilabel(app.UIFigure);
            app.envOrderLabel.Enable = 'off';
            app.envOrderLabel.Position = [621 186 130 22];
            app.envOrderLabel.Text = 'Order in block structure';

            % Create envOrder
            app.envOrder = uidropdown(app.UIFigure);
            app.envOrder.Items = {'n/a', '1', '2'};
            app.envOrder.ItemsData = [-1 1 2];
            app.envOrder.ValueChangedFcn = createCallbackFcn(app, @envOrderValueChanged, true);
            app.envOrder.Enable = 'off';
            app.envOrder.Tooltip = {'determines order of environment in block structure (if random env selection is on, then this is irrelevant)'};
            app.envOrder.Position = [751 186 55 22];
            app.envOrder.Value = -1;

            % Create rewardToleranceLabel
            app.rewardToleranceLabel = uilabel(app.UIFigure);
            app.rewardToleranceLabel.HorizontalAlignment = 'right';
            app.rewardToleranceLabel.Enable = 'off';
            app.rewardToleranceLabel.Position = [756 212 102 22];
            app.rewardToleranceLabel.Text = 'Reward Tolerance';

            % Create rewardTolerance
            app.rewardTolerance = uieditfield(app.UIFigure, 'numeric');
            app.rewardTolerance.Limits = [0 2000];
            app.rewardTolerance.ValueChangedFcn = createCallbackFcn(app, @rewardToleranceValueChanged, true);
            app.rewardTolerance.Enable = 'off';
            app.rewardTolerance.Tooltip = {'length of reward zone in units of percentage or cm'};
            app.rewardTolerance.Position = [861 212 37 22];
            app.rewardTolerance.Value = 10;

            % Create rewardPositionLabel
            app.rewardPositionLabel = uilabel(app.UIFigure);
            app.rewardPositionLabel.Enable = 'off';
            app.rewardPositionLabel.Position = [621 212 93 22];
            app.rewardPositionLabel.Text = 'Reward Position';

            % Create rewardPosition
            app.rewardPosition = uieditfield(app.UIFigure, 'numeric');
            app.rewardPosition.Limits = [0 2000];
            app.rewardPosition.ValueChangedFcn = createCallbackFcn(app, @rewardPositionValueChanged, true);
            app.rewardPosition.Enable = 'off';
            app.rewardPosition.Tooltip = {'length of reward zone in units of percentage or cm'};
            app.rewardPosition.Position = [713 212 37 22];
            app.rewardPosition.Value = 200;

            % Create dsFactorLabel
            app.dsFactorLabel = uilabel(app.UIFigure);
            app.dsFactorLabel.HorizontalAlignment = 'right';
            app.dsFactorLabel.Enable = 'off';
            app.dsFactorLabel.Position = [749 237 112 22];
            app.dsFactorLabel.Text = 'Downsample Factor';

            % Create dsFactor
            app.dsFactor = uieditfield(app.UIFigure, 'numeric');
            app.dsFactor.Limits = [1 1000];
            app.dsFactor.RoundFractionalValues = 'on';
            app.dsFactor.ValueChangedFcn = createCallbackFcn(app, @dsFactorValueChanged, true);
            app.dsFactor.Enable = 'off';
            app.dsFactor.Tooltip = {'factor to downsample environment arrays (for quick loading and testing)'};
            app.dsFactor.Position = [865 237 33 22];
            app.dsFactor.Value = 120;

            % Create envLengthLabel
            app.envLengthLabel = uilabel(app.UIFigure);
            app.envLengthLabel.Enable = 'off';
            app.envLengthLabel.Position = [621 237 94 22];
            app.envLengthLabel.Text = 'Env Length (cm)';

            % Create envLength
            app.envLength = uieditfield(app.UIFigure, 'numeric');
            app.envLength.Limits = [1 2000];
            app.envLength.RoundFractionalValues = 'on';
            app.envLength.ValueChangedFcn = createCallbackFcn(app, @envLengthValueChanged, true);
            app.envLength.Enable = 'off';
            app.envLength.Tooltip = {'length of corridor (in centimeters)'};
            app.envLength.Position = [713 237 37 22];
            app.envLength.Value = 250;

            % Create envSettingsLabel
            app.envSettingsLabel = uilabel(app.UIFigure);
            app.envSettingsLabel.HorizontalAlignment = 'center';
            app.envSettingsLabel.Enable = 'off';
            app.envSettingsLabel.Position = [676 283 168 22];
            app.envSettingsLabel.Text = 'Update Environnment Settings';

            % Create envSettings
            app.envSettings = uidropdown(app.UIFigure);
            app.envSettings.Items = {'n/a'};
            app.envSettings.ValueChangedFcn = createCallbackFcn(app, @envSettingsValueChanged, true);
            app.envSettings.Enable = 'off';
            app.envSettings.Tooltip = {'select environment to update its settings'};
            app.envSettings.Position = [621 263 277 22];
            app.envSettings.Value = 'n/a';

            % Create environmentBlockTab
            app.environmentBlockTab = uitabgroup(app.UIFigure);
            app.environmentBlockTab.Tooltip = {'design block structure for virtual environments'};
            app.environmentBlockTab.Position = [332 166 282 120];

            % Create InitialTab
            app.InitialTab = uitab(app.environmentBlockTab);
            app.InitialTab.Title = 'Initial';

            % Create initEnvironmentLabel
            app.initEnvironmentLabel = uilabel(app.InitialTab);
            app.initEnvironmentLabel.Position = [6 23 73 22];
            app.initEnvironmentLabel.Text = 'Environment';

            % Create initEnvironment
            app.initEnvironment = uidropdown(app.InitialTab);
            app.initEnvironment.Items = {'n/a'};
            app.initEnvironment.ItemsData = -1;
            app.initEnvironment.Tooltip = {'set environment to be used for initial block'};
            app.initEnvironment.Position = [99 24 100 22];
            app.initEnvironment.Value = -1;

            % Create initNumTrialsLabel
            app.initNumTrialsLabel = uilabel(app.InitialTab);
            app.initNumTrialsLabel.Position = [6 49 94 22];
            app.initNumTrialsLabel.Text = 'Number of Trials';

            % Create initNumTrials
            app.initNumTrials = uieditfield(app.InitialTab, 'numeric');
            app.initNumTrials.Limits = [0 500];
            app.initNumTrials.RoundFractionalValues = 'on';
            app.initNumTrials.ValueChangedFcn = createCallbackFcn(app, @initNumTrialsValueChanged, true);
            app.initNumTrials.Tooltip = {'set number of trials in initial block'};
            app.initNumTrials.Position = [99 49 100 22];
            app.initNumTrials.Value = 10;

            % Create initActive
            app.initActive = uicheckbox(app.InitialTab);
            app.initActive.ValueChangedFcn = createCallbackFcn(app, @initActiveValueChanged, true);
            app.initActive.Tooltip = {'use an initial block of one environment, then switch to using all environments'};
            app.initActive.Text = 'Use Initial Block';
            app.initActive.Position = [6 72 107 22];

            % Create PresetTab
            app.PresetTab = uitab(app.environmentBlockTab);
            app.PresetTab.Tooltip = {'one environment per block, same number of trials for all blocks'};
            app.PresetTab.Title = '*Preset*';

            % Create presetTrialsList
            app.presetTrialsList = uilistbox(app.PresetTab);
            app.presetTrialsList.Items = {};
            app.presetTrialsList.ValueChangedFcn = createCallbackFcn(app, @presetTrialsListValueChanged, true);
            app.presetTrialsList.Position = [4 3 274 67];
            app.presetTrialsList.Value = {};

            % Create envTrialsLabel
            app.envTrialsLabel = uilabel(app.PresetTab);
            app.envTrialsLabel.HorizontalAlignment = 'right';
            app.envTrialsLabel.Position = [184 71 44 22];
            app.envTrialsLabel.Text = '# Trials';

            % Create envTrials
            app.envTrials = uieditfield(app.PresetTab, 'numeric');
            app.envTrials.Limits = [1 Inf];
            app.envTrials.ValueChangedFcn = createCallbackFcn(app, @envTrialsValueChanged, true);
            app.envTrials.Tooltip = {'set # of trials per environment for each block of that environment'};
            app.envTrials.Position = [232 72 46 22];
            app.envTrials.Value = 5;

            % Create evenTrialsPerEnv
            app.evenTrialsPerEnv = uibutton(app.PresetTab, 'state');
            app.evenTrialsPerEnv.ValueChangedFcn = createCallbackFcn(app, @evenTrialsPerEnvValueChanged, true);
            app.evenTrialsPerEnv.Tooltip = {'if toggled on, then all environments have same block length'};
            app.evenTrialsPerEnv.Text = 'equal blocks';
            app.evenTrialsPerEnv.Position = [101 73 83 20];
            app.evenTrialsPerEnv.Value = true;

            % Create presetBlocks
            app.presetBlocks = uicheckbox(app.PresetTab);
            app.presetBlocks.ValueChangedFcn = createCallbackFcn(app, @presetBlocksValueChanged, true);
            app.presetBlocks.Enable = 'off';
            app.presetBlocks.Tooltip = {'use preset block structure'};
            app.presetBlocks.Text = 'Preset Blocks';
            app.presetBlocks.Position = [6 72 95 22];
            app.presetBlocks.Value = true;

            % Create RandomTab
            app.RandomTab = uitab(app.environmentBlockTab);
            app.RandomTab.Tooltip = {'one environment per block, randomly selected number of trials per block'};
            app.RandomTab.Title = 'Random';

            % Create randomMeanList
            app.randomMeanList = uilistbox(app.RandomTab);
            app.randomMeanList.Items = {};
            app.randomMeanList.ValueChangedFcn = createCallbackFcn(app, @randomMeanListValueChanged, true);
            app.randomMeanList.Enable = 'off';
            app.randomMeanList.Position = [4 3 274 67];
            app.randomMeanList.Value = {};

            % Create randomLengthMeanLabel
            app.randomLengthMeanLabel = uilabel(app.RandomTab);
            app.randomLengthMeanLabel.Enable = 'off';
            app.randomLengthMeanLabel.Position = [211 72 36 22];
            app.randomLengthMeanLabel.Text = 'Mean';

            % Create randomLengthMean
            app.randomLengthMean = uieditfield(app.RandomTab, 'numeric');
            app.randomLengthMean.Limits = [1 Inf];
            app.randomLengthMean.RoundFractionalValues = 'on';
            app.randomLengthMean.ValueChangedFcn = createCallbackFcn(app, @randomLengthMeanValueChanged, true);
            app.randomLengthMean.Enable = 'off';
            app.randomLengthMean.Tooltip = {'mean for distribution selected above'};
            app.randomLengthMean.Position = [244 72 34 22];
            app.randomLengthMean.Value = 5;

            % Create randomDistribution
            app.randomDistribution = uidropdown(app.RandomTab);
            app.randomDistribution.Items = {'Poisson'};
            app.randomDistribution.ItemsData = 1;
            app.randomDistribution.Enable = 'off';
            app.randomDistribution.Tooltip = {'distribution used for setting each block length'};
            app.randomDistribution.Position = [131 72 76 22];
            app.randomDistribution.Value = 1;

            % Create evenRandMeanPerEnv
            app.evenRandMeanPerEnv = uibutton(app.RandomTab, 'state');
            app.evenRandMeanPerEnv.ValueChangedFcn = createCallbackFcn(app, @evenRandMeanPerEnvValueChanged, true);
            app.evenRandMeanPerEnv.Enable = 'off';
            app.evenRandMeanPerEnv.Tooltip = {'if toggled on, then all environments have same block length'};
            app.evenRandMeanPerEnv.Text = 'allsame';
            app.evenRandMeanPerEnv.Position = [74 72 54 22];
            app.evenRandMeanPerEnv.Value = true;

            % Create randomBlocks
            app.randomBlocks = uicheckbox(app.RandomTab);
            app.randomBlocks.ValueChangedFcn = createCallbackFcn(app, @randomBlocksValueChanged, true);
            app.randomBlocks.Tooltip = {'use random block structure'};
            app.randomBlocks.Text = 'Random';
            app.randomBlocks.Position = [6 72 67 22];

            % Create EnvironmentBlockStructureLabel
            app.EnvironmentBlockStructureLabel = uilabel(app.UIFigure);
            app.EnvironmentBlockStructureLabel.HorizontalAlignment = 'center';
            app.EnvironmentBlockStructureLabel.Position = [333 283 281 22];
            app.EnvironmentBlockStructureLabel.Text = 'Environment Block Structure';

            % Create messagestouserTextAreaLabel
            app.messagestouserTextAreaLabel = uilabel(app.UIFigure);
            app.messagestouserTextAreaLabel.HorizontalAlignment = 'center';
            app.messagestouserTextAreaLabel.Position = [68 253 191 22];
            app.messagestouserTextAreaLabel.Text = 'messages to user';

            % Create messagestouserTextArea
            app.messagestouserTextArea = uitextarea(app.UIFigure);
            app.messagestouserTextArea.Editable = 'off';
            app.messagestouserTextArea.Tooltip = {'This window displays messages to user. It updates to red if there is a passable error. All updates are stored and available upon output of vrControl GUI.  '};
            app.messagestouserTextArea.Position = [1 169 325 85];

            % Create trialSettingsTabs
            app.trialSettingsTabs = uitabgroup(app.UIFigure);
            app.trialSettingsTabs.Position = [309 307 592 140];

            % Create ConditionalTrialTypesTab
            app.ConditionalTrialTypesTab = uitab(app.trialSettingsTabs);
            app.ConditionalTrialTypesTab.Title = '*Conditional Trial Types*';
            app.ConditionalTrialTypesTab.BackgroundColor = [1 1 1];

            % Create removeButton
            app.removeButton = uibutton(app.ConditionalTrialTypesTab, 'push');
            app.removeButton.ButtonPushedFcn = createCallbackFcn(app, @removeButtonPushed, true);
            app.removeButton.Position = [483 5 56 22];
            app.removeButton.Text = 'remove';

            % Create addnewButton
            app.addnewButton = uibutton(app.ConditionalTrialTypesTab, 'push');
            app.addnewButton.ButtonPushedFcn = createCallbackFcn(app, @addnewButtonPushed, true);
            app.addnewButton.Position = [427 5 56 22];
            app.addnewButton.Text = 'add new';

            % Create condMvmtGain
            app.condMvmtGain = uibutton(app.ConditionalTrialTypesTab, 'state');
            app.condMvmtGain.ValueChangedFcn = createCallbackFcn(app, @condMvmtGainValueChanged, true);
            app.condMvmtGain.Text = 'mvmt gain cond.';
            app.condMvmtGain.Position = [427 26 112 22];

            % Create condActiveStop
            app.condActiveStop = uibutton(app.ConditionalTrialTypesTab, 'state');
            app.condActiveStop.ValueChangedFcn = createCallbackFcn(app, @condActiveStopValueChanged, true);
            app.condActiveStop.Text = 'active stop cond.';
            app.condActiveStop.Position = [427 47 112 22];

            % Create condActiveLick
            app.condActiveLick = uibutton(app.ConditionalTrialTypesTab, 'state');
            app.condActiveLick.ValueChangedFcn = createCallbackFcn(app, @condActiveLickValueChanged, true);
            app.condActiveLick.Text = 'active lick cond.';
            app.condActiveLick.Position = [427 68 112 22];
            app.condActiveLick.Value = true;

            % Create condProbRew
            app.condProbRew = uibutton(app.ConditionalTrialTypesTab, 'state');
            app.condProbRew.ValueChangedFcn = createCallbackFcn(app, @condProbRew_Pushed, true);
            app.condProbRew.Text = 'p(reward) cond.';
            app.condProbRew.Position = [427 89 112 22];
            app.condProbRew.Value = true;

            % Create condFreqSettingLabel
            app.condFreqSettingLabel = uilabel(app.ConditionalTrialTypesTab);
            app.condFreqSettingLabel.HorizontalAlignment = 'right';
            app.condFreqSettingLabel.Position = [320 5 62 22];
            app.condFreqSettingLabel.Text = 'Frequency';

            % Create condFreqSetting
            app.condFreqSetting = uieditfield(app.ConditionalTrialTypesTab, 'numeric');
            app.condFreqSetting.RoundFractionalValues = 'on';
            app.condFreqSetting.Position = [386 5 36 22];
            app.condFreqSetting.Value = 1;

            % Create condMvmtGainSettingLabel
            app.condMvmtGainSettingLabel = uilabel(app.ConditionalTrialTypesTab);
            app.condMvmtGainSettingLabel.HorizontalAlignment = 'right';
            app.condMvmtGainSettingLabel.Position = [318 26 64 22];
            app.condMvmtGainSettingLabel.Text = 'Mvmt Gain';

            % Create condMvmtGainSetting
            app.condMvmtGainSetting = uieditfield(app.ConditionalTrialTypesTab, 'numeric');
            app.condMvmtGainSetting.Limits = [0 Inf];
            app.condMvmtGainSetting.Tooltip = {'duration of active stop!'};
            app.condMvmtGainSetting.Position = [386 26 36 22];
            app.condMvmtGainSetting.Value = 1;

            % Create condActiveStopDurationLabel
            app.condActiveStopDurationLabel = uilabel(app.ConditionalTrialTypesTab);
            app.condActiveStopDurationLabel.HorizontalAlignment = 'right';
            app.condActiveStopDurationLabel.Position = [316 47 66 22];
            app.condActiveStopDurationLabel.Text = 'Active Stop';

            % Create condActiveStopDuration
            app.condActiveStopDuration = uieditfield(app.ConditionalTrialTypesTab, 'numeric');
            app.condActiveStopDuration.Limits = [0 Inf];
            app.condActiveStopDuration.Position = [386 47 36 22];

            % Create condActiveLickSettingLabel
            app.condActiveLickSettingLabel = uilabel(app.ConditionalTrialTypesTab);
            app.condActiveLickSettingLabel.HorizontalAlignment = 'right';
            app.condActiveLickSettingLabel.Position = [319 68 63 22];
            app.condActiveLickSettingLabel.Text = 'Active Lick';

            % Create condActiveLickSetting
            app.condActiveLickSetting = uieditfield(app.ConditionalTrialTypesTab, 'numeric');
            app.condActiveLickSetting.Limits = [0 1];
            app.condActiveLickSetting.RoundFractionalValues = 'on';
            app.condActiveLickSetting.Tooltip = {'whether active licks are required for this trial type'};
            app.condActiveLickSetting.Position = [386 68 36 22];
            app.condActiveLickSetting.Value = 1;

            % Create condProbRewSettingLabel
            app.condProbRewSettingLabel = uilabel(app.ConditionalTrialTypesTab);
            app.condProbRewSettingLabel.HorizontalAlignment = 'right';
            app.condProbRewSettingLabel.Position = [324 89 58 22];
            app.condProbRewSettingLabel.Text = 'P(reward)';

            % Create condProbRewSetting
            app.condProbRewSetting = uieditfield(app.ConditionalTrialTypesTab, 'numeric');
            app.condProbRewSetting.Limits = [0 1];
            app.condProbRewSetting.Position = [386 89 36 22];
            app.condProbRewSetting.Value = 1;

            % Create condTrialList
            app.condTrialList = uilistbox(app.ConditionalTrialTypesTab);
            app.condTrialList.Items = {'P(R)=1, AL=1, AS=1, MG=1, 100%, Freq=1'};
            app.condTrialList.ValueChangedFcn = createCallbackFcn(app, @condTrialListValueChanged, true);
            app.condTrialList.Position = [4 5 309 107];
            app.condTrialList.Value = 'P(R)=1, AL=1, AS=1, MG=1, 100%, Freq=1';

            % Create updatetrialtypeButton
            app.updatetrialtypeButton = uibutton(app.ConditionalTrialTypesTab, 'push');
            app.updatetrialtypeButton.ButtonPushedFcn = createCallbackFcn(app, @updatetrialtypeButtonPushed, true);
            app.updatetrialtypeButton.Position = [541 4 47 107];
            app.updatetrialtypeButton.Text = 'update trial type';

            % Create IndependentPRActiveLickingStoppingMovementGainTab
            app.IndependentPRActiveLickingStoppingMovementGainTab = uitab(app.trialSettingsTabs);
            app.IndependentPRActiveLickingStoppingMovementGainTab.Title = 'Independent P(R), Active Licking & Stopping, Movement Gain';
            app.IndependentPRActiveLickingStoppingMovementGainTab.BackgroundColor = [1 1 1];

            % Create stopDurationLabel
            app.stopDurationLabel = uilabel(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.stopDurationLabel.Position = [476 7 79 22];
            app.stopDurationLabel.Text = 'Stop Duration';

            % Create stopDuration
            app.stopDuration = uieditfield(app.IndependentPRActiveLickingStoppingMovementGainTab, 'numeric');
            app.stopDuration.Limits = [0 Inf];
            app.stopDuration.Position = [554 7 31 22];

            % Create activeStopping
            app.activeStopping = uicheckbox(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.activeStopping.Tooltip = {'If checked, will use lick encoder'};
            app.activeStopping.Text = 'Active Stopping';
            app.activeStopping.Position = [480 31 105 22];

            % Create activeLicking
            app.activeLicking = uicheckbox(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.activeLicking.ValueChangedFcn = createCallbackFcn(app, @activeLickingValueChanged, true);
            app.activeLicking.Enable = 'off';
            app.activeLicking.Tooltip = {'If checked, will use lick encoder'};
            app.activeLicking.Text = 'Active Licking';
            app.activeLicking.Position = [480 55 95 22];
            app.activeLicking.Value = true;

            % Create rewProbRemove
            app.rewProbRemove = uibutton(app.IndependentPRActiveLickingStoppingMovementGainTab, 'push');
            app.rewProbRemove.ButtonPushedFcn = createCallbackFcn(app, @rewProbRemoveButtonPushed, true);
            app.rewProbRemove.Enable = 'off';
            app.rewProbRemove.Position = [433 7 38 22];
            app.rewProbRemove.Text = 'rmv';

            % Create rewProbAddNew
            app.rewProbAddNew = uibutton(app.IndependentPRActiveLickingStoppingMovementGainTab, 'push');
            app.rewProbAddNew.ButtonPushedFcn = createCallbackFcn(app, @rewProbAddNewButtonPushed, true);
            app.rewProbAddNew.Enable = 'off';
            app.rewProbAddNew.Position = [433 28 38 22];
            app.rewProbAddNew.Text = 'add';

            % Create rewProbNewFreqLabel
            app.rewProbNewFreqLabel = uilabel(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.rewProbNewFreqLabel.HorizontalAlignment = 'right';
            app.rewProbNewFreqLabel.Enable = 'off';
            app.rewProbNewFreqLabel.Position = [328 7 62 22];
            app.rewProbNewFreqLabel.Text = 'Frequency';

            % Create rewProbNewFreq
            app.rewProbNewFreq = uieditfield(app.IndependentPRActiveLickingStoppingMovementGainTab, 'numeric');
            app.rewProbNewFreq.Limits = [0 Inf];
            app.rewProbNewFreq.Enable = 'off';
            app.rewProbNewFreq.Position = [394 7 36 22];
            app.rewProbNewFreq.Value = 1;

            % Create rewProbNewProbLabel
            app.rewProbNewProbLabel = uilabel(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.rewProbNewProbLabel.HorizontalAlignment = 'right';
            app.rewProbNewProbLabel.Enable = 'off';
            app.rewProbNewProbLabel.Position = [332 28 58 22];
            app.rewProbNewProbLabel.Text = 'P(reward)';

            % Create rewProbNewProb
            app.rewProbNewProb = uieditfield(app.IndependentPRActiveLickingStoppingMovementGainTab, 'numeric');
            app.rewProbNewProb.Limits = [0 1];
            app.rewProbNewProb.Enable = 'off';
            app.rewProbNewProb.Position = [394 28 36 22];
            app.rewProbNewProb.Value = 0.5;

            % Create customProbRewardGenerator
            app.customProbRewardGenerator = uieditfield(app.IndependentPRActiveLickingStoppingMovementGainTab, 'text');
            app.customProbRewardGenerator.ValueChangedFcn = createCallbackFcn(app, @customProbRewardGeneratorValueChanged, true);
            app.customProbRewardGenerator.Enable = 'off';
            app.customProbRewardGenerator.Tooltip = {'generator function for accepting trial structure and adding a custom reward probability value'};
            app.customProbRewardGenerator.Position = [354 59 117 22];

            % Create customProbReward
            app.customProbReward = uicheckbox(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.customProbReward.ValueChangedFcn = createCallbackFcn(app, @customProbRewardValueChanged, true);
            app.customProbReward.Enable = 'off';
            app.customProbReward.Tooltip = {'if selected, use custom reward probability function rather than P(reward) array. Enables if a valid custom p(rew) function is provided.'};
            app.customProbReward.Text = '';
            app.customProbReward.Position = [334 59 25 22];

            % Create rewProbList
            app.rewProbList = uilistbox(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.rewProbList.Items = {};
            app.rewProbList.Enable = 'off';
            app.rewProbList.Position = [165 7 164 81];
            app.rewProbList.Value = {};

            % Create randRewardWindow
            app.randRewardWindow = uidropdown(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.randRewardWindow.Items = {'Per Trial'};
            app.randRewardWindow.ItemsData = 1;
            app.randRewardWindow.Enable = 'off';
            app.randRewardWindow.Tooltip = {'can either randomize on each trial or each block'};
            app.randRewardWindow.Position = [334 89 138 22];
            app.randRewardWindow.Value = 1;

            % Create randReward
            app.randReward = uicheckbox(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.randReward.ValueChangedFcn = createCallbackFcn(app, @randRewardValueChanged, true);
            app.randReward.Enable = 'off';
            app.randReward.Tooltip = {'randomize reward probability on each trial'};
            app.randReward.Text = 'Random reward probability';
            app.randReward.Position = [166 89 165 22];

            % Create customGainGenerator
            app.customGainGenerator = uieditfield(app.IndependentPRActiveLickingStoppingMovementGainTab, 'text');
            app.customGainGenerator.ValueChangedFcn = createCallbackFcn(app, @customGainGeneratorValueChanged, true);
            app.customGainGenerator.Enable = 'off';
            app.customGainGenerator.Tooltip = {'generator function for accepting trial structure and adding a custom gain value'};
            app.customGainGenerator.Position = [27 7 134 22];

            % Create customGain
            app.customGain = uicheckbox(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.customGain.ValueChangedFcn = createCallbackFcn(app, @customGainValueChanged, true);
            app.customGain.Enable = 'off';
            app.customGain.Tooltip = {'if selected, use custom gain function rather than uniform random distribution. Enables if a valid custom gain function is provided.'};
            app.customGain.Text = '';
            app.customGain.Position = [8 7 25 22];

            % Create maxGainLabel
            app.maxGainLabel = uilabel(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.maxGainLabel.HorizontalAlignment = 'center';
            app.maxGainLabel.Enable = 'off';
            app.maxGainLabel.Position = [93 39 28 22];
            app.maxGainLabel.Text = 'max';

            % Create maxGain
            app.maxGain = uieditfield(app.IndependentPRActiveLickingStoppingMovementGainTab, 'numeric');
            app.maxGain.Limits = [1 10];
            app.maxGain.Enable = 'off';
            app.maxGain.Tooltip = {'maximum possible gain'};
            app.maxGain.Position = [122 39 39 22];
            app.maxGain.Value = 2;

            % Create minGainLabel
            app.minGainLabel = uilabel(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.minGainLabel.HorizontalAlignment = 'center';
            app.minGainLabel.Enable = 'off';
            app.minGainLabel.Position = [92 60 31 22];
            app.minGainLabel.Text = 'min';

            % Create minGain
            app.minGain = uieditfield(app.IndependentPRActiveLickingStoppingMovementGainTab, 'numeric');
            app.minGain.Limits = [0 1];
            app.minGain.Enable = 'off';
            app.minGain.Tooltip = {'minimum possible gain'};
            app.minGain.Position = [122 60 39 22];
            app.minGain.Value = 0.5;

            % Create randGainWindow
            app.randGainWindow = uidropdown(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.randGainWindow.Items = {'Per Trial'};
            app.randGainWindow.ItemsData = 1;
            app.randGainWindow.Enable = 'off';
            app.randGainWindow.Tooltip = {'can either randomize each trial or each block'};
            app.randGainWindow.Position = [8 40 84 22];
            app.randGainWindow.Value = 1;

            % Create randGain
            app.randGain = uicheckbox(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.randGain.ValueChangedFcn = createCallbackFcn(app, @randGainValueChanged, true);
            app.randGain.Tooltip = {'randomize gain between movement and VR corridor'};
            app.randGain.Text = 'Randomize';
            app.randGain.Position = [8 62 83 22];

            % Create movementGainLabel
            app.movementGainLabel = uilabel(app.IndependentPRActiveLickingStoppingMovementGainTab);
            app.movementGainLabel.Tooltip = {'sets the baseline gain -- advisable to set this =1 because it''s redundant with "env length"'};
            app.movementGainLabel.Position = [8 89 113 22];
            app.movementGainLabel.Text = 'Baseline Gain Value';

            % Create movementGain
            app.movementGain = uieditfield(app.IndependentPRActiveLickingStoppingMovementGainTab, 'numeric');
            app.movementGain.Limits = [0.01 10];
            app.movementGain.Tooltip = {'sets the baseline gain -- advisable to set this =1 because it''s redundant with "env length"'};
            app.movementGain.Position = [122 89 39 22];
            app.movementGain.Value = 1;

            % Create IntertrialTimingsPanel
            app.IntertrialTimingsPanel = uipanel(app.UIFigure);
            app.IntertrialTimingsPanel.Title = 'Intertrial Timings';
            app.IntertrialTimingsPanel.BackgroundColor = [1 1 1];
            app.IntertrialTimingsPanel.Position = [201 307 108 140];

            % Create distributionITI
            app.distributionITI = uidropdown(app.IntertrialTimingsPanel);
            app.distributionITI.Items = {'Uniform', 'Exponential'};
            app.distributionITI.ItemsData = [1 2];
            app.distributionITI.Tooltip = {'distribution used for generating ITIs'};
            app.distributionITI.Position = [5 7 97 22];
            app.distributionITI.Value = 2;

            % Create randomMeanITILabel
            app.randomMeanITILabel = uilabel(app.IntertrialTimingsPanel);
            app.randomMeanITILabel.HorizontalAlignment = 'right';
            app.randomMeanITILabel.Position = [2 35 53 22];
            app.randomMeanITILabel.Text = 'Mean ITI';

            % Create randomMeanITI
            app.randomMeanITI = uieditfield(app.IntertrialTimingsPanel, 'numeric');
            app.randomMeanITI.Limits = [0 Inf];
            app.randomMeanITI.Tooltip = {'mean of random ITI distribution'};
            app.randomMeanITI.Position = [64 35 37 22];
            app.randomMeanITI.Value = 0.5;

            % Create randomizeITI
            app.randomizeITI = uicheckbox(app.IntertrialTimingsPanel);
            app.randomizeITI.ValueChangedFcn = createCallbackFcn(app, @randomizeITIValueChanged, true);
            app.randomizeITI.Tooltip = {'randomize ITI times'};
            app.randomizeITI.Text = 'Randomize ITI';
            app.randomizeITI.Position = [5 64 100 22];
            app.randomizeITI.Value = true;

            % Create minimumITILabel
            app.minimumITILabel = uilabel(app.IntertrialTimingsPanel);
            app.minimumITILabel.Position = [6 93 49 22];
            app.minimumITILabel.Text = 'ITI (sec)';

            % Create minimumITI
            app.minimumITI = uieditfield(app.IntertrialTimingsPanel, 'numeric');
            app.minimumITI.Limits = [0 Inf];
            app.minimumITI.Tooltip = {'minimum intertrial interval. If randomize selected, then the random ITI duration is added to the minimum.'};
            app.minimumITI.Position = [55 93 46 22];
            app.minimumITI.Value = 1;

            % Create lickEncoderAvailable
            app.lickEncoderAvailable = uicheckbox(app.UIFigure);
            app.lickEncoderAvailable.Enable = 'off';
            app.lickEncoderAvailable.Tooltip = {'Reports whether lick encoder is available on current hardware (set in rigInfo)'};
            app.lickEncoderAvailable.Text = 'Lick Encoder Active (hardware)';
            app.lickEncoderAvailable.Position = [6 294 188 22];
            app.lickEncoderAvailable.Value = true;

            % Create useUpdateWindow
            app.useUpdateWindow = uicheckbox(app.UIFigure);
            app.useUpdateWindow.Text = 'Use Dynamic Update Window';
            app.useUpdateWindow.Position = [6 313 181 22];
            app.useUpdateWindow.Value = true;

            % Create settingsNameLabel
            app.settingsNameLabel = uilabel(app.UIFigure);
            app.settingsNameLabel.HorizontalAlignment = 'right';
            app.settingsNameLabel.Position = [1 335 84 22];
            app.settingsNameLabel.Text = 'Settings Name';

            % Create settingsName
            app.settingsName = uieditfield(app.UIFigure, 'text');
            app.settingsName.HorizontalAlignment = 'right';
            app.settingsName.Position = [90 335 106 22];

            % Create maxTrialDurationLabel
            app.maxTrialDurationLabel = uilabel(app.UIFigure);
            app.maxTrialDurationLabel.HorizontalAlignment = 'right';
            app.maxTrialDurationLabel.Position = [1 356 103 22];
            app.maxTrialDurationLabel.Text = 'Max Trial Duration';

            % Create maxTrialDuration
            app.maxTrialDuration = uieditfield(app.UIFigure, 'numeric');
            app.maxTrialDuration.Limits = [1 1200];
            app.maxTrialDuration.RoundFractionalValues = 'on';
            app.maxTrialDuration.Tooltip = {'maximum number of trials (will automatically end session after this trial is reached)'};
            app.maxTrialDuration.Position = [108 356 88 22];
            app.maxTrialDuration.Value = 60;

            % Create maxTrialNumberLabel
            app.maxTrialNumberLabel = uilabel(app.UIFigure);
            app.maxTrialNumberLabel.HorizontalAlignment = 'right';
            app.maxTrialNumberLabel.Position = [1 377 100 22];
            app.maxTrialNumberLabel.Text = 'Max Trial Number';

            % Create maxTrialNumber
            app.maxTrialNumber = uieditfield(app.UIFigure, 'numeric');
            app.maxTrialNumber.Limits = [1 2000];
            app.maxTrialNumber.RoundFractionalValues = 'on';
            app.maxTrialNumber.ValueChangedFcn = createCallbackFcn(app, @maxTrialNumberValueChanged, true);
            app.maxTrialNumber.Tooltip = {'maximum number of trials (will automatically end session after this trial is reached)'};
            app.maxTrialNumber.Position = [108 377 88 22];
            app.maxTrialNumber.Value = 500;

            % Create sessionOffsetLabel
            app.sessionOffsetLabel = uilabel(app.UIFigure);
            app.sessionOffsetLabel.HorizontalAlignment = 'right';
            app.sessionOffsetLabel.Position = [1 398 83 22];
            app.sessionOffsetLabel.Text = 'Session Offset';

            % Create sessionOffset
            app.sessionOffset = uieditfield(app.UIFigure, 'numeric');
            app.sessionOffset.Limits = [0 10000];
            app.sessionOffset.ValueChangedFcn = createCallbackFcn(app, @sessionOffsetValueChanged, true);
            app.sessionOffset.Tooltip = {'Will name each session: {AnimalName}_{SessionOffset+n}'};
            app.sessionOffset.Position = [90 398 106 22];
            app.sessionOffset.Value = 700;

            % Create animalNameLabel
            app.animalNameLabel = uilabel(app.UIFigure);
            app.animalNameLabel.HorizontalAlignment = 'right';
            app.animalNameLabel.Position = [1 419 78 22];
            app.animalNameLabel.Text = 'Animal Name';

            % Create animalName
            app.animalName = uieditfield(app.UIFigure, 'text');
            app.animalName.ValueChangedFcn = createCallbackFcn(app, @animalNameValueChanged, true);
            app.animalName.HorizontalAlignment = 'right';
            app.animalName.Tooltip = {'determines variable names and save location throughout code'};
            app.animalName.Position = [90 419 106 22];

            % Create vrDirectoryLabel
            app.vrDirectoryLabel = uilabel(app.UIFigure);
            app.vrDirectoryLabel.HorizontalAlignment = 'right';
            app.vrDirectoryLabel.Position = [678 495 134 22];
            app.vrDirectoryLabel.Text = 'virtual environment path';

            % Create fileextensionforenvironmentsLabel
            app.fileextensionforenvironmentsLabel = uilabel(app.UIFigure);
            app.fileextensionforenvironmentsLabel.HorizontalAlignment = 'right';
            app.fileextensionforenvironmentsLabel.Enable = 'off';
            app.fileextensionforenvironmentsLabel.Position = [698 470 168 22];
            app.fileextensionforenvironmentsLabel.Text = 'file extension for environments';

            % Create vrExtension
            app.vrExtension = uieditfield(app.UIFigure, 'text');
            app.vrExtension.ValueChangedFcn = createCallbackFcn(app, @vrExtensionValueChanged, true);
            app.vrExtension.Enable = 'off';
            app.vrExtension.Tooltip = {'file extension to use to look in virtual environment path (can include or omit leading period)'};
            app.vrExtension.Position = [873 471 28 21];
            app.vrExtension.Value = '.tif';

            % Create updateDirectory
            app.updateDirectory = uibutton(app.UIFigure, 'push');
            app.updateDirectory.ButtonPushedFcn = createCallbackFcn(app, @updateDirectoryPushed, true);
            app.updateDirectory.Position = [816 495 83 22];
            app.updateDirectory.Text = 'update path';

            % Create vrDirectory
            app.vrDirectory = uieditfield(app.UIFigure, 'text');
            app.vrDirectory.ValueChangedFcn = createCallbackFcn(app, @vrDirectoryValueChanged, true);
            app.vrDirectory.Position = [1 446 900 26];

            % Create runExperiment
            app.runExperiment = uibutton(app.UIFigure, 'push');
            app.runExperiment.ButtonPushedFcn = createCallbackFcn(app, @runExperimentButtonPushed, true);
            app.runExperiment.Position = [559 475 120 42];
            app.runExperiment.Text = 'run experiment';

            % Create previewExperiment
            app.previewExperiment = uibutton(app.UIFigure, 'push');
            app.previewExperiment.ButtonPushedFcn = createCallbackFcn(app, @previewExperimentButtonPushed, true);
            app.previewExperiment.Tooltip = {'print experiment structure generated from current settings to workspace -- NOTE! if there''s any random components, it will be resampled'};
            app.previewExperiment.Position = [434 475 120 42];
            app.previewExperiment.Text = 'preview experiment';

            % Create printrigparametersButton
            app.printrigparametersButton = uibutton(app.UIFigure, 'push');
            app.printrigparametersButton.ButtonPushedFcn = createCallbackFcn(app, @printrigparametersButtonPushed, true);
            app.printrigparametersButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.printrigparametersButton.Tooltip = {'upon startup, this GUI loads rig parameters. This button prints them to screen. Changing them requires hard coding the change in the relevant code'};
            app.printrigparametersButton.Position = [309 475 120 42];
            app.printrigparametersButton.Text = 'print rig parameters';

            % Create saveSettings
            app.saveSettings = uibutton(app.UIFigure, 'push');
            app.saveSettings.ButtonPushedFcn = createCallbackFcn(app, @saveSettingsPushed, true);
            app.saveSettings.Tooltip = {'save settings to: fullfile(rigInfo.expSettingsDir, sprintf(''vrControlSettings_%s.mat'',animalName))'};
            app.saveSettings.Position = [197 475 107 42];
            app.saveSettings.Text = 'save settings';

            % Create loadSettings
            app.loadSettings = uibutton(app.UIFigure, 'push');
            app.loadSettings.ButtonPushedFcn = createCallbackFcn(app, @loadSettingsButtonPushed, true);
            app.loadSettings.Tooltip = {'load settings from: fullfile(rigInfo.expSettingsDir, sprintf(''vrControlSettings_%s.mat'',animalName))'};
            app.loadSettings.Position = [85 475 107 42];
            app.loadSettings.Text = 'load settings';

            % Create backwardsMovementSwitch
            app.backwardsMovementSwitch = uicheckbox(app.UIFigure);
            app.backwardsMovementSwitch.Tooltip = {'If checked, mice can only move forwards in the VR environment.'};
            app.backwardsMovementSwitch.Text = 'Prevent backwards motion';
            app.backwardsMovementSwitch.Position = [6 273 188 23];
            app.backwardsMovementSwitch.Value = true;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = vrControlGUI

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
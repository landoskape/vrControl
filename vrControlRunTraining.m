function vrControlRunTraining(expSettings)
% vrControlRunExperiment takes in a settings structure (which is the output
% of the vrControlGUI)
% 
% -- ATL -- vrControlRunExperiment performs a blenderVR mouse experience  
% -- ATL -- Note that many evalc commands are used to minimize the output
% to the workspace from PsychToolbox, which I find annoying and distracting
% from what's relevant.
% 
% -- ATL -- In Progress / Needs Updates:
% Currently working on updating the giveReward code, it catches some frames
% when reward is given... why? 

%% -- vrControl uses four structures that are continuously passed through --
% 1. rigInfo: this contains rig information that doesn't change much
% 2. expInfo: this contains experiment settings, including trial type data
% 3. hwInfo: this contains hwInformation like the rotary/lick encoders
% 4. runInfo: this is continuously updated throughout each trial 
% 5. trialInfo: this is a struct that stores data collected each trial

%% 1. Retrieve rigInfo (hard coded parameters in vrControlRigParameters() function)

rigInfo = vrControlRigParameters(); 
rigInfo.wheelCircumference = 2*pi*rigInfo.wheelRadius; % ATTENTION TO MINUTE DETAIL

% define the UDP port
rigInfo = rigInfo.initialiseUDPports(rigInfo);

%% 2. Handle expInfo (trial parameters and experimental settings & info)

expInfo.animalName = expSettings.animalName;
expInfo.sessionName = expSettings.sessionOffset + 1; 
expInfo.dateStr = datestr(now, 'yyyymmdd');
while true
    % While loop ensures that the sessionName is novel
    expInfo.expRef = dat.constructExpRef(expInfo.animalName,now,expInfo.sessionName);
    expInfo.LocalDir = dat.expPath(expInfo.expRef, 'local', 'master');
    if exist(expInfo.LocalDir,'dir')
        expInfo.sessionName = expInfo.sessionName + 1; % try again
    else
        fprintf('Animal: %s --- Session Number: %d\n',expInfo.animalName, expInfo.sessionName);
        expInfo.sessionName = num2str(expInfo.sessionName);
        break
    end
end

% Create Directories (ATL: a lot of these are unnecessary...)
expInfo.ServerDir = dat.expPath(expInfo.expRef, 'main', 'master');
expInfo.AnimalDir = fullfile(expInfo.ServerDir, expInfo.animalName);
if ~isfolder(expInfo.AnimalDir), mkdir(expInfo.AnimalDir); end
if ~isfolder(expInfo.LocalDir), mkdir(expInfo.LocalDir); end
expInfo.SESSION_NAME=[expInfo.LocalDir filesep  expInfo.expRef '_VRBehavior'];
expInfo.centralLogName = [rigInfo.dirSave filesep 'centralLog'];
expInfo.animalLogName  = [expInfo.AnimalDir filesep expInfo.animalName '_log'];
expInfo.useUpdateWindow = expSettings.useUpdateWindow;

trialStructure = vrControlTrialStructure(expSettings); % convert expSettings to trialStructure

% Copy trial data from trial structure to expInfo
fields2copy = {'maxTrials','maxDuration','envIndex','roomLength','rewardPosition','rewardTolerance',...
    'intertrialInterval','probReward','activeLick','activeStop','mvmtGain','getEnvName'};
for f = 1:length(fields2copy), expInfo.(fields2copy{f}) = trialStructure.(fields2copy{f}); end

expInfo.lickEncoder = rigInfo.lickEncoderAvailable && ...
    any(expInfo.activeLick); % use for dynamically engaging with the lick encoder hardware

%% 3. Prepare hwInfo structure

intializePsychToolboxString = 'Screen(''Preference'',''VisualDebugLevel'', 0)';
evalc(intializePsychToolboxString);
Screen('Preference', 'SkipSyncTests', 1);

% Prepare Screen
thisScreen = rigInfo.screenNumber;
hwInfo.screenInfo = prepareScreenVR(thisScreen,rigInfo);

% define synchronization square read by photodiode
if strcmp(rigInfo.photodiodePos,'right')
    hwInfo.photodiodeRect = struct('rect',[(hwInfo.screenInfo.Xmax - rigInfo.photodiodeSize(1)) 0 ...
        hwInfo.screenInfo.Xmax      rigInfo.photodiodeSize(2) - 1], ...
        'colorOn', [1 1 1], 'colorOff', [0 0 0]);
elseif strcmp(rigInfo.photodiodePos,'left')
    hwInfo.photodiodeRect = struct('rect',[0 0 rigInfo.photodiodeSize(1)-1  ...
        rigInfo.photodiodeSize(2)-1], ...
        'colorOn', [1 1 1], 'colorOff', [0 0 0]);
end

if ~rigInfo.useKeyboard
    hwInfo.BALLPort = 9999;
    % Setup wheel hardware info
    hwInfo.session = daq.createSession('ni');
    hwInfo.session.Rate = rigInfo.NIsessRate;
    hwInfo.rotEnc = DaqRotaryEncoder;
    hwInfo.rotEnc.DaqSession = hwInfo.session;
    hwInfo.rotEnc.DaqId = rigInfo.NIdevID;
    hwInfo.rotEnc.DaqChannelId = rigInfo.NIRotEnc;
    hwInfo.rotEnc.createDaqChannel;
    hwInfo.rotEnc.zero();
    
    if expInfo.lickEncoder
        % Then we need to add a lick encoder
        hwInfo.likEnc = DaqLickEncoder;
        hwInfo.likEnc.DaqSession = hwInfo.session;
        hwInfo.likEnc.DaqId = rigInfo.NIdevID;
        hwInfo.likEnc.DaqChannelId = rigInfo.NILicEnc;
        hwInfo.likEnc = hwInfo.likEnc.createDaqChannel;
    end
    
    hwInfo.sessionVal = daq.createSession('ni');
    hwInfo.sessionVal.Rate = rigInfo.NIsessRate;
    
    hwInfo.rewVal = DaqRewardValve;
    load(rigInfo.WaterCalibrationFile);
    hwInfo.rewVal.DaqSession = hwInfo.sessionVal;
    hwInfo.rewVal.DaqId = rigInfo.NIdevID;
    hwInfo.rewVal.DaqChannelId = rigInfo.NIRewVal;
    hwInfo.rewVal.createDaqChannel;
    hwInfo.rewVal.MeasuredDeliveries = Water_calibs(end).measuredDeliveries;
    hwInfo.rewVal.OpenValue = 10;
    hwInfo.rewVal.ClosedValue = 0;
    hwInfo.rewVal.close;
    
    
    %#ATL: Needs updating:
    % -- 
    % Need to add hwInfo.rewVal.prepareRewardDelivery(obj, size, unitytype)
    % to the beginning of each trial (probably in prepareTrial)
    % - 
    % Need to change giveReward function to:
    % hwInfo.rewVal.activateDigitalDelivery(obj)
    % -
    % Need to add the info about the device and channels to rigInfo
    % - 
    % Need to figure out if the createSession line can be consolidated!
    % -
else
    % setup keyboard situation
    KbName('UnifyKeyNames');
    hwInfo.moveForward = KbName('UpArrow');
    hwInfo.moveBackward = KbName('DownArrow');
    hwInfo.increaseSpeed = KbName('RightArrow');
    hwInfo.decreaseSpeed = KbName('LeftArrow');
    hwInfo.minKeyboardSpeed = 1; % cm
    hwInfo.maxKeyboardSpeed = 9; % cm
    hwInfo.stepKeyboardSpeed = 1; % cm
    hwInfo.keyboardSpeed = 3; % cm
end


%% 4. Prepare runInfo structure

runInfo = [];
runInfo.rewardStartT = timer('TimerFcn', 'reward(0.0)');
runInfo.STOPrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', rigInfo.STOPvalveTime );
runInfo.BASErewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', rigInfo.BASEvalveTime );
runInfo.currTrial = 0;
runInfo.flipIdx = 0; % Counts flips throughout trial to store data in trialInfo
runInfo.roomPosition = rigInfo.minimumPosition; % current position
runInfo.move2NextTrial = 0;
runInfo.rewardAvailable = 1; % FLAG to determine if reward has been delivered on current trial (set to 0 if delivered)
runInfo.abort = 0; % turns to 1 if user aborts using the escape key
runInfo.inRewardZone = false;
runInfo.rewZoneTimerActive = false;
runInfo.timeInRewardZone = [];
runInfo.vrEnvIdx = [];
runInfo.pdLevel = 0; % always start at 0 because we have a ramp up from 0 indicating the ITI!
runInfo.totalValveOpenTime = 0; % for tracking duration of reward delivery
runInfo.trialStartTime = []; % timer for tracking duration of trial

% Load VR Environment File(s)
numOptions = length(expSettings.vrOptions);
idxInUse = unique(trialStructure.envIndex);
runInfo.vrEnvs = cell(1,numOptions);
fprintf(1, '#ATL: Loading environments from: %s\n', expSettings.vrDirectory);
for vrOpt = 1:numOptions
    if ~ismember(vrOpt, idxInUse), continue, end % only load environments that are in use
    cpath = trialStructure.getEnvPath(vrOpt);
    vrTifInfo = imfinfo(cpath);
    height = vrTifInfo(1).Height;
    width = vrTifInfo(1).Width;
    if length(vrTifInfo) ~= expSettings.vrFrames(vrOpt)
        error('Handshake between expSettings and trialStructure did not work out (or some earlier issue with the GUI occurred).');
    end
    numVrFrames = expSettings.vrFramesDS(vrOpt);
    fprintf(1, '#ATL: Loading %s, downsampling from %i frames to %i frames (dsratio:%i)...\n',...
        trialStructure.getEnvName(vrOpt), expSettings.vrFrames(vrOpt), expSettings.vrFramesDS(vrOpt), expSettings.vrDSFactor(vrOpt));
    runInfo.vrEnvs{vrOpt} = zeros(height,width,3,numVrFrames,'uint8');
    for f = 1:numVrFrames
        runInfo.vrEnvs{vrOpt}(:,:,:,f) = uint8(imread(cpath,(f-1)*expSettings.vrDSFactor(vrOpt)+1));
    end
end


%% 5. Prepare trialInfo structure

% We need to preallocate arrays for storing trial info from each vr frame
% There's an estimated maximum number of frames per trial based on the
% preferred refresh rate and the maximum trial duration
% This overAllocate factor overestimates that to make sure no failure
% occurs during the experiment
overAllocate = 1.1 * (2*rigInfo.PrefRefreshRate) * expSettings.maxTrialDuration; 

% Preallocate arrays for tracking data related to each trial
trialInfo.trialIdx = sparse(zeros(expSettings.maxTrialNumber,1)); % trial idx (should count up)
trialInfo.startTime = sparse(zeros(expSettings.maxTrialNumber,1)); % timestamp of trial start
trialInfo.startPosition = sparse(zeros(expSettings.maxTrialNumber,1)); % initial position within virtual environment
trialInfo.activeLicking = sparse(zeros(expSettings.maxTrialNumber,1)); % copy here for easy saving
trialInfo.activeStopping = sparse(zeros(expSettings.maxTrialNumber,1)); % copy here for easy saving
trialInfo.rewardPosition = sparse(zeros(expSettings.maxTrialNumber,1)); % copy here for easy saving
trialInfo.rewardTolerance = sparse(zeros(expSettings.maxTrialNumber,1)); % copy here for easy saving
trialInfo.vrEnvIdx = sparse(zeros(expSettings.maxTrialNumber,1)); % copy here for easy saving
trialInfo.iti = sparse(zeros(expSettings.maxTrialNumber,1)); % duration of true ITI (always greater than minimum requested)
trialInfo.outcome = sparse(zeros(expSettings.maxTrialNumber,1)); % was a reward delivered
trialInfo.rewardDeliveryFrame = sparse(zeros(expSettings.maxTrialNumber,1)); % the "count"(flip idx) in which reward delivered
trialInfo.rewardAvailable = sparse(zeros(expSettings.maxTrialNumber,1)); % boolean if reward was available on trial 
trialInfo.userRewardNumber = sparse(zeros(expSettings.maxTrialNumber,1)); % the number of user rewards given (using spacebar)
trialInfo.userRewardFrames = cell(expSettings.maxTrialNumber,1); % the frame idx during user reward delivery

% Preallocate arrays for tracking data related to each frame
trialInfo.time = sparse(zeros(expSettings.maxTrialNumber, overAllocate,'double'));
trialInfo.lick = sparse(zeros(expSettings.maxTrialNumber, overAllocate,'double'));
trialInfo.stop = sparse(zeros(expSettings.maxTrialNumber, overAllocate,'double')); 
trialInfo.inRewardZone = sparse(zeros(expSettings.maxTrialNumber, overAllocate,'double')); 
trialInfo.roomPosition = sparse(zeros(expSettings.maxTrialNumber, overAllocate,'double')); % position in corridor
trialInfo.frameIdx = sparse(zeros(expSettings.maxTrialNumber, overAllocate,'double')); % which frame is on
trialInfo.pdLevel = sparse(zeros(expSettings.maxTrialNumber, overAllocate,'double')); % whether the photodiode is up or down


%% 6. Open vrTrainingWindow

trainingWindow = vrControlTrainingWindow();
trainingWindow.setAvailableEnvironments(unique(expInfo.envIndex), expInfo.getEnvName);
trainingWindow.setCurrentTrial(1);
trainingWindow.envIdx.Value = expInfo.envIndex(1);
trainingWindow.minimumITI.Value = expInfo.intertrialInterval(1);
trainingWindow.envLength.Value = expInfo.roomLength(1);
trainingWindow.mvmtGain.Value = expInfo.mvmtGain(1);
trainingWindow.rewardPosition.Value = expInfo.rewardPosition(1);
trainingWindow.rewardTolerance.Value = expInfo.rewardTolerance(1);
trainingWindow.probReward.Value = expInfo.probReward(1);
trainingWindow.lickRequired.Value = expInfo.activeLick(1);
trainingWindow.stopRequired.Value = logical(expInfo.activeStop(1));
trainingWindow.stopDuration.Value = expInfo.activeStop(1);


%% -- now, prepare vrcontrol loop --

fprintf('\nStarting MouseBall session %s\n', datestr(now, 'mm-dd'));
GetSecs; %To get it started once

VRLogMessage(expInfo);
VRmessage = ['Starting new experiment with animal ' expInfo.animalName ':'];
VRLogMessage(expInfo, VRmessage);
VRLogMessage(expInfo);
try
    VRmessage = ['ExpStart ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
    rigInfo = rigInfo.sendUDPmessage(rigInfo, VRmessage);
    VRLogMessage(expInfo, VRmessage);
    if expInfo.useUpdateWindow
        disp('Press yellow start button to continue after confirming Timeline has started...')
        trainingWindow.enableStart();
        waitfor(trainingWindow, 'timelineActive', true);
    else
        disp('Press key to continue after confirming Timeline has started...')
        pause()
    end
catch
    keyboard
end

runInfo.ititimer = tic; % Initialize this here (usually reset in vrControlOperateTrial)
fhandle = @vrControlPrepareTrial;
while ~isempty(fhandle) 
    % main loop, active during experiment
    [fhandle, runInfo, trialInfo, expInfo] = feval(fhandle, rigInfo, hwInfo, expInfo, runInfo, trialInfo, trainingWindow);
end

fprintf(['TotalValveOpen = ' num2str(runInfo.totalValveOpenTime) ' ul\n']);
close all;
end

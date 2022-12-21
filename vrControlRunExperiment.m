function vrControlRunExperiment(expSettings)
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


%% 1. Retrieve rigInfo (hard coded parameters in vrControlRigParameters() function)

rigInfo = vrControlRigParameters(); 
rigInfo.wheelCircumference = 2*pi*rigInfo.wheelRadius; % ATTENTION TO MINUTE DETAIL

% define the UDP port
rigInfo.initialiseUDPports;

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
        fprintf('Session Number: %d\n',expInfo.sessionName);
        expInfo.sessionName = num2str(expInfo.sessionName);
        break
    end
end

% Create Directories (ATL: a lot of these are unnecessary...)
expInfo.ServerDir = dat.expPath(expInfo.expRef, 'main', 'master');
expInfo.AnimalDir = fullfile(expInfo.ServerDir, expInfo.animalName);
% if ~isfolder(expInfo.AnimalDir), mkdir(expInfo.AnimalDir); end
% if ~isfolder(expInfo.LocalDir), mkdir(expInfo.LocalDir); end
expInfo.SESSION_NAME=[expInfo.LocalDir filesep  expInfo.expRef '_VRBehavior'];
expInfo.centralLogName = [rigInfo.dirSave filesep 'centralLog'];
expInfo.animalLogName  = [expInfo.AnimalDir filesep expInfo.animalName '_log'];

trialStructure = vrControlTrialStructure(expSettings); % convert expSettings to trialStructure

% Load VR Environment File(s)
numOptions = length(expSettings.vrOptions);
idxInUse = unique(trialStructure.envIndex);
vrEnvs = cell(1,numOptions);
for vrOpt = 1:numOptions
    if ~ismember(vrOpt, idxInUse), continue, end
    cpath = trialStructure.getEnvPath(vrOpt);
    vrTifInfo = imfinfo(cpath);
    height = vrTifInfo(1).Height;
    width = vrTifInfo(1).Width;
    if length(vrTifInfo) ~= expSettings.vrFrames(vrOpt)
        error('Handshake between expSettings and trialStructure did not work out (or some earlier issue with the GUI occurred).');
    end
    numVrFrames = expSettings.vrFramesDS(vrOpt);
    fprintf(1, '#ATL: Loading %s, downsampling from %i frames to %i frames (dsratio:%i)...\n',...
        cpath, expSettings.vrFrames(vrOpt), expSettings.vrFramesDS(vrOpt), expSettings.vrDSFactor(vrOpt));
    vrEnvs{vrOpt} = zeros(height,width,3,numVrFrames,'uint8');
    for f = 1:numVrFrames
        vrEnvs{vrOpt}(:,:,:,f) = uint8(imread(cpath,(f-1)*frameDS+1));
    end
end

% Copy trial data from trial structure to expInfo
fields2copy = {'envIndex','roomLength','rewardPosition','rewardTolerance',...
    'intertrialInterval','probReward','activeLick','mvmtGain','activeStop'};
for f = 1:length(fields2copy), expInfo.(fields2copy{f}) = trialStructure.(fields2copy{f}); end


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

if any(expInfoactiveLick)
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


%% 4. Prepare runInfo structure

runInfo = [];
runInfo.rewardStartT = timer('TimerFcn', 'reward(0.0)');
runInfo.STOPrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.STOPvalveTime );
runInfo.BASErewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.BASEvalveTime );
runInfo.currTrial = 0;


%% -- now, prepare vrcontrol loop --

fprintf('\nStarting MouseBall session %s\n', datestr(now, 'mm-dd'));
GetSecs; %To get it started once

VRLogMessage(expInfo);
VRmessage = ['Starting new experiment with animal ' expInfo.animalName ':'];
VRLogMessage(expInfo, VRmessage);
VRLogMessage(expInfo);
try
    VRmessage = ['ExpStart ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
    rigInfo.sendUDPmessage(VRmessage);
    VRLogMessage(expInfo, VRmessage);
    disp('Press key to continue after confirming Timeline has started...')
    % If I don't call figure here, then pause hangs (because of the frame
    % rate / and pause lines in initializeScreen_Blender... dunno why)
    figure(1001); clf; 
    pause()
catch
    keyboard
end

runInfo.ititimer = tic; % Initialize this here (usually reset in operateTrial)
fhandle = @prepareNextTrial;
while ~isempty(fhandle) 
    % main loop, active during experiment
    [fhandle, runInfo] = feval(fhandle, rigInfo, hwInfo, expInfo, runInfo, vrEnvs);
end

fprintf(['TotalValveOpen = ' num2str(runInfo.REWARD.TotalValveOpenTime) ' ul\n']);
clear all; close all; clear mex;
end

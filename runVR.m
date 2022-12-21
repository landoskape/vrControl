function runVR(animalName, lickEncoder, runLocal)
%---------------------------------------
% Usage:    MouseBallExp
%           MouseBallExp(replay_in, offline_in, animal_in,lickencoder present)
%           MouseBallExp(1): To replay an experiment, 0: normal
%           MouseBallExp(x,1): To run/debug on computers that not
%           connected, 0: online
%           MouseBallExp(x,x,'animal'): animal name given in the command
%           line
% Adapted from original code written by Asli Ayaz and Aman Saleem and Mika
% Diamanti
% EB 2021-03: Streamlining scripts, add flickering for frequency tagging
% AA 2009-12: virtual reality for training mice
% AS 2012-15: Current update is of 2015 (Aman Saleem).

% rigInfo : Rig related parameters (is an object)
% hwInfo  : Hardware objects (more related to IO)
% expInfo : Experiment related parameters
% runInfo : Variables that change across multiple functions of the program


% -- ATL -- runVR performs a blenderVR mouse experience 
%
% Currently working on updating the giveReward code, it catches some frames
% when reward is given... why? Using masterCounter to find out. 
% I added a green square when mouse in reward zone...
% 


%% Initialize, settings, saving directories

% Switch for running on PC without using 2P rig
if nargin < 3, runLocal = false; end

intializePsychToolboxString = 'Screen(''Preference'',''VisualDebugLevel'', 0)';
evalc(intializePsychToolboxString);
Screen('Preference', 'SkipSyncTests', 1);

runInfo = [];
rigInfo = rigInfoVR;
expInfo.animalName = animalName;
expInfo.lickEncoder = lickEncoder;
expInfo.sessionName = 701; % use as seed for selection of session names (start @701 as unique session IDs for ATL)

while true
    expInfo.ExpRef = dat.constructExpRef(expInfo.animalName,now,expInfo.sessionName);
    expInfo.TheDir = dat.expPath(expInfo.ExpRef, 'local', 'master');
    if exist(expInfo.TheDir,'dir')
        expInfo.sessionName = expInfo.sessionName + 1;
    else
        fprintf('Session Number: %d\n',expInfo.sessionName);
        expInfo.sessionName = num2str(expInfo.sessionName);
        break
    end
end

expInfo.dateStr =  datestr(now, 'yyyymmdd');

% Create Directories
expInfo.ServerDir = dat.expPath(expInfo.ExpRef, 'main', 'master');
expInfo.AnimalDir = fullfile(expInfo.ServerDir, expInfo.animalName);
if ~isfolder(expInfo.AnimalDir), mkdir(expInfo.AnimalDir); end
if ~isfolder(expInfo.TheDir), mkdir(expInfo.TheDir); end

expInfo.SESSION_NAME=[expInfo.TheDir filesep  expInfo.ExpRef '_VRBehavior'];
expInfo.centralLogName = [rigInfo.dirSave filesep 'centralLog'];
expInfo.animalLogName  = [expInfo.AnimalDir filesep expInfo.animalName '_log'];

% Load VR Environment File(s)
frameDS = 6;
env2use = {'vrEnvironment_001.tif','vrEnvironment_003.tif'};
vrEnvPath = 'C:\Users\Experiment\Documents\vrAndrew\vrEnvironments';
numEnv = length(env2use);
vrEnvs = cell(1,numEnv);
fprintf(2, '#ATL: need handshake between vrEnvs and setExpInfoVR!!!\n');
for ne = 1:numEnv
    cpath = fullfile(vrEnvPath, env2use{ne});
    vrTifInfo = imfinfo(cpath);
    height = vrTifInfo(1).Height;
    width = vrTifInfo(1).Width;
    numRenderFrames = length(vrTifInfo);
    numVrFrames = numRenderFrames/frameDS;
    fprintf(1,'#ATL: Loading %s\n',vrEnvPath);
    fprintf(1,'#ATL: Number of frames on file: %d\n',numRenderFrames);
    fprintf(1,'#ATL: Downsampling to %d frames (dsratio:%d)...\n',numVrFrames,frameDS);
    vrEnvs{ne} = zeros(height,width,3,numVrFrames,'uint8');
    for f = 1:numVrFrames
        vrEnvs{ne}(:,:,:,f) = uint8(imread(cpath,(f-1)*frameDS+1));
    end
end
% Load All Experiment Settings
roomOfReward = [4, 3];
expInfo.EXP = setExpInfoVR(expInfo.animalName, rigInfo, numVrFrames, roomOfReward, true);
expInfo.EXP.wheelCircumference = 2 * pi * expInfo.EXP.wheelRadius;
expInfo.EXP.vrFilePath = vrEnvPath;
expInfo.EXP.env2use = env2use;
expInfo.EXP.vrFrameDS = frameDS;

expInfo.EXP.trialSwitch = 20; % run first environment for this many trials, then switch

% Prepare Screen
thisScreen = rigInfo.screenNumber;
hwInfo.screenInfo = prepareScreenVR(thisScreen,rigInfo);

% define synchronization square read by photodiode
if strcmp(rigInfo.photodiodePos,'right')
    rigInfo.photodiodeRect = struct('rect',[(hwInfo.screenInfo.Xmax - rigInfo.photodiodeSize(1)) 0 ...
        hwInfo.screenInfo.Xmax      rigInfo.photodiodeSize(2) - 1], ...
        'colorOn', [1 1 1], 'colorOff', [0 0 0]);
elseif strcmp(rigInfo.photodiodePos,'left')
    rigInfo.photodiodeRect = struct('rect',[0 0 rigInfo.photodiodeSize(1)-1  ...
        rigInfo.photodiodeSize(2)-1], ...
        'colorOn', [1 1 1], 'colorOff', [0 0 0]);
end

runInfo.rewardStartT = timer('TimerFcn', 'reward(0.0)');
runInfo.STOPrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.STOPvalveTime );
runInfo.BASErewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.BASEvalveTime );

% define the UDP port
hwInfo.BALLPort = 9999;
rigInfo.initialiseUDPports;

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
    hwInfo.likEnc = DaqLickEncoder;
    hwInfo.likEnc.DaqSession = hwInfo.session;
    hwInfo.likEnc.DaqId = rigInfo.NIdevID;
    hwInfo.likEnc.DaqChannelId = rigInfo.NILicEnc;
    hwInfo.likEnc = hwInfo.likEnc.createDaqChannel;
end

% hwInfo.sessionVal = daq.createSession('ni');
% hwInfo.sessionVal.Rate = rigInfo.NIsessRate;

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

GetSecs; %To get it started once

runInfo.currTrial = 0;
fprintf('\nStarting MouseBall session %s\n', datestr(now, 'mm-dd'));

% pause(1)
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

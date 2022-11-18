function runTraining(animalName, lickEncoder)
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

intializePsychToolboxString = 'Screen(''Preference'',''VisualDebugLevel'', 0)';
evalc(intializePsychToolboxString);
Screen('Preference', 'SkipSyncTests', 1);

runInfo =[];
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


% Load VR Environment File - Make this smarter for multiple environments
vrEnvPath = 'C:\Users\Experiment\Documents\vrAndrew\vrEnvironments\vrEnvironment_002.tif';
vrTifInfo = imfinfo(vrEnvPath);
height = vrTifInfo(1).Height;
width = vrTifInfo(1).Width;
frameDS = 1;
numRenderFrames = length(vrTifInfo);
numVrFrames = numRenderFrames/frameDS;
fprintf(1,'#ATL: Using vrEnvironment: %s\n',vrEnvPath);
fprintf(1,'#ATL: Number of frames on file: %d\n',numRenderFrames);
fprintf(1,'#ATL: Downsampling to %d frames (dsratio:%d)...\n',numVrFrames,frameDS);
vrEnv = ones(height,width,3,numVrFrames,'uint8');
% Grey screen!
% for f = 1:numVrFrames
%     vrEnv(:,:,:,f) = uint8(imread(vrEnvPath,(f-1)*frameDS+1));
% end

% Load All Experiment Settings
expInfo.EXP = setExpInfoVR(expInfo.animalName, rigInfo, numVrFrames, true);
expInfo.EXP.wheelCircumference = 2 * pi * expInfo.EXP.wheelRadius;
expInfo.EXP.vrFilePath = vrEnvPath;
expInfo.EXP.vrFrameDS = frameDS;

% Prepare Screen
thisScreen = rigInfo.screenNumber;
hwInfo.screenInfo = prepareScreenVR(thisScreen,rigInfo);

vrEnv = vrEnv * hwInfo.screenInfo.grayIndex; 

% define synchronization square read by photodiode
global gcount
gcount = 0; % global counter for updating photodiode 
if strcmp(rigInfo.photodiodePos,'right')
    rigInfo.photodiodeRect = struct('rect',[(hwInfo.screenInfo.Xmax - rigInfo.photodiodeSize(1)) 0 ...
        hwInfo.screenInfo.Xmax      rigInfo.photodiodeSize(2) - 1], ...
        'colorOn', [1 1 1], 'colorOff', [0 0 0]);
elseif strcmp(rigInfo.photodiodePos,'left')
    rigInfo.photodiodeRect = struct('rect',[0 0 rigInfo.photodiodeSize(1)-1  ...
        rigInfo.photodiodeSize(2)-1], ...
        'colorOn', [1 1 1], 'colorOff', [0 0 0]);
end
Screen('FillRect', hwInfo.screenInfo.windowPtr(1), mod(gcount,2)*255, rigInfo.photodiodeRect.rect);
Screen('Flip', hwInfo.screenInfo.windowPtr(1));
gcount = gcount + 1; % always update this!!!

runInfo.rewardStartT = timer('TimerFcn', 'reward(0.0)');
runInfo.STOPrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.STOPvalveTime );
runInfo.BASErewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.BASEvalveTime );
% runInfo.PASSrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.PASSvalveTime );
% runInfo.ACTVrewardStopT= timer('TimerFcn', 'reward(1.0)','StartDelay', expInfo.EXP.ACTVvalveTime );

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
try
    if rigInfo.sendTTL
        hwInfo.session.addDigitalChannel(...
            'Dev1', 'Port0/Line0', 'OutputOnly');
        hwInfo.session.outputSingleScan(false);
    end
catch ME
    disp(ME)
    rigInfo.sendTTL = 0;
end

if rigInfo.sendTTL
    expRef = getfield(dat.mpepMessageParse(['blah ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName]),'expRef');
    if ~expInfo.lickEncoder
        tl.start(expRef, {'rotaryEncoder'},fullfile('C:\Users\Experiment\Documents\Data\Timeline', expInfo.animalName, expInfo.dateStr, expInfo.sessionName, [expRef, '_Timeline']));
    else
        tl.start(expRef, {'rotaryEncoder', 'lickDetector'},fullfile('C:\Users\Experiment\Documents\Data\Timeline', expInfo.animalName, expInfo.dateStr, expInfo.sessionName, [expRef, '_Timeline']));
    end
end

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
    % rate / and pause lines in initializeScreen_Blender... dunno why
    figure(1001); clf; 
    pause()
catch
    keyboard
end

fhandle = @prepareNextTrial;
while ~isempty(fhandle) 
    % main loop, active during experiment
    [fhandle, runInfo] = feval(fhandle, rigInfo, hwInfo, expInfo, runInfo, vrEnv);
end
if exist('tl','var')
    tl.stop()
end
fprintf(['TotalValveOpen = ' num2str(runInfo.REWARD.TotalValveOpenTime) ' ul\n']);
clear all; close all; clear mex;
end

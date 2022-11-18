function [fhandle, runInfo] = prepareNextTrial(rigInfo, hwInfo, expInfo, runInfo, ~)
% prepareNextTrial - adapted by EB March 2021
% initializes trial specific information such us initializing base
% information
% #ATL: used to have rigInfo and hwInfo as first inputs...

fhandle =  @operateTrial;

global TRIAL % save trial specific info here

runInfo.currTrial = runInfo.currTrial + 1; 
runInfo.roomPosition = expInfo.EXP.minimumPosition; % current position
runInfo.move2NextTrial = 0;
runInfo.reward_active = 1; % FLAG to determine if reward has been delivered on current trial (set to 0 if delivered)

info = [];
info.no = runInfo.currTrial;
info.epoch = 0; %number of steps within a run loop
info.abort = 0;
TRIAL.info = info;
% TRIAL.trialStart(runInfo.currTrial) = runInfo.roomPosition;
% TRIAL.trialActive(runInfo.currTrial) = expInfo.EXP.activeLicking;
% TRIAL.trialOutcome(runInfo.currTrial) = nan;
% TRIAL.trialRewPos(runInfo.currTrial) = expInfo.EXP.rew_pos;

% Initialize data to save
overindexFactor = 1.1 * 2 * expInfo.EXP.PrefRefreshRate; 
if runInfo.currTrial == 1
    % Track each trial
    TRIAL.trialStart = nan(expInfo.EXP.maxTrials,1); %(runInfo.currTrial) = runInfo.roomPosition;
    TRIAL.trialActiveLicking = nan(expInfo.EXP.maxTrials,1); % expInfo.EXP.activeLicking;
    TRIAL.trialActiveStopping = nan(expInfo.EXP.maxTrials,1);
    TRIAL.trialRewPos = nan(expInfo.EXP.maxTrials,1); % expInfo.EXP.rew_pos;
    TRIAL.vrEnvIdx = nan(expInfo.EXP.maxTrials,1); % which vrEnv file does this trial use?
    TRIAL.trialIdx = nan(expInfo.EXP.maxTrials,1); % trial idx (should count up)
    TRIAL.trialBlankTime = nan(expInfo.EXP.maxTrials,1); % measures ITI (always before trial...)
    TRIAL.trialOutcome = nan(expInfo.EXP.maxTrials,1); % nan
    TRIAL.trialRewDelivery = nan(expInfo.EXP.maxTrials,1); % "count"(flip idx) in which reward delivered
    TRIAL.trialRewAvailable = nan(expInfo.EXP.maxTrials,1); % nan - 1 if reward available (from EXP.rewardProbability)
    
    % Track each frame
    TRIAL.time = nan(expInfo.EXP.maxTrials, expInfo.EXP.maxTrialDuration*overindexFactor,'double');
    TRIAL.lick = nan(expInfo.EXP.maxTrials, expInfo.EXP.maxTrialDuration*overindexFactor,'double');
    TRIAL.roomPosition = nan(expInfo.EXP.maxTrials, expInfo.EXP.maxTrialDuration*overindexFactor,'double'); % position in corridor
    TRIAL.frameIdx = nan(expInfo.EXP.maxTrials, expInfo.EXP.maxTrialDuration*overindexFactor,'double'); % which frame is on
    TRIAL.pdLevel = nan(expInfo.EXP.maxTrials, expInfo.EXP.maxTrialDuration*overindexFactor,'double');
end
if runInfo.currTrial==1
    runInfo.REWARD.TRIAL = [];
    runInfo.REWARD.count = [];
    runInfo.REWARD.TYPE  = [];
    runInfo.REWARD.TotalValveOpenTime = 0;
    runInfo.REWARD.STOP_VALVE_TIME = expInfo.EXP.STOPvalveTime;
    runInfo.REWARD.BASE_VALVE_TIME = expInfo.EXP.BASEvalveTime;
    runInfo.REWARD.PASS_VALVE_TIME = expInfo.EXP.PASSvalveTime;
    runInfo.REWARD.ACTV_VALVE_TIME = expInfo.EXP.ACTVvalveTime;
    runInfo.REWARD.USER_VALVE_TIME = expInfo.EXP.BASEvalveTime;
end

% Reset Values
runInfo.move2NextTrial = 0;
runInfo.inRewardZone = false;
runInfo.rewZoneTimerActive = false;
runInfo.timeInRewardZone = [];

ListenChar(2);

% Select vrEnv (for now, just start with one and switch eventuaally)
if runInfo.currTrial <= expInfo.EXP.trialSwitch
    runInfo.vrEnvIdx = 1;
else
    runInfo.vrEnvIdx = 2;
end

% Set TRIAL values (update each trial)
TRIAL.trialStart(runInfo.currTrial) = runInfo.roomPosition;
TRIAL.trialActiveLicking(runInfo.currTrial) = expInfo.EXP.activeLicking; % possible to make this update, for now it's just always the same
TRIAL.trialActiveStopping(runInfo.currTrial) = expInfo.EXP.activeStopping; % possible to make this update, ...
TRIAL.trialRewPos(runInfo.currTrial) = expInfo.EXP.rewardPosition(runInfo.vrEnvIdx); 
TRIAL.vrEnvIdx(runInfo.currTrial) = runInfo.vrEnvIdx;
TRIAL.trialIdx(runInfo.currTrial) = runInfo.currTrial;

rewAvailable = rand() < expInfo.EXP.rewardProbability;
TRIAL.trialRewAvailable(runInfo.currTrial) = rewAvailable;
if ~rewAvailable, runInfo.reward_active = 0; end

% Record trial start time to abort trial if it lasts too long
runInfo.trialStartTime = tic;


%% -- move on to operate trial --
runInfo.flipIdx = 0; % Counts flips throughout trial to store data in TRIAL

fprintf('TRIAL#:%d/%d, vrEnv:%d, RP:%.1fcm, AL:%d, AS:%d, RewAvailable:%d\n',...
    runInfo.currTrial, expInfo.EXP.maxTrials, runInfo.vrEnvIdx, ...
    TRIAL.trialRewPos(runInfo.currTrial),TRIAL.trialActiveLicking(runInfo.currTrial),...
    TRIAL.trialActiveStopping(runInfo.currTrial), TRIAL.trialRewAvailable(runInfo.currTrial));

% Perform Trial Initiation sequence
ifi = Screen('GetFlipInterval',hwInfo.screenInfo.windowPtr);
prefRefreshTime = 1/expInfo.EXP.PrefRefreshRate;
waitframes = round(prefRefreshTime / ifi);

% Reset PD signal to 0 before startup ramp
Screen('FillRect', hwInfo.screenInfo.windowPtr,0,rigInfo.photodiodeRect.rect);
vbl = Screen('Flip', hwInfo.screenInfo.windowPtr,0,2);

% Make sure pdSignal reaches 0
pause(0.1);

% Perform startup ramp
numPDTrialInitSamples = 20;
for ns = linspace(0, 1, numPDTrialInitSamples)
    Screen('FillRect', hwInfo.screenInfo.windowPtr, ns*255, rigInfo.photodiodeRect.rect);
    vbl = Screen('Flip', hwInfo.screenInfo.windowPtr,vbl+(waitframes-0.5)*ifi,2);
end

% Wait for desired ITI time
while toc(runInfo.ititimer) < expInfo.EXP.itiTime
    pause(0.0001) 
end

TRIAL.trialBlankTime(runInfo.currTrial) =  toc(runInfo.ititimer);
























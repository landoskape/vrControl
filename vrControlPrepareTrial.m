function [fhandle, runInfo, trialInfo] = vrControlPrepareTrial(rigInfo, hwInfo, expInfo, runInfo, trialInfo)

fhandle =  @vrControlOperateTrial;

runInfo.currTrial = runInfo.currTrial + 1; 
runInfo.flipIdx = 0; % Counts flips throughout trial to store data in trialInfo
runInfo.roomPosition = rigInfo.minimumPosition; % current position
runInfo.move2NextTrial = 0;
runInfo.rewardAvailable = 1; % FLAG to determine if reward has been delivered on current trial (set to 0 if delivered)
runInfo.abort = 0; % turns to 1 if user aborts using the escape key
runInfo.inRewardZone = false;
runInfo.rewZoneTimerActive = false;
runInfo.timeInRewardZone = [];
runInfo.vrEnvIdx = expInfo.envIndex(runInfo.currTrial);
runInfo.pdLevel = 0; % always start at 0 because we have a ramp up from 0 indicating the ITI!

ListenChar(2);

% Set TRIAL values (update each trial)
trialInfo.trialIdx(runInfo.currTrial) = runInfo.currTrial; % call me crazy
trialInfo.trialStartTime(runInfo.currTrial) = GetSecs; % time stamp!!!
trialInfo.trialStartPosition(runInfo.currTrial) = runInfo.roomPosition; % maybe we'll drop the mice in randomly sometimes...
trialInfo.trialActiveLicking(runInfo.currTrial) = expInfo.activeLick(runInfo.currTrial); % possible to make this update, for now it's just always the same
trialInfo.trialActiveStopping(runInfo.currTrial) = expInfo.activeStop(runInfo.currTrial); % possible to make this update, ...
trialInfo.trialRewPos(runInfo.currTrial) = expInfo.rewardPosition(runInfo.currTrial);
trialInfo.trialRewTol(runInfo.currTrial) = expInfo.rewardTolerance(runInfo.currTrial);
trialInfo.vrEnvIdx(runInfo.currTrial) = expInfo.envIndex(runInfo.currTrial);

rewAvailable = rand() < expInfo.probReward(runInfo.currTrial);
trialInfo.trialRewAvailable(runInfo.currTrial) = rewAvailable;
if ~rewAvailable, runInfo.rewardAvailable = 0; end % make it impossible to get a reward in this trial


fprintf('TRIAL#:%d/%d, vrEnv:%d, RP:%.1fcm, AL:%d, RewAvailable:%d\n',...
    runInfo.currTrial, length(expInfo.envIndex), runInfo.vrEnvIdx, expInfo.rewardPosition(runInfo.currTrial),...
    expInfo.activeLick(runInfo.currTrial),trialInfo.trialRewAvailable(runInfo.currTrial));

% Perform Trial Initiation sequence
ifi = Screen('GetFlipInterval',hwInfo.screenInfo.windowPtr);
prefRefreshTime = 1/rigInfo.PrefRefreshRate;
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
while toc(runInfo.ititimer) < expInfo.intertrialInterval(runInfo.currTrial)
    pause(0.0001) 
end

trialInfo.trialBlankTime(runInfo.currTrial) =  toc(runInfo.ititimer);
























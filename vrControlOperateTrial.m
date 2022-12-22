function [fhandle, runInfo, trialInfo] = vrControlOperateTrial(rigInfo, hwInfo, expInfo, runInfo, trialInfo)

fhandle = @vrControlTrialEnd;

% make a flip here to establish vbl
ifi = Screen('GetFlipInterval',hwInfo.screenInfo.windowPtr);
vbl = Screen('Flip',hwInfo.screenInfo.windowPtr,0,2);
prefRefreshTime = 1/rigInfo.PrefRefreshRate;
waitframes = round(prefRefreshTime / ifi);

myPort = pnet('udpsocket', hwInfo.BALLPort); % open udp port

% -- send trial start message --
trStartMessage = sprintf('TrialStart %s %s %s %d',...
    expInfo.animalName, expInfo.dateStr, expInfo.sessionName, runInfo.currTrial);
rigInfo.sendUDPmessage(trStartMessage); 
VRLogMessage(expInfo,trStartMessage);

roomLength = expInfo.roomLength(runInfo.currTrial);
numVRFrames = size(expInfo.vrEnvs{runInfo.vrEnvIdx},4);

runInfo.trialStartTimer = tic; % Start trial timer right before actual beginning of trial

% -- main program that operates the trial --
hwInfo.rotEnc.readPositionAndZero();
if expInfo.lickEncoder
    hwInfo.likEnc = hwInfo.likEnc.zero(); % set lick encoder to zero
end
while ~runInfo.move2NextTrial && ~runInfo.abort
    % Update every frame to index data storage in TRIAL structure
    runInfo.flipIdx = runInfo.flipIdx + 1;
   
    % Grab current frame from vrEnv array
    currentFrame = round(runInfo.roomPosition / roomLength * numVRFrames);
    currentFrame = max(1, currentFrame);
    currentFrame = min(numVRFrames, currentFrame);
    frame2show = expInfo.vrEnvs{runInfo.vrEnvIdx}(:,:,:,currentFrame);
    
    imageTexture = Screen('MakeTexture', hwInfo.screenInfo.windowPtr, frame2show); % Prepare frame for PTBs
    Screen('DrawTexture', hwInfo.screenInfo.windowPtr(1), imageTexture, [], hwInfo.screenInfo.screenRect, 0); % draw
    
    % Update photodiode sync square
    trialInfo.pdLevel(runInfo.currTrial,runInfo.flipIdx) = runInfo.pdLevel;
    Screen('FillRect', hwInfo.screenInfo.windowPtr, mod(runInfo.pdLevel,2)*255, rigInfo.photodiodeRect.rect);
    vbl=Screen('Flip', hwInfo.screenInfo.windowPtr,vbl+(waitframes-0.5)*ifi,2);
    runInfo.pdLevel = mod(runInfo.pdLevel+1,2); % update every photodiode flip
    
    % And send update to timeline (post flip is more accurate)
    % __FrameIdx (Animal) (Date) (Session) (FrameNum) (RoomPosition)
    frameMessage = sprintf('__FrameIdx %s %s %s %d %.1f',...
        expInfo.animalName, expInfo.dateStr, expInfo.sessionName, currentFrame, runInfo.roomPosition);
    rigInfo.sendUDPmessage(frameMessage, 2); 
    
    % Immediately after screen flip to optimize coordination bw VR and TL!
    trialInfo.time(runInfo.currTrial,runInfo.flipIdx) = vbl; % record time of screen flip
    trialInfo.frameIdx(runInfo.currTrial,runInfo.flipIdx) = currentFrame; % record which frame was presented
    trialInfo.roomPosition(runInfo.currTrial,runInfo.flipIdx) = runInfo.roomPosition;
    
    % --- mouse behavior --- MOVEMENT ---
    wheelPosition = hwInfo.rotEnc.readPositionAndZero;
    dbx = rigInfo.rotEncSign * wheelPosition; % apply correct sign for forward movement
    roomMovement = dbx / rigInfo.wheelToVR * rigInfo.wheelCircumference;
    if isnan(roomMovement), roomMovement=0; end % Inherited from previous code, don't know why this would ever be a nan
    % fprintf('Wheel Position: %.1f, Room Movement: %.1f\n', wheelPosition, roomMovement);
    runInfo.roomPosition = runInfo.roomPosition + roomMovement * expInfo.mvmtGain(runInfo.currTrial);
    
    % tell user if mouse speed was unusually fast...
    if roomMovement/prefRefreshTime >= rigInfo.maxSpeed
        fprintf(2, 'Mouse speed was recorded as %.2f cm/s!!!\n', roomMovement/prefRefreshTime);
    end
    % prevent mouse from moving before start of corridor
    runInfo.roomPosition = max(runInfo.roomPosition, rigInfo.minimumPosition);
    
    % --- mouse behavior --- LICKS ---
    if expInfo.lickEncoder
        [currLikStatus,hwInfo.likEnc] = hwInfo.likEnc.readPositionAndZero;
        if currLikStatus
            trialInfo.lick(runInfo.currTrial,runInfo.flipIdx) = 1;
        else
            trialInfo.lick(runInfo.currTrial,runInfo.flipIdx) = 0;
        end
    else
        trialInfo.lick(runInfo.currTrial,runInfo.flipIdx) = 0;
    end
    
    % --- mouse behavior --- STOPPING ---
    runInfo.inRewardZone = abs(runInfo.roomPosition - expInfo.rewardPosition(runInfo.currTrial)) < expInfo.rewardTolerance(runInfo.currTrial);
    if runInfo.inRewardZone && ~runInfo.rewZoneTimerActive
        % This means mouse entered reward zone
        runInfo.rewZoneTimerActive = true; % indicate that they entered reward zone
        runInfo.timeInRewardZone = tic; % start timer
    end
    if ~runInfo.inRewardZone && runInfo.rewZoneTimerActive
        % This means they left the reward zone
        runInfo.rewZoneTimerActive = false; % indicate that they've left reward zone
        runInfo.timeInRewardZone = []; % clear timer
    end
    
    % --- deliver rewards ---
    if runInfo.rewardAvailable % (1 if reward hasn't been delivered this trial and is available)
        % Only consider reward delivery if in reward zone
        if runInfo.inRewardZone
            % Determine if lick conditionality permits reward delivery
            if ~expInfo.activeLick(runInfo.currTrial) || ...
                    (expInfo.activeLicking(runInfo.currTrial) && trialInfo.lick(runInfo.currTrial, runInfo.flipIdx))
                lickValid = true; % If active licking + valid lick, or not active licking
            else
                lickValid = false; % Otherwise don't give reward yet
            end
            
            % Determine if lick conditionality permits reward delivery
            if ~expInfo.activeStop(runInfo.currTrial) || ...
                    (expInfo.activeStop(runInfo.currTrial) && ...
                    runInfo.rewZoneTimerActive && (toc(runInfo.timeInRewardZone) > expInfo.stopDuration))
                stopValid = true; % If active stopping + valid stop, or not active stopping
            else
                stopValid = false; % Otherwise don't give reward yet
            end
            
            % Give reward if in reward zone and lickValid and stopValid
            if lickValid && stopValid
                runInfo = vrControlGiveReward('PASSIVE', expInfo, runInfo, hwInfo);
                runInfo.rewardAvailable = 0;
                % trial outcome used to indicate active vs. passive
                trialInfo.trialRewDelivery(runInfo.currTrial) = runInfo.flipIdx;
                trialInfo.trialOutcome(runInfo.currTrial) = 1; 
            end
        end
    end
    
    % --- determine if we should end trial
    endCorridorReached = runInfo.roomPosition >= roomLength;
    trialDurationExceeded = toc(runInfo.trialStartTimer) > expInfo.maxDuration;
    if (endCorridorReached || trialDurationExceeded)
        if runInfo.rewardAvailable
            % Mouse didn't receive a reward
            trialInfo.trialOutcome(runInfo.currTrial) = 0;
        end
        
        % If this isn't the last trial, set up trialEnd script and break
        if runInfo.currTrial < expInfo.maxTrials
            runInfo.move2NextTrial = 1;
        else
            VRmessage = sprintf('Last trial reached for animal %s, on date %s, session %s, trialNum %d.',...
                expInfo.animalName, expInfo.dateStr, expInfo.sessionName, runInfo.currTrial);
            rigInfo.sendUDPmessage(VRmessage); 
            VRLogMessage(expInfo, VRmessage);
            if rigInfo.sendTTL
                hwInfo.session.outputSingleScan(true);
            end
            runInfo.move2NextTrial = 1;
        end
    end
    
    % --- check for manual abort or reward delivery ---
    keyPressed = checkKeyboard;
    if keyPressed == 1
        runInfo.abort = 1;
        if runInfo.rewardAvailable
            % Mouse didn't receive a reward
            trialInfo.trialOutcome(runInfo.currTrial) = 0;
        end
        VRmessage = sprintf('Manual Abort for animal %s, on date %s, session %s, trialNum %d.',...
                expInfo.animalName, expInfo.dateStr, expInfo.sessionName, runInfo.currTrial);
        rigInfo.sendUDPmessage(VRmessage); 
        VRLogMessage(expInfo, VRmessage);
        if rigInfo.sendTTL
            hwInfo.session.outputSingleScan(false);
        end
    elseif keyPressed == 2
        runInfo = vrControlGiveReward('USER', expInfo, runInfo, hwInfo);
        trialInfo.userRewardNumber(runInfo.currTrial) = trialInfo.userRewardNumber(runInfo.currTrial) + 1;
        trialInfo.userRewardFrames{runInfo.currTrial}(end+1) = runInfo.flipIdx;
    end
end

% close udp port and reset priority level
pnet(myPort,'close');

ListenChar(0);
Priority(0);

% Screen to blank and last pd flip
imageTexture = Screen('MakeTexture', hwInfo.screenInfo.windowPtr, hwInfo.screenInfo.grayIndex);
Screen('DrawTexture', hwInfo.screenInfo.windowPtr, imageTexture, [], hwInfo.screenInfo.screenRect, 0);
Screen('FillRect', hwInfo.screenInfo.windowPtr, runInfo.pdLevel*255, rigInfo.photodiodeRect.rect);
Screen('Flip', hwInfo.screenInfo.windowPtr,vbl+(waitframes-0.5)*ifi,0);
runInfo.pdLevel = mod(runInfo.pdLevel+1,2);

% Start ITI Timer
runInfo.ititimer = tic;

% Pause so trialend stamp is after last screen blank flip
pause(0.2);

heapTotalMemory = java.lang.Runtime.getRuntime.totalMemory;
heapFreeMemory = java.lang.Runtime.getRuntime.freeMemory;

if(heapFreeMemory < (heapTotalMemory*0.1))
    java.lang.Runtime.getRuntime.gc;
    fprintf('\n garbage collection \n');
end























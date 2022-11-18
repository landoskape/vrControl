function [fhandle, runInfo] = operateTrial(rigInfo, hwInfo, expInfo, runInfo, vrEnvs)

global TRIAL;
global gcount
gcount = 0; % always start with down flip because of startup ramp (woot)

vrEnv = vrEnvs{runInfo.vrEnvIdx};

% make a flip here to establish vbl
ifi = Screen('GetFlipInterval',hwInfo.screenInfo.windowPtr);
vbl = Screen('Flip',hwInfo.screenInfo.windowPtr,0,2);
prefRefreshTime = 1/expInfo.EXP.PrefRefreshRate;
waitframes = round(prefRefreshTime / ifi);

myPort = pnet('udpsocket', hwInfo.BALLPort); % open udp port

% -- send trial start message --
trStartMessage = sprintf('TrialStart %s %s %s %d',...
    expInfo.animalName, expInfo.dateStr, expInfo.sessionName, runInfo.currTrial);
rigInfo.sendUDPmessage(trStartMessage); 
VRLogMessage(expInfo,trStartMessage);

% -- main program that operates the trial --
hwInfo.rotEnc.readPositionAndZero();
if expInfo.lickEncoder
    hwInfo.likEnc = hwInfo.likEnc.zero(); % set lick encoder to zero
end
while ~runInfo.move2NextTrial && ~TRIAL.info.abort
    % Update every frame to index data storage in TRIAL structure
    runInfo.flipIdx = runInfo.flipIdx + 1;
   
    % Grab current frame from vrEnv array
    currentFrame = round(runInfo.roomPosition / expInfo.EXP.roomLength * expInfo.EXP.numVRFrames);
    currentFrame = max(1, currentFrame);
    currentFrame = min(expInfo.EXP.numVRFrames, currentFrame);
    frame2show = vrEnv(:,:,:,currentFrame);
    
    imageTexture = Screen('MakeTexture', hwInfo.screenInfo.windowPtr, frame2show); % Prepare frame for PTBs
    Screen('DrawTexture', hwInfo.screenInfo.windowPtr(1), imageTexture, [], hwInfo.screenInfo.screenRect, 0); % draw

    % Update reward indicator RGB
    if bitand(expInfo.EXP.rewIndMode, 1) && runInfo.inRewardZone
        Screen('FillRect', hwInfo.screenInfo.windowPtr, expInfo.EXP.rewRGB, expInfo.EXP.rewIndPos);
    end
    
    % Update photodiode sync square
    TRIAL.pdLevel(runInfo.currTrial,runInfo.flipIdx) = gcount;
    Screen('FillRect', hwInfo.screenInfo.windowPtr, mod(gcount,2)*255, rigInfo.photodiodeRect.rect);
    vbl=Screen('Flip', hwInfo.screenInfo.windowPtr,vbl+(waitframes-0.5)*ifi,2);
    gcount = mod(gcount+1,2); % update every photodiode flip
    
    % And send update to timeline (post flip is more accurate)
    % __FrameIdx (Animal) (Date) (Session) (FrameNum) (RoomPosition)
    frameMessage = sprintf('__FrameIdx %s %s %s %d %.1f',...
        expInfo.animalName, expInfo.dateStr, expInfo.sessionName, currentFrame, runInfo.roomPosition);
    rigInfo.sendUDPmessage(frameMessage, 2); 
    
    % Immediately after screen flip to optimize coordination bw VR and TL!
    TRIAL.time(runInfo.currTrial,runInfo.flipIdx) = vbl; % record time of screen flip
    TRIAL.frameIdx(runInfo.currTrial,runInfo.flipIdx) = currentFrame; % record which frame was presented
    TRIAL.roomPosition(runInfo.currTrial,runInfo.flipIdx) = runInfo.roomPosition;
    
    % --- mouse behavior --- MOVEMENT ---
    wheelPosition = hwInfo.rotEnc.readPositionAndZero;
    dbx = rigInfo.rotEncSign * wheelPosition;
    % hwInfo.rotEnc.zero();
    roomMovement = dbx / expInfo.EXP.wheelToVR * expInfo.EXP.wheelCircumference;
    roomMovement = nansum([roomMovement 0]); % ensure that movement is valid number (#ATL: seems smart, but why would this be a nan?)
    runInfo.roomPosition = runInfo.roomPosition + roomMovement;
    % tell user if mouse speed was unusually fast...
    if roomMovement/prefRefreshTime >= expInfo.EXP.maxSpeed
        fprintf(2, 'Mouse speed was recorded as %.2f cm/s!!!\n', roomMovement/prefRefreshTime);
    end
    % prevent mouse from moving before start of corridor
    runInfo.roomPosition = max(runInfo.roomPosition, expInfo.EXP.minimumPosition);
    
    % --- mouse behavior --- LICKS ---
    if expInfo.lickEncoder
        [currLikStatus,hwInfo.likEnc] = hwInfo.likEnc.readPositionAndZero;
        if currLikStatus
            TRIAL.lick(runInfo.currTrial,runInfo.flipIdx) = 1;
        else
            TRIAL.lick(runInfo.currTrial,runInfo.flipIdx) = 0;
        end
    else
        TRIAL.lick(runInfo.currTrial,runInfo.flipIdx) = 0;
    end
    
    % --- mouse behavior --- STOPPING ---
    runInfo.inRewardZone = abs(runInfo.roomPosition - TRIAL.trialRewPos(runInfo.currTrial)) < expInfo.EXP.rewPosTolerance;
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
    if runInfo.reward_active % (1 if reward hasn't been delivered this trial)
        % Only consider reward delivery if in reward zone
        if runInfo.inRewardZone
            % Determine if lick conditionality permits reward delivery
            if ~TRIAL.trialActiveLicking(runInfo.currTrial) || ...
                    (TRIAL.trialActiveLicking(runInfo.currTrial) && TRIAL.lick(runInfo.currTrial, runInfo.flipIdx))
                lickValid = true; % If active licking + valid lick, or not active licking
            else
                lickValid = false; % Otherwise don't give reward yet
            end
            
            % Determine if lick conditionality permits reward delivery
            if ~TRIAL.trialActiveStopping(runInfo.currTrial) || ...
                    (TRIAL.trialActiveStopping(runInfo.currTrial) && ...
                    runInfo.rewZoneTimerActive && (toc(runInfo.timeInRewardZone) > expInfo.EXP.stopDuration))
                stopValid = true; % If active stopping + valid stop, or not active stopping
            else
                stopValid = false; % Otherwise don't give reward yet
            end
            
            % Give reward if in reward zone and lickValid and stopValid
            if lickValid && stopValid
                runInfo = giveReward('PASSIVE', expInfo, runInfo, hwInfo);
                runInfo.reward_active = 0;
                % trial outcome used to indicate active vs. passive
                TRIAL.trialRewDelivery(runInfo.currTrial) = runInfo.flipIdx;
                TRIAL.trialOutcome(runInfo.currTrial) = 1; 
            end
        end
    end
    
    % --- determine if we should end trial
    endCorridorReached = runInfo.roomPosition >= expInfo.EXP.roomLength;
    trialDurationExceeded = toc(runInfo.trialStartTime) > expInfo.EXP.maxTrialDuration;
    if (endCorridorReached || trialDurationExceeded)
        if runInfo.reward_active
            % Mouse didn't receive a reward
            TRIAL.trialOutcome(runInfo.currTrial) = 0;
        end
        
        % If this isn't the last trial, set up trialEnd script and break
        if runInfo.currTrial < expInfo.EXP.maxTrials
            runInfo.move2NextTrial = 1;
            fhandle =  @trialEnd_Blender;
        else
            VRmessage = sprintf('Last trial reached for animal %s, on date %s, session %s, trialNum %d.',...
                expInfo.animalName, expInfo.dateStr, expInfo.sessionName, runInfo.currTrial);
            rigInfo.sendUDPmessage(VRmessage); 
            VRLogMessage(expInfo, VRmessage);
            if rigInfo.sendTTL
                hwInfo.session.outputSingleScan(true);
            end
            runInfo.move2NextTrial = 1;
            fhandle = @trialEnd_Blender;
        end
    end
    
    % --- check for manual abort or reward delivery ---
    keyPressed = checkKeyboard;
    if keyPressed == 1
        TRIAL.info.abort = 1;
        if runInfo.reward_active
            % Mouse didn't receive a reward
            TRIAL.trialOutcome(runInfo.currTrial) = 0;
        end
        VRmessage = sprintf('Manual Abort for animal %s, on date %s, session %s, trialNum %d.',...
                expInfo.animalName, expInfo.dateStr, expInfo.sessionName, runInfo.currTrial);
        rigInfo.sendUDPmessage(VRmessage); 
        VRLogMessage(expInfo, VRmessage);
        if rigInfo.sendTTL
            hwInfo.session.outputSingleScan(false);
        end
        fhandle = @trialEnd_Blender;
    elseif keyPressed == 2
        runInfo = giveReward('USER', expInfo, runInfo, hwInfo);
    end
end

% close udp port and reset priority level
pnet(myPort,'close');

ListenChar(0);
Priority(0);

% Screen to blank and last pd flip
imageTexture = Screen('MakeTexture', hwInfo.screenInfo.windowPtr, hwInfo.screenInfo.grayIndex);
Screen('DrawTexture', hwInfo.screenInfo.windowPtr, imageTexture, [], hwInfo.screenInfo.screenRect, 0);
Screen('FillRect', hwInfo.screenInfo.windowPtr, gcount*255, rigInfo.photodiodeRect.rect);
Screen('Flip', hwInfo.screenInfo.windowPtr,vbl+(waitframes-0.5)*ifi,0);
gcount = mod(gcount+1,2);

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























function trialStructure = createTrialStructure(settings)
    
    % How many trials
    trialStructure.maxTrials = settings.maxTrialNumber;
    trialStructure.maxDuration = settings.maxTrialDuration;
    trialStructure.preventBackwardMovement = settings.preventBackwardMovement;
    
    % Inline for getting path to vrEnv files
    trialStructure.envNames = settings.vrOptions;
    trialStructure.envPaths = settings.vrDirectory;
    trialStructure.getEnvName = @(idx) settings.vrOptions{idx};
    trialStructure.getEnvPath = @(idx) fullfile(settings.vrDirectory, ...
        sprintf('%s%s',settings.vrOptions{idx},settings.vrExtension));
    
    % Initial block (does nothing if there isn't one)
    initBlockLength = 1*(settings.initBlock * settings.initTrials);
    trialStructure.envIndex = nan(trialStructure.maxTrials,1);
    trialStructure.envIndex(1:initBlockLength) = settings.initEnvIdx;
    
    % Prepare environment selection across block structure
    assert(sum(settings.blockType)==1, 'Settings file has multiple block types selected...');
    blockType = settings.blockTypeNames{settings.blockType};
    switch lower(blockType)
        case 'preset'
            getBlockLength = @(envidx) settings.blockTrialsPer(envidx);
        case 'random'
            if strcmpi(settings.blockRandomDistributionName,'poisson')
                % Don't allow blocks of length 0
                getBlockLength = @(envidx) max([1, poissrnd(settings.blockRandomMean(envidx))]);
            else
                error('didn''t recognize random block length distribution');
            end
        otherwise
            error('earlier error message is logically broken...');
    end
    
    % Perform environment selection
    cTrial = initBlockLength;
    idxActive = returnOrder(settings.vrOrder, settings.vrActive);
    numActive = length(idxActive);
    if numActive > 1
        if ~isempty(settings.initEnvIdx)
            prevEnvFlag = ismember(idxActive, settings.initEnvIdx) * logical(initBlockLength); % Flags init environment unless there isn't one
        else
            prevEnvFlag = false(numActive,1);
        end
        needEnvFlag = true(numActive,1); % Flags environment that need to be selected in miniblock
        assert(sum(prevEnvFlag)>=0 && sum(prevEnvFlag)<=1, 'Logical error in code.') % make sure this works correctly
    else
        nextEnvIdx = 1; % There's only one to select from...
    end
    
    while cTrial < trialStructure.maxTrials
        if numActive > 1
            % Select Next Environment Randomly (Within Each Miniblock)
            nextEnvCandidates = find(needEnvFlag & ~prevEnvFlag);
            nextEnvIdx = nextEnvCandidates(randi(numel(nextEnvCandidates)));
            needEnvFlag(nextEnvIdx) = false;
            if sum(needEnvFlag)==0, needEnvFlag = true(numActive,1); end
            prevEnvFlag = false(numActive,1);
            prevEnvFlag(nextEnvIdx) = true;
        end
        
        cBlockLength = getBlockLength(idxActive(nextEnvIdx)); % dynamically choose block length
        excessTrials = max(cTrial + cBlockLength - trialStructure.maxTrials, 0); % prevent block from extending past max trial number
        cBlockLength = cBlockLength - excessTrials;
    
        trialStructure.envIndex(cTrial + (1:cBlockLength)) = idxActive(nextEnvIdx); % set next group of trials
        cTrial = cTrial + cBlockLength; % update current trial index
    end
    
    % Associate with length, reward position & tolerance
    trialStructure.roomLength = settings.vrLength(trialStructure.envIndex);
    trialStructure.rewardPosition = settings.vrRewPos(trialStructure.envIndex);
    trialStructure.rewardTolerance = settings.vrRewTol(trialStructure.envIndex);
    
    % Predetermine intertrial interval
    trialStructure.intertrialInterval = settings.minimumITI * ones(trialStructure.maxTrials,1);
    if settings.randomITI
        itiDistName = settings.distributionNameITI;
        switch lower(itiDistName)
            case 'uniform'
                additionalITI = 2*settings.randomMeanITI*rand(trialStructure.maxTrials,1);
                trialStructure.intertrialInterval = trialStructure.intertrialInterval + additionalITI;
            case 'exponential'
                additionalITI = exprnd(settings.randomMeanITI,trialStructure.maxTrials,1);
                trialStructure.intertrialInterval = trialStructure.intertrialInterval + additionalITI;
            otherwise
                error('Didn''t recognize ITI distribution type');
        end
    end
    
    % Prepare trial structure selection
    if settings.trialTypesLinkedToEnvironment
        trialStructure.probReward = ones(trialStructure.maxTrials, 1);
        trialStructure.activeLick = ones(trialStructure.maxTrials, 1);
        trialStructure.activeStop = ones(trialStructure.maxTrials, 1);
        trialStructure.mvmtGain = ones(trialStructure.maxTrials, 1);

        envUsed = unique(trialStructure.envIndex(:)');
        for envidx = envUsed(:)'
            idx_trials = find(trialStructure.envIndex == envidx);
            num_trials = length(idx_trials);
            [probReward, activeLick, activeStop, mvmtGain] = generateTrialStructure(settings, num_trials, true, envidx);
            trialStructure.probReward(idx_trials) = probReward;
            trialStructure.activeLick(idx_trials) = activeLick;
            trialStructure.activeStop(idx_trials) = activeStop;
            trialStructure.mvmtGain(idx_trials) = mvmtGain;
        end            
    else 
        [probReward, activeLick, activeStop, mvmtGain] = generateTrialStructure(settings, trialStructure.maxTrials, false);
        trialStructure.probReward = probReward;
        trialStructure.activeLick = activeLick;
        trialStructure.activeStop = activeStop;
        trialStructure.mvmtGain = mvmtGain;
    end
end



function [probReward, activeLick, activeStop, mvmtGain] = generateTrialStructure(settings, numTrials, useEnvSpecificSettings, vrEnvIndex)
    if useEnvSpecificSettings
        % Use settings for given environment
        condReward = settings.vrCondProbRew{vrEnvIndex};
        condActiveLicking = settings.vrCondActiveLick{vrEnvIndex};
        condActiveStopping = settings.vrCondActiveStop{vrEnvIndex};
        condGain = settings.vrCondMvmtGain{vrEnvIndex};
        condTrialReward = settings.vrCondTrialReward{vrEnvIndex};
        condTrialActiveLicking = settings.vrCondTrialActiveLicking{vrEnvIndex};
        condTrialActiveStopping = settings.vrCondTrialActiveStopping{vrEnvIndex};
        condTrialGain = settings.vrCondTrialGain{vrEnvIndex};
        condTrialFreq = settings.vrCondTrialFreq{vrEnvIndex};
        randomReward = settings.vrRandomReward{vrEnvIndex};
        randomRewardArray = settings.vrRandomRewardArray{vrEnvIndex};
        activeLicking = settings.vrActiveLicking{vrEnvIndex};
        activeStopping = settings.vrActiveStopping{vrEnvIndex};
        stopDuration = settings.vrActiveStopDuration{vrEnvIndex};
        randomGain = settings.vrRandomGain{vrEnvIndex};
        movementGain = settings.vrMovementGain{vrEnvIndex};
        minGain = settings.vrMinGain{vrEnvIndex};
        maxGain = settings.vrMaxGain{vrEnvIndex};
    else
        % Otherwise use standard settings
        condReward = settings.condReward;
        condActiveLicking = settings.condActiveLicking;
        condActiveStopping = settings.condActiveStopping;
        condGain = settings.condGain;
        condTrialReward = settings.condTrialReward;
        condTrialActiveLicking = settings.condTrialActiveLicking;
        condTrialActiveStopping = settings.condTrialActiveStopping;
        condTrialGain = settings.condTrialGain;
        condTrialFreq = settings.condTrialFreq;
        randomReward = settings.randomReward;
        randomRewardArray = settings.randomRewardArray;
        activeLicking = settings.activeLicking;
        activeStopping = settings.activeStopping;
        stopDuration = settings.stopDuration;
        randomGain = settings.randomGain;
        movementGain = settings.movementGain;
        minGain = settings.minGain;
        maxGain = settings.maxGain;
    end

    % -- there's always a value for each of the possible
    % conditional trial variables, so let's just generate the trial
    % structure as if it was fully conditional, then overwrite
    % things when they're independent --
    % -- if there aren't conditional trials, we'll skip this step --
    numCond = length(condTrialReward);
    if numCond
        condFreq = condTrialFreq;
        if any(mod(condFreq,1)), error('condTrialFreqs should be integers'); end
        condTrialIdx = randsample(1:numCond, numTrials, true, condFreq);
        
        % Write trial structure and overwrite if not conditional
        probReward = condTrialReward(condTrialIdx)';
        activeLick = condTrialActiveLicking(condTrialIdx)';
        activeStop = condTrialActiveStopping(condTrialIdx)';
        mvmtGain = condTrialGain(condTrialIdx)';
    end

    % Overwrite (or write) arrays for independent generation
    if ~condReward || (numCond == 0)
        % Overwrite probReward with independent generation
        if randomReward
            numReward = size(randomRewardArray,1);
            randRewFreq = randomRewardArray(:,2);
            if any(mod(randRewFreq,1)), error('Random Reward Frequencies should be integers'); end
            toSelect = cell2mat(cellfun(@(freq,idx) ...
                idx*ones(1,freq), num2cell(randRewFreq(:)'), num2cell(1:numReward), 'uni', 0));
            randRewIdx = randsample(toSelect, numTrials, true);
            probReward = randomRewardArray(randRewIdx,1);
        else
            probReward = ones(numTrials, 1);
        end
    end
    if ~condActiveLicking || (numCond == 0)
        activeLick = activeLicking * ones(numTrials, 1);
    end
    if ~condActiveStopping || (numCond == 0)
        activeStop = activeStopping * stopDuration * ones(numTrials, 1);
    end
    if ~condGain || (numCond == 0)
        if randomGain
            gainRange = sort([minGain, maxGain]);
            mvmtGain = movementGain * (diff(gainRange)*rand(numTrials, 1) + gainRange(1));
        else
            mvmtGain = movementGain * ones(numTrials,1);
        end
    end
end


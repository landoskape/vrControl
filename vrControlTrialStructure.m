function trialStructure = vrControlTrialStructure(settings)

% How many trials
trialStructure.maxTrials = settings.maxTrialNumber;
trialStructure.maxDuration = settings.maxTrialDuration;
            
% Inline for getting path to vrEnv files
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
idxActive = vrControlReturnOrder(settings.vrOrder, settings.vrActive);
numActive = length(idxActive);
if numActive > 1
    prevEnvFlag = ismember(idxActive, settings.initEnvIdx) * logical(initBlockLength); % Flags init environment unless there isn't one
    needEnvFlag = true(numActive,1); % Flags environment that need to be selected in miniblock
    assert(sum(prevEnvFlag)>=0 && sum(prevEnvFlag)<=1, 'Logical error in code.') % make sure this works correctly
else
    nextEnvIdx = 1; % There's only one to select from...
end

while cTrial < trialStructure.maxTrials
    if numActive > 1
        % Select Next Environment Randomly (Within Each Miniblock)
        nextEnvIdx = datasample(find(needEnvFlag & ~prevEnvFlag),1); % sample from those still not selected in miniblock
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
% -- there's always a value for each of the possible
% conditional trial variables, so let's just generate the trial
% structure as if it was fully conditional, then overwrite
% things when they're independent --
numCond = length(settings.condTrialReward);
condFreq = settings.condTrialFreq;
if any(mod(condFreq,1)), error('condTrialFreqs should be integers'); end
toSelect = cell2mat(cellfun(@(freq,idx) ...
    idx*ones(1,freq), num2cell(condFreq), num2cell(1:numCond), 'uni', 0));
condTrialIdx = randsample(toSelect, trialStructure.maxTrials, true);

% Write trial structure and overwrite if not conditional
trialStructure.probReward = settings.condTrialReward(condTrialIdx)';
trialStructure.activeLick = settings.condTrialActiveLicking(condTrialIdx)';
trialStructure.activeStop = settings.condTrialActiveStopping(condTrialIdx)';
trialStructure.mvmtGain = settings.condTrialGain(condTrialIdx)';
if ~settings.condReward
    % Overwrite probReward with independent generation
    if settings.randomReward
        if settings.customRewardProb
            error('Haven''t implemented any custom functions yet...');
        else
            numReward = size(settings.randomRewardArray,1);
            randRewFreq = settings.randomRewardArray(:,2);
            if any(mod(randRewFreq,1)), error('Random Reward Frequencies should be integers'); end
            toSelect = cell2mat(cellfun(@(freq,idx) ...
                idx*ones(1,freq), num2cell(randRewFreq(:)'), num2cell(1:numReward), 'uni', 0));
            randRewIdx = randsample(toSelect, trialStructure.maxTrials, true);
            trialStructure.probReward = settings.randomRewardArray(randRewIdx,1);
        end
    else
        trialStructure.probReward = ones(trialStructure.maxTrials,1);
    end
end
if ~settings.condActiveLicking
    trialStructure.activeLick = settings.activeLicking * ones(trialStructure.maxTrials,1);
end
if ~settings.condActiveStopping
    trialStructure.activeStop = settings.activeStopping * settings.stopDuration * ones(trialStructure.maxTrials,1);
end
if ~settings.condGain
    if settings.randomGain
        if settings.customGain
            error('Haven''t implemented any custom functions yet...');
        else
            gainRange = sort([settings.minGain, settings.maxGain]);
            trialStructure.mvmtGain = settings.movementGain * (diff(gainRange)*rand(trialStructure.maxTrials,1) + gainRange(1));
        end
    else
        trialStructure.mvmtGain = settings.movementGain * ones(trialStructure.maxTrials,1);
    end
end


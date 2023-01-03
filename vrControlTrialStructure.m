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
if sum(settings.blockType)~=1, error('Settings file has multiple block types selected...'); end
blockType = settings.blockTypeNames{settings.blockType};
switch lower(blockType)
    case 'even'
        getBlockLength = @() settings.blockTrialsPer;
    case 'random'
        if strcmpi(settings.blockRandomDistributionName,'poisson')
            getBlockLength = @() poissrnd(settings.blockRandomMean);
        else
            error('didn''t recognize random block length distribution');
        end
    case 'custom'
        error('custom block structure note coded yet');
    otherwise
        error('earlier error message is logically broken...');
end

% Perform environment selection
idxActive = vrControlReturnOrder(settings.vrOrder, settings.vrActive);
cEnvIdx = 1;
cTrial = initBlockLength;
while cTrial < trialStructure.maxTrials
    cBlockLength = getBlockLength();
    excessTrials = max(cTrial + cBlockLength - trialStructure.maxTrials, 0);
    cBlockLength = cBlockLength - excessTrials;
    trialStructure.envIndex(cTrial + (1:cBlockLength)) = idxActive(cEnvIdx);
    cEnvIdx = mod((cEnvIdx+1)-1, length(idxActive))+1; 
    cTrial = cTrial + cBlockLength;
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
trialStructure.activeLick = settings.condTrialActive(condTrialIdx)';
trialStructure.mvmtGain = settings.condTrialGain(condTrialIdx)';
trialStructure.activeStop = settings.activeStopping * ones(trialStructure.maxTrials,1);
trialStructure.stopDuration = settings.stopDuration * ones(trialStructure.maxTrials,1);
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
                idx*ones(1,freq), num2cell(randRewFreq), num2cell(1:numReward), 'uni', 0));
            randRewIdx = randsample(toSelect, trialStructure.maxTrials, true);
            trialStructure.probReward = settings.randomRewardArray(randRewIdx,1);
        end
    else
        trialStructure.probReward = ones(trialStructure.maxTrials,1);
    end
end
if ~settings.condActive
    trialStructure.activeLick = settings.activeLicking * ones(trialStructure.maxTrials,1);
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


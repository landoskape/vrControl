function [fhandle, runInfo] = trialEnd_Blender(rigInfo, ~, expInfo, runInfo, ~)

global TRIAL;

VRmessage = ['TrialEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
rigInfo.sendUDPmessage(VRmessage);
VRLogMessage(expInfo, VRmessage);

if TRIAL.info.no > 0
    s = sprintf('%s_trial', expInfo.SESSION_NAME);
    EXP    = expInfo.EXP;
    REWARD = runInfo.REWARD;
    save(s, 'TRIAL', 'EXP', 'REWARD');
end

fprintf('TrialEnd...\n\n'); % debug

if runInfo.currTrial >= expInfo.EXP.maxTrials
    fhandle = @endOfExperiment_Blender;
    return;
end

if TRIAL.info.abort == 1
    fhandle = @endOfExperiment_Blender;
    return;
end

% Otherwise go to next trial
fhandle = @prepareNextTrial;




function [fhandle, runInfo, trialInfo] = vrControlTrialEnd(rigInfo, ~, expInfo, runInfo, trialInfo)

VRmessage = ['TrialEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
rigInfo.sendUDPmessage(rigInfo, VRmessage);
VRLogMessage(expInfo, VRmessage);

if runInfo.currTrial > 0
    s = sprintf('%s_trial', expInfo.SESSION_NAME);
    save(s, 'trialInfo', 'expInfo');
end

if runInfo.currTrial >= expInfo.maxTrials || runInfo.abort
    fhandle = @vrControlExperimentEnd;
    return;
end

% Otherwise go to next trial
fhandle = @vrControlPrepareTrial;





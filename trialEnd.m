function [fhandle, runInfo, trialInfo, expInfo] = trialEnd(rigInfo, ~, expInfo, runInfo, trialInfo, ~)

VRmessage = ['TrialEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
rigInfo.sendUDPmessage(rigInfo, VRmessage);
VRLogMessage(expInfo, VRmessage);

if runInfo.currTrial > 0
    s = sprintf('%s_trial', expInfo.SESSION_NAME);
    save(s, 'trialInfo', 'expInfo', 'rigInfo');
end

if runInfo.currTrial >= expInfo.maxTrials || runInfo.abort
    fhandle = @experimentEnd;
    return;
end

% Otherwise go to next trial
fhandle = @prepareTrial;



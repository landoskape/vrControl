function runInfo = giveReward(expInfo, runInfo, hwInfo, rigInfo)

if strcmp(runInfo.rewardStartT.Running, 'off') ...
        && strcmp(runInfo.STOPrewardStopT.Running,'off')...
        && strcmp(runInfo.BASErewardStopT.Running,'off')
    
    VRmessage = sprintf('Reward given at trial %d, frame %d',...
        runInfo.currTrial,runInfo.flipIdx);
    fprintf([VRmessage,'\n']);
    VRLogMessage(expInfo, VRmessage);
    
    if rigInfo.useAnalogRewardValve
        hwInfo.rewVal.deliverBackground(expInfo.rewardSize, 'ul');
        runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + expInfo.rewardSize;
    else
        hwInfo.rewVal.activateDigitalDelivery(); 
        runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterValveTime;
    end
end







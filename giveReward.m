function runInfo = giveReward(tag, expInfo, runInfo, hwInfo, rigInfo)

if strcmp(runInfo.rewardStartT.Running, 'off') ...
        && strcmp(runInfo.STOPrewardStopT.Running,'off')...
        && strcmp(runInfo.BASErewardStopT.Running,'off')
    
    VRmessage = sprintf('Reward given at trial %d, frame %d, with tag %s',...
        runInfo.currTrial,runInfo.flipIdx, tag);
    fprintf([VRmessage,'\n']);
    VRLogMessage(expInfo, VRmessage);

    switch tag
        case 'STOP'
            hwInfo.rewVal.activateDigitalDelivery(); %hwInfo.rewVal.deliverBackground(rigInfo.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
        case 'ACTIVE'
            hwInfo.rewVal.activateDigitalDelivery(); %hwInfo.rewVal.deliverBackground(rigInfo.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
        case 'PASSIVE'
            hwInfo.rewVal.activateDigitalDelivery(); %hwInfo.rewVal.deliverBackground(rigInfo.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
        case 'BASE'
            hwInfo.rewVal.activateDigitalDelivery(); %hwInfo.rewVal.deliverBackground(rigInfo.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
        case 'USER'
            hwInfo.rewVal.activateDigitalDelivery(); %hwInfo.rewVal.deliverBackground(rigInfo.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
        otherwise
            fprintf(2, 'giveReward tag not recognized, reward not delivered...\n');
    end
end







function runInfo = vrControlGiveReward(tag, expInfo, runInfo, hwInfo)

if strcmp(runInfo.rewardStartT.Running, 'off') ...
        && strcmp(runInfo.STOPrewardStopT.Running,'off')...
        && strcmp(runInfo.BASErewardStopT.Running,'off')
    
    VRmessage = sprintf('Reward given at trial %d, frame %d, with tag %s',...
        runInfo.currTrial,runInfo.flipIdx, tag);
    fprintf([VRmessage,'\n']);
    VRLogMessage(expInfo, VRmessage);

    switch tag
        case 'STOP'
            hwInfo.rewVal.deliverBackground(rigInfo.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.BASEvalveTime;
        case 'ACTIVE'
            hwInfo.rewVal.deliverBackground(rigInfo.ACTVvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.ACTVvalveTime;
        case 'PASSIVE'
            hwInfo.rewVal.deliverBackground(rigInfo.PASSvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
        case 'BASE'
            hwInfo.rewVal.deliverBackground(rigInfo.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.BASEvalveTime;
        case 'USER'
            hwInfo.rewVal.deliverBackground(rigInfo.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.BASEvalveTime;
        otherwise
            fprintf(2, 'giveReward tag not recognized, reward not delivered...\n');
    end
end







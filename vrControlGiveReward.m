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
            hwInfo.rewVal.deliverBackground(expInfo.EXP.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + expInfo.EXP.BASEvalveTime;
        case 'ACTIVE'
            hwInfo.rewVal.deliverBackground(expInfo.EXP.ACTVvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + expInfo.EXP.ACTVvalveTime;
        case 'PASSIVE'
            hwInfo.rewVal.deliverBackground(expInfo.EXP.PASSvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + expInfo.EXP.PASSvalveTime;
        case 'BASE'
            hwInfo.rewVal.deliverBackground(expInfo.EXP.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + expInfo.EXP.BASEvalveTime;
        case 'USER'
            hwInfo.rewVal.deliverBackground(expInfo.EXP.BASEvalveTime,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + expInfo.EXP.BASEvalveTime;
        otherwise
            fprintf(2, 'giveReward tag not recognized, reward not delivered...\n');
    end
end







function runInfo = giveReward(tag, expInfo, runInfo, hwInfo)

if strcmp(runInfo.rewardStartT.Running, 'off') ...
        && strcmp(runInfo.STOPrewardStopT.Running,'off')...
        && strcmp(runInfo.BASErewardStopT.Running,'off')
    
    VRmessage = sprintf('Reward given at trial %d, frame %d, with tag %s',...
        runInfo.currTrial,runInfo.flipIdx, tag);
    fprintf([VRmessage,'\n']);
    VRLogMessage(expInfo, VRmessage);

    runInfo.REWARD.TRIAL = [runInfo.REWARD.TRIAL runInfo.currTrial];
    runInfo.REWARD.count = [runInfo.REWARD.count runInfo.flipIdx];

    switch tag
        case 'STOP'
            hwInfo.rewVal.deliverBackground(expInfo.EXP.BASEvalveTime,'ul');
            runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 0];
            runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.BASEvalveTime;
        case 'ACTIVE'
            hwInfo.rewVal.deliverBackground(expInfo.EXP.ACTVvalveTime,'ul');
            runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 2];
            runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.ACTVvalveTime;
        case 'PASSIVE'
            hwInfo.rewVal.deliverBackground(expInfo.EXP.PASSvalveTime,'ul');
            runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 1];
            runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.PASSvalveTime;
        case 'BASE'
            hwInfo.rewVal.deliverBackground(expInfo.EXP.BASEvalveTime,'ul');
            runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 1];
            runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.BASEvalveTime;
        case 'USER'
            hwInfo.rewVal.deliverBackground(expInfo.EXP.BASEvalveTime,'ul');
            runInfo.REWARD.TYPE = [runInfo.REWARD.TYPE 0];
            runInfo.REWARD.TotalValveOpenTime = runInfo.REWARD.TotalValveOpenTime + expInfo.EXP.BASEvalveTime;
        otherwise
            fprintf(2, 'giveReward tag not recognized, reward not delivered...\n');
    end
end







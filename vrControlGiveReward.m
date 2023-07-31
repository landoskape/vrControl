function runInfo = vrControlGiveReward(tag, expInfo, runInfo, hwInfo, rigInfo)

if strcmp(runInfo.rewardStartT.Running, 'off') ...
        && strcmp(runInfo.STOPrewardStopT.Running,'off')...
        && strcmp(runInfo.BASErewardStopT.Running,'off')
    
    VRmessage = sprintf('Reward given at trial %d, frame %d, with tag %s',...
        runInfo.currTrial,runInfo.flipIdx, tag);
    fprintf([VRmessage,'\n']);
    VRLogMessage(expInfo, VRmessage);

    switch tag
        case 'STOP'
            hwInfo.rewVal.deliverBackground(rigInfo.waterVolumeSTOP,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumeSTOP;
        case 'ACTIVE'
            hwInfo.rewVal.deliverBackground(rigInfo.waterVolumeACTV,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumeACTV;
        case 'PASSIVE'
            hwInfo.rewVal.deliverBackground(rigInfo.waterVolumePASS,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumePASS;
        case 'BASE'
            hwInfo.rewVal.deliverBackground(rigInfo.waterVolumeBASE,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumeBASE;
        case 'USER'
            hwInfo.rewVal.deliverBackground(rigInfo.waterVolumePASS,'ul');
            runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumePASS;
        otherwise
            fprintf(2, 'giveReward tag not recognized, reward not delivered...\n');
    end
end






function runInfo = giveReward(tag, expInfo, runInfo, hwInfo, rigInfo)

if strcmp(runInfo.rewardStartT.Running, 'off') ...
        && strcmp(runInfo.STOPrewardStopT.Running,'off')...
        && strcmp(runInfo.BASErewardStopT.Running,'off')
    
    VRmessage = sprintf('Reward given at trial %d, frame %d, with tag %s',...
        runInfo.currTrial,runInfo.flipIdx, tag);
    fprintf([VRmessage,'\n']);
    VRLogMessage(expInfo, VRmessage);
    

    switch tag
        case 'ACTIVE'
            if rigInfo.useAnalogRewardValve
                hwInfo.rewVal.deliverBackground(rigInfo.waterVolumeACTV,'ul');
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumeACTV;
            else
                hwInfo.rewVal.activateDigitalDelivery(); 
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
            end
        case 'PASSIVE'
            if rigInfo.useAnalogRewardValve
                hwInfo.rewVal.deliverBackground(rigInfo.waterVolumePASS,'ul');
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumePASS;
            else
                hwInfo.rewVal.activateDigitalDelivery(); 
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
            end
        case 'BASE'
            if rigInfo.useAnalogRewardValve
                hwInfo.rewVal.deliverBackground(rigInfo.waterVolumeBASE, 'ul');
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumeBASE;
            else
                hwInfo.rewVal.activateDigitalDelivery(); 
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
            end

        otherwise
            fprintf(2, 'giveReward tag (%s) not recognized, reward not delivered...\n', tag);
    end
end







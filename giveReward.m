function runInfo = giveReward(tag, expInfo, runInfo, hwInfo, rigInfo)

if strcmp(runInfo.rewardStartT.Running, 'off') ...
        && strcmp(runInfo.STOPrewardStopT.Running,'off')...
        && strcmp(runInfo.BASErewardStopT.Running,'off')
    
    VRmessage = sprintf('Reward given at trial %d, frame %d, with tag %s',...
        runInfo.currTrial,runInfo.flipIdx, tag);
    fprintf([VRmessage,'\n']);
    VRLogMessage(expInfo, VRmessage);
    

    if rigInfo.rewardSizeByVolume
            hwInfo.rewVal.prepareRewardDelivery(rigInfo.waterVolumePASS, 'ul');
        else
            hwInfo.rewVal.prepareRewardDelivery(rigInfo.PASSvalveTime, 's');
    end
        
    switch tag
        case 'ACTIVE'
            if rigInfo.useAnalogRewardValve
                hwInfo.rewVal.deliverBackground(rigInfo.waterVolumeACTV,'ul');
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumeACTV;
            else
                hwInfo.rewVal.activateDigitalDelivery(); 
                if rigInfo.rewardSizeByVolume
                    runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumePASS;
                else
                    runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
                end
            end
        case 'PASSIVE'
            if rigInfo.useAnalogRewardValve
                hwInfo.rewVal.deliverBackground(rigInfo.waterVolumePASS,'ul');
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumePASS;
            else
                hwInfo.rewVal.activateDigitalDelivery(); 
                if rigInfo.rewardSizeByVolume
                    runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumePASS;
                else
                    runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
                end
            end
        case 'BASE'
            if rigInfo.useAnalogRewardValve
                hwInfo.rewVal.deliverBackground(rigInfo.waterVolumeBASE, 'ul');
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumeBASE;
            else
                hwInfo.rewVal.activateDigitalDelivery(); 
                if rigInfo.rewardSizeByVolume
                    runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumePASS;
                else
                    runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
                end
            end
            
        case 'USER'
            if rigInfo.useAnalogRewardValve
                hwInfo.rewVal.deliverBackground(rigInfo.waterVolumeBASE, 'ul');
                runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumeBASE;
            else
                hwInfo.rewVal.activateDigitalDelivery(); 
                if rigInfo.rewardSizeByVolume
                    runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.waterVolumePASS;
                else
                    runInfo.totalValveOpenTime = runInfo.totalValveOpenTime + rigInfo.PASSvalveTime;
                end
            end

        otherwise
            fprintf(2, 'giveReward tag (%s) not recognized, reward not delivered...\n', tag);
    end
end







function habMod = rawHabituationModule()

% Get RigInfo
rigInfo = rigParameters(); 
rigInfo.wheelCircumference = 2*pi*rigInfo.wheelRadius; % ATTENTION TO MINUTE DETAIL

% Set up rotary encoder
habMod.BALLPort = 9999;
% Setup wheel hardware info
habMod.session = daq.createSession('ni');
habMod.session.Rate = rigInfo.NIsessRate;
habMod.rotEnc = hw.DaqRotaryEncoder;
habMod.rotEnc.DaqSession = habMod.session;
habMod.rotEnc.DaqId = rigInfo.NIdevID;
habMod.rotEnc.DaqChannelId = rigInfo.NIRotEnc;
habMod.rotEnc.createDaqChannel;
habMod.rotEnc.zero();

% Set up reward valve
habMod.sessionVal = daq.createSession('ni');
habMod.sessionVal.Rate = rigInfo.NIsessRate;
habMod.rewVal = hw.DaqRewardValve_Analog;
load(rigInfo.WaterCalibrationFile);
habMod.rewVal.DaqSession = habMod.sessionVal;
habMod.rewVal.DaqId = rigInfo.NIdevID;
habMod.rewVal.DaqChannelId = rigInfo.NIRewVal;
habMod.rewVal.createDaqChannel;
habMod.rewVal.MeasuredDeliveries = Water_calibs(end).measuredDeliveries;
habMod.rewVal.OpenValue = 10;
habMod.rewVal.ClosedValue = 0;
habMod.rewVal.close;
habMod.rewTime = 0.200; % s 

habMod.changeRewardTime = @(habMod, rewTime) changeRewardTime(habMod, rewTime);
habMod.deliverReward = @(habMod) deliverReward(habMod);
habMod.printRotaryPosition = @(habMod) printRotaryPosition(habMod);

habMod.changeRewardTime(habMod, habMod.rewTime);

end

function deliverReward(habMod)
     habMod.rewVal.activateDigitalDelivery()
end

function habMod = changeRewardTime(habMod, rewTime)
    habMod.rewTime = rewTime;
    habMod.rewVal.prepareRewardDelivery(rewTime, 's')
end

function printRotaryPosition(habMod)
    rotPos = habMod.rotEnc.readPositionAndZero;
    display(rotPos);
end

function checkUserReward()
    keyPressed = checkKeyboard;
    if keyPressed == 2
        habMod.rewVal.TriggerSession.outputSingleScan(1);
        habMod.rewVal.TriggerSession.outputSingleScan(0);
    end
end

function printUpdates(timeDelays)
end

function checkUserAb()
    if keyPressed == 1
        runInfo.abort = 1;
        if runInfo.rewardAvailable
            % Mouse didn't receive a reward
            trialInfo.outcome(runInfo.currTrial) = 0;
        end
        VRmessage = sprintf('Manual Abort for animal %s, on date %s, session %s, trialNum %d.',...
                expInfo.animalName, expInfo.dateStr, expInfo.sessionName, runInfo.currTrial);
        rigInfo = rigInfo.sendUDPmessage(rigInfo, VRmessage); 
        VRLogMessage(expInfo, VRmessage);
        if rigInfo.sendTTL
            hwInfo.session.outputSingleScan(false);
        end
    end
end

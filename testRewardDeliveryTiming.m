function summary = testRewardDeliveryTiming()

rigInfo = rigInfoVR;

hwInfo.session = daq.createSession('ni');
hwInfo.session.Rate = rigInfo.NIsessRate;
hwInfo.sessionVal = daq.createSession('ni');
hwInfo.sessionVal.Rate = rigInfo.NIsessRate;

hwInfo.rewVal = DaqRewardValve;
load(rigInfo.WaterCalibrationFile);
hwInfo.rewVal.DaqSession = hwInfo.sessionVal;
hwInfo.rewVal.DaqId = rigInfo.NIdevID;
hwInfo.rewVal.DaqChannelId = rigInfo.NIRewVal;
hwInfo.rewVal.createDaqChannel;
hwInfo.rewVal.MeasuredDeliveries = Water_calibs(end).measuredDeliveries;
hwInfo.rewVal.OpenValue = 10;
hwInfo.rewVal.ClosedValue = 0;
hwInfo.rewVal.close;

basePause = 0.0001; 
maxSamples = 5e4;
currSample = 0;

timeStamps = zeros(maxSamples,1);
rewDelivery = round(linspace(1,maxSamples-1,5));
rewDeliveryTime = 0.005; 
if any(rewDelivery==maxSamples)
    error('set all rewdeliveries to before last sample...');
end

fastMethod = false; 
if fastMethod
    hwInfo.rewVal.prepareDelivery(rewDeliveryTime, 's');
end

startTracking = tic;
while currSample < maxSamples
    currSample = currSample + 1;
    timeStamps(currSample) = toc(startTracking);
    if ismember(currSample, rewDelivery)
        if fastMethod
            hwInfo.rewVal.performDelivery()
        else
            hwInfo.rewVal.deliverBackground(rewDeliveryTime,'s');
        end
    end
    pause(basePause);
end

listStamps = 1:maxSamples-1;
idxReward = ismember(listStamps, rewDelivery);
idxNormal = ~idxReward;

diffTimeStamps = diff(timeStamps);
timeNormal = diffTimeStamps(idxNormal);
timeReward = diffTimeStamps(idxReward);

summary.basePause = basePause;
summary.maxSamples = maxSamples;
summary.timeStamps = timeStamps;
summary.rewDelivery = rewDelivery;
summary.timeBetween = diffTimeStamps;
summary.timeNormal = timeNormal;
summary.timeReward = timeReward;
summary.timeNormalMean = mean(timeNormal); % this is about equal to "basePause"
summary.timeNormalSTD = std(timeNormal);
summary.timeRewardMean = mean(timeReward); % this is about equal to "rewDeliveryTime"
summary.timeRewardSTD = std(timeReward);

% function deliverBackground(obj, size, unitytype)
%     % size is the volume to deliver in microlitres (ul). This is turned
%     % into an open duration for the valve using interpolation of the
%     % calibration measurements.
%     if nargin<3
%       unitytype = 'ul';
%     end
%     if strcmp(unitytype,'s')
%       duration = size;
%     elseif strcmp(unitytype,'ul')
%       duration = openDurationFor(obj, size);
%     else
%       disp('assumed input is required size in ul, if not specify unity type')
%       duration = openDurationFor(obj, size);
%     end
%     daqSession = obj.DaqSession;
%     sampleRate = daqSession.Rate;
%     nOpenSamples = round(duration*sampleRate);
%     samples = [obj.OpenValue*ones(nOpenSamples, 1) ; ...
%     obj.ClosedValue*ones(3,1)];
%     if daqSession.IsRunning
%     daqSession.wait();
%     end
%     %       fprintf('Delivering %gul by opening valve for %gms\n', size, 1000*duration);
%     daqSession.queueOutputData(samples);
%     daqSession.startBackground();
%     time = obj.Clock.now;
%     obj.CurrValue = obj.ClosedValue;
%     logSample(obj, size, time);
% end


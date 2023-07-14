function vrControlCalibrateRewardSize(numDelivery, openTime)

rigInfo = vrControlRigParameters();

% Setup hardware info
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

hwInfo.rewVal.prepareRewardDelivery(openTime,'s');
hwInfo.rewVal.prepareDigitalTrigger();

msg = '';
for delivery = 1:numDelivery
    hwInfo.rewVal.activateDigitalDelivery(); 
    pause(0.4);
    fprintf(repmat('\b',1,length(msg)));
    msg = sprintf('%i/%i rewards delivered for opentime=%.4f seconds \n', delivery, numDelivery, openTime);
    fprintf(msg);
end

fprintf(1, 'finished.\n');

% water_calibs file:
%water_calibs.measuredDeliveries.durationSecs = []
%water_calibs.measuredDeliveries.volumeMicroLitres = []
%water_calibs.dateTime = []

% 0.02 / 0.0525 / 0.085 / 0.1175 / 0.15

% 100@0.01 --> 0.5g  ==> 0.01s=5uL
% 100@0.02 --> 1.37g ==> 0.02s=13.7uL
% 100@0.03 --> 1.98g ==> 0.03s=19.8uL








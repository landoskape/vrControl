function [fhandle, runInfo] = endOfExperiment_Blender(rigInfo, ~, expInfo, runInfo, ~)

% cleans up and exits state system
fprintf('<stateSystem> endOfExperiment\n'); % debug
Priority(0);

VRmessage = ['VR_ExpEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
rigInfo.sendUDPmessage(VRmessage);
VRLogMessage(expInfo, VRmessage);
VRmessage = ['ExpEnd ' expInfo.animalName ' ' expInfo.dateStr ' ' expInfo.sessionName];
rigInfo.sendUDPmessage(VRmessage);
VRLogMessage(expInfo, VRmessage);

VRLogMessage(expInfo);
VRLogMessage(expInfo);

rigInfo.closeUDPports;

try
    disp(['Copy data from '  expInfo.TheDir ' to ' expInfo.ServerDir])
    copyfile(expInfo.TheDir,expInfo.ServerDir)
catch ME
    disp(ME)
end
Screen('CloseAll');

heapTotalMemory = java.lang.Runtime.getRuntime.totalMemory;
heapFreeMemory = java.lang.Runtime.getRuntime.freeMemory;

if(heapFreeMemory < (heapTotalMemory*0.1))
    java.lang.Runtime.getRuntime.gc;
    fprintf('\n garbage collection \n');
end

fhandle = []; % exit state system
clear mex;
sca
end
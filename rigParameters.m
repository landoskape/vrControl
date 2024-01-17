function rigInfo = rigParameters(hostname)

if nargin==0
    [~,hostname] = system('hostname');
    hostname = upper(hostname(1:end-1));
end

% Default Settings:
rigInfo.computerName = hostname;
rigInfo.localFigurePosition = [4072 200];
rigInfo.screenNumber = 1;
rigInfo.screenDist = 10;
rigInfo.dialogueXYPosition = [3900 487];
rigInfo.NIdevID = '';
rigInfo.NIsessRate = [];
rigInfo.NIRotEnc = '';
rigInfo.NILicEnc = '';
rigInfo.NIRewVal = '';
rigInfo.photodiodePos = 'right';
rigInfo.photodiodeSize = [650 190]; % 650 190
rigInfo.rotEncPos = 'left';
rigInfo.rotEncSign = -1;
rigInfo.wheelToVR = 4000;
rigInfo.wheelRadius = 9.75;
rigInfo.minimumPosition = 0.01; % this helped with something, I forgot what, better to keep it positive but very small
rigInfo.maxSpeed = 200; % 200 cm / s is the max speed allowed without reporting to user
rigInfo.lickEncoderAvailable = true; 
rigInfo.BASEvalveTime = 0.02;
rigInfo.PASSvalveTime = 0.02;
rigInfo.ACTVvalveTime = 0.02;
rigInfo.waterVolumeBASE = 8;
rigInfo.waterVolumePASS = 8;
rigInfo.waterVolumeACTV = 8;
rigInfo.useAnalogRewardValve = true;
rigInfo.rewardSizeByVolume = true;
rigInfo.PrefRefreshRate = 30; % hz
rigInfo.dirSave = 'C:\Behaviour';
rigInfo.dirScreenCalib = fileparts(mfilename('fullpath'));
rigInfo.filenameScreenCalib = 'defaultCalibration.mat';
rigInfo.doScreenTransform = true;
rigInfo.doScreenFlip = true;
rigInfo.expSettingsDir = fullfile(fileparts(mfilename('fullpath')),'settingsFolder'); % Part of the github repository...
rigInfo.numConnect = 0;
rigInfo.connectPCs = [];
rigInfo.activePorts = [];
rigInfo.sendTTL = 0;
rigInfo.TTLchannel = [];
rigInfo.ChannelMapping = [];
rigInfo.connectPortnr = [];
rigInfo.UseRange = [];
rigInfo.WaterCalibrationFile = [];
rigInfo.useKeyboard = 0;
rigInfo.initialiseUDPports = @initialiseUDPports;
rigInfo.sendUDPmessage = @sendUDPmessage;
rigInfo.updateTTL = @updateTTL;
rigInfo.closeUDPports = @closeUDPports;

calibFilePath = fullfile(rigInfo.dirScreenCalib, rigInfo.filenameScreenCalib);
if ~exist(calibFilePath, 'file')
    defaultCalibration = fullfile(rigInfo.dirScreenCalib,'defaultCalibration.txt');
    if ~exist(defaultCalibration, 'file')
        error('No default calibration found. Check existing installation or github.'); 
    end
    createCalibrationFromDefault(defaultCalibration,calibFilePath);
end

if contains(upper(hostname), 'ANDREWS-MBP')
    hostname = upper('Andrews-MacBook-Pro.local');
end

% Rig Specific Settings
switch upper(hostname)              
    case 'ZINKO'
        % Local computer info (basic)
        rigInfo.computerName = 'ZINKO';
        rigInfo.localFigurePosition = [4000 200];
        rigInfo.screenNumber = 1; %Checked
        rigInfo.screenDist = 10; 
        rigInfo.dialogueXYPosition = [4000 200]; %to check (parameters for GUI)
        %RigInfo.parameterscript = 'SetExperimentParametersB2_Blender';

        rigInfo.NIdevID = 'Dev1';
        rigInfo.NIsessRate = 5000;
        rigInfo.NIRotEnc = 'ctr0';
        rigInfo.NILicEnc = 'ctr1'; 
        rigInfo.NIRewVal = 'ao0';
        rigInfo.photodiodePos  = 'right';
        rigInfo.photodiodeSize = [500 150]; % [650 190] %% Enny: CHECK   %[250 75];
        rigInfo.rotEncPos = 'left'; 
        rigInfo.rotEncSign = -1;
        rigInfo.wheelToVR = 4000;
        rigInfo.wheelRadius = 9.75; 
        rigInfo.lickEncoderAvailable = true; 

        rigInfo.STOPvalveTime = 0.0;
        rigInfo.BASEvalveTime = 0.025;
        rigInfo.PASSvalveTime = 0.025;
        rigInfo.ACTVvalveTime = 0.025;
        rigInfo.waterVolumeSTOP = 0.0;
        rigInfo.waterVolumeBASE = 6;
        rigInfo.waterVolumePASS = 6;
        rigInfo.waterVolumeACTV = 6;

        rigInfo.rewardSizeByVolume = true;
        rigInfo.useAnalogRewardValve = false;
        
        rigInfo.PrefRefreshRate = 30;

        % Saving directories: remote
        rigInfo.dirSave = 'C:\Users\Experiment\Documents\vrAndrew\animalData';
        rigInfo.dirScreenCalib = 'C:\Users\Experiment\Documents\MATLAB\';
        rigInfo.filenameScreenCalib = 'halfcyclindercalib_22102021.mat';
        rigInfo.doScreenTransform = true;
        rigInfo.doScreenFlip = true;
        
        rigInfo.WaterCalibrationFile = 'Zinko_water_calibs'; %Change!!

        % External computer connection info -- NEEDS CHECKING
        % SCANIMAGE
        rigInfo.connectPCs{1} = 'ZYLVIA';
        rigInfo.connectPortnr{1} = 1001;                   

        % Timeline
        rigInfo.connectPCs{2} = 'ZODIAC';
        rigInfo.connectPortnr{2} = 1001;
        
        % EYE CAMERA
        rigInfo.connectPCs{3} = 'ZEITGEIST';
        rigInfo.connectPortnr{3} = 1001;

        rigInfo.numConnect = length(rigInfo.connectPCs);
        rigInfo.sendTTL = 0; % ttl not necessary here for timeline sync
        rigInfo.TTLchannel = 'Port0/Line0'; %might be flipped.


    case 'ZEELAND'
        % Local computer info (basic)
        rigInfo.computerName = 'ZEELAND';
        rigInfo.localFigurePosition = [2040 -650];
        rigInfo.screenNumber = 2; % Checked
        rigInfo.screenDist = 10; 
        rigInfo.dialogueXYPosition = [2040 -650]; %to check (parameters for GUI)
        
        rigInfo.NIdevID = 'Dev1';
        rigInfo.NIsessRate = 5000;
        rigInfo.NIRotEnc = 'ctr1';
        rigInfo.NILicEnc = ''; 
        rigInfo.NIRewVal = 'ao0';
        rigInfo.photodiodePos  = 'right';
        rigInfo.photodiodeSize = [100 75]; % [650 190] %% Enny: CHECK   %[250 75];
        rigInfo.rotEncPos = 'left'; 
        rigInfo.rotEncSign = -1; 
        rigInfo.wheelToVR = 4000;
        rigInfo.wheelRadius = 10; 
        rigInfo.lickEncoderAvailable = false; 

        rigInfo.STOPvalveTime = 0.0;
        rigInfo.BASEvalveTime = 0.025;
        rigInfo.PASSvalveTime = 0.025;
        rigInfo.ACTVvalveTime = 0.025;
        rigInfo.waterVolumeSTOP = 0.0;
        rigInfo.waterVolumeBASE = 8;
        rigInfo.waterVolumePASS = 8;
        rigInfo.waterVolumeACTV = 8;
        
        rigInfo.rewardSizeByVolume = true;
        rigInfo.useAnalogRewardValve = true;
        
        rigInfo.PrefRefreshRate = 30;

        % Saving directories: remote
        rigInfo.dirSave = 'C:\Users\Experiment\Documents\animalData';
        rigInfo.dirScreenCalib = 'C:\Users\Experiment\Documents\GitHub\vrControlGratings';
        rigInfo.filenameScreenCalib = 'halfcyclindercalib_22102021.mat';
        rigInfo.doScreenTransform = true;
        rigInfo.doScreenFlip = true;
        
        rigInfo.WaterCalibrationFile = 'Zeeland_water_calibs'; %Change!!

        % Timeline
        rigInfo.connectPCs{1} = 'ZEELAND';
        rigInfo.connectPortnr{1} = 1001;

        % EYE CAMERA
        rigInfo.connectPCs{2} = 'ZOOLAND';
        rigInfo.connectPortnr{2} = 1001;

        rigInfo.numConnect = length(rigInfo.connectPCs);
        rigInfo.sendTTL = 0; % ttl not necessary here for timeline sync
        rigInfo.TTLchannel = 'Port0/Line0'; %might be flipped.
        
    
    case 'ZAANLAND'
        % Local computer info (basic)
        rigInfo.computerName = 'ZAANLAND';
        rigInfo.localFigurePosition = [4400 -85];
        rigInfo.screenNumber = 2; % Checked
        rigInfo.screenDist = 10; 
        rigInfo.dialogueXYPosition = [4400 -85]; %to check (parameters for GUI)
        
        rigInfo.NIdevID = 'Dev2';
        rigInfo.NIsessRate = 5000;
        rigInfo.NIRotEnc = 'ctr1';
        rigInfo.NILicEnc = ''; 
        rigInfo.NIRewVal = 'ao0';
        rigInfo.photodiodePos  = 'right';
        rigInfo.photodiodeSize = [100 75]; % [650 190] %% Enny: CHECK   %[250 75];
        rigInfo.rotEncPos = 'left'; 
        rigInfo.rotEncSign = -1; 
        rigInfo.wheelToVR = 4000;
        rigInfo.wheelRadius = 10; 
        rigInfo.lickEncoderAvailable = false; 

        rigInfo.STOPvalveTime = 0.0;
        rigInfo.BASEvalveTime = 0.025;
        rigInfo.PASSvalveTime = 0.025;
        rigInfo.ACTVvalveTime = 0.025;
        rigInfo.waterVolumeSTOP = 0.0;
        rigInfo.waterVolumeBASE = 8;
        rigInfo.waterVolumePASS = 8;
        rigInfo.waterVolumeACTV = 8;
        
        rigInfo.rewardSizeByVolume = true;
        rigInfo.useAnalogRewardValve = true;
        
        rigInfo.PrefRefreshRate = 30;


        % Saving directories: remote
        rigInfo.dirSave = 'C:\Users\Experiment\Documents\animalData';
        rigInfo.dirScreenCalib = 'C:\Users\Experiment\Documents\GitHub\vrControlGratings';
        rigInfo.filenameScreenCalib = 'halfcyclindercalib_22102021.mat';
        rigInfo.doScreenTransform = true;
        rigInfo.doScreenFlip = true;
        
        rigInfo.WaterCalibrationFile = 'Zeeland_water_calibs'; %Change!!

        % Timeline
        rigInfo.connectPCs{1} = 'ZAANLAND';
        rigInfo.connectPortnr{1} = 1001;

        % EYE CAMERA
        rigInfo.connectPCs{2} = 'ZOOLAND';
        rigInfo.connectPortnr{2} = 1001;

        rigInfo.numConnect = length(rigInfo.connectPCs);
        rigInfo.sendTTL = 0; % ttl not necessary here for timeline sync
        rigInfo.TTLchannel = 'Port0/Line0'; %might be flipped.

        
    case 'DESKTOP-C0GU3US'
        rigInfo.localFigurePosition = [680 500];
        rigInfo.dirSave = 'C:\Users\andrew\Documents\GitHub\vrControl\settingsFolder';
        rigInfo.useKeyboard = 1; % to control the linear track with the keyboard arrow keys
        rigInfo.screenNumber = 2;
        rigInfo.filenameScreenCalib = '';
        rigInfo.lickEncoderAvailable = false; 

    case upper('Andrews-MacBook-Pro.local')
        rigInfo.localFigurePosition = [680 500];
        rigInfo.dirSave = '/Users/landauland/Documents/GitHub/vrControl/settingsFolder';
        rigInfo.useKeyboard = 1; % to control the linear track with the keyboard arrow keys
        rigInfo.filenameScreenCalib = '';
        rigInfo.lickEncoderAvailable = false; 
    
    otherwise
        error('hostname not recognized!!');
end 

end

function rigInfo = initialiseUDPports(rigInfo)
    if rigInfo.numConnect>0
        for iPC = 1:rigInfo.numConnect
            rigInfo.activePorts{iPC} = pnet('udpsocket', 1001);
            pnet(rigInfo.activePorts{iPC}, 'udpconnect', rigInfo.connectPCs{iPC}, rigInfo.connectPortnr{iPC});
            fprintf('Sent message to %s\n',rigInfo.connectPCs{iPC});
        end
    end
end

function rigInfo = sendUDPmessage(rigInfo, message, sendIdx_iIP)
    if rigInfo.numConnect>0
        if nargin < 3
            for iPC = 1:rigInfo.numConnect
                pnet(rigInfo.activePorts{iPC},'write', message);
                pnet(rigInfo.activePorts{iPC}, 'writePacket');
            end
        else
            for iPC = sendIdx_iIP
                pnet(rigInfo.activePorts{iPC},'write',message);
                pnet(rigInfo.activePorts{iPC}, 'writePacket');
            end
        end
    end
end

function rigInfo = updateTTL(rigInfo,state)
    rigInfo.TTLchannel.outputSingleScan(state);
end

function rigInfo = closeUDPports(rigInfo)
    if rigInfo.numConnect>0
        for iPC = 1:rigInfo.numConnect
            pnet(rigInfo.activePorts{iPC},'close');
        end
    end
end
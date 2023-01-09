function rigInfo = vrControlRigParameters(hostname)

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
rigInfo.NIdevID = 'Dev1';
rigInfo.NIsessRate = 5000;
rigInfo.NIRotEnc = 'ctr0';
rigInfo.NILicEnc = 'ctr1';
rigInfo.NIRewVal = 'ao0';
rigInfo.photodiodePos = 'right';
rigInfo.photodiodeSize = [650 190];
rigInfo.rotEncPos = 'left';
rigInfo.rotEncSign = -1;
rigInfo.wheelToVR = 4000;
rigInfo.wheelRadius = 9.75;
rigInfo.minimumPosition = 0.01; % this helped with something, I forgot what, better to keep it positive but very small
rigInfo.maxSpeed = 200; % 200 cm / s is the max speed allowed without reporting to user
rigInfo.lickEncoderAvailable = true; 
rigInfo.STOPvalveTime = 0.0;
rigInfo.BASEvalveTime = 3.0;
rigInfo.PASSvalveTime = 3.0;
rigInfo.ACTVvalveTime = 3.0;
rigInfo.PrefRefreshRate = 30; % hz
rigInfo.dirSave = 'C:\Behaviour';
rigInfo.dirScreenCalib = fileparts(mfilename('fullpath'));
rigInfo.filenameScreenCalib = 'defaultCalibration.mat';
rigInfo.expSettingsDir = fullfile(fileparts(mfilename('fullpath')),'settingsFolder'); % Part of the github repository...
rigInfo.numConnect = 0;
rigInfo.connectIPs = [];
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
    vrControlCreateCalibrationFromDefault(defaultCalibration,calibFilePath);
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
        rigInfo.dialogueXYPosition = [4000 487]; %to check (parameters for GUI)
        %RigInfo.parameterscript = 'SetExperimentParametersB2_Blender';

        rigInfo.NIdevID = 'Dev1';
        rigInfo.NIsessRate = 5000;
        rigInfo.NIRotEnc = 'ctr0';
        rigInfo.NILicEnc = 'ctr1'; 
        rigInfo.NIRewVal = 'ao0';
        rigInfo.photodiodePos  = 'right';
        rigInfo.photodiodeSize = [650 190];  %% Enny: CHECK   %[250 75];
        rigInfo.rotEncPos = 'left'; 
        rigInfo.rotEncSign = -1;
        rigInfo.wheelToVR = 4000;
        rigInfo.wheelRadius = 9.75; 
        rigInfo.lickEncoderAvailable = true; 

        rigInfo.STOPvalveTime = 0.0;
        rigInfo.BASEvalveTime = 3.0;
        rigInfo.PASSvalveTime = 3.0;
        rigInfo.ACTVvalveTime = 3.0;
        rigInfo.PrefRefreshRate = 30;

        % Saving directories: remote
        rigInfo.dirSave = 'C:\Users\Experiment\Documents\vrAndrew\animalData';
        rigInfo.dirScreenCalib = 'C:\Users\Experiment\Documents\MATLAB\';
        rigInfo.filenameScreenCalib = 'halfcyclindercalib_22102021.mat';
        
        rigInfo.WaterCalibrationFile = 'Zinko_water_calibs'; %Change!!

        % External computer connection info -- NEEDS CHECKING
        % SCANIMAGE
        rigInfo.connectIPs{1} = '128.40.198.105';
        rigInfo.connectPCs{1} = 'ZYLVIA';
        rigInfo.connectPortnr{1} = 1001;                   

        % Timeline
        rigInfo.connectIPs{2} = '128.40.198.101';
        rigInfo.connectPCs{2} = 'ZODIAC';
        rigInfo.connectPortnr{2} = 1001;
        
        % EYE CAMERA
        rigInfo.connectIPs{3} = '128.40.198.102';
        rigInfo.connectPCs{3} = 'ZEITGEIST';
        rigInfo.connectPortnr{3} = 1001;

        rigInfo.numConnect = length(rigInfo.connectIPs);
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
        for iIP = 1:rigInfo.numConnect
            rigInfo.activePorts{iIP} = pnet('udpsocket', 1001);
            pnet(rigInfo.activePorts{iIP}, 'udpconnect', rigInfo.connectIPs{iIP}, rigInfo.connectPortnr{iIP});
            fprintf('Sent message to %s\n',rigInfo.connectPCs{iIP});
        end
    end
end

function rigInfo = sendUDPmessage(rigInfo, message, sendIdx_iIP)
    if rigInfo.numConnect>0
        if nargin < 3
            for iIP = 1:rigInfo.numConnect
                pnet(rigInfo.activePorts{iIP},'write',message);
                pnet(rigInfo.activePorts{iIP}, 'writePacket');
            end
        else
            for iIP = sendIdx_iIP
                pnet(rigInfo.activePorts{iIP},'write',message);
                pnet(rigInfo.activePorts{iIP}, 'writePacket');
            end
        end
    end
end

function rigInfo = updateTTL(rigInfo,state)
    rigInfo.TTLchannel.outputSingleScan(state);
end

function rigInfo = closeUDPports(rigInfo)
    if rigInfo.numConnect>0
        for iIP = 1:rigInfo.numConnect
            pnet(rigInfo.activePorts{iIP},'close');
        end
    end
end
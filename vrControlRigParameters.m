function rigInfo = vrControlRigParameters(hostname)

if nargin==0
    [~,hostname] = system('hostname');
    hostname = upper(hostname(1:end-1));
end

% Default Settings:
rigInfo.computerName = hostname;
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
rigInfo.STOPvalveTime = 0.0;
rigInfo.BASEvalveTime = 3.0;
rigInfo.PASSvalveTime = 3.0;
rigInfo.ACTVvalveTime = 3.0;
rigInfo.PrefRefreshRate = 30; % hz
rigInfo.dirSave = 'C:\Behaviour';
rigInfo.dirScreenCalib = '';
rigInfo.filenameScreenCalib = '';
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
rigInfo.initialiseUDPports = @initialiseUDPports;
rigInfo.sendUDPmessage = @sendUDPmessage;
rigInfo.updateTTL = @updateTTL;
rigInfo.closeUDPports = @closeUDPports;

% Rig Specific Settings
switch upper(hostname)              
    case 'ZINKO'
        % Local computer info (basic)
        rigInfo.computerName = 'ZINKO';
        rigInfo.screenNumber = 1; %Checked
        rigInfo.screenDist = 10; 
        rigInfo.dialogueXYPosition = [3900 487]; %to check (parameters for GUI)
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
        rigInfo.dirSave = 'C:\Users\andrew\Documents\GitHub\vrControl\settingsFolder';

    otherwise
        error('hostname not recognized!!');
end 

end

function initialiseUDPports(rigInfo)
    if rigInfo.numConnect>0
        fprintf('#ATL: Suppressing output of pnet...\n');
        for iIP = 1:rigInfo.numConnect
            evalc('RigInfo.activePorts{iIP} = pnet(''udpsocket'', 1001);');
            pnet(rigInfo.activePorts{iIP}, 'udpconnect', rigInfo.connectIPs{iIP}, rigInfo.connectPortnr{iIP});
            fprintf('Sent message to %s\n',rigInfo.connectPCs{iIP});
        end
    end
end

function sendUDPmessage(rigInfo, message, sendIdx_iIP)
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

function updateTTL(rigInfo,state)
    rigInfo.TTLchannel.outputSingleScan(state);
end

function closeUDPports(rigInfo)
    if rigInfo.numConnect>0
        for iIP = 1:rigInfo.numConnect
            pnet(rigInfo.activePorts{iIP},'close');
        end
    end
end
classdef rigInfoVR < handle
    
    properties
        % Local computer info (basic)
        computerName;
        screenNumber;
        screenDist;
        photodiodePos = 'right';
        photodiodeSize;
        photodiodeRect = [0 0 1 1];
        % NI card info
        NIdevID = 'Dev1'; %muse
        NIsessRate = 5000;
        NIRotEnc = 'ctr0';
        NILicEnc = 'ctr1';
        NIRewVal = 'ao0';
        % Other
        rotEncPos = 'left';
        rotEncSign = -1;
        % Saving directories
        dirSave = 'C:\Behaviour';
        % Screen related info
        dirScreenCalib;
        filenameScreenCalib;
        % External computer connection info
        % (These are optinal)
        numConnect = 0;
        connectIPs = [];
        connectPCs = [];
        activePorts = [];
        sendTTL = 0;
        TTLchannel = [];
        dialogueXYPosition = [0 0]
        ChannelMapping = [];
        connectPortnr = [];
        UseRange=[];
        WaterCalibrationFile  = [];
        %parameterscript = 'SetExperimentParametersV2';
    end
    
    methods
        function RigInfo = rigInfoVR
            
            [foo,hostname] = system('hostname'); %#ok<ASGLU>
            hostname = upper(hostname(1:end-1));
            fprintf('Host name is %s\n', hostname);
            
            switch upper(hostname)                    
                case 'ZINKO'
                    % Local computer info (basic)
                    RigInfo.computerName = 'ZINKO';
                    RigInfo.screenNumber = 1; %Checked
                    RigInfo.screenDist = 10; 
                    RigInfo.dialogueXYPosition = [3900 487]; %to check (parameters for GUI)
                    %RigInfo.parameterscript = 'SetExperimentParametersB2_Blender';

                    RigInfo.NIdevID = 'Dev1';
                    RigInfo.NIsessRate = 5000;
                    RigInfo.NIRotEnc = 'ctr0';
                    RigInfo.NILicEnc = 'ctr1'; 
                    RigInfo.NIRewVal = 'ao0';
                    RigInfo.photodiodePos  = 'right';
                    RigInfo.photodiodeSize = [650 190];  %% Enny: CHECK   %[250 75];
                    RigInfo.rotEncPos = 'left'; 
                    RigInfo.rotEncSign = -1;

                    % Saving directories: remote
                    RigInfo.dirSave = 'C:\Users\Experiment\Documents\vrAndrew\animalData';
                    RigInfo.dirScreenCalib = 'C:\Users\Experiment\Documents\MATLAB\';
                    RigInfo.filenameScreenCalib = 'halfcyclindercalib_22102021.mat';
                    
                    RigInfo.WaterCalibrationFile = 'Zinko_water_calibs'; %Change!!

                    % External computer connection info -- NEEDS CHECKING
                    % SCANIMAGE
                    RigInfo.connectIPs{1} = '128.40.198.105';
                    RigInfo.connectPCs{1} = 'ZYLVIA';
                    RigInfo.connectPortnr{1} = 1001;                   

                    % Timeline
                    RigInfo.connectIPs{2} = '128.40.198.101';
                    RigInfo.connectPCs{2} = 'ZODIAC';
                    RigInfo.connectPortnr{2} = 1001;
                    
                    % EYE CAMERA
                    RigInfo.connectIPs{3} = '128.40.198.102';
                    RigInfo.connectPCs{3} = 'ZEITGEIST';
                    RigInfo.connectPortnr{3} = 1001;

                    RigInfo.numConnect = length(RigInfo.connectIPs);
                    RigInfo.sendTTL = 0; % ttl not necessary here for timeline sync
                    RigInfo.TTLchannel = 'Port0/Line0'; %might be flipped.
                    
                otherwise
                    error('hostname not recognized!!');
            end
        end
        
        function initialiseUDPports(RigInfo)
            if RigInfo.numConnect>0
                fprintf('#ATL: Suppressing output of pnet...\n');
                for iIP = 1:RigInfo.numConnect
                    evalc('RigInfo.activePorts{iIP} = pnet(''udpsocket'', 1001);');
                    pnet(RigInfo.activePorts{iIP}, 'udpconnect', RigInfo.connectIPs{iIP}, RigInfo.connectPortnr{iIP});
                    fprintf('Sent message to %s\n',RigInfo.connectPCs{iIP});
                end
            end
        end
        function sendUDPmessage(RigInfo, blah, sendIdx_iIP)
            if RigInfo.numConnect>0
                if nargin < 3
                    for iIP = 1:RigInfo.numConnect
                        pnet(RigInfo.activePorts{iIP},'write',blah);
                        pnet(RigInfo.activePorts{iIP}, 'writePacket');
                    end
                else
                    for iIP = sendIdx_iIP
                        pnet(RigInfo.activePorts{iIP},'write',blah);
                        pnet(RigInfo.activePorts{iIP}, 'writePacket');
                    end
                end     
            end
        end
        function updateTTL(RigInfo,state)
            RigInfo.TTLchannel.outputSingleScan(state);
        end
        function closeUDPports(RigInfo)
            if RigInfo.numConnect>0
                for iIP = 1:RigInfo.numConnect
                    pnet(RigInfo.activePorts{iIP},'close');
                end
            end
        end
        % methods
    end
    % class
end
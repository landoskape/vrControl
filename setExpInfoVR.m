function exp = setExpInfoVR(animalName, RIGinfo, vrFrames, roomOfReward, reset)
if nargin<5
    reset=0;
    fprintf(1, '#ATL: default expInfo reset value: %d...\n', reset);
end

dataDir = RIGinfo.dirSave;
animalDir = fullfile(dataDir, animalName);

if ~exist(animalDir,'dir'); mkdir(animalDir); end

createExperimentData = true;
if exist(fullfile(animalDir,'exp.mat'),'file') && ~reset
    expFile = load(fullfile(animalDir,'exp.mat'),'exp');
    exp = expFile.exp;
    
    % Check vrEnvironment frames (simple check, not perfect...)
    if exp.numVRFrames ~= vrFrames
        error('saved experiment file recorded a different number of vr frames than the environment provided!!');
    end
    createExperimentData = false;
end

% Establish basic expInfo fields related to VR room
fprintf(1, '#ATL: opportunity to handle VR environments better\n');
numRooms = 4;
wheelRadius = 9.75; % cm
wheelCircumference = 2*pi*wheelRadius;
corridorLength = wheelCircumference * numRooms; 
rewardPosition = (roomOfReward - 1/2)*wheelCircumference;
rewardTolerance = corridorLength/10/2; % make reward tolerance 10% of corridor length

if createExperimentData
    fprintf(1, '#ATL: Recreating "EXP" structure from code...\n');
    % Meta Parameters
    exp.username = 'ATL';
    exp.AnimalName = animalName;
    exp.Species = 'C57BL6J';
    exp.SurgeryDate = '1 Jan 2014';
    exp.BaseWeight = '25g';
    
    % Wheel Parameters
    exp.wheelType = 'WHEEL';
    exp.wheelRadius = 9.75; % in cm
    exp.wheelToVR = 4000; % number of clicks of rotary encoder for 1 rotation of wheel
    exp.maxSpeed = 200; % cm/s - if movement in any frame exceeds this, inform user that something weird going on
    
    % Trial Structure
    exp.minimumPosition = 0.05; % initial (and minimum) position 
    exp.maxTrials = 500;
    exp.maxTrialDuration = 60;
    exp.itiTime = 0.7; % ~1 secs pause b/w trials (longer helps with photodiode!)
    exp.rewPosTolerance = rewardTolerance; % 
    exp.activeLicking = false;
    exp.activeStopping = false;
    exp.roomLength = corridorLength;
    exp.numVRFrames = vrFrames;
    exp.rewardPosition = rewardPosition;
    exp.rewardProbability = 1; %0.9; % 1
        
    % Reward Delivery Parameters
    exp.STOPvalveTime = 0.0;
    exp.rewCorners = 1;
    exp.BASEvalveTime = 3.0;
    exp.PASSvalveTime = 3.0;
    exp.ACTVvalveTime = 3.0;
    exp.rewRGB = uint8([0,255,0]);
    exp.rewIndPos = [400 0 1000 400];
    exp.rewIndMode = 1; % (uses bitand, 1->on in reward zone, 2-> on when reward delivery) -- only have 1 coded...
    
    % Screen Parameters (& Photodiode)
    exp.PrefRefreshRate = 30;
    exp.syncSquareSize = 75; 
    exp.syncSquareSizeX = 250;
end

save(fullfile(animalDir,'exp'),'exp');

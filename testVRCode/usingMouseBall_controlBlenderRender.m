% Clear the workspace and the screen
sca;
close all;
clear mex; 
clearvars('-except','vrEnv');

% Load VR Environment File
vrEnvPath = 'C:\Users\Experiment\Documents\vrAndrew\vrEnvironments\vrEnvironment_001.tif';
vrTifInfo = imfinfo(vrEnvPath);
height = vrTifInfo(1).Height;
width = vrTifInfo(1).Width;

dsFrames = 3;
% fprintf(2, 'Note --- downsampling by %dx\n',dsFrames);
totalFrames = length(vrTifInfo);
frames = totalFrames/dsFrames;
% vrEnv = zeros(height,width,3,frames,'uint8');
% for f = 1:frames
%     vrEnv(:,:,:,f) = uint8(imread(vrEnvPath,(f-1)*dsFrames+1));
% end

Screen('Preference','VisualDebugLevel',0)
Screen('Preference', 'SkipSyncTests', 1);
screens=Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = 1;

ScreenInfo.whiteIndex = WhiteIndex(screenNumber);
ScreenInfo.blackIndex = BlackIndex(screenNumber);
ScreenInfo.grayIndex = round((ScreenInfo.whiteIndex+ScreenInfo.blackIndex)/2); 

Screen('CloseAll');
WaitSecs(0.5);

ScreenInfo.FrameRate = FrameRate(screenNumber);

% to get fish-eye transform: uncomment previous statement to remove
rigInfo.dirScreenCalib = 'C:\Users\Experiment\Documents\MATLAB\';
rigInfo.filenameScreenCalib = 'halfcyclindercalib_22102021.mat';                    
transformFile = [rigInfo.dirScreenCalib rigInfo.filenameScreenCalib];
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'AllViews', 'GeometryCorrection', transformFile);

PsychImaging('AddTask', 'AllViews', 'FlipHorizontal');
[ScreenInfo.windowPtr, ScreenInfo.screenRect] = PsychImaging('OpenWindow', screenNumber, ScreenInfo.grayIndex);

ScreenInfo.Xmax = RectWidth(ScreenInfo.screenRect);
ScreenInfo.Ymax = RectHeight(ScreenInfo.screenRect);

rsTarget = [ScreenInfo.Ymax, ScreenInfo.Xmax]; % [1024, 3840]
destRect = [0 0 rsTarget];

% make a linear Clut (do this even though you will do ltLoadCalibration later!!!)
Screen('LoadNormalizedGammaTable', screenNumber, repmat( (0:255)', 1, 3)/255);

% define synchronization square read by photodiode
rigInfo.photodiodeSize = [650 190];  %% Enny: CHECK   %[250 75];
pdRect = [ScreenInfo.Xmax - rigInfo.photodiodeSize(1), 0, ScreenInfo.Xmax, rigInfo.photodiodeSize(2)-1];
rigInfo.photodiodeRect = struct(...
    'rect',pdRect,'colorOn', [1 1 1], 'colorOff', [0 0 0]);
Screen('FillRect', ScreenInfo.windowPtr, ScreenInfo.whiteIndex, rigInfo.photodiodeRect.rect);
Screen('Flip', ScreenInfo.windowPtr);

rewardCircleSize = [650 190];
rewardCirclePos = [ScreenInfo.Xmax/3 - rewardCircleSize(1), 0, rewardCircleSize(1), rewardCircleSize(2)];
rewCircle = zeros(rewardCircleSize(2), rewardCircleSize(1), 3, 'uint8');
rewCircle(:,:,2) = uint8(255);
rewardTexture = Screen('MakeTexture', ScreenInfo.windowPtr, rewCircle);

ifi = Screen('GetFlipInterval',ScreenInfo.windowPtr);
vbl = Screen('Flip',ScreenInfo.windowPtr);

%Screen(ScreenInfo.windowPtr,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('BlendFunction', ScreenInfo.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Define User Control
escapeKey = KbName('esc');
upKey = KbName('up');
downKey = KbName('down');
leftKey = KbName('left');
rightKey = KbName('right');

% This is the cue which determines whether we exit the demo
exitDemo = false;
frame = 1;
numFrames = size(vrEnv,4);

framesPerPress = 2;

numFlips = 300;
flipTimes = zeros(1,numFlips);

waitframes = 1;
gcount = 0;
msg = '';
while exitDemo == false

    % Check the keyboard to see if a button has been pressed
    [~,~,keyCode] = KbCheck;

    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey)
        exitDemo = true;
    elseif keyCode(leftKey)
        framesPerPress = max([framesPerPress - 1, 1]);
    elseif keyCode(rightKey)
        framesPerPress = min([framesPerPress + 1, ceil(numFrames/5)]);
    elseif keyCode(upKey)
        frame = mod(frame + framesPerPress - 1, numFrames) + 1;
    elseif keyCode(downKey)
        frame = mod(frame - framesPerPress - 1, numFrames) + 1;
    end

    %thisImage = imresize(vrEnv(:,:,:,frame),rsTarget);
    thisImage = vrEnv(:,:,:,frame);
    imageTexture = Screen('MakeTexture', ScreenInfo.windowPtr, thisImage);
    Screen('DrawTexture', ScreenInfo.windowPtr, imageTexture, [], ScreenInfo.screenRect, 0);
    
    % Draw text in the upper portion of the screen with the default font in
    % white
    frameLine = sprintf('\nFrame: %d',frame);
    fppLine = sprintf('\nFrames Per Press: %d',framesPerPress);
    DrawFormattedText(ScreenInfo.windowPtr, [frameLine, fppLine], 'center', 100, [1 1 1]);
    
    Screen('FillRect', ScreenInfo.windowPtr, mod(gcount,2)*255, rigInfo.photodiodeRect.rect);
    Screen('DrawTexture', ScreenInfo.windowPtr, rewardTexture, [], [0 0 round(3840/3) 500], 2);
    
    vbl  = Screen('Flip', ScreenInfo.windowPtr, vbl + (waitframes - 0.5) * ifi);
    
    gcount = gcount+1;
    
    flipTimes(gcount) = vbl;
    
    fprintf(repmat('\b',1,length(msg)));
    msg = sprintf('Frame #: %d/%d...\n',frame,frames);
    fprintf(msg);
end

% Clear the screen
sca;













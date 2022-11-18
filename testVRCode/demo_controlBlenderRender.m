% Clear the workspace and the screen
sca;
close all;
clearvars('-except','vrEnv','vrEnvFilt');

% Load VR Environment File
vrEnvPath = 'C:\Users\Experiment\Documents\vrAndrew\vrEnvironments\vrEnvironment_001.tif';
vrTifInfo = imfinfo(vrEnvPath);
height = vrTifInfo(1).Height;
width = vrTifInfo(1).Width;
frameDS = 1;
numRenderFrames = length(vrTifInfo);
numVrFrames = numRenderFrames/frameDS;
fprintf(1,'#ATL: Downsampling vrMovie from %d to %d frames! (dsratio:%d)...\n',...
    numRenderFrames,numVrFrames,frameDS);
vrEnv = zeros(height,width,3,numVrFrames, 'uint8');
% for f = 1:numVrFrames
%     vrEnv(:,:,:,f) = imread(vrEnvPath,(f-1)*frameDS+1);
% end
% mdFiltDepth = 11;
% vrEnvFilt = uint8(medfilt1(vrEnv,mdFiltDepth,[],4));
% vrEnv = uint8(vrEnv);

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(1);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Define User Control
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Instead of the above from the demo, use one of the VR files
thisImage = vrEnv(:,:,:,1);

% Get the size of the image
[s1, s2, s3] = size(thisImage);

% Make the image into a texture
imageTexture = Screen('MakeTexture', window, thisImage);

% Draw the image to the screen, unless otherwise specified PTB will draw
% the texture full size in the center of the screen. We first draw the
% image in its correct orientation.
Screen('DrawTexture', window, imageTexture, [], [], 0);

% Flip to the screen
Screen('Flip', window);

% This is the cue which determines whether we exit the demo
exitDemo = false;
frame = 1;
numFrames = size(vrEnv,4);

framesPerPress = 1;

% Loop the animation until the escape key is pressed
vbl = Screen('Flip', window);
waitframes = 1;
while exitDemo == false

    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;

    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey)
        exitDemo = true;
    elseif keyCode(leftKey)
        framesPerPress = max([framesPerPress - 1, 1]);
    elseif keyCode(rightKey)
%         framesPerPress = min([framesPerPress + 1, round(numFrames/10)]);
        framesPerPress = min([framesPerPress + 1, 2]);
    elseif keyCode(upKey)
        frame = mod(frame + 8*framesPerPress - 1, numFrames) + 1;
    elseif keyCode(downKey)
        frame = mod(frame - 8*framesPerPress - 1, numFrames) + 1;
    end
    
    if framesPerPress==1
        thisImage = vrEnv(:,:,:,frame);
    else
        thisImage = vrEnvFilt(:,:,:,frame);
    end
    imageTexture = Screen('MakeTexture', window, thisImage);
    Screen('DrawTexture', window, imageTexture, [], [0 0 3840 1024], 0);
    
    % Draw text in the upper portion of the screen with the default font in
    % white
    frameLine = sprintf('\nFrame: %d',frame);
    fppLine = sprintf('\nFrames Per Press: %d',framesPerPress);
    DrawFormattedText(window, [frameLine, fppLine], 'center', 100, [1 1 1]);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end

% Clear the screen
sca;













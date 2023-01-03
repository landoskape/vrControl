function screenInfo = prepareScreenVR(whichScreen,rigInfo)
% initializes screen: ltScreenInitialize [Screen('OpenWindow',...)]
% loads calibration: ltLoadCalibration
% asks for screen distance 

screenInfo = struct();
screenInfo.Dist = rigInfo.screenDist;
screenInfo.whiteIndex = WhiteIndex(whichScreen);
screenInfo.blackIndex = BlackIndex(whichScreen);
screenInfo.grayIndex = round((screenInfo.whiteIndex+screenInfo.blackIndex)/2); 
if screenInfo.grayIndex == screenInfo.whiteIndex
    screenInfo.grayIndex = screenInfo.whiteIndex / 2;
end

screenInfo.WhichScreen = whichScreen;

Screen('CloseAll');
WaitSecs(0.5);

fprintf(1, '#ATL: Suppressing output of numerous PsychToolbox functions...\n');
evalc('screenInfo.FrameRate = FrameRate(whichScreen);');

transformFile = fullfile(rigInfo.dirScreenCalib, rigInfo.filenameScreenCalib);
[~,~,extension] = fileparts(transformFile);
PsychImagingNonverbose('PrepareConfiguration');
if exist(transformFile,'file') && strcmp(extension, '.mat')
    PsychImagingNonverbose('AddTask', 'AllViews', 'GeometryCorrection', transformFile);
else
    fprintf(2,'No transform file for psychtoolbox exists! Continuing without one...\n');
end

PsychImagingNonverbose('AddTask', 'AllViews', 'FlipHorizontal');
evalc('[screenInfo.windowPtr, screenInfo.screenRect] = PsychImaging(''OpenWindow'', whichScreen, screenInfo.grayIndex);');

display(screenInfo.screenRect);

screenInfo.Xmax = RectWidth(screenInfo.screenRect);
screenInfo.Ymax = RectHeight(screenInfo.screenRect);
screenInfo.MonitorType = 'Apple Ipad';
screenInfo.MonitorSize = 20*3; % cm - horizontal
screenInfo.Calibration.Directory = 'C:\Calibrations\';
screenInfo.MonitorHeight = 16; % cm - Vertical

%{
#ATL: I removed the following lines because my VR environments look fine
without them and maybe a little darker, which is probably better for
imaging and the mice.
--------------------------
% Enable alpha blending
Screen('BlendFunction', screenInfo.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% make a linear Clut (do this even though you will do ltLoadCalibration later!!!)
Screen('LoadNormalizedGammaTable', whichScreen, repmat( (0:255)', 1, 3)/255);

% Load calibration file - this changes some settings... I don't like it!
Calibration.Load(screenInfo);
--------------------------
%}





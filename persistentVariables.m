function output = persistentVariables(name, setValue)

% Define perVar="persistent variables structure"
% Add all required variables here, then use dynamic field notation for
% updating and returning variables.
persistent perVar
if ~isfield(perVar,'vrDirectory'), perVar.vrDirectory = ''; end
if ~isfield(perVar,'vrExtension'), perVar.vrExtension = ''; end
if ~isfield(perVar,'animalName'), perVar.animalName = ''; end
if ~isfield(perVar,'sessionOffset'), perVar.sessionOffset = []; end
if ~isfield(perVar,'maxTrialNumber'), perVar.maxTrialNumber = []; end
if ~isfield(perVar,'maxTrialDuration'), perVar.maxTrialDuration = []; end
if ~isfield(perVar,'settingsName'), perVar.settingsName = ''; end
if ~isfield(perVar,'useUpdateWindow'), perVar.useUpdateWindow = true; end
if ~isfield(perVar,'useTrainingMode'), perVar.useTrainingMode = true; end


% Now update and/or return requested variable
if ~isfield(perVar, name), error('The requested variable does not exist'); end
if nargin==2, perVar.(name) = setValue; end % Update if new value provided
if nargout, output = perVar.(name); end % Output if requested




%{
Once included but not really necessary now that saving and loading are
efficient...

% if ~isfield(perVar,'lickEncoderAvailable'), perVar.lickEncoderAvailable = []; end
% if ~isfield(perVar,'activeLicking'), perVar.activeLicking = []; end
% if ~isfield(perVar,'vrOptions'), perVar.vrOptions={}; end
% if ~isfield(perVar,'envInfo'), perVar.envInfo=[]; end
% if ~isfield(perVar,'minimumITI'), perVar.minimumITI=[]; end
% if ~isfield(perVar,'randomITI'), perVar.randomITI=[]; end
% if ~isfield(perVar,'randomMeanITI'), perVar.randomMeanITI=[]; end
% if ~isfield(perVar,'distributionITI'), perVar.distributionITI=[]; end
% if ~isfield(perVar,'movementGain'), perVar.movementGain=[]; end
% if ~isfield(perVar,'randomGain'), perVar.randomGain=[]; end
% if ~isfield(perVar,'customGain'), perVar.customGain=[]; end
% if ~isfield(perVar,'customGainFunction'), perVar.customGainFunction=''; end
% if ~isfield(perVar,'minGain'), perVar.minGain=[]; end
% if ~isfield(perVar,'maxGain'), perVar.maxGain=[]; end
% if ~isfield(perVar,'randGainWindow'), perVar.randGainWindow=[]; end
% if ~isfield(perVar,'randomReward'), perVar.randomReward=[]; end
% if ~isfield(perVar,'customRewardProb'), perVar.customRewardProb=[]; end
% if ~isfield(perVar,'customRewardFunction'), perVar.customRewardFunction=''; end
% if ~isfield(perVar,'randomRewardArray'), perVar.randomRewardArray=[]; end
% if ~isfield(perVar,'randomRewardWindow'), perVar.randomRewardWindow=[]; end
% if ~isfield(perVar,'initBlock'), perVar.initBlock=''; end
% if ~isfield(perVar,'initTrials'), perVar.initTrials=[]; end
% if ~isfield(perVar,'initEnvIdx'), perVar.initEnvIdx=[]; end
% if ~isfield(perVar,'blockType'), perVar.blockType=[]; end
% if ~isfield(perVar,'blockTrialsPer'), perVar.blockTrialsPer=[]; end
% if ~isfield(perVar,'blockRandomMean'), perVar.blockRandomMean=[]; end
% if ~isfield(perVar,'blockRandomDistribution'), perVar.blockRandomDistribution=[]; end
% if ~isfield(perVar,'blockCustomFunction'), perVar.blockCustomFunction=''; end

%}
# vrControlGUI Developer Documentation

## Architecture Overview

The vrControlGUI is a MATLAB App Designer application that serves as the configuration interface for VR behavioral experiments. It follows a model-view-controller pattern where the GUI manages state, validates inputs, and generates configuration structures for the experiment runner.

## Core Data Structures

### Environment Management Arrays
```matlab
% Core environment data (all same length = number of environments)
app.vrLength          % [numEnv x 1] - Environment lengths in cm
app.vrFrames          % [numEnv x 1] - Original frame counts  
app.vrFramesDS        % [numEnv x 1] - Downsampled frame counts
app.vrDSFactor        % [numEnv x 1] - Downsampling factors
app.vrRewPos          % [numEnv x 1] - Reward positions in cm
app.vrRewTol          % [numEnv x 1] - Reward tolerances in cm
app.vrOrder           % [numEnv x 1] - Order in block structure
app.vrActive          % [numEnv x 1] - Boolean active status

% Environment metadata
app.envBaseNames      % {numEnv x 1} - Base filenames
app.envRichNames      % {numEnv x 1} - Rich display names with properties
```

### Trial Type Data Structures

#### Independent Mode (Default)
```matlab
% Single values applied to all environments
app.condTrialReward           % [1 x numTrialTypes] - P(reward) per trial type
app.condTrialActiveLicking    % [1 x numTrialTypes] - Active licking per trial type  
app.condTrialActiveStopping   % [1 x numTrialTypes] - Active stopping per trial type
app.condTrialGain            % [1 x numTrialTypes] - Movement gain per trial type
app.condTrialFreq            % [1 x numTrialTypes] - Frequency of each trial type
app.randRewardArray          % [numRewardProbs x 2] - [P(reward), Frequency] pairs
```

#### Environment-Linked Mode
```matlab
% Cell arrays where each cell contains settings for one environment
app.vrCondTrialReward         % {numEnv x 1} each containing [1 x numTrialTypes]
app.vrCondTrialActiveLicking  % {numEnv x 1} each containing [1 x numTrialTypes]
app.vrCondTrialActiveStopping % {numEnv x 1} each containing [1 x numTrialTypes]
app.vrCondTrialGain          % {numEnv x 1} each containing [1 x numTrialTypes]
app.vrCondTrialFreq          % {numEnv x 1} each containing [1 x numTrialTypes]
app.vrRandomRewardArray      % {numEnv x 1} each containing [numRewardProbs x 2]
```

## Key Methods and Their Responsibilities

### Environment Management

#### `validateVrDirectory(app, newDirectory, startupSwitch)`
**Purpose**: Validates directory path and triggers environment loading
**Parameters**:
- `newDirectory`: Path to validate
- `startupSwitch`: Boolean, true if called during app startup
**Side Effects**: 
- Sets `app.validDirectory` flag
- Calls `activateEnvironmentOptions()` if valid
- Updates persistent variables

#### `activateEnvironmentOptions(app)`
**Purpose**: Loads environment files and populates GUI options
**Process**:
1. Scans directory for files matching `app.vrExtension`
2. Reads image info to get frame counts
3. Initializes all environment property arrays with defaults
4. Populates GUI listboxes and dropdowns
5. Enables environment-related UI components

**Key Implementation Details**:
```matlab
% Environment scanning
vrExt = standardizeExtension(app);
vrList = dir(fullfile(app.vrDirectory.Value,['*',vrExt]));
numEnv = length(vrList);

% Initialize arrays with defaults
app.vrLength = environmentDefaults(app,'length') * ones(numEnv,1);
% ... (other properties)

% Read frame counts from image files
for vrenv = 1:numEnv
    cpath = fullfile(app.vrDirectory.Value,vrList(vrenv).name);
    ctifinfo = imfinfo(cpath);
    numFrames = length(ctifinfo);
    app.vrFrames(vrenv) = numFrames;
end
```

#### `addEnvironment(app, envidx)` / `removeEnvironment(app, envidx)`
**Purpose**: Manage active environment list
**Process**:
- Updates `app.vrActive` and `app.vrOrder` arrays
- Refreshes GUI listboxes
- Maintains order consistency when environments are added/removed
- Updates block structure menus

### Trial Type System

#### `switchToLinkingTrialsToEnvs(app)`
**Purpose**: Toggles between independent and environment-linked trial types
**Implementation Strategy**:
```matlab
if conditional && numEnvOptions
    % Create cell arrays with current values replicated for each environment
    app.vrCondTrialReward = repmat({app.condTrialReward}, numEnvOptions, 1);
    app.vrCondActiveLicking = repmat({app.activeLicking.Value}, numEnvOptions, 1);
    % ... (other properties)
else
    % Clear environment-specific arrays
    app.vrCondTrialReward = [];
    % ... (other properties)
end
```

#### `updateVrenvTrialType(app, componentName, newValue)`
**Purpose**: Updates trial type setting for currently selected environment
**Usage**: Called whenever a trial type setting changes in environment-linked mode
```matlab
idx = app.envSettings.Value;  % Currently selected environment
app.(componentName){idx} = newValue;  % Update that environment's setting
```

#### `updateConditionalStructure(app)`
**Purpose**: Manages conditional vs independent trial type UI state
**Responsibilities**:
- Enables/disables UI components based on conditional toggles
- Updates tab titles to show active modes
- Calls `handleChangeToConditionalTrials()` for list updates

### Settings Management

#### `generateOutputStructure(app)`
**Purpose**: Compiles all GUI settings into experiment configuration structure
**Returns**: Comprehensive settings structure with all experiment parameters
**Key Sections**:
```matlab
% Meta parameters
out.vrDirectory = app.vrDirectory.Value;
out.animalName = app.animalName.Value;
% ...

% Environment configuration  
idxActive = returnOrder(app.vrOrder, app.vrActive);
out.vrInUse = app.envBaseNames(idxActive);
out.vrLength = app.vrLength;
% ...

% Trial type configuration (mode-dependent)
if out.trialTypesLinkedToEnvironment
    out.vrCondTrialReward = app.vrCondTrialReward;
    % ... (environment-specific arrays)
else
    out.condReward = app.condProbRew.Value;
    out.randomReward = app.randReward.Value;
    % ... (global settings)
end
```

#### `loadSettings()` / `saveSettings()`
**Purpose**: Persistent storage of experiment configurations
**File Format**: MATLAB .mat files in `rigInfo.expSettingsDir`
**Loading Process**:
1. Load .mat file containing settings structure
2. Merge with current defaults (for backward compatibility)
3. Apply settings to GUI components
4. Handle mode-specific loading (independent vs environment-linked)
5. Refresh all dependent UI elements

## GUI State Management

### Double-Click Detection System
```matlab
% Pattern used for environment selection
clickTime = datetime("now");
secondsSinceLast = seconds(clickTime - app.envOptionsLastClick);
wasDoubleClick = secondsSinceLast < app.doubleClickTime;
if selection==app.envOptionsLastSelection && wasDoubleClick
    addEnvironment(app,selection);
end
```

### Component State Synchronization
The GUI maintains consistency between related components through cascading updates:

1. **Environment Selection** → Updates settings menus → Updates trial type displays
2. **Trial Type Mode Toggle** → Recreates data structures → Updates all trial type UI
3. **Block Structure Change** → Enables/disables relevant controls → Updates lists

### Validation and Error Handling

#### Input Validation Pattern
```matlab
function dsFactorValueChanged(app, event)
    envidx = app.envSettings.Value;
    prevValue = event.PreviousValue;
    newValue = event.Value;
    frames = app.vrFrames(envidx);
    dsFrames = frames/newValue;
    if mod(dsFrames,1) ~= 0
        app.dsFactor.Value = prevValue;  % Revert invalid change
        presentMessage(app,sprintf('dsFactor must divide %d frames!',frames),2)
    else
        % Apply valid change
        app.vrDSFactor(envidx) = newValue;
        app.vrFramesDS(envidx) = dsFrames;
    end
end
```

#### User Feedback System
```matlab
function presentMessage(app,message,type)
    app.messagestouserTextArea.Value = message;
    if type==1, app.messagestouserTextArea.FontColor = 'k'; end  % Info
    if type==2, app.messagestouserTextArea.FontColor = 'r'; end  % Error
    % Store in message history
    messageNumber = size(app.userMessages,1) + 1;
    app.userMessages{messageNumber,1} = message;
    app.userMessages{messageNumber,2} = type;
end
```

## Integration Points

### Hardware Integration
```matlab
% Loaded during startup
app.rigInfo = rigParameters();
app.lickEncoderAvailable.Value = app.rigInfo.lickEncoderAvailable;
app.rewardSize.Value = app.rigInfo.waterVolumeBASE;
```

### Experiment Execution
```matlab
% Final handoff to experiment runner
settings = generateOutputStructure(app);
delete(app);  % Close GUI
runExperiment(settings);  % Start experiment with settings
```

## Performance Considerations

### Lazy Loading
- Environment properties loaded only when directory is validated
- Image file information read once during activation
- GUI updates batched to minimize redraws

### Memory Management
- Large environment arrays created only when needed
- Cell arrays used efficiently for environment-specific settings
- GUI components disabled when not applicable

### Scalability
- Supports arbitrary number of environments (limited by directory contents)
- Trial type arrays can grow dynamically
- Block structure calculations handle variable environment counts

## Extension Points

### Adding New Trial Type Properties
1. Add property to both independent and environment-linked data structures
2. Create GUI components for configuration
3. Add to `switchToLinkingTrialsToEnvs()` for mode switching
4. Include in `generateOutputStructure()` output
5. Add validation logic if needed

### Adding New Block Structure Types
1. Add new tab to `environmentBlockTab`
2. Implement `changeBlockStructure()` case
3. Add configuration storage to output structure
4. Update block type validation logic

### Hardware Integration
1. Add hardware detection to `rigParameters()`
2. Add GUI components with hardware-dependent enabling
3. Include hardware state in validation logic
4. Add to output structure for experiment runner

This architecture provides a flexible, extensible foundation for VR experiment configuration while maintaining clear separation between GUI state management, data validation, and experiment execution.

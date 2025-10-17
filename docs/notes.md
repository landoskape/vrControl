# vrControlGUI Analysis Notes

## Overview
The vrControlGUI is a MATLAB App Designer application for controlling virtual reality (VR) experiments on a linear track. It provides a comprehensive interface for designing and running behavioral experiments where animals navigate through pre-rendered VR environments.

## Core Functionality

### Main Purpose
- Configure VR experiments with multiple environments
- Design trial structures with various reward probabilities, active licking/stopping requirements, and movement gains
- Control block structures (how environments are presented over time)
- Manage intertrial intervals and timing
- Generate experiment settings that can be passed to the main experiment runner

### Key Components

#### 1. VR Environment Management
- **vrDirectory**: Path to folder containing VR environment files (.tif format)
- **vrenvOptions**: List of all available environments in the directory
- **vrenvInUse**: Subset of environments selected for the current experiment
- **Environment Properties**: Each environment has configurable properties:
  - Length (cm)
  - Reward position and tolerance
  - Downsampling factor for performance
  - Order in block structure
  - Active/inactive status

#### 2. Trial Type System
The app supports two modes for trial types:

**Independent Mode** (default):
- Trial properties apply to all environments equally
- Single set of reward probabilities, licking requirements, etc.

**Environment-Linked Mode**:
- Each environment can have its own trial type settings
- Allows for environment-specific behavioral requirements

**Trial Properties Include**:
- Reward probability (can be conditional or random)
- Active licking requirements (requires lick encoder hardware)
- Active stopping requirements (animal must stop for reward)
- Movement gain (scaling factor for movement speed)

#### 3. Block Structure
Controls how environments are presented over time:

**Initial Block**: Optional single-environment block at experiment start
**Main Block Types**:
- **Preset**: Fixed number of trials per environment block
- **Random**: Randomly determined block lengths (Poisson distribution)

#### 4. Timing Controls
- **Intertrial Intervals (ITI)**: Time between trials
- **Maximum trial duration**: Auto-timeout for trials
- **Maximum trial number**: Experiment end condition

### Architecture

#### Data Flow
1. User selects VR directory → environments loaded and validated
2. User configures environment properties via dropdown selection
3. User designs trial types (either independent or environment-specific)
4. User sets up block structure and timing
5. Settings compiled into output structure for experiment runner

#### Key Methods

**Environment Management**:
- `validateVrDirectory()`: Validates and loads environments from directory
- `activateEnvironmentOptions()`: Populates GUI with available environments
- `addEnvironment()` / `removeEnvironment()`: Manage active environment list
- `updateSettingsMenus()`: Updates GUI when environment selection changes

**Trial Type Management**:
- `updateConditionalStructure()`: Manages conditional vs independent trial modes
- `switchToLinkingTrialsToEnvs()`: Toggles between trial type modes
- `generateCondTrialList()`: Updates conditional trial type display

**Data Persistence**:
- `generateOutputStructure()`: Compiles all settings into experiment structure
- `saveSettings()` / `loadSettings()`: Persistent storage of configurations
- `persistentVariables()`: Stores commonly used values between sessions

#### GUI State Management
The app maintains complex state across multiple tabs and panels:
- Environment selection state (double-click detection for activation)
- Trial type configuration state (conditional vs independent)
- Block structure state (preset vs random)
- Hardware availability state (lick encoder, etc.)

#### Validation and Error Handling
- Directory validation for VR environments
- Hardware compatibility checking (lick encoder availability)
- Numeric input validation and limits
- State consistency checking between related components

### Integration Points
- **rigParameters()**: Loads hardware-specific configuration
- **persistentVariables()**: Manages session persistence
- **createTrialStructure()**: Converts settings to trial sequence
- **runExperiment()**: Main experiment execution function

### Notable Design Patterns
- Extensive use of callback functions for GUI interactions
- State-dependent enabling/disabling of UI components
- Hierarchical settings structure (global → environment-specific → trial-specific)
- Real-time validation and user feedback via message system

## Technical Implementation Details

### File Structure
- Single .m file with embedded GUI component definitions
- Uses MATLAB App Designer framework
- Integrates with external functions for experiment execution

### Data Structures
- Cell arrays for environment names and properties
- Numeric arrays for environment-specific settings
- Structured output for experiment configuration

### Performance Considerations
- Downsampling factor for large VR environment files
- Efficient GUI updates when switching between environments
- Lazy loading of environment properties

This GUI serves as the central configuration interface for a sophisticated VR behavioral experiment system, providing researchers with fine-grained control over experimental parameters while maintaining usability through a well-organized interface.

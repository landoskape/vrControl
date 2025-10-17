# User Logic Analysis: vrControlGUI

## User's Experimental Design Workflow

### 1. VR Environment Selection System

#### vrEnv Options Level
- **Purpose**: Shows all available VR environments from the selected directory
- **User Action**: Double-click to activate an environment
- **Display**: Shows environment index and filename (e.g., "1 - corridor_texture1")
- **State**: Environments start as "available but not selected"

#### vrEnv In Use Level  
- **Purpose**: Shows currently active environments that will be used in the experiment
- **User Action**: Double-click to deactivate an environment
- **Display**: Rich information including length, frames, reward position (e.g., "(1)-corridor_texture1 || Length=250cm || 1200 frames -(ds)-> 10 || Reward Position=200.0 +/- 10.0cm")
- **State**: These are the environments that will actually appear in trials

**Flow**: Available → Double-click → In Use → Configure Properties → Ready for Experiment

### 2. VR Environment Properties (envSettings Menu)

When an environment is selected from the dropdown, users can configure:

#### Physical Properties
- **Environment Length**: Total corridor length in cm (affects reward position scaling)
- **Downsample Factor**: Reduces frames for performance (must divide evenly into total frames)

#### Reward Zone Configuration  
- **Reward Position**: Where in the corridor rewards are available (cm from start)
- **Reward Tolerance**: Size of reward zone (±cm around reward position)

#### Experiment Structure
- **Order in Block**: Determines sequence when multiple environments are used
- **Active Status**: Toggle to quickly enable/disable environment

**Key Insight**: When environment length changes, reward position and tolerance scale proportionally to maintain the same relative reward zone.

### 3. Trial Types System

The trial type system has two distinct modes:

#### Mode 1: Independent Trial Types (Default)
**How it works**:
- Single set of trial type settings applies to ALL environments
- User configures reward probability, licking requirements, etc. once
- All environments use the same behavioral requirements

**User Experience**:
- Simpler configuration
- Consistent behavior across all environments
- Good for experiments focused on environmental differences rather than behavioral requirement differences

#### Mode 2: Environment-Linked Trial Types
**How it works**:
- Each environment gets its own copy of trial type settings
- User selects environment from dropdown, then configures trial types for that specific environment
- GUI shows "trial types for environment X" indicator
- Same interface, but settings are stored per-environment

**User Experience**:
- More complex but more flexible
- Can have different behavioral requirements for different environments
- Must configure trial types separately for each environment
- Good for experiments where environments should have different behavioral demands

#### Trial Type Components

**Reward Probability**:
- **Conditional Mode**: Define specific trial types with different P(reward) values
- **Independent Mode**: Either fixed probability or random selection from defined probabilities

**Active Licking** (requires lick encoder hardware):
- **Conditional Mode**: Some trial types require licking, others don't
- **Independent Mode**: Either all trials require licking or none do

**Active Stopping**:
- **Conditional Mode**: Some trial types require stopping for specified duration
- **Independent Mode**: Either all trials require stopping or none do  

**Movement Gain**:
- **Conditional Mode**: Different trial types can have different movement scaling
- **Independent Mode**: Either fixed gain or random gain within specified range

### 4. Block Structure System

#### Initial Block (Optional)
- **Purpose**: Start experiment with single environment for habituation
- **Configuration**: Choose environment and number of trials
- **User Decision**: Enable if animals need familiarization period

#### Main Block Types

**Preset Blocks**:
- **Concept**: Fixed number of trials per environment block
- **Configuration**: Set trials per environment (can be same for all or different per environment)
- **Use Case**: Predictable, controlled exposure to each environment

**Random Blocks**:
- **Concept**: Block lengths drawn from probability distribution (Poisson)
- **Configuration**: Set mean block length (can be same for all environments or different)
- **Use Case**: Unpredictable environment switches, prevents anticipation

### 5. Intertrial Intervals (ITI)

#### Fixed ITI
- Simple: same time between all trials

#### Random ITI  
- **Minimum ITI**: Base time that's always present
- **Additional Random Time**: Drawn from distribution (Uniform or Exponential)
- **Mean Additional Time**: Parameter for the distribution

**User Logic**: "I want at least X seconds between trials, plus some random additional time averaging Y seconds"

## User Mental Models

### Experimental Design Flow
1. **"What environments do I want to test?"** → Select VR directory and activate environments
2. **"How should each environment be configured?"** → Set lengths, reward zones, order
3. **"What should animals have to do for rewards?"** → Configure trial types (same for all environments or different per environment)
4. **"How should environments be presented over time?"** → Design block structure
5. **"How much time between trials?"** → Set ITI parameters
6. **"Let me test this configuration"** → Preview experiment
7. **"Run the experiment"** → Execute with current settings

### Key Decision Points

**Trial Type Complexity Decision**:
- Simple experiment: Keep trial types independent of environment
- Complex experiment: Link trial types to environments for fine-grained control

**Block Structure Decision**:
- Controlled exposure: Use preset blocks with fixed trial counts
- Naturalistic/unpredictable: Use random blocks with variable lengths

**Hardware Considerations**:
- Lick encoder available: Can use active licking requirements
- No lick encoder: Licking settings ignored but permitted in GUI

### Common User Workflows

**Basic Experiment Setup**:
1. Load VR directory
2. Double-click environments to activate
3. Keep trial types independent
4. Use preset blocks with equal trials per environment
5. Set simple fixed ITI
6. Run experiment

**Advanced Multi-Environment Experiment**:
1. Load VR directory  
2. Activate multiple environments
3. Configure each environment's properties individually
4. Link trial types to environments
5. Set different behavioral requirements per environment
6. Use random block structure for unpredictability
7. Configure complex ITI with random component
8. Preview and validate before running

This analysis reveals that the GUI is designed around a hierarchical decision-making process, where users make increasingly specific choices about their experimental design, with the flexibility to keep things simple or create highly complex, environment-specific behavioral paradigms.

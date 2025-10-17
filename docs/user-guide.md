# vrControlGUI User Guide

## Getting Started

The vrControlGUI is your control center for setting up virtual reality behavioral experiments. Think of it as the "mission control" where you design everything about your experiment before the animal starts running.

### What This App Does
- **Configures VR environments**: Choose which virtual corridors your animal will experience
- **Designs behavioral requirements**: Set up what the animal needs to do to get rewards
- **Controls experiment flow**: Decide how environments are presented over time
- **Manages timing**: Set intervals between trials and experiment duration

## Quick Start Guide

### 1. First Time Setup
1. **Set VR Directory**: Click "update path" and select the folder containing your VR environment files (.tif images)
2. **Enter Animal Name**: This determines where data gets saved
3. **Load Default Settings**: Click "load settings" to start with reasonable defaults

### 2. Basic Experiment (Recommended for Beginners)
1. **Select Environments**: Double-click environments in the left panel to activate them
2. **Keep Simple Settings**: Leave "link trial types to environment" OFF (unchecked)
3. **Set Reward Requirements**: Use the "Independent P(R), Active Licking..." tab to set what animals must do
4. **Choose Block Structure**: Use "Preset" blocks with equal trials per environment
5. **Preview**: Click "preview experiment" to see what you've created
6. **Run**: Click "run experiment" when ready

## Understanding the Interface

### Main Sections

#### Top: VR Directory and Basic Settings
- **VR Directory Path**: Shows where your environment files are located
- **Animal Name**: Critical! This determines data file names
- **Session Offset**: Usually set to multiples of 100 (e.g., 700, 800, 900)
- **Max Trials/Duration**: Safety limits to prevent overly long sessions

#### Left Side: Environment Selection
- **VR Options**: All available environments from your directory
- **VR In Use**: Environments you've selected for this experiment
- **Double-click to move**: Options → In Use (activate), In Use → Options (deactivate)

#### Right Side: Environment Configuration
- **Dropdown Menu**: Select which environment to configure
- **Length**: How long the virtual corridor is (in cm)
- **Reward Position/Tolerance**: Where rewards are available
- **Order**: Sequence when multiple environments are used

#### Center: Block Structure
Controls how environments are presented:
- **Initial**: Optional single-environment warm-up period
- **Preset**: Fixed number of trials per environment
- **Random**: Variable block lengths (more unpredictable)

#### Bottom Tabs: Trial Types
This is where you define what animals must do for rewards.

## Core Concepts

### VR Environments
Think of these as different "rooms" or "corridors" your animal can experience. Each environment:
- Has a specific visual appearance (textures, patterns, etc.)
- Has a defined length (how far the animal travels)
- Has a reward zone (where rewards can be obtained)
- Can be configured independently

**Example**: You might have a "striped corridor" (250cm long, reward at 200cm) and a "dotted corridor" (300cm long, reward at 250cm).

### Trial Types: Two Ways to Think About Experiments

#### Simple Approach: Same Rules Everywhere
- **When to use**: When you want to test how animals respond to different environments with the same behavioral requirements
- **How it works**: Set up reward rules once, they apply to all environments
- **Example**: "Animal gets reward 50% of the time in ALL environments"

#### Advanced Approach: Different Rules Per Environment  
- **When to use**: When different environments should have different behavioral demands
- **How it works**: Configure reward rules separately for each environment
- **Example**: "Animal gets reward 80% of the time in striped corridor, but only 20% in dotted corridor"

**To switch**: Check/uncheck "link trial types to environment"

### Block Structure: How Environments Are Presented

#### Preset Blocks (Recommended for Beginners)
- **Concept**: Each environment gets exactly X trials in a row
- **Example**: 10 trials in striped corridor, then 10 trials in dotted corridor, repeat
- **Good for**: Controlled, predictable experiments

#### Random Blocks  
- **Concept**: Block lengths vary randomly (but average to your setting)
- **Example**: Sometimes 8 trials in striped, sometimes 12, sometimes 15 (averaging 10)
- **Good for**: Preventing animals from predicting environment switches

## Step-by-Step Workflows

### Workflow 1: Simple Two-Environment Experiment

**Goal**: Compare animal behavior in two different visual environments with the same reward rules.

1. **Setup Environments**:
   - Set VR directory to folder with your environment files
   - Double-click two environments to activate them
   - Configure each environment's length and reward position

2. **Set Behavioral Requirements**:
   - Keep "link trial types to environment" OFF
   - Go to "Independent P(R)..." tab
   - Set reward probability (e.g., 0.8 = 80% of trials have reward)
   - Choose if animal must lick for reward (if you have lick sensor)

3. **Design Block Structure**:
   - Use "Preset" blocks
   - Set number of trials per environment (e.g., 15)
   - Keep "equal blocks" ON so both environments get same number of trials

4. **Set Timing**:
   - Set minimum time between trials (e.g., 2 seconds)
   - Optionally add random additional time

5. **Test and Run**:
   - Click "preview experiment" to see trial sequence
   - Click "run experiment" when satisfied

### Workflow 2: Environment-Specific Behavioral Requirements

**Goal**: Make one environment "easy" (high reward rate) and another "hard" (low reward rate).

1. **Setup Environments** (same as Workflow 1)

2. **Enable Environment-Specific Settings**:
   - Check "link trial types to environment"
   - Notice the interface now shows "trial types for environment X"

3. **Configure Each Environment Separately**:
   - Select first environment from dropdown
   - Set high reward probability (e.g., 0.9)
   - Select second environment from dropdown  
   - Set low reward probability (e.g., 0.3)

4. **Continue with Block Structure and Timing** (same as Workflow 1)

### Workflow 3: Complex Multi-Environment with Conditional Trial Types

**Goal**: Create multiple trial types within each environment with different behavioral requirements.

1. **Setup Environments** (as above)

2. **Enable Conditional Trial Types**:
   - Go to "Conditional Trial Types" tab
   - Check boxes for which properties should vary (e.g., "p(reward) cond.")
   - This creates different "trial types" with different requirements

3. **Design Trial Types**:
   - Set values for each trial type (reward probability, licking requirement, etc.)
   - Set frequency (how often each trial type occurs)
   - Use "add new" to create additional trial types
   - Use "update trial type" to modify existing ones

4. **Link to Environments** (if desired):
   - Check "link trial types to environment"
   - Configure different trial type sets for each environment

## Common Settings Explained

### Reward Settings
- **P(reward)**: Probability that reward is available (0.0 = never, 1.0 = always)
- **Random reward probability**: Instead of fixed probability, randomly select from a list
- **Conditional reward**: Different trial types have different reward probabilities

### Behavioral Requirements
- **Active Licking**: Animal must lick to get reward (requires lick sensor hardware)
- **Active Stopping**: Animal must stop moving for specified time to get reward
- **Movement Gain**: How much virtual movement per real movement (1.0 = normal, 0.5 = half speed, 2.0 = double speed)

### Timing Controls
- **ITI (Intertrial Interval)**: Time between trials
  - **Fixed**: Same time every trial
  - **Random**: Base time + random additional time
- **Max Trial Duration**: Auto-end trials that take too long
- **Max Trial Number**: Auto-end session after this many trials

## Tips and Best Practices

### For Beginners
1. **Start Simple**: Use 2 environments, independent trial types, preset blocks
2. **Test First**: Always use "preview experiment" before running
3. **Save Settings**: Use "save settings" to preserve configurations you like
4. **Check Hardware**: Make sure lick encoder settings match your actual hardware

### For Advanced Users
1. **Environment-Specific Design**: Use linked trial types when environments should have different behavioral demands
2. **Conditional Trial Types**: Create complex within-session variability
3. **Random Blocks**: Prevent anticipation of environment switches
4. **Session Management**: Use session offset to organize data across days

### Troubleshooting
- **"Invalid vrDirectory"**: Check that folder exists and contains .tif files
- **Red error messages**: Read carefully - usually indicates invalid settings
- **Can't activate environment**: Make sure VR directory is set first
- **Lick encoder warnings**: Check if your hardware actually has a lick sensor

## Understanding the Output

When you click "preview experiment", you'll see a table showing:
- **Trial #**: Sequential trial number
- **EnvIdx/EnvName**: Which environment for this trial
- **Length**: Corridor length for this trial
- **RewPos/RewTol**: Reward zone location and size
- **P(R)**: Reward probability for this trial
- **Act.Lick**: Whether licking is required
- **StopDuration**: Required stopping time (if any)
- **MvmtGain**: Movement scaling factor
- **ITI**: Time before this trial starts

This preview helps you verify that your experiment design matches your intentions.

## Advanced Features

### Session Management
- **Animal Name**: Creates data folders and filenames
- **Session Offset**: Allows numbering sessions (e.g., Mouse1_701, Mouse1_702, etc.)
- **Settings Files**: Save/load complete configurations for reuse

### Hardware Integration
- **Lick Encoder**: Automatically detected and settings adjusted accordingly
- **Reward Size**: Calibrated per rig for consistent reward delivery
- **Training Mode**: Special mode for initial animal training

### Data Integration
The settings you create here are passed to the main experiment runner, which:
- Controls the VR display
- Monitors animal behavior
- Delivers rewards
- Logs all data for analysis

## Getting Help

### Built-in Help
- **Tooltips**: Hover over any control for brief explanations
- **Messages**: Watch the message area for feedback and warnings
- **Preview**: Use preview function to verify your design

### Common Questions
- **"How many environments should I use?"**: Start with 2-3, can use more as needed
- **"How many trials per session?"**: Typically 100-500, depends on your research question
- **"Should I use random or preset blocks?"**: Preset for controlled studies, random to prevent anticipation
- **"When should I link trial types to environments?"**: When different environments should have different behavioral requirements

This GUI gives you powerful control over your VR experiments. Start with simple configurations and gradually add complexity as you become more comfortable with the interface.

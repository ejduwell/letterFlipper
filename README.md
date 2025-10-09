# letterFlipper

Repository of generalized functions for building visual stimuli presenting letters in MATLAB with Psychtoolbox.

## Overview

**yourProjectRepoName** is a MATLAB-based project developed for [insert research purpose here]. This repository contains code used for [experiment, simulation, data analysis, modeling, etc.], including all required user-defined functions and scripts.

## Dependencies

- MATLAB R2021a or newer
- Required Toolbox(es):
  - MATLAB (base)
  - [Add any additional toolboxes used]

## Installation

### macOS and Linux

Open a terminal and run:

```bash
# Navigate to desired install location
cd ~/Documents/MATLAB

# Clone the repository from GitHub
git clone https://github.com/yourGithubUsername/yourProjectRepoName.git

# Open MATLAB and add the project to your path:
addpath(genpath('~/Documents/MATLAB/yourProjectRepoName'))
savepath
```

### Windows

1. Open MATLAB
2. In the Command Window, run:

```matlab
% Change directory to desired location
cd('C:\Users\YourName\Documents\MATLAB')

% Clone from GitHub (or download ZIP and unzip manually)
system('git clone https://github.com/yourGithubUsername/yourProjectRepoName.git')

% Add the project folder to your MATLAB path:
addpath(genpath('C:\Users\YourName\Documents\MATLAB\yourProjectRepoName'))
savepath
```

## Usage

### Common File Types

| File/Folder            | Description                                       |
|------------------------|---------------------------------------------------|
| `yourMainScript.m`     | Primary script to run the project                 |
| `miscFcns/`            | User-defined functions that did not match a tag  |
| `subFolderName/`       | Functions grouped based on original path tags     |
| `data/`, `figures/`    | Additional manually created folders if present    |

## Tips for Reuse

- If you are adapting this repository for your own project, rename the folder and scripts as needed.
- If you wish to clean/export a new version, use `pipeCleaner` to regenerate a fresh copy with updated dependencies.
- If you make changes to file structure, be sure to re-test that your pipeline runs correctly.

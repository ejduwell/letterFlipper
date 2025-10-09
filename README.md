# letterFlipper

Repository of generalized functions for building visual stimuli presenting letters in MATLAB with Psychtoolbox.

## Overview

**yourProjectRepoName** is a MATLAB-based project developed for [insert research purpose here]. This repository contains code used for [experiment, simulation, data analysis, modeling, etc.], including all required user-defined functions and scripts.

## Dependencies

- MATLAB R2021a or newer
- Required Toolbox(es):
  - MATLAB (base)
  - [Deep Learning Toolbox](https://www.mathworks.com/help/deeplearning/index.html?s_tid=srchtitle_site_search_1_Deep+learning+toolbox)
  - [Computer Vision Toolbox](https://www.mathworks.com/help/vision/index.html?s_tid=srchtitle_site_search_1_Computer+vision+toolbox)
  - [Psychtoolbox 3](http://psychtoolbox.org/) (I developed this repository using version [3.0.19.13](https://github.com/Psychtoolbox-3/Psychtoolbox-3/tree/3.0.19.13))

## Installation:

### macOS and Linux

Open a terminal and run:

```bash
# Navigate to desired install location
cd ~/Documents/MATLAB

# Clone the repository from GitHub
git clone https://github.com/ejduwell/letterFlipper.git

# Open MATLAB and add the project to your path:
addpath(genpath('~/Documents/MATLAB/letterFlipper'))
savepath
```

### Windows

1. Open MATLAB
2. In the Command Window, run:

```matlab
% Change directory to desired location
cd('C:\Users\YourName\Documents\MATLAB')

% Clone from GitHub (or download ZIP and unzip manually)
system('git clone https://github.com/ejduwell/letterFlipper.git')

% Add the project folder to your MATLAB path:
addpath(genpath('C:\Users\YourName\Documents\MATLAB\letterFlipper'))
savepath
```

## Usage:

### Short List of Important Files

| File/Folder                | Description                                       |
|----------------------------|---------------------------------------------------|
| `genImgFlipperMain_v1.m`   | Primary script to run the project                 |
| `miscFcns/`                | User-defined functions that did not match a tag   |
| `subFolderName/`           | Functions grouped based on original path tags     |
| `data/`, `figures/`        | Additional manually created folders if present    |



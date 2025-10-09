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

### Short List of Important Files and Folders/Directories:

| File/Folder                         | Description                                                                                                             |
|-------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `letterFlipper/`                    | Main program directory. Contains Matlab code.                                                                           |
| `letterFlipper/stimImages/`         | Subdirectory where stimulus images are saved/stored.                                                                    |
| `letterFlipper/expDataOut/`         | Subdirectory where subjects' data are saved                                                                             |
| `txtPltCntrlFixImgStackBldr_v1.m`   | Main function for generating stimulus image sets                                                                        |
| `txtTaskImgBuilderPDF_01.m`         | 'Parameter Descriptor File' instance/template for defining adustable parameters used in txtPltCntrlFixImgStackBldr_v1.m |
| `genImgFlipperMain_v1.m`            | Main function for running/presenting stimuli                                                                            |
| `genImgFlipperPDF_01.m`             | 'Parameter Descriptor File' instance/template for defining adustable parameters used in genImgFlipperMain_v1.m          |


### General workflow for creating and running stimuli with letterFlipper:

- **Step 01:** Generate the desired stimulus image files using txtPltCntrlFixImgStackBldr_v1.m

- **Step 02:** Generate a genImgFlipperPDF_##.m instance pointing to stimulus files created in Step 01 and adjust other stimulus presentation parameters as desired.

- **Step 03:** Update genImgFlipperMain_v1.m to point to instance pointing to newly created genImgFlipperPDF_##.

- **Step 04:** Run genImgFlipperMain_v1.m to run the task.








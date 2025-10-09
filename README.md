# letterFlipper

Repository of code which establishes a generalized framework for building and running visual stimuli presenting letters in MATLAB with Psychtoolbox.

## General Overview:

**letterFlipper** is a MATLAB repository developed for building and implimenting cognitive vision science experiments presenting letter-containing stimuli with Psychtoolbox. **letterFlipper** contains generalized code enabling users to quickly and flexibly design and run wide range of potential visual tasks presenting letters/characters.

## Brief List of Built in Capabilities:
- Separate functions and workflows for image/task creation and task presentation enable users to develop and impliment tasks in a modular manner:
    - Let me unpack that: letterFlipper has separate, 'stand-alone' functions/workflows for both generating the stack of images and files presented in an experiment and for presenting them in the precise manner desired.
    - In other words, letterFlipper effectively allows users to flexibly generate a set of task images/rules with a "letter image/task generation" workflow and impliment/present them in desired manner using a separate "letter image flipper" task presentation workflow.
- Frameworks for creating and running tasks are highly generalized and can both create and impliment a wide range of potential different tasks with minimal coding.
    - Q: How does **letterFlipper** achieve this? A: 'Parameter Descriptor Files'
      - Users can flexibly create and update 'parameter descriptor files' 
      - These allow users to define all relevant aspects of

## Dependencies:

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
```

```bash
# Clone the repository from GitHub
git clone https://github.com/ejduwell/letterFlipper.git
```

```bash
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
```

```matlab
% Clone from GitHub (or download ZIP and unzip manually)
system('git clone https://github.com/ejduwell/letterFlipper.git')
```

```matlab
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

---
> - **Step 00:** Make a new `txtTaskImgBuilderPDF_##.m` instance/copy for this task, and adjust parameters to set desired stimulus image and response parameters
> - **Step 01:** Generate the desired stimulus image files using `txtPltCntrlFixImgStackBldr_v1`.
> - **Step 02:** Make a new `genImgFlipperPDF_##.m` instance/copy for this task pointing to stimulus files created in **Step 01** and adjust other stimulus presentation parameters as desired.
> - **Step 03:** Update `genImgFlipperMain_v1.m` to point to instance pointing to newly created genImgFlipperPDF_##.
> - **Step 04:** Run `genImgFlipperMain_v1.m` to run the task.
---

## Task Output Data:







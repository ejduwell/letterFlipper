
%% Set Parameters

strtDir=pwd; % save full path to wherever they start from 
             % (so we can return at the end)

% Specify which parameter descriptor file name to use..
parDescFile="txtTaskImgBuilderPDF_01";

disp(" ");
disp(strcat("Parameter descriptor file is set to: ",which(parDescFile)));
disp(" ");

% Read in parameters set in parDescFile:
% =========================================================================
parStruct = eval(parDescFile);
% =========================================================================

% Output/Save parameters
% Automatically detect and set directory/path params:
% -------------------------------------
% get matlab directory path by "which-ing" for this file..
% NOTE: key assumption: there is only one copy of this on the path.. (that
% should always be the case to avoid other conflicts..)
programDir = fileparts(which('txtPltCntrlFixImgStackBldr_v1.m'));
addpath(genpath(programDir)); % make sure the program folder is on our path
outputDirParent=strcat(programDir,"/stimImages"); % make outputDirParent the stimImages folder
% -------------------------------------
outDirName="testTaskImgs"; % Specify name for output director
outFileName="stimImgData.mat";

%% Run Image Generation Routine

%[tdfOut, fixOnlyIm, LRbuttons, correctButtonsCol] = txtPltCntrlFixImgGen_v1(parStruct);

[tdfOut, fixOnlyIm, LRbuttons, correctButtonsCol] = txtPltCntrlFixImgGen_v1_2(parStruct);

%% Grab the response variable info from parStruct to save in output

respVarInfo=struct;
respVarInfo.respParName=parStruct.respParName;
respVarInfo.tdfRespColName=parStruct.respColName;
respVarInfo.tdfRespColNum=parStruct.respParIdx;
respVarInfo.correctButtonsCol=correctButtonsCol;

%% Grab the QUEST variable info from parStruct to save in output

qstVarInfo=struct;
qstVarInfo.qstParName=parStruct.qstParName;
qstVarInfo.tdfQstColName=parStruct.qstColName;
qstVarInfo.tdfQstColNum=parStruct.qstParIdx;

%% Grab and save the "mode" that was run

SnellenEmode=parStruct.SnellenEmode;
if SnellenEmode==1
    mode="SnellenEmode";
else
    mode="normal";
end

%% Save the Outputs/Close Up.

% save data
uniqueTimeStamp = datestr(now,30); % get current time/date stamp for filename to ensure uniqueness
outDirFullPath=strcat(outputDirParent,"/",outDirName,"_",uniqueTimeStamp,"/");
mkdir(outDirFullPath);
outFileFullPath=strcat(outputDirParent,"/",outDirName,"_",uniqueTimeStamp,"/",outFileName);
save(outFileFullPath,"tdfOut","fixOnlyIm","LRbuttons","respVarInfo","qstVarInfo","mode","-v7.3");

% return to start location..
cd(strtDir);

% clear workspace
clear;
close all;
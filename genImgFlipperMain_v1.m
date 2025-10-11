%function genImgFlipperMain_v1()

%% Set Parameters

startDir=pwd; % save starting directory location
uniqueTimeStamp = datestr(now,30); % get current time/date stamp for filename to ensure uniqueness

parsIn=struct; % initialize
parsIn.parDescFile="genImgFlipperPDF_01";

% Output/Save parameters
% Automatically detect and set directory/path params:
% -------------------------------------
% get matlab directory path by "which-ing" for this file..
% NOTE: key assumption: there is only one copy of this on the path.. (that
% should always be the case to avoid other conflicts..)
programDir = fileparts(which('genImgFlipperMain_v1.m'));
addpath(genpath(programDir)); % make sure the program folder is on our path
outputDirParent=strcat(programDir,"/expDataOut"); % make outputDirParent the stimImages folder
% -------------------------------------


%% Get Subject Info

% Ask if they want to run the practice trials..
disp(" ");
subjectID = input('Please enter a 3-digit Subject ID code to use for this session. Then press return.  ','s');
disp(" ");

% build output folder name for this session..
outDirName=subjectID;
outSubDirName=strcat(subjectID,"_",uniqueTimeStamp);
outFileName=strcat(subjectID,"_",uniqueTimeStamp,".mat");

%% Run genImgFlipper_v1

%tdfOut = genImgFlipperQst_v1(parsIn);
%tdfOut = genImgFlipperQst_v1_2(parsIn);
tdfOut = genImgFlipperQst_v1_3(parsIn);

%% Save Output Data

% enter output parent directory
cd(outputDirParent);
% create directory for subject id if it doesn't exist yet
if ~exist(outDirName, 'dir')
    mkdir(outDirName);
end

% enter subject's directory
cd(outDirName);

% make subdirectory for this session
mkdir(outSubDirName);
% enter it
cd(outSubDirName);

% save a copy of the parameter descriptor file
parDescFile=which(parsIn.parDescFile);
curDir=pwd;
copyfile(parDescFile,strcat(curDir,"/pdfFileFrmExmt_",outSubDirName,".m"));

% get the parameter struct output from the parameter descriptor file
%parsIn.expParz = eval(parsIn.parDescFile);

% save it plus the subject response data from this session
save(outFileName,"tdfOut","parsIn","-v7.3");

% return to start directory
cd(startDir);

%% Clean Up
clear;
close all;
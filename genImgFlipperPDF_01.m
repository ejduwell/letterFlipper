function expParz = genImgFlipperPDF_01()

%% Initialize Output Struct

expParz=struct;

%% Input Data/TDF Parameters

% ADJUSTABLE PARS: PARS YOU MAY NEED/WANT TO ADJUST
%--------------------------------------------------------------------------
% Specify path to .mat file containing the tdf
expParz.path2tdfMat="/home/eduwell/SynologyDrive/SNAP/projects/sandbox/pipeCleaner/cleanPrgrmDirsOut/letterFlipper/stimImages/testTaskImgs_20250715T185809/stimImgData.mat";
%--------------------------------------------------------------------------

% AUTO SET PARS: DON'T UPDATE THESE UNLESS ABSOLUTELY NECESSARY
%--------------------------------------------------------------------------
% Load and store the tdf variable from the .mat file in the struct out..
matFilePars=load(expParz.path2tdfMat);
expParz.tdfIn=matFilePars.tdfOut;
% Grab the "fixation only" image..
expParz.fixOnlyIm=matFilePars.fixOnlyIm;
% Grab the LRbuttons indicating the expected left and right button keys..
expParz.LRbuttons=matFilePars.LRbuttons;
% Specify which column contains the stimulus images
expParz.imgCol=size(expParz.tdfIn,2); % currently assuming its the last column..

% get the response variable info
expParz.respVarInfo=matFilePars.respVarInfo;
% Note: for reference, this should contain:
%----------------------------------------------------
% respVarInfo.respParName=parStruct.respParName;
% respVarInfo.tdfRespColName=parStruct.respColName;
% respVarInfo.tdfRespColNum=parStruct.respParIdx;
% respVarInfo.correctButtonsCol=correctButtonsCol;
%----------------------------------------------------

% get QUEST variable info
expParz.qstVarInfo=matFilePars.qstVarInfo;
% Note: for reference, this should contain:
%----------------------------------------------------
% qstVarInfo.qstParName=parStruct.qstParName;
% qstVarInfo.tdfQstColName=parStruct.qstColName;
% qstVarInfo.tdfQstColNum=parStruct.qstParIdx;
%----------------------------------------------------
%--------------------------------------------------------------------------

%% Screen Dimension Parameters

% ADJUSTABLE PARS: PARS YOU MAY NEED/WANT TO ADJUST
%--------------------------------------------------------------------------
% Specify proportion of screen to use
% Note: should be values ranging 0-1. 
% 1 means use full width/height
% 0.25 means use 25%, 0.5 means use 50%, etc...
expParz.widProp=0.5;
expParz.heiProp=1;
%--------------------------------------------------------------------------

%% Trial Structure/Timing Parameters

% ADJUSTABLE PARS: PARS YOU MAY NEED/WANT TO ADJUST
%--------------------------------------------------------------------------
% Specify the total number of trials desired for the experiment
expParz.numTrials=50;
% Presentation Time for the image in seconds
expParz.presTimeSecs = 0.25;
% Interstimulus interval time in seconds
expParz.isiTimeSecs = 1;
% Number of frames to wait before re-drawing
expParz.waitframes = 1;
% Max time allowed for response..
expParz.tRespMax=200; % set to large number if you want effectively unlimited response time..
%--------------------------------------------------------------------------

%% QUEST Parameters

expParz.qstParams=struct;
expParz.qstParams.questParTdfCol=1;
expParz.qstParams.nQuests=3;
expParz.qstParams.qstMinMax={5,75};
expParz.qstParams.qstThresholds={0.65,0.70,0.75};

for hh=1:expParz.qstParams.nQuests
    qStringTmp=strcat("q",num2str(hh));
    expParz.qstParams.(qStringTmp).thrhld = expParz.qstParams.qstThresholds{1,hh};
    expParz.qstParams.(qStringTmp).tGuess = mean(expParz.qstParams.qstMinMax{1,:}); % start at the mean of the range
    expParz.qstParams.(qStringTmp).tGuessSd = 0.3*(abs(expParz.qstParams.qstMinMax{1,1}-expParz.qstParams.qstMinMax{1,2}));  % set std. dev. to n% of the total possible parameter value range
    expParz.qstParams.(qStringTmp).grain = 0.01;
    expParz.qstParams.(qStringTmp).range = 2*(abs(expParz.qstParams.qstMinMax{1,1}-expParz.qstParams.qstMinMax{1,2})); % set quest range to 2 times total possible parameter range.
end

% common to all quests..
%--------------------------------------------------------------------------
expParz.qstParams.common.beta=3.5;
expParz.qstParams.common.delta=0.01;
expParz.qstParams.common.gamma=0.5;
%--------------------------------------------------------------------------

end
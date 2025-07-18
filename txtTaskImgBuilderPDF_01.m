function parStruct = txtTaskImgBuilderPDF_01()

%% Initialize Output Struct

parStruct=struct; % initialize

%% Specify Parameters that vary across images

% (NOTE: each line/row/index is a separate image & correresponding 
% rows/indices across parameter arrays correspond to the same image)
% =========================================================================

% Build out set of letters
%--------------------------------------------------------------------------
parStruct.letterSet={'E'};
parStruct.SnellenEmode=1; % if 1, will build "snellen Es" instead of drawing normal text..
%--------------------------------------------------------------------------

% Build out set of locations
%--------------------------------------------------------------------------
parStruct.nEcc=1;
parStruct.MinMaxEcc=[0,0]; % max/min eccentricity
parStruct.nAng=1; % 
%parStruct.MinMaxAng=[0,(360-(360/parStruct.nAng))]; % for nAng evenly spaced between 0 and 360
parStruct.MinMaxAng=[0,0]; % for nAng evenly spaced between 0 and 360
parStruct.LocationSet = genEccAngSet_v1(parStruct.nEcc, parStruct.nAng, parStruct.MinMaxEcc, parStruct.MinMaxAng);
%--------------------------------------------------------------------------

% Build out set of text sizes
%--------------------------------------------------------------------------
parStruct.nTxtSizes=71;
parStruct.txtSizeMinMax=[5,75];
parStruct.txtSizeSet=num2cell(linspace(parStruct.txtSizeMinMax(1),parStruct.txtSizeMinMax(2),parStruct.nTxtSizes));
%--------------------------------------------------------------------------

% Build out set of text colors
%--------------------------------------------------------------------------
parStruct.txtClrSet={
    [0,0,0],... 
    };
%--------------------------------------------------------------------------

% Build out set of text rotation angles
%--------------------------------------------------------------------------
% note, angles assume clockwise rotation..
parStruct.txtAngSet={
    0,...
    90,...
    -90,...
    180,...
    };

%--------------------------------------------------------------------------

% List Names for Sets Pars Changing Across Images
%--------------------------------------------------------------------------
parStruct.combVecParNames={
    "setOfLetters",...
    "setOfLocations",...
    "txtSize",...
    "txtClr",...
    "setOfAngles",...
    };
%--------------------------------------------------------------------------

% List Corresponding Sets of Pars Changing Across Images
%--------------------------------------------------------------------------
parStruct.combVecPars={
    parStruct.letterSet,...
    parStruct.LocationSet,...
    parStruct.txtSizeSet,...
    parStruct.txtClrSet,...
    parStruct.txtAngSet,...
    };
%--------------------------------------------------------------------------

% List TDF Header Label Names for Sets Pars Changing Across Images
%--------------------------------------------------------------------------
parStruct.tdfHeaderz={
    "Letter",...
    "Location",...
    "TextSize",...
    "TextColor",...    
    "TextRotation",...
    };
%--------------------------------------------------------------------------

%% Generate full set of all possible images with combVecCellz2Struct_v1

%parStruct.updatedImgPars = combVecCellz2Struct_v1(parStruct.combVecPars,parStruct.combVecParNames);
parStruct.updatedImgPars = combVecCellz2Struct_v2(parStruct.combVecPars,parStruct.combVecParNames);

%% Specify parameter for 2AFC responses

parStruct.respParName=parStruct.combVecParNames{1,5}; % specify par name in combVecParNames
parStruct.respColName=parStruct.tdfHeaderz{1,5}; % specify column name in tdfHeaderz
% Automatically save the index too..
parStruct.respParIdx = find(cellfun(@(x) isequal(x, parStruct.respParName), parStruct.combVecParNames));

%% Specify parameter for QUEST to manipulate

parStruct.qstParName=parStruct.combVecParNames{1,3}; % specify par name in combVecParNames
parStruct.qstColName=parStruct.tdfHeaderz{1,3}; % specify column name in tdfHeaderz
% Automatically save the index too..
parStruct.qstParIdx = find(cellfun(@(x) isequal(x, parStruct.qstParName), parStruct.combVecParNames));

%% Specify "L" and "R" Buttons and Build Correct Button Column

parStruct.LRbuttons=upper({'W','D','A','S'}); % set buttons. ensure uppercase..

% Build out parKeyPressDecoder:
% each row is for a single parameter and should contain a 1x2 cell array.
% the first variable in each cell array should be the parameter value, the
% second variable in each cell array should be the expected character
% string for desired "correct" button press for that par value
%--------------------------------------------------------------------------
% parStruct.parKeyPressDecoder={
%     {parStruct.combVecPars{1,parStruct.respParIdx}{1,1},parStruct.LRbuttons{1,1}}, ...
%     {parStruct.combVecPars{1,parStruct.respParIdx}{1,2},parStruct.LRbuttons{1,2}}, ...
%     };
parStruct.parKeyPressDecoder={
    {parStruct.combVecPars{1,parStruct.respParIdx}{1,1},parStruct.LRbuttons{1,1}}, ...
    {parStruct.combVecPars{1,parStruct.respParIdx}{1,2},parStruct.LRbuttons{1,2}}, ...
    {parStruct.combVecPars{1,parStruct.respParIdx}{1,3},parStruct.LRbuttons{1,3}}, ...
    {parStruct.combVecPars{1,parStruct.respParIdx}{1,4},parStruct.LRbuttons{1,4}}, ...
    };
%--------------------------------------------------------------------------

% Build out the "correct button press" array automatically using Ethan's
% respPar2KeyPress_v1 function, the response parameter in the first input
% position, and the parKeyPressDecoder in the second positon.
%--------------------------------------------------------------------------
parStruct.correctButtons = respPar2KeyPress_v1(parStruct.updatedImgPars.(parStruct.respParName),parStruct.parKeyPressDecoder);
%--------------------------------------------------------------------------

%% Fixation point parameters...

%--------------------------------------------------------------------------
parStruct.fixChar='+'; % specify which character to use for fixation
parStruct.fixSize=30; % fixation character size
parStruct.fixClr=[1,1,1]; % fixation character color
%--------------------------------------------------------------------------

%% Set output stimulus image size..

%--------------------------------------------------------------------------
parStruct.cropsz = 1024; % output edge dimension of screen & images (square)
%--------------------------------------------------------------------------

%% other misc pars

%--------------------------------------------------------------------------
parStruct.pause4eachIm=0; % if 1, will pause after each image waiting for button press to continue..
%--------------------------------------------------------------------------

end
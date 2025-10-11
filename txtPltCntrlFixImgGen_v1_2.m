function [tdfOut, fixOnlyIm, buttons, correctButtonsCol] = txtPltCntrlFixImgGen_v1_2(parsIn)

%% Unpack Input Parameters

% Check whether SnellenE_Mode is on..
SnellenE_Mode=parsIn.SnellenEmode;

% get set of field names for image pars updated across images..
updatedImgParFldz=fieldnames(parsIn.updatedImgPars);

% transpose updatedImgPars bc ethan is a dufus..
for kk=1:size(updatedImgParFldz,1)
    fldPass=updatedImgParFldz{kk,1};
    parsIn.updatedImgPars.(fldPass)=parsIn.updatedImgPars.(fldPass)';
end
% 
% setOfLetters = parsIn.updatedImgPars.setOfLetters';
% setOfLocations = parsIn.updatedImgPars.setOfLocations';
% setOfAngles = parsIn.updatedImgPars.setOfAngles';
% txtClr = parsIn.updatedImgPars.txtClr';
% txtSize = parsIn.updatedImgPars.txtSize';

% read in and process parameters that don't change across images..
cropsz = parsIn.cropsz';
fixChar = parsIn.fixChar';
fixSize = parsIn.fixSize';
fixClr = parsIn.fixClr';
pause4eachIm = parsIn.pause4eachIm;
correctButtons=parsIn.correctButtons;
buttons=parsIn.buttons;

nImgz = size(parsIn.updatedImgPars.(updatedImgParFldz{1,1}), 2);
imageArrayOut = cell(1, nImgz);

%% Build Mask Aperture

MaskImg = buildCircularMask(cropsz);
MaskImg = repmat(MaskImg, 1, 1, 3);  % Make RGB

%% Prepare the Screen

sca;
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens'));
grey = WhiteIndex(screenNumber) / 2;
windowRect = [0 0 cropsz cropsz];
scrn_1percX = cropsz / 100; % compute 1 perc interval for X
scrn_1percY = cropsz / 100; % compute 1 perc interval for Y
[xCenter, yCenter] = RectCenter(windowRect);

window = PsychImaging('OpenWindow', screenNumber, grey, windowRect);
Screen(window, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% Create Fixation + Background Only Image

Screen('TextSize', window, fixSize);
DrawFormattedText(window, fixChar, 'center', 'center', fixClr);
Screen('Flip', window);
fixOnlyIm = Screen('GetImage', window);
fixOnlyIm = uint8(double(fixOnlyIm) .* MaskImg);
fixImg_tex = Screen('MakeTexture', window, fixOnlyIm);

%% Create Background Only Image..

% Draw fixation & gray background
Screen('FillRect', window, grey);
Screen('Flip', window);
bgOnlyIm = Screen('GetImage', window);
bgOnlyIm = uint8(double(bgOnlyIm) .* MaskImg);
bgImg_tex = Screen('MakeTexture', window, bgOnlyIm);


%% Main Stimulus Loop

% initialize struct for storing pars updated each pass..
passPars=struct;
for kk=1:size(updatedImgParFldz,1)
    fldPass=updatedImgParFldz{kk,1};
    passPars.(fldPass)={}; % initialize as empty cell..
end

for ii = 1:nImgz
    
    %  update image pars for this pass
    for kk=1:size(updatedImgParFldz,1)
        fldPass=updatedImgParFldz{kk,1};
        passPars.(fldPass)=parsIn.updatedImgPars.(fldPass){1,ii};
    end
    % passPars Parameters Key For Reference:
    %----------------------------------------------------------------------
    % txt2Plt = passPars.(updatedImgParFldz{1,1})
    % xVal = passPars.(updatedImgParFldz{2,1})(1);
    % yVal = passPars.(updatedImgParFldz{2,1})(2);  
    % txtSizePass = passPars.(updatedImgParFldz{3,1})
    % txtClrPass = passPars.(updatedImgParFldz{4,1})    
    % currentAngle = passPars.(updatedImgParFldz{5,1})
    %----------------------------------------------------------------------

    xVal = passPars.(updatedImgParFldz{2,1})(1);
    yVal = passPars.(updatedImgParFldz{2,1})(2);    
    destX = xCenter + xVal * scrn_1percX;
    destY = yCenter + yVal * scrn_1percY;

    % Draw fixation & gray background
    Screen('FillRect', window, grey);
    %Screen('DrawTexture', window, fixImg_tex);
    Screen('DrawTexture', window, bgImg_tex);
    
    %% Measure Text Bounds
    
    if SnellenE_Mode==0
        Screen('TextSize', window, passPars.(updatedImgParFldz{3,1}));
        textBounds = Screen('TextBounds', window, passPars.(updatedImgParFldz{1,1}));
        textW = textBounds(3) - textBounds(1);
        textH = textBounds(4) - textBounds(2);
        padding = 10;  % Margin in pixels
    
        % Create offscreen window sized to text + padding
        offScrRect = [0 0 ceil(textW + 2 * padding) ceil(textH + 2 * padding)];
        offScr = Screen('OpenOffscreenWindow', window, grey, offScrRect);
    
        % Draw text centered in the offscreen window
        Screen('TextSize', offScr, passPars.(updatedImgParFldz{3,1}));
        DrawFormattedText(offScr, passPars.(updatedImgParFldz{1,1}), 'center', 'center', passPars.(updatedImgParFldz{4,1}));

        % Make texture from offscreen window
        txtTexture = Screen('MakeTexture', window, Screen('GetImage', offScr));
        Screen('Close', offScr);

        % Get texture size & position it on screen
        [texW, texH] = Screen('WindowSize', txtTexture);

    elseif SnellenE_Mode==1
    
        snellenEbgClr=[grey,grey,grey];
        %snellenEtxtClr=[0,0,0];
        snellenEtxtClr=passPars.(updatedImgParFldz{4,1});

        snellenEimg = plotSnellen_E(snellenEbgClr,snellenEtxtClr,passPars.(updatedImgParFldz{3,1}));
        texW = size(snellenEimg,2);
        texH = size(snellenEimg,1);
        txtTexture = Screen('MakeTexture', window, snellenEimg);

    end
    
    dstRect = CenterRectOnPoint([0 0 texW texH], destX, destY);

    % Draw rotated texture at desired location
    Screen('DrawTextures', window, txtTexture, [], dstRect, passPars.(updatedImgParFldz{5,1}));
    %Screen('DrawTextures', window, txtTexture, [], [], passPars.(updatedImgParFldz{5,1}));

    % Flip to the screen
    Screen('Flip', window);

    % Capture image and apply mask
    img_snap = Screen('GetImage', window);
    img_snap = uint8(double(img_snap) .* MaskImg);
    imageArrayOut{1,ii} = img_snap;

    % Pause if needed
    if pause4eachIm
        disp("Press any key to continue...");
        KbStrokeWait;
    end
end

sca;

%% Package Output

% get the initial length of the headers for reference
initHeaderLength=length(parsIn.tdfHeaderz);

% build the headers
tdfHeaderz = horzcat(parsIn.tdfHeaderz,{"CorrectButtons", "StimulusImg"});

% save the column number containing the correct button presses
correctButtonsCol=initHeaderLength+1;

% initialize tdfOut as just ther first updatedImgPars column
tdfOut=parsIn.updatedImgPars.(updatedImgParFldz{1,1})';
% then loop through and iteratively horzcat on the rest of the updatedImgPars.
for ii=2:(size(updatedImgParFldz,1))
    fldPass=updatedImgParFldz{ii,1};
    tdfOut=horzcat(tdfOut,parsIn.updatedImgPars.(fldPass)');
end

% then add the correctButtons and imageArray columns
tdfOut = horzcat(tdfOut, correctButtons', imageArrayOut');
% finally, add the headers
tdfOut = vertcat(tdfHeaderz, tdfOut);

end

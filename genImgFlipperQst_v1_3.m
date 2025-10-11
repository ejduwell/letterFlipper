function tdfOut = genImgFlipperQst_v1_3(parsIn)
%
% genImgFlipperQst_v1:
% General "image flipper" function for presenting visual images and
% collecting button presses/response times.
%
% E.J. Duwell, PhD wrote this 7/9/25 as a postdoc in Adam Greenberg's Lab
% at the Medical College of Wisconsin (MCW)
% 
% Ethan built this using a couple of Peter Scarfe's demos as a starting 
% point: 
%--------------------------------------------------------------------------
% https://peterscarfe.com/orientationThreshold.html
% https://peterscarfe.com/accurateTiming.html
%--------------------------------------------------------------------------


%----------------------------------------------------------------------
%%                       Process Input Parameters
%----------------------------------------------------------------------

% Get the parameter descriptor file name to use..
parDescFile=parsIn.parDescFile;

disp(" ");
disp(strcat("Experiment descriptor file is set to: ",which(parDescFile)));
disp(" ");

% Read in and unpack parDescFile parameters:
% =========================================================================
expParz = eval(parDescFile);
tdfIn=expParz.tdfIn;
tdfHeaderz=tdfIn(1,:); % split off the tdf headers
tdfIn=tdfIn(2:end,:); % split off the tdf data..
fixOnlyIm=expParz.fixOnlyIm;
widProp=expParz.widProp;
heiProp=expParz.heiProp;
imgCol=expParz.imgCol;
%ImgWindowPadding=expParz.ImgWindowPadding;
buttons=expParz.buttons;
%numTrials=size(tdfIn,1); % get the total # of trials..
numTrials=expParz.numTrials;
respCol=cell(1,numTrials);
correctnessCol=cell(1,numTrials);
tRespCol=cell(1,numTrials);
tdfOut=cell(numTrials,size(tdfIn,2)); % initialize tdfOut as empty cell
                                      % array with same # of columns as 
                                      % tdfIn, but with numTrials rows..
trialParams=zeros(1,numTrials); % initialize array to store params for each trial
respVarInfo=expParz.respVarInfo;
tdfRespColNum=respVarInfo.tdfRespColNum; % grab column number of response 
                                         % variable column in the tdf

% build column indicating which column is the "response variable"                                         
respVarColNumCol=num2cell(tdfRespColNum.*(ones(1,numTrials)));

correctButtonsCol=respVarInfo.correctButtonsCol;
nButtons=length(buttons);
% =========================================================================

% Seed the random number generator
rng('shuffle');

%----------------------------------------------------------------------
%%                       Set Up the Quests
%----------------------------------------------------------------------

% pull out the quest parameters from the input struct
qstParams=expParz.qstParams; 

% get the info on the QUEST manipulated variable too
qstVarInfo=expParz.qstVarInfo;
tdfQstColNum=qstVarInfo.tdfQstColNum;
qstVarColCpy=cell2mat(tdfIn(:,tdfQstColNum)); % make ref copy of the quest var col

% initialize field to store the quest subfield names..
qstSubFldz=cell(1,qstParams.nQuests); 
for hh=1:qstParams.nQuests
    % update qStringTmp for this pass..
    qStringTmp=strcat("q",num2str(hh));
    % store the subfield name in qstSubFldz
    qstSubFldz{1,hh}=qStringTmp;
    % Set up the quest with the pars stored in qstParams(qStringTmp) ...
    qstParams.(qStringTmp).QUEST=QuestCreate(qstParams.(qStringTmp).tGuess,qstParams.(qStringTmp).tGuessSd,qstParams.(qStringTmp).thrhld,qstParams.common.beta,qstParams.common.delta,qstParams.common.gamma,qstParams.(qStringTmp).grain,qstParams.(qStringTmp).range);        
    qstParams.(qStringTmp).QUEST.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.    
end

% use the total number of trials, the number of interleaved quests, and the
% names loaded into qstSubFldz above to build a cell column numTrials with
% each quest subfield name sequentially as many times as required to make a
% total of numTrials trials..
nQstReps=(numTrials/qstParams.nQuests);
nQstRepsFloor=floor(nQstReps);
decTest=nQstReps-nQstRepsFloor;
if decTest>0
    nQstReps=nQstRepsFloor+1; % if there is a decimal, add 1 to nQstRepsFloor
end

% Build an array of nQstReps concatenated copies of qstSubFldz
questCol=repmat(qstSubFldz,1,nQstReps);
% Cut to size to ensure length always equals numTrials
questCol=questCol(:,1:numTrials);

% build column indicating which column is the "QUEST variable"
questVarColNumCol=num2cell(tdfQstColNum.*(ones(1,numTrials)));

% get the max and min values specified for quest
maxparam=qstParams.qstMinMax{1,2};
minparam=qstParams.qstMinMax{1,1};

%----------------------------------------------------------------------
%%                       Prepare the Screen
%----------------------------------------------------------------------

sca;
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
grey = WhiteIndex(screenNumber) / 2;
black = BlackIndex(screenNumber);
windowRect = Screen('Rect',0);	% get the size of the display screen
windowRect(3)=windowRect(3)*widProp;
windowRect(4)=windowRect(4)*heiProp;
scrn_1percX = windowRect(3) / 100; % compute 1 perc interval for X
scrn_1percY = windowRect(4) / 100; % compute 1 perc interval for Y
[xCenter, yCenter] = RectCenter(windowRect);

window = PsychImaging('OpenWindow', screenNumber, black, windowRect);
Screen(window, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');

% Create offscreen window sized to image size + padding
% imW=size(fixOnlyIm,2);
% imH=size(fixOnlyIm,1);
%offScrRect = [0 0 ceil(imW + 2 * ImgWindowPadding) ceil(imH + 2 * ImgWindowPadding)];
%offScr = Screen('OpenOffscreenWindow', window, black, offScrRect);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 40);

%----------------------------------------------------------------------
%%                       Timing Information
%----------------------------------------------------------------------

% Presentation Time for the Gabor in seconds and frames
%presTimeSecs = 0.2;
presTimeSecs=expParz.presTimeSecs;
presTimeFrames = round(presTimeSecs / ifi);

% Interstimulus interval time in seconds and frames
%isiTimeSecs = 1;
isiTimeSecs=expParz.isiTimeSecs;
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to wait before re-drawing
%waitframes = 1;
waitframes=expParz.waitframes;

% get the max response time
tRespMax=expParz.tRespMax;

%----------------------------------------------------------------------
%%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right button keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');

buttonz=struct;
for kk=1:nButtons
    buttonStr=strcat("b",num2str(kk));
    buttonz.(buttonStr)= KbName(buttons{1,kk});
end
%leftKey = KbName(LRbuttons{1,1});
%rightKey = KbName(LRbuttons{1,2});

%----------------------------------------------------------------------
%%                       Experimental loop
%----------------------------------------------------------------------

% pre-make fixation only texture..
fixImgTex = Screen('MakeTexture', window, fixOnlyIm);
%txtTexture = Screen('MakeTexture', window, Screen('GetImage', offScr));
destX = xCenter;
destY = yCenter;
% Get texture size & position it on main screen
[texW, texH] = Screen('WindowSize', fixImgTex);
dstRect = CenterRectOnPoint([0 0 texW texH], destX, destY);

% Set drawing to maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel); % set process priority to highest

ListenChar(2);  % stop throwing characters to matlab windows
HideCursor; % hide cursor..

% Animation loop: we loop for the total number of trials
for trial = 1:numTrials

    % Update QUEST pars for this trial/pass
    %======================================================================
    % get the quest calling the shots for this trial..
    qstFldPass=questCol{1,trial};
    
    % if this is the first pass (for any of the quests), start at the 
    % midpoint between max/min
    if trial<=qstParams.nQuests
        trialParams(1,trial)=qstParams.(qstFldPass).tGuess;
    else
        %trialParams(trial)=quant(10^(QuestQuantile(q1)),0.1);  % get next level of parameter to test
        trialParams(1,trial)=quant(10^(QuestQuantile(qstParams.(qstFldPass).QUEST)),0.1);  % get next level of parameter to test
    end
    if isnan(trialParams(1,trial))
        trialParams(1,trial)= trialParams(1,trial-1);
    end

    % limit to range btw maxparam and minparam
    if trialParams(1,trial) > maxparam
        trialParams(1,trial) = maxparam;
    end
    if trialParams(1,trial) < minparam
        trialParams(1,trial) = minparam;
    end

    % grab the parameter closest to the one requested by quest and save it 
    % back in its index for this trial/pass and get the index within the 
    % tdf (tdfIdxPass) using getIndexOfClosestPar_v1
    [tdfIdxPass, trialParams(1,trial)] = getIndexOfClosestPar_v1(qstVarColCpy,trialParams(1,trial));
    % add full row of tdfIn at tdfIdxPass to this trials row in tdfOut
    tdfOut(trial,:)=tdfIn(tdfIdxPass,:);
    %======================================================================

    % grab image for this pass from tdf..
    stimImgPass=tdfOut{trial,imgCol};

    % Make texture from offscreen window
    imgTexture = Screen('MakeTexture', window, stimImgPass);

    % If this is the first trial we present a start screen and wait for a
    % key-press
    if trial == 1
        % Draw fixation texture at desired location
        Screen('DrawTextures', window, fixImgTex, [], [], 0);
        % draw message ..
        DrawFormattedText(window, 'Press Any Key To Begin', 'center', (yCenter-scrn_1percY*20), white);
        vbl = Screen('Flip', window);
        KbStrokeWait;
    end

    % Flip again to sync us to the vertical retrace at the same time as
    % drawing our fixation point

    % Draw  fixation texture at desired location
    Screen('DrawTextures', window, fixImgTex, [], [], 0);
    % vbl = Screen('Flip', window);
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Now we present the isi interval with fixation point minus one frame
    % because we presented the fixation point once already when getting a
    % time stamp. We dont really need a loop here, we could use a value of
    % waitframnes greater than one. However, as we are using a loop below,
    % I have also used a loop here.
    for frame = 1:isiTimeFrames - 1

        % Draw fixation image texture at desired location
        Screen('DrawTextures', window, fixImgTex, [], [], 0);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end


    % Now we draw the stimulus image and the fixation point (assuming that
    % the fixation point drawn within the stimulus image as in fixation img)
    % Draw stimulus image texture at desired location
    Screen('DrawTextures', window, imgTexture, [], [], 0);
    % Flip to the screen
    vblInit = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Now we wait for a keyboard button signaling the observers response.
    % The left arrow key signals a "left" response and the right arrow key
    % a "right" response. You can also press escape if you want to exit the
    % program
    respToBeMade = true;
    tSinceFlp=GetSecs-vblInit;
    tResp=[]; % initialize tResp as empty double to control for non-responses
    response=[]; % initialize response as empty too for same reason..
    correctness=false; % initialize as false for same reason..
    while ((respToBeMade) && (tRespMax>tSinceFlp))
        tSinceFlp=GetSecs-vblInit;
        [keyIsDown,RespSecs, keyCode] = KbCheck;
                
        if keyCode(escapeKey)
            ShowCursor;
            ListenChar(0);
            sca;
            return
        elseif keyIsDown==1            
            response=upper(KbName(keyCode));
            correctness=(response==tdfOut{trial,correctButtonsCol});
            respToBeMade = false;
            tResp=RespSecs-vblInit;
        end
    end
    
    % Draw fixation image texture at desired location
    Screen('DrawTextures', window, fixImgTex, [], [], 0);
    % Flip to the screen
    vbl = Screen('Flip', window);

    % Record the response
    respCol{1,trial}=response;
    tRespCol{1,trial}=tResp;
    correctnessCol{1,trial}=correctness;

    % Update the QUESTS
    %----------------------------------------------------------------------
    for hh=1:qstParams.nQuests
        % update qStringTmp for this pass..
        qStringTmp=strcat("q",num2str(hh));
        % update the quest 
        qstParams.(qStringTmp).QUEST = QuestUpdate(qstParams.(qStringTmp).QUEST,log10(trialParams(1,trial)),correctness);
    end
    %----------------------------------------------------------------------
    
end

%% Show final page

accuracy=round(mean(cell2mat(correctnessCol)).*100);
accuracyMessage=char(strcat("Accuracy Was ",num2str(accuracy)," Percent"));

% Draw fixation texture at desired location
Screen('DrawTextures', window, fixImgTex, [], [], 0);
% draw message ..
DrawFormattedText(window, 'This Run is Complete! Press Any Key To Exit.', 'center', (yCenter+scrn_1percY*20), white);
DrawFormattedText(window, accuracyMessage, 'center', (yCenter-scrn_1percY*20), white);
vbl = Screen('Flip', window);
KbStrokeWait;

disp(" ");
disp(accuracyMessage);
disp(" ");


%% Repackage the tdf with the responses..

tdfHeaderz{1,end+1}="SubjectResponses";
tdfHeaderz{1,end+1}="ResponseTimes";
tdfHeaderz{1,end+1}="Correctness";
tdfHeaderz{1,end+1}="RespVarColNum";
tdfHeaderz{1,end+1}="QUEST";
tdfHeaderz{1,end+1}="QuestVarColNum";

tdfOut= horzcat(tdfOut,respCol',tRespCol',correctnessCol',respVarColNumCol',questCol',questVarColNumCol');
tdfOut=vertcat(tdfHeaderz,tdfOut);

%% Clean up

sca;
ShowCursor;
ListenChar(0);
Priority(0);

end

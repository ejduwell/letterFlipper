function keyPressArray = respPar2KeyPress_v1(parArray,parKeyPressDecoder)
%
% respPar2KeyPress_v1:
%
% respPar2KeyPress_v1 takes in an array of parameter values (parArray) plus
% a "decoder" (parKeyPressDecoder) indicating the correct button for each
% parameter value and returns an array containing the "correct" responses
% to the parameter values in parArray.
%
% This function accepts two input variables:
% parArray: a 1xN cell array input called parArray containing a list of 
%           parameters. Each index is presumed to be the parameter for a
%           particular trial.
%
% parKeyPressDecoder: a 1xN cell array of 1x2 cell arrays containing parameter 
%                     values in the first column, and the corresponding 
%                     desired button press in the second column. Each row 
%                     is for a separate parameter value.
%
% This function outputs a single variable:
% keyPressArray: This is the array of "correct" button presses in response
% to the input parArray based on the contents of the parKeyPressDecoder
%
% Written by E.J. Duwell PhD 7/2025
%

%% Initialize output array

keyPressArray=cell(1,size(parArray,2));

%% Get indices of each unique parameter in parKeyPressDecoder

nRespPars=size(parKeyPressDecoder,2); % compute the total number of response parameters
for ii=1:nRespPars
    parKeyPair=parKeyPressDecoder{1,ii};
    parPass=parKeyPair{1,1};
    keyPass=parKeyPair{1,2};
    logicIdxsPass = cellfun(@(x) isequal(x, parPass), parArray);
    idxsPass = find(logicIdxsPass);
    for jj=1:length(idxsPass)
        idx=idxsPass(jj);
        keyPressArray{1,idx}=keyPass;
    end
end


end
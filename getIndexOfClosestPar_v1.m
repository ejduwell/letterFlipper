function [idxOut, parValOut] = getIndexOfClosestPar_v1(parColIn,parValIn)

%% Ensure rng is shuffled

rng("shuffle");

%% Find the val in parColIn closest to parValIn

% grab the image from  img_array with parameter closest to one
% suggested by from quest (param1)
a=parColIn(:,1);
n=parValIn; % assign the most recent param in param1 to "n"
dVect=abs(a-n); % compute differnce vector to get indices with smallest dif
[val,idx]=min(dVect); % find smallest difference value..
matchIdxs=find(dVect==val); % grab indices matching this
% grab a random index from matchIdxs (in case there are multiple)
idxOut = matchIdxs(randi([1, length(matchIdxs)]),1);
parValOut=parColIn(idxOut,1);

end
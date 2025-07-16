function parStuct = combVecCellz2Struct_v2(arrayIn,parNamesIn)

%% Initialize output variable

parStuct=struct;

%% Process input parameters

% get the total number of unique parameters
nParz=size(arrayIn,2); 

% get the total number of values for each unique parameter set
parIdxs=cell(1,nParz); % preallocate
parValzTot=cell(1,nParz); % preallocate
for ii=1:nParz
    nParValz=size(arrayIn{1,ii},2);
    parIdxs{1,ii}=linspace(1,nParValz,nParValz);
    parValzTot{1,ii}=nParValz;
end

%% Use combvec to build combVecIdxArray of parameter index values

% Because combvec only accepts vectors of numbers we need to give it the
% sets of index values instead of the actual cell contents stored at that
% particular index. combvect works fast and can quickly spit out the full
% set of combinations. We'll just need to convert the output matrix of 
% index values into a cell array containing the contents at those indices 
% in an additional step (right after this one).

combVecIdxArray = (combvec(parIdxs{1,:}))';

%% Use index values in combVecIdxArray to build out combVecParArray

% convert the combvec output matrix of index values into a cell array 
% containing the contents at those indices in that parameter's cell 
% in the input array (arrayIn).

% initialize with cell array equivilant of combVecIdxArray
% (this will have the desired dimensions)
combVecParArray = num2cell(combVecIdxArray); 

nRowz=size(combVecParArray,1);
for ii=1:nParz
    for jj=1:nRowz
        combVecParArray{jj,ii}=arrayIn{1,ii}{1,combVecParArray{jj,ii}};
    end    
end

%% Load the cell columns for each parameter into final output struct

for ii=1:nParz
    parNamePass=parNamesIn{1,ii};
    parStuct.(parNamePass)=combVecParArray(:,ii);
end


end
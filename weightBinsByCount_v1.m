function [xOut,yOut,cOut] = weightBinsByCount_v1(x,y,c)

    % get the sum of all elements in c (the sum of all counts)
    % this will be the total number of indices required for the output vars
    nCounts=sum(c,"all");

    % get the total number of indices/elements in c too..
    nIdx = length(c);

    % preallocate output vectors
    xOut=zeros(1,nCounts);
    yOut=zeros(1,nCounts);
    cOut=zeros(1,nCounts);

    countr=1; % initialize countr
    for ii = 1:nIdx

        % get input variable values for this pass
        xValPass=x(ii); % x value
        yValPass=y(ii); % y value
        cValPass=c(ii); % bin count value
        
        % assign cValPass # of the the x and y value to the next cValPass 
        % indices within xOut and yOut
        xOut(1, countr:(countr+(cValPass-1)))=xValPass;
        yOut(1, countr:(countr+(cValPass-1)))=yValPass;
        cOut(1, countr:(countr+(cValPass-1)))=cValPass;

        countr=countr+cValPass; % update countr for next pass
    end
    
end
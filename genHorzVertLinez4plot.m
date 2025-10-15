function linesOut = genHorzVertLinez4plot(xValz,yValz,xInt,yInt)
    
    % initialize output variable struct
    linesOut=struct; 

    % get the number of x and y positions for vert/horz lines
    linesOut.nXvalz=length(xValz);
    linesOut.nYvalz=length(yValz);

    % generate vertical lines
    linesOut.vertLines=cell(1,linesOut.nXvalz);
    for ii=1:linesOut.nXvalz
        xValPass=xValz(ii);
        linePassX=ones(1,length(yInt)).*xValPass;
        linePassY=yInt;
        linesOut.vertLines{1,ii}={linePassX,linePassY};

    end

    % generate horizontal lines
    linesOut.horzLines=cell(1,linesOut.nYvalz);
    for ii=1:linesOut.nYvalz
        yValPass=yValz(ii);
        linePassY=ones(1,length(xInt)).*yValPass;
        linePassX=xInt;
        linesOut.horzLines{1,ii}={linePassX,linePassY};
    end

end
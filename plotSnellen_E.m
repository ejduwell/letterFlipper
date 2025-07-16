function imgOut = plotSnellen_E(bgColor,txtColor,desiredSize)
%
% This function builds a "Snellen E" 
% Ethan Duwell adapted this from code provided by Mina Gaffery
% Input Variables:
% bgColor: value 0-255 to indicate color of background
% txtColor: value 0-255 to indicate color of text
% desiredSize: desired square image dimension size for output in pixels..

% set desiredSize equal to vector with desiredSize as both position 1 and 2
% to indicate desired rows/columns in units of pixels..
desiredSize=[desiredSize,desiredSize];

% Build basic E of 5x5 pixels with 0s (black text) and 1s (white bg)
% and multiply each color channel by input channel value
basicE=ones(5,5,3);
for ii=1:size(basicE,3)
    % grab color channel for this pass
    basicEPass=basicE(:,:,ii);
    % make basic E with 1s and 0s
    basicEPass(:,1)=0;
    basicEPass(1:2:5,:)=0;
    % set color values for pass
    bgColorPass=bgColor(ii);
    txtColorPass=txtColor(ii);
    % use logical indexing to set text (0s) and bg (1s) to desired values
    bgIdx=find(basicEPass==1);
    txtIdx=find(basicEPass==0);
    basicEPass(bgIdx)=bgColorPass;
    basicEPass(txtIdx)=txtColorPass;   
    % put it back
    basicE(:,:,ii)= basicEPass;
end

% resize to desired size
imgOut=imresize(basicE,desiredSize,"nearest","Antialiasing",true);

% uncomment to view image for debugging..
%-----------------------------------------
% figure;
% imshow(imgOut);
% axis image;
%-----------------------------------------

end
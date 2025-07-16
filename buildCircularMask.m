function imgOut = buildCircularMask(imgDim)

% E. J. Duwell wrote this for generating a circular mask image that 
% circumscribes an input image dimension.

% if odd preallocate empty 0 array without adjustment
imgOut=zeros(imgDim,imgDim);

%get center
imgCenter=[(imgDim/2),(imgDim/2)];
% assign circle radius as half image width
circleRad=round(imgDim(1)/2);

% assign radius and center coordinate to circle position variable..
circlePos=[imgCenter(1)+1,imgCenter(2)+1,circleRad];
% draw circle on empty 0s image with insertShape
imgOut = insertShape(imgOut,"filled-circle",circlePos,"ShapeColor",[1,1,1]);
% make it grayscale
imgOut=rgb2gray(imgOut);
% run ethan's quantize values to ensure only 2 unique values are present
imgOut = quantizeImageToValues(imgOut, 2);
% rescale to 0 and 1 so the output functions as a mask..
imgOut=rescale(imgOut,0,1);

% combine flipped versions to ensure mask is symmetrical
vertFlpCopy=flip(imgOut,1);
horzFlpCopy=flip(imgOut,2);
%comboImg=vertFlpCopy.*horzFlpCopy.*imgOut;
imgOut=vertFlpCopy.*horzFlpCopy.*imgOut;

% for debugging:
% figure;
% imshow(imgOut);
% figure;
% imshow(vertFlpCopy);
% figure;
% imshow(horzFlpCopy);
% figure;
% imshow(comboImg);

end
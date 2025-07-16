function imgOut = quantizeImageToValues(imgIn, nUniqueValz)
% quantizeImageToValues adjusts each pixel in imgIn to the nearest value from
% a linearly spaced vector between the minimum and maximum pixel values.
%
% Usage:
% imgOut = quantizeImageToValues(imgIn, nUniqueValz)
%
% Inputs:
% imgIn        - Input image (2D matrix)
% nUniqueValz  - Integer specifying number of unique quantization values
%
% Output:
% imgOut       - Quantized output image

% Get minimum and maximum values from input image
% Also, make sure all values are of same type..
nUniqueValz=double(nUniqueValz);
imgIn=double(imgIn);
minVal = min(imgIn(:));
maxVal = max(imgIn(:));


% Create linearly spaced vector of unique values
quantVals = linspace(minVal, maxVal, nUniqueValz);

% Adjust each pixel value to the nearest value in quantVals
[~, idx] = min(abs(imgIn(:) - quantVals), [], 2);

% Reshape idx back to image dimensions and map to quantized values
imgOut = reshape(quantVals(idx), size(imgIn));

end
function ptSetOut = genEccAngSet_v1(nEcc, nAng, MinMaxEcc, MinMaxAng)
%
% genEccAngSet_v1
%
% Generate a set of 2D coordinate points arranged by eccentricity and angle.
%
% Inputs:
%   - nEcc: number of eccentricity steps
%   - nAng: number of angular steps per eccentricity
%   - MinMaxEcc: [minEcc maxEcc], range of eccentricity values (distance from center)
%   - MinMaxAng: [minAng maxAng], range of angles in degrees (0° is along x-axis)
%
% Output:
%   - ptSetOut: 1xN cell array containing N [x y] coordinate vectors

    % Ensure eccentricity range includes both Min and Max exactly
    if nEcc == 1
        eccVals = mean(MinMaxEcc);
    else
        eccVals = linspace(MinMaxEcc(1), MinMaxEcc(2), nEcc);
    end

    % Ensure angular range includes both Min and Max exactly
    if nAng == 1
        angValsDeg = mean(MinMaxAng);
    else
        angValsDeg = linspace(MinMaxAng(1), MinMaxAng(2), nAng);
    end

    angValsRad = deg2rad(angValsDeg);  % Convert to radians

    % Preallocate output cell array
    totalPts = nEcc * nAng;
    ptSetOut = cell(1, totalPts);

    % Fill in points
    idx = 1;
    for iEcc = 1:nEcc
        ecc = eccVals(iEcc);
        for iAng = 1:nAng
            ang = angValsRad(iAng);
            x = ecc * cos(ang);
            y = ecc * sin(ang);
            ptSetOut{idx} = [x, y];
            idx = idx + 1;
        end
    end
end

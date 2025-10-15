function [bestFit,bestFitSSE, thldzOut] = fitNakaRushton_v2(parsIn)

%% Process input parameters

% x and y data
x=parsIn.xVals;
y=parsIn.yVals;

% NR function pars
nr_bLower=parsIn.nr_bLower;
nr_bUpper=parsIn.nr_bUpper;
nr_bSteps=parsIn.nr_bSteps;
nr_bStart_grid=linspace(nr_bLower,nr_bUpper,nr_bSteps);
%nr_bStart=parsIn.nr_bStart;

nr_n_lower=parsIn.nr_n_lower;
nr_n_upper=parsIn.nr_n_upper;
nr_n_steps=parsIn.nr_n_steps;
nr_nStart_grid= linspace(nr_n_lower,nr_n_upper,nr_n_steps);

nr_rmaxLower=parsIn.nr_rmaxLower;
nr_rmaxUpper=parsIn.nr_rmaxUpper;
nr_rmaxSteps=parsIn.nr_rmaxSteps;
nr_rmaxStart_grid =linspace(nr_rmaxLower,nr_rmaxUpper,nr_rmaxSteps);

c50_lower=parsIn.c50_lower;
c50_upper=parsIn.c50_upper;
c50_steps=parsIn.c50_steps;
c50start_grid = linspace(c50_lower,c50_upper,c50_steps);

thrldz2solve=parsIn.thrldz2solve;

%% Create Grid of Starting Pars

startPar_grid=combvec(nr_bStart_grid,nr_nStart_grid,nr_rmaxStart_grid,c50start_grid);
initGrid_gofMat_passNum = cell(1,size(startPar_grid,2));
initGrid_gofMat_sse = cell(1,size(startPar_grid,2));
initGrid_gofMat_fcns = cell(1,size(startPar_grid,2));


%% Fit Naka Rushton Model

% Loop through and fit the model using each set of starting pars in 
% initGrid_gofMat. Then select the best fit from the set.
%==========================================================================
%parfor ii = 1:size(startPar_grid,2)
for ii = 1:size(startPar_grid,2)
    % update starting pars for pass
    passNum=ii;
    initGrid_gofMat_passNum{1,ii} = passNum;
    nr_bStart = startPar_grid(1,ii);
    nr_nStart = startPar_grid(2,ii);
    nr_rmaxStart = startPar_grid(3,ii);
    c50start = startPar_grid(4,ii);
    % fit function with these starting pars and save data
    [f2,gof2] = fit(x',y',"nr_rmax*((x^nr_n)/(nr_c50^nr_n + x^nr_n)) + nr_b","StartPoint",[nr_bStart,c50start, nr_nStart, nr_rmaxStart],'Lower',[nr_bLower, c50_lower, nr_n_lower, nr_rmaxLower],'Upper',[nr_bUpper, c50_upper, nr_n_upper, nr_rmaxUpper],'Robust', 'Bisquare');
    initGrid_gofMat_sse{1,ii} = gof2.sse;
    initGrid_gofMat_fcns{1,ii} = f2;
end

% combine columns after parfor
initGrid_gofMat=vertcat(initGrid_gofMat_passNum,initGrid_gofMat_sse,initGrid_gofMat_fcns);
% clear seperate columns after combining..
clear initGrid_gofMat_passNum;
clear initGrid_gofMat_sse;
clear initGrid_gofMat_fcns;

% select best fit based on sse (lowest)
gof_mat2 = cell2mat(initGrid_gofMat(2,1:end));
[val,idx]=min(gof_mat2);
bestFit = initGrid_gofMat{3,idx};
bestFitSSE = initGrid_gofMat{2,idx};

% solve best fitting functions for specified accuracy threshold values
solvFcnParz=struct;
solvFcnParz.inputFcn=bestFit;
solvFcnParz.valz=thrldz2solve;
solvFcnParz.xBounds=[0, parsIn.c50_upper];
thldzOut = solveFcn4valz(solvFcnParz);
%==========================================================================


end
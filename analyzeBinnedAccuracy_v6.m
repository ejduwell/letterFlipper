function dataOut = analyzeBinnedAccuracy_v6(dirOut, subjIDz, tdfArray, headerz, ...
                                         subjIDcolNum, correctColNum, ...
                                         accuracyParColNum, parName, binInfo, ...
                                         otherThrPars, titleStr,yPltLimz,NRfitParsIn)


% analyzeBinnedAccuracy_v6
% Bins trial data by a chosen parameter, computes per-bin mean accuracy
% and counts for each subject, appends bin assignment to the trials, fits a
% sigmoidal Naka Rushton psychometric function, plots this over subject's 
% accuracy data and saves a figure per subject.
%
% Features:
% - otherThrPars (Nx2 cell): Column filters applied BEFORE per-subject ops.
%   otherThrPars{:,1} = column indices; otherThrPars{:,2} = required values.
%   Only rows where all conditions hold (logical AND) are kept.
% - binInfo.binThresh: only plot bins with count >= binThresh.
% - Y-axis is set to [yPltLimz(2), yPltLimz(1)].
% - titleStr: appended to the figure title and injected into the filename
%   (as "_<titleStr>" just before ".png").
% - Titles are auto-wrapped and auto-shrunk (down to 8 pt) so they fit
%   within the horizontal bounds of the plot.
%
% Inputs:
% -------------------------------------------------------------------------
%   dirOut              : (char/string) output directory to save figures
%   subjIDz             : 1xN cellstr of 3-digit subject IDs
%   tdfArray            : (cell) trials x columns cell array
%   headerz             : 1xM cellstr column headers (not required but kept)
%   subjIDcolNum        : (scalar) column index of subject ID
%   correctColNum       : (scalar) column index of correctness (0/1)
%   accuracyParColNum   : (scalar) column index of parameter for binning/x-axis
%   parName             : (char/string) label for the parameter
%   binInfo             : struct with fields: min, max, nbins, (optional) binThresh
%   otherThrPars        : Nx2 cell array: {colIdx, requiredValue}; pass [] or {} for none
%   titleStr            : (char/string) extra title text and filename suffix
%   yPltLimz            : (1X2 double) yPltLimz(1) = upper limit, yPltLimz(2) = lower limit
%   NRfitParsIn         : struct containing the Naka Rushton model fitting parameters
%   pltHorzLines        : either 1 or 0, controls for whether (1) or not
%                         (0) vertical dotted lines are plotted at 
%                         subjects' thresholds
% -------------------------------------------------------------------------
%
% Outputs:
% -------------------------------------------------------------------------
%   dataOut struct with fields:
%       subjIDz, binInfo, subjTDFdata, subjBinCountz, subjBinMeanz, subjCIfigz, accuracyParColNum
%   (Also returns headersWithBin for reference.)
% -------------------------------------------------------------------------

    % ---------- Input checks ----------
    if ~iscell(subjIDz); error('subjIDz must be a 1xN cell array of subject ID strings.'); end
    if ~iscell(tdfArray); error('tdfArray must be a cell array (trials x columns).'); end
    if ~iscell(headerz); error('headerz must be a 1xM cell array of column header strings.'); end
    mustBeScalarPositive(subjIDcolNum);
    mustBeScalarPositive(correctColNum);
    mustBeScalarPositive(accuracyParColNum);

    reqFields = {'min','max','nbins'};
    for f = reqFields
        if ~isfield(binInfo,f{1})
            error('binInfo.%s is required.', f{1});
        end
    end
    if binInfo.nbins < 1 || floor(binInfo.nbins) ~= binInfo.nbins
        error('binInfo.nbins must be a positive integer.');
    end
    if binInfo.max <= binInfo.min
        error('binInfo.max must be greater than binInfo.min.');
    end
    % binThresh: optional; default to 1 if not provided
    if ~isfield(binInfo,'binThresh') || isempty(binInfo.binThresh)
        binInfo.binThresh = 1;
    end
    if ~(isscalar(binInfo.binThresh) && isnumeric(binInfo.binThresh) && binInfo.binThresh >= 1 && binInfo.binThresh == floor(binInfo.binThresh))
        error('binInfo.binThresh must be a positive integer >= 1.');
    end

    if nargin < 10 || isempty(otherThrPars)
        otherThrPars = {};
    end
    if ~isempty(otherThrPars)
        if ~iscell(otherThrPars) || size(otherThrPars,2) ~= 2
            error('otherThrPars must be an Nx2 cell array {colIdx, value}.');
        end
    end
    if nargin < 11 || isempty(titleStr)
        titleStr = '';
    end

    % Ensure output directory exists
    if ~exist(dirOut, 'dir')
        mkdir(dirOut);
    end

    % ---------- Helpers ----------
    % Convert a column of a cell array to a numeric column vector
    function v = col2double(C, colIdx)
        col = C(:, colIdx);
        if iscell(col)
            try
                v = cellfun(@(x) toNum(x), col);
            catch
                error('Column %d could not be converted to numeric.', colIdx);
            end
        else
            v = col; % already numeric
        end
        v = v(:);
    end

    function out = toNum(x)
        if isnumeric(x)
            out = double(x);
        elseif islogical(x)
            out = double(x);
        elseif ischar(x) || (isstring(x) && isscalar(x))
            xs = strtrim(char(x));
            d = str2double(xs);
            if ~isnan(d)
                out = d;
            else
                % Allow '0'/'1' or similar single-digit strings
                if ~isempty(xs) && all(ismember(xs, '01')) && ismember(length(xs), [1 2])
                    out = str2double(xs);
                else
                    error('Non-numeric value encountered: %s', xs);
                end
            end
        else
            error('Unsupported cell content type for numeric conversion.');
        end
    end

    function s = toChar(x)
        if isstring(x); s = char(x); else; s = x; end
    end

    % Column equals helper (robust to numeric/string types)
    function mask = colEqualsCell(C, colIdx, targetVal)
        col = C(:, colIdx);
        if isnumeric(targetVal) || islogical(targetVal)
            mask = false(size(col));
            tgt = double(targetVal);
            for ii = 1:numel(col)
                try
                    vi = toNum(col{ii});
                    mask(ii) = (vi == tgt);
                catch
                    mask(ii) = false;
                end
            end
        else
            tgt = char(string(targetVal));
            mask = cellfun(@(x) strcmpi(char(string(x)), tgt), col);
        end
    end

    % Text wrapper (wrap by words to ~maxChars per line)
    function wrapped = wrapText(str, maxChars)
        str = strtrim(toChar(str));
        if isempty(str), wrapped = ''; return; end
        words = regexp(str, '\s+', 'split');
        current = '';
        lines = {};
        for ii = 1:numel(words)
            w = words{ii};
            if isempty(current), test = w; else, test = [current ' ' w]; end %#ok<AGROW>
            if numel(test) > maxChars
                lines{end+1} = current; %#ok<AGROW>
                current = w;
            else
                current = test;
            end
        end
        if ~isempty(current), lines{end+1} = current; end
        wrapped = strjoin(lines, '\n');
    end

    % Fit a title within axes width by shrinking font if needed
    function fitTitleWithinAxes(ax, hTitle)
        MIN_FS = 8; % do not shrink below this
        % Guard for environments lacking TitleFontSizeMultiplier
        try
            ax.TitleFontSizeMultiplier = 1.0;
        catch
        end
        origAxUnits    = ax.Units;
        origTitleUnits = hTitle.Units;
        ax.Units       = 'pixels';
        hTitle.Units   = 'pixels';
        maxW = ax.Position(3) * 0.98; % 2% margin
        fs   = hTitle.FontSize;
        % Draw to update Extent
        drawnow;
        % Reduce font size until fits or hits minimum
        while hTitle.Extent(3) > maxW && fs > MIN_FS
            fs = fs - 1;
            hTitle.FontSize = fs;
            drawnow;
        end
        % Restore units
        hTitle.Units = origTitleUnits;
        ax.Units     = origAxUnits;
    end

    % Bin centers (inclusive of endpoints, evenly spaced)
    binCtrs = linspace(binInfo.min, binInfo.max, binInfo.nbins);

    % Preallocate output containers
    subjTDFdata   = struct(); % subject -> cell array (with appended bin column)
    subjBinCountz = struct(); % subject -> 1xnbins counts
    subjBinMeanz  = struct(); % subject -> 1xnbins mean accuracy
    subjCIfigz    = struct(); % subject -> struct with file path

    % If headers are provided, append a header for the new bin column
    appendedHeader = sprintf('%s_bin', toChar(parName));
    headersWithBin = headerz;
    headersWithBin{end+1} = appendedHeader;

    % ---------- Apply global filtering via otherThrPars (if provided) ----------
    tdfFiltered = tdfArray; % start with all rows
    if ~isempty(otherThrPars)
        mask = true(size(tdfArray,1),1);
        for rr = 1:size(otherThrPars,1)
            colIdx = otherThrPars{rr,1};
            valReq = otherThrPars{rr,2};
            if ~isscalar(colIdx) || ~isnumeric(colIdx) || colIdx < 1
                error('otherThrPars row %d: first column must be a positive scalar column index.', rr);
            end
            mask = mask & colEqualsCell(tdfArray, colIdx, valReq);
        end
        tdfFiltered = tdfArray(mask, :);
    end

    % ---------- Process each subject ----------
    allSubjIDs = subjIDz(:)'; % ensure row
    indSubjFcnFits=struct; % initialize struct for subject's function fits
    for sIdx = 1:numel(allSubjIDs)
        sid = allSubjIDs{sIdx};

        % 1) Extract rows for this subject via logical indexing (on filtered data)
        subjCol = tdfFiltered(:, subjIDcolNum);
        subjStrCol = cellfun(@(x) string(x), subjCol, 'UniformOutput', false);
        subjMask = cellfun(@(x) strcmpi(char(x), sid), subjStrCol);

        subjTrials = tdfFiltered(subjMask, :);

        % Handle case where no rows for subject
        if isempty(subjTrials)
            warning('No trials found for subject %s after filtering. Skipping plotting but still recording empty outputs.', sid);
            subjTDFdata.(sid)   = [subjTrials, cell(0,1)];
            subjBinCountz.(sid) = zeros(1, binInfo.nbins);
            subjBinMeanz.(sid)  = nan(1, binInfo.nbins);
            subjCIfigz.(sid)    = struct('file', fullfile(dirOut, sprintf('%s_no_data.png', sid)));
            continue;
        end

        % Convert needed columns to numeric vectors
        parVals = col2double(subjTrials, accuracyParColNum);
        correct = col2double(subjTrials, correctColNum);

        % 2) Assign each trial to the nearest bin center and append the bin value
        parClamped = min(max(parVals, binInfo.min), binInfo.max);
        [~, nearestIdx] = min(abs(parClamped - binCtrs), [], 2);
        assignedBinVals = binCtrs(nearestIdx);

        % Append as a new column to the subject trials (cell)  (transpose fix retained)
        subjTrialsWithBin = [subjTrials, num2cell(assignedBinVals)'];

        % 3) Count per bin & 4) Mean accuracy per bin
        counts = zeros(1, binInfo.nbins);
        meanAcc = nan(1, binInfo.nbins);
        meanParPerBin = nan(1, binInfo.nbins);

        for b = 1:binInfo.nbins
            inBin = (nearestIdx == b);
            counts(b) = sum(inBin);
            if counts(b) > 0
                meanAcc(b) = mean(correct(inBin));
                meanParPerBin(b) = mean(parVals(inBin)); % x-axis uses mean of original param values
            end
        end

        % Save into output structs
        subjTDFdata.(sid)   = subjTrialsWithBin;
        subjBinCountz.(sid) = counts;
        subjBinMeanz.(sid)  = meanAcc;

        % reduce to only bins with count >= binThresh       
        keep = counts >= binInfo.binThresh;
        x = meanParPerBin(keep);
        y = meanAcc(keep);
        c = counts(keep);

        % generate copy of x, y and y for model fitting with values in x
        % and y dupicated by their number of counts such that bin count
        % figures into the model fitting
        [x_wReps,y_wReps,c_wReps] = weightBinsByCount_v1(x,y,c);        

        % set x and y value data to x_wReps and y_wReps
        NRfitParsIn.xVals=x_wReps;
        NRfitParsIn.yVals=y_wReps;

        % fit the Naka Rushton model
        [bestFit,bestFitSSE,thldzOut] = fitNakaRushton_v2(NRfitParsIn);
        
        %NR model bounds
        xupper = binInfo.max;
        xlower = 0;
        xincrmt=(xupper-xlower)/1000; % controls the x axis resolution/smallest incriment..
        interval = xlower:xincrmt:xupper;
        fitted_curve = double(bestFit(interval));

        % store subject's function fit data in indSubjFcnFits
        indSubjFcnFits.(sid).bestFit=bestFit;
        indSubjFcnFits.(sid).bestFitSSE=bestFitSSE;
        indSubjFcnFits.(sid).thldzOut=thldzOut;
        indSubjFcnFits.(sid).pltdCrv.fitted_curve=fitted_curve;
        indSubjFcnFits.(sid).pltdCrv.interval=interval;
        indSubjFcnFits.(sid).pltdCrv.xincrmt=xincrmt;
        indSubjFcnFits.(sid).pltdCrv.xlower=xlower;
        indSubjFcnFits.(sid).pltdCrv.xupper=xupper;
        indSubjFcnFits.(sid).NRfitParsIn=NRfitParsIn;
        
        % generate threshold lines for plots and store this in 
        % indSubjFcnFits for each subject too..
        linesOut = genHorzVertLinez4plot(cell2mat(indSubjFcnFits.(sid).thldzOut.solutionz),indSubjFcnFits.(sid).NRfitParsIn.thrldz2solve,xlower:xincrmt:xupper,0:0.001:1);
        pltHorzLines=0;
        pltVertLines=1;
       
        % 5) Generate and save figure (only for bins with count >= binThresh)
        fig = figure('Color','w','Visible','off');
        hold on;
        try
            if any(keep)
                scatter(x, y, 60, c, 'filled'); % color by counts
                colorbar;
                plot(interval,fitted_curve,'Color','red');
                
                % plot lines to indicate threshold locations..
                % vertical lines
                if pltVertLines==1
                for yy=1:linesOut.nXvalz
                    lineValzPass=linesOut.vertLines{1,yy};
                    plot(lineValzPass{1,1},lineValzPass{1,2},':','Color','black','LineWidth',2);
                end
                end

                % horizontal lines
                if pltHorzLines==1
                for yy=1:linesOut.nYvalz
                    lineValzPass=linesOut.horzLines{1,yy};
                    plot(lineValzPass{1,1},lineValzPass{1,2},':','Color','black','LineWidth',2);
                end
                end
                %scatter(cell2mat(indSubjFcnFits.(sid).thldzOut.solutionz), indSubjFcnFits.(sid).NRfitParsIn.thrldz2solve, 60, 'red', 'filled'); % Plot thr values on curve
                
                xlabel(sprintf('Mean %s (per bin)', toChar(parName)), 'Interpreter','none');
                ylabel('Mean accuracy (0–1)');
                baseTitle = sprintf('Subject %s — Accuracy vs. %s (binned, count ≥ %d)', ...
                                    sid, toChar(parName), binInfo.binThresh);
                % Wrap the optional suffix and build the title (multi-line if needed)
                suffixWrapped = wrapText(titleStr, 60);
                if ~isempty(suffixWrapped)
                    fullTitle = sprintf('%s\n%s', baseTitle, suffixWrapped);
                else
                    fullTitle = baseTitle;
                end
                % Apply title, then shrink if necessary to fit horizontally
                hT = title(fullTitle, 'Interpreter','none');
                fitTitleWithinAxes(gca, hT);

                grid off; box on;
                set(gca,'FontName','Arial','FontSize',11);
                xlim([binInfo.min, binInfo.max]);
                ylim([yPltLimz(2),yPltLimz(1)]);    % fixed y-axis range
                hold off;
            else
                % No bins met the threshold: informative blank figure
                tline1 = sprintf('No bins with count \\geq %d', binInfo.binThresh);
                tline2 = sprintf('Subject %s', sid);
                tline3 = strtrim(toChar(titleStr));
                if isempty(tline3)
                    txt = sprintf('%s\n%s', tline1, tline2);
                else
                    txt = sprintf('%s\n%s\n%s', tline1, tline2, wrapText(tline3, 60));
                end
                text(0.5, 0.6, txt, 'HorizontalAlignment','center','FontSize',11);
                axis off
            end
        catch ME
            close(fig);
            rethrow(ME);
        end

        % 6) Save PNG (inject titleStr into filename if provided)
        safePar   = regexprep(toChar(parName),   '\W+', '_');
        safeTitle = regexprep(toChar(titleStr),  '\W+', '_');
        baseName  = sprintf('subj_%s_%s_acc_by_bin_%dbins_thresh%d', ...
                            sid, safePar, binInfo.nbins, binInfo.binThresh);
        if ~isempty(titleStr)
            outName = sprintf('%s_%s.png', baseName, safeTitle);
        else
            outName = sprintf('%s.png', baseName);
        end
        outPath = fullfile(dirOut, outName);

        % Prefer exportgraphics when available for better quality
        try
            exportgraphics(fig, outPath, 'Resolution', 200);
        catch
            print(fig, outPath, '-dpng', '-r200');
        end
        close(fig);

        subjCIfigz.(sid) = struct('file', outPath);
    end

    % Package outputs
    dataOut = struct();
    dataOut.subjIDz            = subjIDz;
    dataOut.binInfo            = binInfo;
    dataOut.subjTDFdata        = subjTDFdata;
    dataOut.subjBinCountz      = subjBinCountz;
    dataOut.subjBinMeanz       = subjBinMeanz;
    dataOut.subjCIfigz         = subjCIfigz;
    dataOut.accuracyParColNum  = accuracyParColNum;
    dataOut.headersWithBin     = headersWithBin;
    dataOut.indSubjFcnFits     = indSubjFcnFits;
end

% --- Local input validator for positive scalars (MATLAB-compatible, harmless in Octave) ---
function mustBeScalarPositive(x)
    if ~(isscalar(x) && isnumeric(x) && x > 0)
        error('Input must be a positive scalar.');
    end
end

function dataOut = solveFcn4valz(parsIn)
% solveFcn4valz
% For each target value y in parsIn.valz, solve for x such that inputFcn(x) = y.
%
% USAGE:
%   dataOut = solveFcn4valz(parsIn)
%
% REQUIRED INPUT (struct) parsIn with fields:
%   - inputFcn : function handle/name, a cfit/sfit, or any object with a feval method.
%                Must accept a scalar x and return a (real) scalar y = f(x).
%   - valz     : 1 x N numeric vector of target y-values.
%
% OPTIONAL INPUT FIELDS in parsIn (all optional):
%   - xBounds      : [xmin xmax] overall search bounds to look for roots (default = []).
%                    If provided, a coarse grid search within these bounds is used to
%                    find sign changes for bracketing.
%   - brackets     : N x 2 array of per-target brackets [a b]. If a valid sign change
%                    exists in [a b] for target i, it's used directly.
%   - x0           : scalar or 1 x N vector of initial guesses (default 0). Used as
%                    the center for expanding search if no bracket is known.
%   - gridN        : number of grid points for bracketing when xBounds provided
%                    (default 1001; must be >= 2).
%   - initStep     : starting step size for expanding search around x0 (default 1).
%   - expandFactor : factor (>1) to grow step during expansion (default 2).
%   - maxExpand    : max number of expansion rounds (default 30).
%   - fzeroOptions : options struct for fzero (default Display='off').
%   - returnDiag   : if true, include dataOut.diag with per-target details (default false).
%
% OUTPUT (struct) dataOut with fields:
%   - solutionz : 1 x N cell; each entry is the solved x (double) or [] on failure.
%   - failz     : 1 x N cell; empty on success, else a descriptive error message string.
%   - exitCon   : 0 if all succeeded, 1 if any failure (incl. input validation).
%   - (optional) diag : per-target diagnostic info (present only if returnDiag=true).
%
% NOTES:
%   - If multiple roots exist within xBounds, the first bracket found (left-to-right)
%     is used. If xBounds are not given, an expanding search around x0 is used.
%   - If f(x) or g(x)=f(x)-y is undefined or complex at a probe, that probe is skipped.

    % ---- Initialize conservative defaults ----
    dataOut = struct();
    dataOut.solutionz = {};
    dataOut.failz     = {};
    dataOut.exitCon   = 1;  % pessimistic until proven OK

    try
        % ---- Basic input validation ----
        if ~isstruct(parsIn)
            error('Input must be a struct named parsIn.');
        end
        if ~isfield(parsIn,'inputFcn')
            error('parsIn.inputFcn is required.');
        end
        if ~isfield(parsIn,'valz')
            error('parsIn.valz is required.');
        end

        % Normalize/validate targets (y-values)
        yTargets = parsIn.valz;
        if ~isnumeric(yTargets) || isempty(yTargets)
            error('parsIn.valz must be a non-empty numeric vector of target y-values.');
        end
        yTargets = yTargets(:).';   % 1 x N
        N = numel(yTargets);

        % ---- Solver and search parameters (with defaults) ----
        xBounds      = gopt(parsIn,'xBounds',[]);
        brackets     = gopt(parsIn,'brackets',[]);
        x0_in        = gopt(parsIn,'x0',0);
        gridN        = gopt(parsIn,'gridN',1001);
        initStep     = gopt(parsIn,'initStep',1);
        expandFactor = gopt(parsIn,'expandFactor',2);
        maxExpand    = gopt(parsIn,'maxExpand',30);
        returnDiag   = gopt(parsIn,'returnDiag',false);

        if ~isempty(xBounds)
            validateattributes(xBounds,{'numeric'},{'vector','numel',2,'increasing','finite'});
        end
        if ~isempty(brackets)
            if ~isnumeric(brackets) || size(brackets,2) ~= 2 || size(brackets,1) ~= N
                error('parsIn.brackets must be N x 2 numeric array matching numel(valz).');
            end
        end
        if ~isscalar(gridN) || gridN < 2
            error('parsIn.gridN must be a scalar integer >= 2.');
        end
        if ~(isscalar(initStep) && initStep > 0)
            error('parsIn.initStep must be a positive scalar.');
        end
        if ~(isscalar(expandFactor) && expandFactor > 1)
            error('parsIn.expandFactor must be a scalar > 1.');
        end
        if ~(isscalar(maxExpand) && maxExpand >= 1)
            error('parsIn.maxExpand must be a scalar integer >= 1.');
        end

        % Prepare x0 vector
        if isscalar(x0_in)
            x0 = repmat(x0_in,1,N);
        else
            x0 = x0_in(:).';
            if numel(x0) ~= N
                error('parsIn.x0 must be scalar or 1 x N to match numel(valz).');
            end
        end

        % fzero options
        if isfield(parsIn,'fzeroOptions')
            fzOpt = parsIn.fzeroOptions;
            if ~isstruct(fzOpt), error('parsIn.fzeroOptions must be a struct.'); end
        else
            fzOpt = optimset('Display','off');
        end

        % ---- Normalize inputFcn into evaluator fEval(x) returning real scalar ----
        inputFcn_raw = parsIn.inputFcn;
        fEval = normalizeEvaluator(inputFcn_raw);

        % ---- Preallocate outputs ----
        dataOut.solutionz = cell(1,N);
        dataOut.failz     = cell(1,N);
        if returnDiag
            dataOut.diag = repmat(struct('y',[],'bracket',[],'x0',[],'g_at_bracket',[],'solver_msg',''),1,N);
        end

        hadAnyError = false;

        % ---- Main per-target solve loop ----
        for ii = 1:N
            yi = yTargets(ii);
            xi_sol = [];
            errMsg = '';

            % Define residual g(x) = f(x) - yi
            g = @(x) safeResidual(fEval, x, yi);

            try
                % 1) Try provided bracket (if any) --------------------------
                usedBracket = [];
                gAtBracket  = [];

                if ~isempty(brackets)
                    a = brackets(ii,1); b = brackets(ii,2);
                    [isOK, ga, gb] = validSignChange(g, a, b);
                    if isOK
                        usedBracket = [a b]; gAtBracket = [ga gb];
                    end
                end

                % 2) If no bracket yet, try xBounds grid search -------------
                if isempty(usedBracket) && ~isempty(xBounds)
                    [found, ab, gab] = bracketViaGrid(g, xBounds, gridN);
                    if found
                        usedBracket = ab; gAtBracket = gab;
                    end
                end

                % 3) If still no bracket, expand around x0 -------------------
                if isempty(usedBracket)
                    [found, ab, gab] = bracketViaExpansion(g, x0(ii), initStep, expandFactor, maxExpand);
                    if found
                        usedBracket = ab; gAtBracket = gab;
                    end
                end

                % 4) If STILL no bracket, check if x0 already a root --------
                if isempty(usedBracket)
                    g0 = g(x0(ii));
                    if isfinite(g0) && isreal(g0) && g0 == 0
                        xi_sol = x0(ii);
                    end
                end

                % 5) Solve with fzero if bracket available ------------------
                if isempty(xi_sol)
                    if ~isempty(usedBracket)
                        xi_sol = fzero(g, usedBracket, fzOpt);
                    else
                        error('Could not bracket a root for target y=%g.', yi);
                    end
                end

                % Final sanity: ensure real finite
                if ~(isfinite(xi_sol) && isreal(xi_sol))
                    error('Solver returned non-finite or complex solution for y=%g.', yi);
                end

                dataOut.solutionz{ii} = xi_sol;

                if returnDiag
                    dataOut.diag(ii).y = yi;
                    dataOut.diag(ii).x0 = x0(ii);
                    dataOut.diag(ii).bracket = usedBracket;
                    dataOut.diag(ii).g_at_bracket = gAtBracket;
                    dataOut.diag(ii).solver_msg = 'ok';
                end

            catch MEi
                hadAnyError = true;
                dataOut.solutionz{ii} = [];
                errMsg = sprintf('Solve failed for target y=%g: %s', safeNum(yi), MEi.message);
                dataOut.failz{ii} = errMsg;

                if returnDiag
                    dataOut.diag(ii).y = yi;
                    dataOut.diag(ii).x0 = x0(ii);
                    if exist('usedBracket','var')
                        dataOut.diag(ii).bracket = usedBracket;
                        dataOut.diag(ii).g_at_bracket = gAtBracket;
                    else
                        dataOut.diag(ii).bracket = [];
                        dataOut.diag(ii).g_at_bracket = [];
                    end
                    dataOut.diag(ii).solver_msg = errMsg;
                end
            end
        end

        dataOut.exitCon = hadAnyError;  % 0 if none, 1 if any

    catch MEtop
        % Top-level failure (e.g., validation)
        if isempty(dataOut.failz)
            dataOut.failz = {['Input validation error: ' MEtop.message]};
        else
            dataOut.failz{end+1} = ['Input validation error: ' MEtop.message];
        end
        dataOut.solutionz = {};
        dataOut.exitCon   = 1;
    end
end

% ---------- helpers ----------

function v = gopt(S, name, defaultVal)
    if isfield(S, name), v = S.(name); else, v = defaultVal; end
end

function fEval = normalizeEvaluator(f)
    % Accept function handle/name, cfit/sfit, or any object with feval method.
    if isa(f,'function_handle')
        fEval = @(x) f(x);
    elseif ischar(f) || (isstring(f) && isscalar(f))
        fh = str2func(char(f));
        fEval = @(x) fh(x);
    elseif isa(f,'cfit') || isa(f,'sfit')
        fEval = @(x) feval(f, x);
    elseif isobject(f) && ismethod(f,'feval')
        fEval = @(x) feval(f, x);
    else
        error(['parsIn.inputFcn must be a function handle or name, a cfit/sfit, ' ...
               'or any object that implements a feval method.']);
    end
end

function r = safeResidual(fEval, x, y)
    % g(x) = f(x) - y, guarding against non-finite/complex evaluations
    fx = fEval(x);
    if ~isscalar(fx)
        error('inputFcn(x) must return a scalar for scalar x.');
    end
    if ~isreal(fx) || ~isfinite(fx)
        error('inputFcn(x) produced non-real or non-finite value at x=%g.', safeNum(x));
    end
    r = fx - y;
end

function [ok, ga, gb] = validSignChange(g, a, b)
    ga = NaN; gb = NaN; ok = false;
    if ~(isfinite(a) && isfinite(b)) || ~(isreal(a) && isreal(b)) || ~(a < b)
        return
    end
    try, ga = g(a); catch, ga = NaN; end
    try, gb = g(b); catch, gb = NaN; end
    if isfinite(ga) && isfinite(gb)
        if ga == 0 || gb == 0 || sign(ga) ~= sign(gb)
            ok = true;
        end
    end
end

function [found, ab, gab] = bracketViaGrid(g, xBounds, gridN)
    % Scan [xmin,xmax] on a uniform grid to find first adjacent sign change.
    xmin = xBounds(1); xmax = xBounds(2);
    xs = linspace(xmin, xmax, gridN);
    gs = NaN(size(xs));
    for k = 1:numel(xs)
        try
            t = g(xs(k));
            if isreal(t) && isfinite(t), gs(k) = t; end
        catch
            % leave as NaN
        end
    end
    found = false; ab = []; gab = [];
    for k = 1:numel(xs)-1
        a = xs(k); b = xs(k+1);
        ga = gs(k); gb = gs(k+1);
        if ~(isfinite(ga) && isfinite(gb)), continue; end
        if ga == 0
            found = true; ab = [a a]; gab = [ga ga]; return
        end
        if gb == 0
            found = true; ab = [b b]; gab = [gb gb]; return
        end
        if sign(ga) ~= sign(gb)
            found = true; ab = [a b]; gab = [ga gb]; return
        end
    end
end

function [found, ab, gab] = bracketViaExpansion(g, x0, initStep, expandFactor, maxExpand)
    % Expand symmetrically around x0 until sign change or maxExpand reached.
    found = false; ab = []; gab = [];
    % Probe at x0: exact root?
    try
        g0 = g(x0);
        if isfinite(g0) && g0 == 0
            found = true; ab = [x0 x0]; gab = [g0 g0]; return
        end
    catch
        % ignore, continue expanding
    end

    step = initStep;
    prev_a = NaN; prev_b = NaN; prev_ga = NaN; prev_gb = NaN;

    for iter = 1:maxExpand
        a = x0 - step;
        b = x0 + step;

        ga = NaN; gb = NaN;
        try, ga = g(a); end
        try, gb = g(b); end

        if isfinite(ga) && ga == 0
            found = true; ab = [a a]; gab = [ga ga]; return
        end
        if isfinite(gb) && gb == 0
            found = true; ab = [b b]; gab = [gb gb]; return
        end

        if isfinite(ga) && isfinite(gb) && sign(ga) ~= sign(gb)
            found = true; ab = [a b]; gab = [ga gb]; return
        end

        % Try to connect with previous endpoints to see if a sign change emerges
        if isfinite(ga) && isfinite(prev_ga) && sign(ga) ~= sign(prev_ga)
            found = true; ab = [a prev_a]; gab = [ga prev_ga]; return
        end
        if isfinite(gb) && isfinite(prev_gb) && sign(gb) ~= sign(prev_gb)
            found = true; ab = [prev_b b]; gab = [prev_gb gb]; return
        end

        prev_a = a; prev_b = b; prev_ga = ga; prev_gb = gb;
        step = step * expandFactor;
    end
end

function s = safeNum(x)
    try
        s = sprintf('%g', x);
    catch
        s = '<unprintable>';
    end
end


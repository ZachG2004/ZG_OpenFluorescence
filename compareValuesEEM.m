%% Compare two EEM metrics
% Created by Zachary A. Gioppo on 2026/05/12 
% This will compare the contents of two EEM matrices on the same
% excitation/emission grid.
% ReferenceFile  : An influent or earlier-cycle sample
% comparisonFile : An effluent or later-cycle sample
% Outputs:
%   Delta       = comparison - reference
%   Ratio       = comparison ./ reference
%   Rejection   = 1 - comparison ./ reference
%% Function
function comparedResults = compareValuesEEM(referenceFile, comparisonFile, outputBasePath)
    % Ensure the output is established
    if nargin < 3 || isempty(outputBasePath)
	[~, compName, ~] = fileparts(comparisonFile);
	outputBasePath = ['EEM_comparison_' compName];
    end

    % Isolate components of each eem matrices
    ref = loadMatrixEEM(referenceFile);
    cmp = loadMatrixEEM(comparisonFile);

    ex_ref = ref(1, 2:end);
    em_ref = ref(2:end, 1);
    ex_cmp = cmp(1, 2:end);
    em_cmp = cmp(2:end, 1);

    if ~isequal(ex_ref, ex_cmp) || ~isequal(em_ref, em_cmp)
        error('Excitation/Emission grids do not correlate. Thus, interpolation will be necessary for direct comparison');
    end
    
    fl_ref = ref(2:end, 2:end);
    fl_cmp = cmp(2:end, 2:end);
    
    % Calculation for comparisons
    fl_delta = fl_cmp - fl_ref;
    
    % Establish the threshhold and masking ratios
    threshhold  = 0.01*max(fl_ref(:));
    mask        = fl_ref > threshhold;

    % Establish matrices for fluorescence ratio and fluorescence rejection
    fl_ratio    = nan(size(fl_ref));
    fl_reject   = nan(size(fl_ref));
   
    fl_ratio(mask)  = fl_cmp(mask) ./ fl_ref(mask);
    fl_reject(mask) = 1 - fl_ratio(mask);

    % Compile output tables
    eem_delta   = [NaN, ex_ref; em_ref, fl_delta];
    eem_ratio   = [NaN, ex_ref; em_ref, fl_ratio];
    eem_reject  = [NaN, ex_ref; em_ref, fl_reject];

    % Establish Results for Output
    comparedResults = struct();

    comparedResults.reference   = ref;
    comparedResults.comparison  = cmp;
    comparedResults.delta       = eem_delta;
    comparedResults.ratio       = eem_ratio;
    comparedResults.rejection   = eem_reject;
    comparedResults.threshhold  = threshhold;
    comparedResults.mask = mask;
end
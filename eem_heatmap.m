%% Develop the heatmap plot for the system  
% Created by Zachary A. Gioppo on 2026/05/12 
% This script will develop a direct 2D excitation-emission heatmap for
% Fluorescence Toolbox EEM matrices
% Functional mode for EEM Inputs:
%       eemdata(1,2:end)      = excitation wavelengths
%       eemdata(2:end,1)      = emission wavelengths
%       eemdata(2:end,2:end)  = fluorescence intensities
%% Function
function heatmapOut = eem_heatmap(eemdata, plotTitle, climVals, plotMode, varargin)
    % Ensure settings are established
    if nargin < 2 || isempty(plotTitle)
        plotTitle = 'EEM Heatmap';
    end
    if nargin < 3 || isempty(climVals)
        climVals = [];
    end
    if nargin < 4 || isempty(plotMode)
	plotMode = 'raw';
    end

    % ----------------------------------------
    %  Name-Value parser
    % ----------------------------------------
    param = inputParser;
	% Establish the possible options
        addParameter(param, 'plotTitle', plotTitle, ...
	    @(x) ischar(x) || isstring(x)); % Select the plotting technique
        addParameter(param, 'climVals', climVals, ...
	    @(x) isempty(x) || (isnumeric(x) && numel(x) == 2)); % Ensure ClimVals are established
        addParameter(param, 'plotMode', plotMode, ...
	    @(x) ischar(x) || isstring(x)); % Select the plotting method to use

        addParameter(param, 'useDialog', true, ...
	    @(x) islogical(x) || isnumeric(x)); % Should a dialog menu be used? 

        % Parse the called option(s)
        parse(param, varargin{:});
        opt = param.Results;
	plotMode = char(opt.plotMode);
	plotTitle = char(opt.plotTitle);
	climVals = opt.climVals;
        % expand to Dialogue box if necessary
        if opt.useDialog
            plotMode = localImportDialog(plotMode);
        end

    % Define function elements
    ex = eemdata(1, 2:end);
    em = eemdata(2:end, 1);
    fl = eemdata(2:end,2:end);

    % Create the plot
    figure;

    % select plotting method
    switch lower(plotMode)
	case 'raw'
	    heatmapOut = imagesc(ex, em, fl);
	    axis xy;

	case 'interp'
	    warning('Interpolation mode is currently partially implemented. Do not perform analysis with this data');
	    exFine = linspace(min(ex), max(ex), 300);
	    emFine = linspace(min(em), max(em), 400);
	    
	    [exRaw, emRaw] = meshgrid(ex, em);
	    [exQ, emQ] = meshgrid(exFine, emFine);
	    flQ = interp2(exRaw, emRaw, fl, exQ, emQ, 'linear');

	    heatmapOut = imagesc(exFine, emFine, flQ);
	    axis xy;

	case 'contourf'
	    [exCtf, emCtf] = meshgrid(ex, em);
	    heatmapOut = contourf(exCtf, emCtf, fl, 50, 'LineColor', 'none');
	    axis tight;
	otherwise
	    error('Unknown plotMode: %s defined. Use raw, interp, or contourf.', plotMode);
	end

    xlabel('Excitation Wavelength (nm)');
    ylabel('Emission Wavelength (nm)');
    title(plotTitle, 'Interpreter', 'none');
    colorbar;
    colormap(jet(128));

    if ~isempty(climVals)
        clim(climVals);
    end
end


% Establish dialogue control for import function
function plotMode = localImportDialog(currentMode)
    % Creat variable list of dialog options (Single Select options)
    optionNames = {...
    'Raw Matrix-Data Display', ...
    'Interpolated Surface Display', ...
    'Filled Contour Display'};
        
    modeValues = { ...
	'raw', ...
	'interp', ...
	'contourf'};

    % ------------------
    % Handle each option
    % ------------------
    switch lower(char(currentMode))
	case 'raw'
	    selectedMode = 1;
	case 'interp'
	    selectedMode = 2;
	case 'contourf'
	    selectedMode = 3;
	otherwise
	    error('Please select a plotting mode.');
	end
    % ------------------
    % Generate dialog
    % ------------------
    [selected, tf] = listdlg(...
        'PromptString', 'Select actions', ...
        'SelectionMode', 'single', ...
        'ListString', optionNames, ...
        'InitialValue', selectedMode, ...
        'ListSize', [240 110], ...
        'Name', 'EEM Plotting Wizard — Heatmap Modes');
    if ~tf
        error('EEM Heatmap Plotting was cancelled by the User.');
    end

    plotMode = modeValues{selected};
end
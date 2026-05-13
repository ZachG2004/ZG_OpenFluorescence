%% Unified eem comparison script
% Created by Zachary A. Gioppo on 2026/05/12 
% A unified file comparison tool for multiple
% EEM/PLT files, utilizing dedicated comparison script
%
% This script handles:
%   .plt The Fluorescence Toolbox plot files
%   .eem MATLAB-based EEM structured
% This script only outputs the final comparison results
%
%                    An example function call / usage:
%-------------------------------------------------------------------------%
%   output = eemCompare();                                                %
%                                                                         %
%   output = eemCompare('sampleOne', 'sample01_Effluent.CSV', ...         %
%       'sampleTwo', 'sample01_Influent.CSV', ...                         %
%       'makeHeatmap', true );                                            %
%                                                                         %
%   output = eemCompare('sampleOne', 'sample01_Effluent.CSV', ...         %
%       'sampleTwo', 'sample01_Influent.CSV', ...                         %
%	'saveCompMAT', true, 'saveCompTXT', true, ...			  %
%       'makeHeatmap', true );                                            %
%-------------------------------------------------------------------------%
%% Function
%% Function
function compResults = eemCompare_Ext(sampleOneFile, sampleTwoFile, varargin)
    if nargin < 1
        sampleOneFile = '';
    end
    if nargin < 2
	sampleTwoFile = '';
    end
    % ----------------------------------------
    % Parsing the inputted file and parameters
    % ----------------------------------------
        param = inputParser;
            % Establish the possible options
    
            addOptional(param, 'sampleOneFile', '', ...
                 @(x) ischar(x) || isstring(x) ); % Select first Sample file as string
            addOptional(param, 'sampleTwoFile', '', ...
                @(x) ischar(x) || isstring(x) ); % Select second Sample file as string

            addParameter(param, 'outputBasePath', '', ...
                @(x) ischar(x) || isstring(x) ); % Clarify output directory
        
            addParameter(param, 'saveTXT', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Select to save comparison outputs as .TXT
            addParameter(param, 'saveMAT', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Select to save comparison outputs as as .MAT
        
            addParameter(param, 'makeRefHeatmap', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Should a Heatmap be generated for Comparison File (sampleOne)
            addParameter(param, 'makeCompHeatmap', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Should a Heatmap be generated for Reference File (sampleTwo)

            addParameter(param, 'plotDiff', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Should a plot be generated to show Comp-Ref
            addParameter(param, 'plotRatio', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Should a plot be generated to show ratio Comp / Ref
            addParameter(param, 'plotRejection', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Should a plot be generated to show rejection (1 - Comp/Ref)


            addParameter(param, 'useDialog', true, ...
                @(x) islogical(x) || isnumeric(x)); % Should a dialog menu be used? 
        
        % Parse the called option(s)
        parse(param, sampleOneFile, sampleTwoFile, varargin{:});
        opt = param.Results;
        % Finalize the input file
        sampleOneFile = char(opt.sampleOneFile);
	sampleTwoFile = char(opt.sampleTwoFile);

        % expand to Dialogue box if necessary
        if opt.useDialog
            opt = localImportDialog(opt);
        end

    % --------------------------------------
    % Select the input files (if omitted)
    % --------------------------------------
        if isempty(sampleOneFile)
            % Open a selection menu for the user to pick their source doc(s)
            [fn, pn] = uigetfile( ...
            {'*.plt;*.eem;*.mat', ...
            'EEM-Compatible Files (*.plt, *.eem, *.mat)'}, ...
            'Select First EEM file for processing (Comparison File)');
            % Make sure a(n appropriate) file was selected
            if isequal(fn, 0)
                error('No input file selected.');
            end
            % Finalize input file
            sampleOneFile = fullfile(pn, fn);
        end
        if isempty(sampleTwoFile)
            % Open a selection menu for the user to pick their source doc(s)
            [fnn, pnn] = uigetfile( ...
            {'*.plt;*.eem;*.mat', ...
            'EEM-Compatible Files (*.plt, *.eem, *.mat)'}, ...
            'Select Second EEM file for processing (Reference File)');
            % Make sure a(n appropriate) file was selected
            if isequal(fnn, 0)
                error('No input file selected.');
            end
            % Finalize input file
            sampleTwoFile = fullfile(pnn, fnn);
        end

        [compFolder, compName, ext] = fileparts(sampleOneFile);
        ext = lower(ext);
        [refFolder, refName, ext] = fileparts(sampleTwoFile);
        ext = lower(ext);

        outputName = ['EEM_comparison_' compName];

        if isempty(opt.outputBasePath)
            outputBasePath = fullfile(compFolder, outputName);
        else
            outputBasePath = char(opt.outputBasePath);
        end

    % ------------------------------------------
    % Load the matrix form for each file
    % ------------------------------------------
    compResults = compareValuesEEM(sampleTwoFile, sampleOneFile, outputBasePath);
    compMatrix = compResults.comparison;
    refMatrix  = compResults.reference;

    % ------------------------------------------
    % Process Heatmaps, if selected
    % ------------------------------------------
    if opt.makeRefHeatmap
	eem_heatmap(refMatrix, refName, [], 'raw', false, 'useDialog', true);
    end
    if opt.makeCompHeatmap
	eem_heatmap(compMatrix, compName, [], 'raw', false, 'useDialog', true);
    end
    % ------------------------------------------
    % Perform selected comparison computation(s)
    % ------------------------------------------
    if opt.plotDiff
	eem_heatmap(compResults.delta, [outputName ' | comparison - reference'], [], 'raw', false, 'useDialog', true);
    end
    if opt.plotRatio
	eem_heatmap(compResults.ratio, [outputName ' | comparison / reference'], [], 'raw', false, 'useDialog', true);
    end
    if opt.plotRejection
	eem_heatmap(compResults.rejection, [outputName ' | apparent rejection'], [], 'raw', false, 'useDialog', true);
    end
    % ------------------------------------------
    % Save comparison to chosen format(s)
    % ------------------------------------------
    if opt.saveTXT
	writematrix(deltaOut,  [outputBasePath '_delta.txt'],     'Delimiter', ' ');
	writematrix(ratioOut,  [outputBasePath '_ratio.txt'],     'Delimiter', ' ');
	writematrix(rejectOut, [outputBasePath '_rejection.txt'], 'Delimiter', ' ');
    end
    if opt.saveMAT
	save([outputBasePath '_comparison.mat'], 'compResults');
    end

end
%% Helper Functions
% Establish dialogue control for import function
function opt = localImportDialog(opt)
    % Creat variable list of dialog options (All y/n)
    optionNames = {...
    'Save comparison results as .TXT', ...
    'Save comparison results as .MAT', ...
    'Plot Reference File''s heatmap', ...
    'Plot Comparison File''s heatmap', ...
    'Plot Sample Delta (Comp - Ref)', ...
    'Plot Sample Ratio (Comp / Ref)', ...
    'Plot Apparent Rejection (1- Ratio)'};
    
    defaultSelected = []; % No action by default
    allSelected = defaultSelected; % append defaultSelected to list

    % ------------------
    % Handle each option
    % ------------------
    if opt.saveTXT
        allSelected(end+1) = 1;
    end
    if opt.saveMAT
        allSelected(end+1) = 2;
    end

    if opt.makeRefHeatmap
        allSelected(end+1) = 3;
    end
    if opt.makeCompHeatmap
        allSelected(end+1) = 4;
    end
    if opt.plotDiff
        allSelected(end+1) = 5;
    end
    if opt.plotRatio
        allSelected(end+1) = 6;
    end
    if opt.plotRejection
        allSelected(end+1) = 7;
    end

    % ------------------
    % Generate dialog
    % ------------------
    [selected, tf] = listdlg(...
        'PromptString', 'Select actions', ...
        'SelectionMode', 'multiple', ...
        'ListString', optionNames, ...
        'InitialValue', allSelected, ...
        'ListSize', [220 130], ...
        'Name', 'EEM Comparison Wizard — Options');
    if ~tf
        error('EEM Import was cancelled by the User.');
    end

    opt.saveTXT     	   = ismember(1, selected);
    opt.saveMAT    	   = ismember(2, selected);
    opt.makeRefHeatmap     = ismember(3, selected);
    opt.makeCompHeatmap    = ismember(4, selected);
    opt.plotDiff 	   = ismember(5, selected);
    opt.plotRatio 	   = ismember(6, selected);
    opt.plotRejection 	   = ismember(7, selected);
end
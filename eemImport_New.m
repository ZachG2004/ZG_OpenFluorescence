%% Unified eem import script
% Created by Zachary A. Gioppo on 2026/05/12 
% A unified importer/converter function to expand the Fluorescence Toolbox
% EEM workfows
%
% This script handles:
%   .csv / .xls / .clsx machine outputs, blank, and corrections
%   .txt / .asc / .dat wrapped ASCII file in MATLAB-based EEM structures
%   .plt The Fluorescence Toolbox plot files
%   .eem MATLAB-based EEM structured
%   .mat files containing EEM variables or structure
% This script outputs according to user needs:
%   .eem :: MATLAB structure for downstream EEM processing
%   .plt :: Fluorescence Toolbox loadscan-compatible plot file
%   .txt :: Wrapped ASCII matrix for use elsewhere
%   .mat :: analysis-friendly MATLAB structures for use elsewhere
%
%                    An example function call / usage:
%-------------------------------------------------------------------------%
%   output = eemImport();                                                 %
%                                                                         %
%   output = eemImport('sample01_Effluent.CSV', ...                       %
%       'blankFile', 'samples01-05_Blank.CSV', ...                        %
%       'makeHeatmap', true );                                            %
%                                                                         %
%   output = eemImport('sample01_Effluent.plt', ...                       %
%       'saveEEM', true, ...                                              %
%       'saveTXT', true, ...                                              %
%       'makeHeatmap', true );                                            %
%-------------------------------------------------------------------------%
%% Function
function output = eemImport_New(inputFile, varargin)
    if nargin < 1
        inputFile = '';
    end
    % ----------------------------------------
    % Parsing the inputted file and parameters
    % ----------------------------------------
        param = inputParser;
            % Establish the possible options
    
            addOptional(param, 'inputFile', '', ...
                 @(x) ischar(x) || isstring(x) ); % Select input file as string

            addParameter(param, 'blankFile', '', ...
                @(x) ischar(x) || isstring(x) ); % Select blank file as string
            addParameter(param, 'outputBasePath', '', ...
                @(x) ischar(x) || isstring(x) ); % Clarify output directory
            
            addParameter(param, 'parmsFile', 'parms.xls', ...
                @(x) ischar(x) || isstring(x) ); % Select parameter file as string
            addParameter(param, 'correctFile', 'correct.xls', ...
                 @(x) ischar(x) || isstring(x) ); % Select correction file as string
            addParameter(param, 'baseOpt', 0, ...
                @(x) isnumeric(x) && isscalar(x) ); % Select Adjustment as integer
        
            addParameter(param, 'saveEEM', false, ...
                 @(x) islogical(x) || isnumeric(x) ); % Select to save as .EEM
            addParameter(param, 'savePLT', true, ...
                @(x) islogical(x) || isnumeric(x) ); % Select to save as .PLT
            addParameter(param, 'saveTXT', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Select to save as .TXT
            addParameter(param, 'saveMAT', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Select to save as .MAT
        
            addParameter(param, 'makeHeatmap', false, ...
                @(x) islogical(x) || isnumeric(x) ); % Should a Heatmap be generated

            addParameter(param, 'useDialog', true, ...
                @(x) islogical(x) || isnumeric(x)); % Should a dialog menu be used? 
        
        % Parse the called option(s)
        parse(param, inputFile, varargin{:});
        opt = param.Results;
        % Finalize the input file
        inputFile = char(opt.inputFile);

        % expand to Dialogue box if necessary
        if opt.useDialog
            opt = localImportDialog(opt);
        end

    % --------------------------------------
    % Select the input file (if omitted)
    % --------------------------------------
        if isempty(inputFile)
            % Open a selection menu for the user to pick their source doc(s)
            [fn, pn] = uigetfile( ...
            {'*.csv;*.xls;*.xlsx;*.txt;*.asc;*.dat;*.plt;*.eem;*.mat', ...
            'EEM-Compatible Files (*.csv, *.xls, *.txt, *.plt, *.eem, *.mat)'}, ...
            'Select EEM input file for processing');
            % Make sure a(n appropriate) file was selected
            if isequal(fn, 0)
                error('No input file selected.');
            end
            % Finalize input file
            inputFile = fullfile(pn, fn);
        end
        [inputFolder, inputName, ext] = fileparts(inputFile);
        ext = lower(ext);
    
        if isempty(opt.outputBasePath)
            outputBasePath = fullfile(inputFolder, inputName);
        else
            outputBasePath = char(opt.outputBasePath);
        end

    % --------------------------------------
    % Main formatting structure for work
    % --------------------------------------
        % Establish an output structure 
        output = struct();
        output.inputFile = inputFile;
        output.outputBasePath = outputBasePath;
        output.inputType = ext;
    
        switch ext
            case {'.csv', '.xls', '.xlsx'} % if input file is formal spreadsheet
                % Raw matrix from machine output, must be blanked and corrected
                blankFile = char(opt.blankFile);
    
                if isempty(blankFile)
                    [bfn, bpn] = uigetfile( ...
                        {'*.csv;*.xls;*.xlsx', 'Machine Blanks (*.csv, *.xls, *.xlsx)'}, ...
                        'Select matching blank measurement file');
                    if isequal(bfn, 0)
                        error('Raw sample files will require a blank for assessment');
                    end
                    blankFile = fullfile(bpn, bfn);
                end
                [eemRaw, eemBlanked, eemCorrected, correct, parms, eemFilter] = ...
                    localCorrectRawCSV(inputFile, blankFile, opt.parmsFile, opt.correctFile, opt.baseOpt);
                output.blankFile = blankFile;
                output.eemRaw = eemRaw;
                output.eemBlanked = eemBlanked;
                output.eemCorrected = eemCorrected;
                output.correct = correct;
                output.parms = parms;
                output.eemFilter = eemFilter;
    
                eemdata = eemCorrected;
            
            case {'.txt', '.asc', '.dat'} % if the input file is already a wrapped ASCII document
                % Already wrapped, no further processing
                eemdata = readmatrix(inputFile, 'FileType', 'text');
                output.eemRaw = eemdata;
                output.blankFile = [];
                output.eemBlanked = [];
                output.eemCorrected = eemdata;
                output.correct = [];
                output.parms = [];
                output.eemFilter = [];
            
            case '.plt'
                % Fluorescence Toolbox plot file already developed
                S = load(inputFile, '-mat');
    
                if isfield(S, 'save_eem')
                    eemdata = S.save_eem;
                elseif all(isfield(S, {'save_ex', 'save_em', 'save_fl'}))
                    eemdata = [NaN, S.save_ex; S.save_em, S.save_fl];
                else
                    error('No save_eem or save_ex/save_em/save_fl matrices found in .plt file.')
                end
                % Establish the output file structure 
                output.eemRaw = eemdata;
                output.eemBlanked = [];
                output.blankFile = [];
                output.eemCorrected = eemdata;
                output.correct = [];
                output.parms = [];
                output.eemFilter = [];
    
            case '.eem'
                % An already established MATLAB-made EEM structure
                S = load(inputFile, '-mat');
                % Validate that the eem structure exists
                if ~isfield(S, 'eem')
                    error('.eem file chosen does not contain a variable named eem.');
                end
                % Identify the elements of the eem structure
                if isfield(S.eem, 'corrected') && ~isempty(S.eem.corrected)
                    eemdata = S.eem.corrected;
                elseif isfield(S.eem, 'raw') && ~isempty(S.eem.raw)
                    eemdata = S.eem.raw;
                else
                    error('.eem file contains no usuable eem.corrected or eem.raw matrices.')
                end
                % Establish the output file structure
                output.eemRaw = [];
                output.eemBlanked = [];
                output.blankFile = [];
                output.eemCorrected = eemdata;
                output.correct = [];
                output.parms = [];
                output.eemFilter = [];
    
            case '.mat'
                % A MATLAB file in of itself
                S = load(inputFile);
    
                if isfield(S, 'eem_cor')
                    eemdata = S.eem_cor;
                elseif isfield(S, 'eemdata')
                    eemdata = S.eemdata;
                elseif isfield(S, 'save_eem')
                    eemdata = S.save_eem;
                elseif isfield(S, 'eem')
                    if isfield(S.eem, 'corrected') && ~isempty(S.eem.corrected)
                        eemdata = S.eem.corrected;
                    elseif isfield(S.eem, 'raw') && ~isempty(S.eem.raw)
                        eemdata = S.eem.raw;
                    else
                        error('MAT file contains EEM structure, but no usuable raw/corrected matrix.')
                    end
                else
                    error('No recognized EEM matrix variable found in the selected MAT file.')
                end
                % Establish the output file structure
                output.eemRaw = [];
                output.eemBlanked = [];
                output.blankFile = [];
                output.eemCorrected = eemdata;
                output.correct = [];
                output.parms = [];
                output.eemFilter = [];
            otherwise
                error('The file type %s is not supported by the importer.', ext);
        end

    % --------------------------------------
    % Validate wrapped EEM matrices
    % --------------------------------------
        % run the local helper function
        localValidateWrapperEEM(eemdata);
        % set the output
        output.eemMatrix    = eemdata;
        output.excitation   = eemdata(1, 2:end);
        output.emission     = eemdata(2:end, 1);
        output.fluorescence = eemdata(2:end, 2:end);

    % --------------------------------------
    % Create the EEM structure if needed
    % --------------------------------------
        eem = localBuildEEMStruct( ...
            inputFile, ...
            output.eemRaw, ...
            output.eemBlanked, ...
            output.eemCorrected, ...
            output.correct, ...
            output.parms);

        output.eem = eem;
    % --------------------------------------
    % Save the requested output file(s)
    % --------------------------------------
        % create the output file structure
        output.files = struct();

        % 1) saveEEM
        if opt.saveEEM
            eemFile = [outputBasePath, '.eem'];
            save(eemFile, 'eem');
            output.files.eem = eemFile;
        end

        % 2) saveTXT
        if opt.saveTXT
            txtFile = [outputBasePath, '.txt'];
            writematrix(eemdata, txtFile, 'Delimiter', ' ');
            output.files.txt = txtFile;
        end

        % 3) saveMAT
        if opt.saveMAT
            matFile = [outputBasePath, '_eemdata.mat'];
            eemMatrix = eemdata;
            excitation = output.excitation;
            emission = output.emission;
            fluorescence = output.fluorescence;

            if isfield(output, 'eemFilter')
                eemFilter = output.eemFilter;
            else
                eemFilter = [];
            end

            if isfield(output, 'correct')
                correct = output.correct;
            else
                correct = [];
            end

            if isfield(output, 'parms')
                parms = output.parms;
            else
                parms = [];
            end

            save(matFile, ...
                'eem', ...
                'eemMatrix', ...
                'excitation', ...
                'emission', ...
                'fluorescence', ...
                'eemFilter', ...
                'correct', ...
                'parms');

            output.files.mat = matFile;
        end

        % 4) savePLT
        if opt.savePLT
            pltFile = [outputBasePath, '.plt'];
            localSavePLT(pltFile, eemdata, inputName);
            output.files.plt = pltFile;
        end

    % --------------------------------------
    % Create a heatmap directly, if desired
    % --------------------------------------
        if opt.makeHeatmap
            if exist('eem_heatmap', 'file') == 2
                eem_heatmap(eemdata, inputName, [], 'raw', false, 'useDialog', true);
            else
                figure;
                imagesc(output.excitation, output.emission, output.fluorescence);
                axis xy;
                xlabel('Excitation wavelength (nm)');
                ylabel('Emission wavelength (nm)');
                title(inputName, 'Interpreter', 'none');
                colorbar;
                colormap(jet(128));
            end
        end
end

%%
% ==========================================================
% Establish a local helper function for correcting raw CSVs
% ==========================================================

% A simply function to ensure the raw CSV file is parsed and that the correction, parameters, etc. are properly labelled and handled
function [eemRaw, eemBlanked, eemCorrected, correct, parms, eemFilter] = localCorrectRawCSV(sampleFile, blankFile, parmsFile, correctFile, baseopt)

    sample  = readmatrix(sampleFile);
    sample  = sample(~all(isnan(sample), 2), ~all(isnan(sample), 1));
    
    blank   = readmatrix(blankFile);
    blank   = blank(~all(isnan(blank), 2), ~all(isnan(blank), 1));
    
    parms = readmatrix(parmsFile);
    parms = parms(~all(isnan(parms), 2), ~all(isnan(parms), 1));

    correct = readmatrix(correctFile);
    correct = correct(~all(isnan(correct), 2), ~all(isnan(correct), 1));

    [eemBlanked, eemCorrected, correct, eemFilter] = cleanscanlez_NEW_LAPIERRE_2(sample, blank, correct, parms, baseopt);
    eemRaw = sample;
end

% A short function to setup the EEM structure
function eem = localBuildEEMStruct(description, raw, blanked, corrected, correct, parms)
   
    eem = struct();

    eem.raw = raw;
    eem.blanked = blanked;
    eem.corrected = corrected;

    eem.description = description;
    eem.date = datetime("now");

    eem.calibration = '';
    eem.scattertol = correct;
    eem.scatterpeaks = parms;
    eem.raman = [];
    eem.ramanwave = [];
    eem.slits = [];
    eem.diluent = [];
    eem.df = [];
    eem.qsparms = [];
end
% A function to validate the wrapping of EEM 
function localValidateWrapperEEM(eemdata)
    if ~isnumeric(eemdata)
        error('EEM data must be numeric.');
    end
    if size(eemdata, 1) < 2 || size(eemdata, 2) < 2
        error('EEM matrix is not a wrapped EEM matrix')
    end
    if ~isnan(eemdata(1,1))
        warning('EEM matrix first cell is not NaN. Expected format [NaN ex; em Fl].');
    end
    
    ex = eemdata(1, 2:end);
    em = eemdata(2:end, 1);
    
    if any(isnan(ex)) || any(isnan(em)) || any(isnan(em))
        warning('EEM Matrix row for Excitation, or Column for Emission contains NaN values');
    end
end

% Create the minimally viable .plt file compatible with loadscan.m for toolbox
function localSavePLT(pltFile, eemdata, titleText)
    % Isolate eemdata matrix elements 
    ex = eemdata(1, 2:end);
    em = eemdata(2:end, 1);
    fl = eemdata(2:end, 2:end);
    % Store the eemdata appropriately
    save_eem    = eemdata;
    save_eemorig = eemdata;
    save_cdata  = fl;

    % -----------------------------------
    % Save other required .plt properties
    % -----------------------------------
    save_azel = [-27.5, 30];
    save_axis = [min(ex), max(ex), min(em), max(em), min(fl(:)), max(fl(:))];
    save_zlim = [min(fl(:)), max(fl(:))];

    save_edge    = 'none';
    save_facecol = 'interp';
    save_mesh    = 'both';

    save_xtick = linspace(min(ex), max(ex), min(6, numel(ex)));
    save_ytick = linspace(min(em), max(em), min(6, numel(em)));
    save_ztick = linspace(min(fl(:)), max(fl(:)), 6);

    save_xdir = 'normal';
    save_ydir = 'normal';
    save_zdir = 'normal';

    save_cbaropt = 1;
    save_grid = 1;
    save_contour = 'off';
    save_contourdata = [];
    save_showpeaks = 'off';
    save_peaklabels = [];
    save_polys = [];
    save_cmap = {'cmap_jet(128)', 1};

    save_eeminfo = [];
    save_title = struct( ...
        'String', titleText, ...
        'Color', [0 0 0], ...
        'FontName', 'Helvetica', ...
        'FontWeight', 'bold', ...
        'FontAngle', 'normal', ...
        'Interpreter', 'none', ...
        'FontSize', 10);
    save_xlabel = struct( ...
        'String', 'Excitation Wavelength (nm)', ...
        'Color', [0 0 0], ...
        'FontName', 'Helvetica', ...
        'FontWeight', 'bold', ...
        'FontAngle', 'normal', ...
        'Interpreter', 'none', ...
        'FontSize', 10);
    save_ylabel = struct( ...
        'String', 'Emission Wavelength (nm)', ...
        'Color', [0 0 0], ...
        'FontName', 'Helvetica', ...
        'FontWeight', 'bold', ...
        'FontAngle', 'normal', ...
        'Interpreter', 'none', ...
        'FontSize', 10);
    save_zlabel = struct( ...
        'String', 'Fluorescence', ...
        'Color', [0 0 0], ...
        'FontName', 'Helvetica', ...
        'FontWeight', 'bold', ...
        'FontAngle', 'normal', ...
        'Interpreter', 'none', ...
        'FontSize', 10);
    save_cbarlabel = struct( ...
        'String', '', ...
        'Color', [0 0 0], ...
        'FontName', 'Helvetica', ...
        'FontWeight', 'bold', ...
        'FontAngle', 'normal', ...
        'Interpreter', 'none', ...
        'FontSize', 10);

    axisfont = struct( ...
        'fontangle', 'normal', ...
        'fontname', 'Helvetica', ...
        'fontsize', 9, ...
        'fontweight', 'normal');
    cbarfont = struct( ...
        'fontangle', 'normal', ...
        'fontname', 'Helvetica', ...
        'fontsize', 8, ...
        'fontweight', 'normal');
    
    save_lightval = [0, 90, 65];

    colorscheme = struct( ...
        'figclr', [1 1 1], ...
        'axisclr', [1 1 1], ...
        'uniclr', [0 0 0], ...
        'titleclr', [0 0 0], ...
        'xclr', [0 0 0], ...
        'xlclr', [0 0 0], ...
        'yclr', [0 0 0], ...
        'ylclr', [0 0 0], ...
        'zclr', [0 0 0], ...
        'zlclr', [0 0 0], ...
        'cbarclr', [0 0 0]);
    
    % --------------------------
    % Export the final PLT file
    % --------------------------
    save(pltFile, ...
        'save_eem', ...
        'save_eemorig', ...
        'save_azel', ...
        'save_axis', ...
        'save_zlim', ...
        'save_title', ...
        'save_zlabel', ...
        'save_edge', ...
        'save_facecol', ...
        'save_mesh', ...
        'save_xtick', ...
        'save_ytick', ...
        'save_ztick', ...
        'save_showpeaks', ...
        'save_peaklabels', ...
        'save_polys', ...
        'save_cbaropt', ...
        'save_grid', ...
        'save_contour', ...
        'save_contourdata', ...
        'save_xdir', ...
        'save_ydir', ...
        'save_zdir', ...
        'save_eeminfo', ...
        'save_cmap', ...
        'save_cdata', ...
        'save_xlabel', ...
        'save_ylabel', ...
        'save_cbarlabel', ...
        'save_lightval', ...
        'colorscheme', ...
        'axisfont', ...
        'cbarfont');

end

% Establish dialogue control for import function
function opt = localImportDialog(opt)
    % Creat variable list of dialog options (All y/n)
    optionNames = {...
    'Save file as .eem', ...
    'save file as .plt', ...
    'Save file as .txt', ...
    'Save file as .mat', ...
    'Generate Heatmap'};
    
    defaultSelected = []; % No action by default
    allSelected = defaultSelected; % append defaultSelected to list

    % ------------------
    % Handle each option
    % ------------------
    if opt.saveEEM
        allSelected(end+1) = 1;
    end
    if opt.savePLT
        allSelected(end+1) = 2;
    end
    if opt.saveTXT
        allSelected(end+1) = 3;
    end
    if opt.saveMAT
        allSelected(end+1) = 4;
    end
    if opt.makeHeatmap
        allSelected(end+1) = 5;
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
        'Name', 'EEM Import Wizard — Options');
    if ~tf
        error('EEM Import was cancelled by the User.');
    end

    opt.saveEEM     = ismember(1, selected);
    opt.savePLT     = ismember(2, selected);
    opt.saveTXT     = ismember(3, selected);
    opt.saveMAT     = ismember(4, selected);
    opt.makeHeatmap = ismember(5, selected);
end
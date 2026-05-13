%% Make EEM Files
% Created by Zachary A. Gioppo on 2026/05/12 
% A script for creation of new EEM files from other formats 
% based in any saved data document .plt, .txt, OR .mat files
%% Function
function eem = makeFileEEM(inputFile, outputFile, description)
    % Ensure functions were set
    if nargin < 2 || isempty(outputFile)
        [folder, name, ~] = fileparts(inputFile);
        outputFile = fullfile(folder, [name, '.eem']);
    end
    if nargin < 3 || isempty(description)
        description = inputFile;
    end

    eemdata = loadMatrixEEM(inputFile);

    eem = struct();
    eem.raw            = eemdata;
    eem.blanked        = [];
    eem.corrected      = eemdata;
    eem.description    = description;
    eem.date           = datestr(now);
    eem.calibration    = '';
    eem.scattertol     = [];
    eem.scatterpeaks   = [];
    eem.raman          = [];
    eem.ramanwave      = [];
    eem.slits          = [];
    eem.diluent        = [];
    eem.df             = [];
    eem.qsparms        = [];

    save(outputFile, 'eem');
end
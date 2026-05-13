%%New EEM from CSV .m file 
% Created by Zachary A. Gioppo on 2026/05/12 
% This script will take a blank (prepared) .xls or .csv file outputted by
% the Fluorescence Spectroscopy machine
% Inputs:   sampleFile      : The .CSV or .XLS for the sample being measured
%           blankFile       : The .CSV or .XLS for the appropriate sample
%           outputBasePath  : the path for the output, no extensions
% OUTPUTS:  eem_cor         : corrected EEM wrapper
%           eem_blanc       : blank-subtracted, wrapped EEM matrix
%           eem_filter      : correction filter matrix
%% Function
function [eem_cor, eem_blanc, eem_filter] = newEEMfromCSV(sampleFile, blankFile, outputBasePath)
    
    % Ensure the output file has been configured
    if nargin < 3 || isempty(outputBasePath)
        [sampleFolder, sampleName, ~] = fileparts(sampleFile);
        outputBasePath = fullfile(sampleFolder, sampleName);
    end
    % Read raw sample and blank
    sample = readmatrix(sampleFile);
    blank = readmatrix(blankFile);

    % Ensure empty rows or columns are removed, including trailing CSV delimiters
    sample = sample(~all(isnan(sample),2), ~all(isnan(sample),1));
    blank = blank(~all(isnan(blank),2),  ~all(isnan(blank),1));

    % Load correction parameter files
    parms    = readmatrix('parms.xlt');
    correct  = readmatrix('correct.xls');
    parms    = parms(~all(isnan(parms),2), ~all(isnan(parms),1));
    correct  = correct(~all(isnan(correct),2),  ~all(isnan(correct),1));

    % Apply fluorescence Toolbox correction
    baseopt = 0;
    [eem_blanc, eem_cor, correct, eem_filter] = ...
        cleanscanlez_NEW_LAPIERRE_2(sample, blank, correct, parms, baseopt);
    
    % Save the ASCII matrix equivalent of .txt output
    writematrix(eem_cor, [outputBasePath, '.txt'], 'Delimiter', ' ');

    % Save minimal-ized EEM structure for MATLAB file
    eem = struct();
    
    eem.raw            = sample;
    eem.blanked        = eem_blanc;
    eem.corrected      = eem_cor;
    eem.description    = sampleFile;
    eem.date           = datestr(now);
    eem.calibration    = '';
    eem.scattertol     = correct;
    eem.scatterpeaks   = parms;
    eem.raman          = [];
    eem.ramanwave      = [];
    eem.slits          = [];
    eem.diluent        = [];
    eem.df             = [];
    eem.qsparms        = [];
    
    save([outputBasePath, '.eem'], 'eem');

    % Also save a .mat copy of the corrected matrix directly
    save([outputBasePath '_corrected.mat'], 'eem_cor', 'eem_blanc', 'eem_filter', 'correct', 'parms');
end
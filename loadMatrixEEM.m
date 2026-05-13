%% Load EEM Matrices
% Created by Zachary A. Gioppo on 2026/05/12 
% A script for loading a matrix in the Fluorescence Toolbox format 
% from any saved data document .plt, .txt, .eem, OR .mat files
%% Function
function loadedEEM = loadMatrixEEM(fileName)
    
    % Seperate components of fileName for saving/importing
    [~, ~, ext] = fileparts(fileName);
    
    % Allow specific operations for the different possible filetypes
    switch lower(ext)
        case '.plt'
            S = load(fileName, '-mat');

            if isfield(S, 'save_eem')
                loadedEEM = S.save_eem;
            elseif all(isfield(S, {'save_ex','save_em','save_fl'}))
                loadedEEM = [NaN, S.save_ex; S.save_em, S.save_fl];
            else
                error('No save_eem or save_ex/save_em/save_fl found in the .plt file.');
            end

        case {'.txt', '.asc', '.dat', '.csv'}
            loadedEEM = readmatrix(fileName, 'FileType', 'text');

        case '.eem'
            S = load(fileName, '-mat');

            if  isfield(S, 'eem')
                if isfield(S.eem, 'corrected') && ~isempty(S.eem.corrected)
                    loadedEEM = S.eem.corrected;

                elseif isfield(S.eem, 'raw') && ~isempty(S.eem.raw)
                    loadedEEM = S.eem.raw;
                else
                    error('.eem file found, but no usable eem.corrected or eem.raw matrix identified.')
                end
            else
                error('.eem file does not contain a variable named eem.')
            end

        case '.mat'
            S = load(fileName);

            if  isfield(S, 'eem_cor')
                loadedEEM = S.eem_cor;
            elseif isfield(S, 'eemdata')
                loadedEEM = S.eemdata;
            elseif isfield(S, 'save_eem')
                loadedEEM = S.save_eem;
            else
                error('The .mat file was successfully imported, but no EEM matrix variable was identified');
            end
        otherwise 
            error('Unsupported file type: %s', ext);
    end
end
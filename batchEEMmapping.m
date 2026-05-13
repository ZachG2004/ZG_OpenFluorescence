%% Batch comparison of EEM Files
% Created by Zachary A. Gioppo on 2026/05/12 
% This script allows input of multiple eem files, for heatmapping
% Each file is used to generate an EEM comparison
% Functional inputted filelist can be a string array or cell array of files
%% Function
function batchEEMmapping(fileList, useCommonScale)
    % ensure common scale is used
    if nargin < 2
        useCommonScale = true;
    end
    if isstring(fileList)
        fileList = cellstr(fileList);
    end

    % Process cell-list
    E = cell(size(fileList));
    allFluorescence = [];

    for k = 1:numel(fileList)
        E{k} = loadEEMmatrix(fileList{k});
        fl = E{k}(2:end, 2:end);
        allFluorescence = [allFluorescence, fl(:)];
    end

    if useCommonScale
        climVals = [min(allFluorescence), max(allFluorescence)];
    else
        climVals = [];
    end

    for k = 1:numel(fileList)
        eem_heatmap(E{k}, fileList{k}, climVals);
    end
end
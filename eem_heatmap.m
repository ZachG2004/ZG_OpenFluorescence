%% Develop the heatmap plot for the system  
% Created by Zachary A. Gioppo on 2026/05/12 
% This script will develop a direct 2D excitation-emission heatmap for
% Fluorescence Toolbox EEM matrices
% Functional mode for EEM Inputs:
%       eemdata(1,2:end)      = excitation wavelengths
%       eemdata(2:end,1)      = emission wavelengths
%       eemdata(2:end,2:end)  = fluorescence intensities
%% Function
function heatmapOut = eem_heatmap(eemdata, plotTitle, climVals)
    % Ensure settings are established
    if nargin < 2 || isempty(plotTitle)
        plotTitle = 'EEM Heatmap';
    end
    if nargin < 3 || isempty(climVals)
        climVals = [];
    end

    % Define function elements
    ex = eemdata(1, 2:end);
    em = eemdata(2:end, 1);
    fl = eemdata(2:end,2:end);

    % Create the plot
    figure;
    heatmapOut = imagesc(ex, em, fl);
    axis xy;
    xlabel('Excitation Wavelength (nm)');
    ylabel('Emission Wavelength (nm)');
    title(plotTitle, 'Interpreter', 'none');
    colorbar;
    colormap(jet(128));

    if ~isempty(climVals)
        clim(climVals);
    end
end
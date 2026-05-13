function newaxis(axlims)
%syntax:  newaxis(axlims)
%
%Sets the axes limits of an EEM plot to the values in 'ax',
%resets the PlotBoxAspectRatio to reflect the new axes, and
%runs 'clip3d' to truncate any portions of the EEM plot that
%lie outside the axes planes
%
%(c)1999 by Wade Sheldon
%Department of Marine Sciences
%University of Georgia
%Athens, Georgia  30602-3636
%sheldon@uga.edu
%
%This file is part of the Fluorescence Toolbox for MATLAB(r) software library.
%
%The Fluorescence Toolbox is free software: you can redistribute it and/or modify it under the terms
%of the GNU General Public License as published by the Free Software Foundation, either version 3
%of the License, or (at your option) any later version.
%
%The Fluorescence Toolbox is distributed in the hope that it will be useful, but WITHOUT ANY
%WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%PURPOSE. See the GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License along with The Fluorescence Toolbox
%as 'license.txt'. If not, see <http://www.gnu.org/licenses/>.
%
%last modified 2/24/2005

if nargin == 0
   axlims = axis;
end

if length(axlims) == 4
   zlimits = get(gca,'ZLim');
   axlims = [axlims zlimits];
else
   zlimits = axlims(5:6);
end

[az,el] = view;  %buffer viewpoint
axis(axlims)
view(az,el)

set(gca,'PlotBoxAspectRatio',[abs(axlims(2)-axlims(1))./abs(axlims(4)-axlims(3)) 1 1])

caxis(zlimits)

if mlversion < 7

   colorbar  %refresh existing bar

else  %regenerate bar after buffering settings

   %buffer colorbar settings
   h_bar = findobj(gcf,'Tag','Colorbar');
   if ~isempty(h_bar)
      barvis = get(h_bar,'Visible');
      barcolor = get(h_bar,'XColor');
      barpos = get(h_bar,'Position');
      barunits = get(h_bar,'Units');
      h_y = get(h_bar,'YLabel');
      ylabel = get(h_y,'String');
      yfontname = get(h_y,'FontName');
      ycolor = get(h_y,'Color');
      yfontsize = get(h_y,'FontSize');
      yfontweight = get(h_y,'FontWeight');
      delete(h_bar)
   else
      ylabel = '';
      barpos = [];
   end

   h_bar = colorbar;  %regenerate bar

   %restore prior colorbar settings
   if ~isempty(h_bar) & ~isempty(barpos)

      set(h_bar, ...
         'XColor',barcolor, ...
         'YColor',barcolor, ...
         'ZColor',barcolor)

      set(get(h_bar,'YLabel'),'Color',barcolor)

      h_barobj = findobj(h_bar);
      h_y = get(h_bar,'YLabel');

      if ~isempty(ylabel)
         set(h_y, ...
            'FontName',yfontname, ...
            'FontSize',yfontsize, ...
            'Color',ycolor, ...
            'FontWeight',yfontweight, ...
            'String',ylabel, ...
            'ButtonDownFcn','textedit')
      end

      set(h_barobj,'Visible',barvis)

   end
end

clip3d
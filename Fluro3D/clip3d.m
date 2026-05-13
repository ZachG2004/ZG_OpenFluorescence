function clip3d(op,h_s)
%syntax:  clip3d(operation,h_s)
%
%Clipping function for 3d surface plots.
%
%If 'op' is 'init', the XData, YData, and ZData of the specified surface object are
%stored in the userdata property of the surface and replaced with values matching
%the current dimensions plot.  XData and YData values outside of the current limits
%are replaced with NaN, and ZData values are replaced with maximum or minimum values.
%
%If 'op' is 'reset', the ZData matrix is replaced by the stored matrix.
%
%If 'op' is 'update', the clipped matrix is updated to match the axes limits.
%
%'h_s' is an optional handle for the surface object to clip; if 'h_s' is omitted
%the first surface object on the current axis is assumed.
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
%last modified 5/5/1999

cancel = 0;

if exist('h_s') ~= 1  %surface handle not specified - use default

   h_s = findobj(gca,'Type','surface');

   if isempty(h_s)

      cancel = 1;

      disp(' '); disp('No valid surface plot on current axes!'); disp(' ');

   end

end

if cancel == 0

   if exist('op') ~= 1  %no operation specified - choose appropriate option

      XYZ_stored = get(h_s,'UserData');

      if isempty(XYZ_stored)  %no stored data - assume 'init'

         op = 'init';

      else  %stored data - assume 'update'

         op = 'update';

      end

   end

end

if cancel == 0

   if strcmp(op,'init')

      X_current = get(h_s,'XData');
      Y_current = get(h_s,'YData');
      Z_current = get(h_s,'ZData');

      XYZ_current = [NaN X_current ; Y_current Z_current];  %concatenate values

      set(h_s,'UserData',XYZ_current);

      clip3d('update',h_s)

   elseif strcmp(op,'reset')

      Z_current = get(h_s,'ZData');
      [r1,c1] = size(Z_current);

      XYZ_stored = get(h_s,'UserData');
      [r2,c2] = size(XYZ_stored);

      if r1+1 == r2 & c1+1 == c2  %check for matching matrix dimensions

         %break out individual components
         X_stored = XYZ_stored(1,2:size(XYZ_stored,2));
         Y_stored = XYZ_stored(2:size(XYZ_stored,1),1);
         Z_stored = XYZ_stored(2:size(XYZ_stored,1),2:size(XYZ_stored,2));

         %restore initial values
         set(h_s,'XData',X_stored)
         set(h_s,'YData',Y_stored)
         set(h_s,'ZData',Z_stored)

         refresh

      else

         disp(' '); disp('Error - stored matrix does not match current surface dimensions!'); disp(' ')

      end

   elseif strcmp(op,'update')

      update = 0;

      %get current axis limits
      xlims = get(gca,'XLim');
      ylims = get(gca,'YLim');
      zlims = get(gca,'ZLim');

      %use stored data values as starting values
      XYZ_stored = get(h_s,'UserData');
      X_clip = XYZ_stored(1,2:size(XYZ_stored,2));
      Y_clip = XYZ_stored(2:size(XYZ_stored,1),1);
      Z_clip = XYZ_stored(2:size(XYZ_stored,1),2:size(XYZ_stored,2));

      %clip X data to match axis limits
      X_clip(X_clip > xlims(2)) = NaN;
      X_clip(X_clip < xlims(1)) = NaN;

      %clip Y data to match axis limits
      Y_clip(Y_clip > ylims(2)) = NaN;
      Y_clip(Y_clip < ylims(1)) = NaN;

      %clip Z data to match axis limits
      Z_clip(Z_clip  > zlims(2)) = zlims(2) + eps;
      Z_clip(Z_clip  < zlims(1)) = zlims(1) - eps;

      set(h_s,'XData',X_clip);
      set(h_s,'YData',Y_clip);
      set(h_s,'ZData',Z_clip);

      %clip peaklabels to work around ML bugs
      h_peaklabels = findobj(gcf,'Tag','peaklabels');
      if ~isempty(h_peaklabels)
         for n = 1:length(h_peaklabels)
            if strcmp(get(h_peaklabels(n),'Visible'),'on')
               pos = get(h_peaklabels(n),'Position');
               if pos(1) < xlims(1) | pos(1) > xlims(2) | pos(2) < ylims(1) | pos(2) > ylims(2)
                  set(h_peaklabels(n),'Visible','off')
               else
                  set(h_peaklabels(n),'Visible','on')
               end
            end
         end
      end

   end

end

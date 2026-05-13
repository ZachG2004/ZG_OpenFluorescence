function [mouse_x,mouse_y,mouse_z] = click_pos
%syntax:  [mouse_x,mouse_y,mouse_z] = click_pos
%
%Function called by various 'Fluorescence Toolbox' routines to read
%the numerical values of plot locations clicked on by the mouse and return
%corresponding data values.
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
%last modified 2/27/2007

global AXISLOCK

if isempty(AXISLOCK)

   %shift focus back to main axis if colorbar is current axis
   h_ax = findobj(gcf,'Type','axes');
   h_bar = findobj(gcf,'Tag','Colorbar');

   if ~isempty(h_bar)
      if h_bar == gca
         if h_bar == h_ax(1)
            axes(h_ax(2))
         else
            axes(h_ax(1))
         end
      end
   end

   [az,el] = view;

   mouse_x = []; mouse_y = []; mouse_z = [];  %initialize output parameters

   if el./90 == fix(el./90) & az./90 == fix(az./90)  %check for valid orientation

      xlim = get(gca,'XLim');
      ylim = get(gca,'YLim');
      zlim = get(gca,'ZLim');

      oob = 0;

      axpos = get(gca,'CurrentPoint');

      if el == 90 | el == 270  %top/bottom view

         mouse_x = roundsig(axpos(1,1),3);

         if mouse_x < xlim(1) | mouse_x > xlim(2)
            oob = 1;
         end

         mouse_y = roundsig(axpos(1,2),3);

         if mouse_y < ylim(1) | mouse_y > ylim(2)
            oob = 1;
         end

         if oob == 0

            %get z position using surface interpolation
            h_surf = findobj(gca,'Type','surface');
            storedvals = get(h_surf,'UserData');

            if ~isempty(storedvals)
               x = storedvals(1,2:size(storedvals,2));
               y = storedvals(2:size(storedvals,1),1);
               z = storedvals(2:size(storedvals,1),2:size(storedvals,2));
            else
               x = nonneg(get(h_surf,'XData'));
               y = nonneg(get(h_surf,'YData'));
               z = get(h_surf,'ZData');
            end

            I_y = find(y);
            ydata = y(I_y);

            I_x = find(x);
              xdata = x(I_x);

            zdata = z(I_y,I_x);

            try
               mouse_z = interp2(xdata,ydata,zdata,mouse_x,mouse_y);
            catch
               mouse_z = [];
            end

         end

      else         %side view

         if az == 0 | az == 180   %horizontal axis = x

            mouse_x = roundsig(axpos(1,1),3);

            if mouse_x < xlim(1) | mouse_x > xlim(2)
               oob = 1;
            end

         else         %horizontal axis = y

            mouse_y = roundsig(axpos(1,2),3);

            if mouse_y < ylim(1) | mouse_y > ylim(2)
               oob = 1;
            end

         end

         mouse_z = axpos(1,3);

         if mouse_z < zlim(1) | mouse_z > zlim(2)
            oob = 1;
         end

      end

      if oob == 0  %check for out of bounds click before updating values

         hx = findobj(gcf,'Tag','lambda-ex');
         hy = findobj(gcf,'Tag','lambda-em');
         hz = findobj(gcf,'Tag','fluor');

         if ~isempty(hx)
            set(hx,'String',num2str(mouse_x))
         end

         if ~isempty(hy)
            set(hy,'String',num2str(mouse_y))
         end

         if ~isempty(hz)

            set(hz,'String',num2str(roundsig(mouse_z,6)))

%             if mouse_z > max(zlim)
%               set(hz,'String',['> ' num2str(max(zlim))])
%            elseif mouse_z < min(zlim)
%               set(hz,'String',['< ' num2str(min(zlim))])
%            else
%               set(hz,'String',num2str(roundsig(mouse_z,6)))
%            end

         end

      end

   end

end

function plottoggle(op)
%Toggles display of EEM plot features
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
%last modified 6/27/00

if nargin > 0

   h_fig = gcf;

   switch op

   case 'cbar'  %toggle colorbar visibility

      h_cbaropt = findobj(h_fig,'Tag','hidecbar');

      if ~isempty(h_cbaropt)

         h_bar = findobj(h_fig,'Tag','Colorbar');
         h_barobj = findobj(h_bar);
         lbl = get(h_cbaropt,'Label');

         if strcmp(lbl(1,1),'H')

            set(h_cbaropt,'Label','Show Color Bar')
            set(h_barobj,'Visible','off')
            drawnow

         else

            set(h_cbaropt,'Label','Hide Color Bar')
            set(h_barobj,'Visible','on')
            drawnow

         end

      end

   case 'grid'  %toggle grid display

      h_grid = findobj(h_fig,'Tag','hidegrid');

      if ~isempty(h_grid)

         lbl = get(h_grid,'Label');

         if strcmp(lbl(1,1),'H')

            set(h_grid,'Label','Show Grid Lines')
            grid off
            drawnow

         else

            set(h_grid,'Label','Hide Grid Lines')
            grid on
            drawnow

         end

      end

   case 'view'  %toggle between rotate3d/view control buttons

      h_view = findobj(h_fig,'Tag','viewmode');
      h_ctrls = findobj(gcf,'Type','uicontrol');
      h_uihide = findobj(gcf,'Tag','uihide');

      if ~isempty(h_view)

         lbl = get(h_view,'Label');

         if strcmp(lbl(1,1),'F')

            set(h_view,'Label','Standard View Mode')
            set(h_uihide,'Enable','off')
            set(h_ctrls,'Visible','off')

            rotate3d on

         else

            set(h_view,'Label','Free Rotate Mode')
            set(h_uihide,'Enable','on')
              if strcmp(get(h_uihide,'Label'),'Hide Plot Controls')
               set(h_ctrls,'Visible','on')
            end

            rotate3d off
            set(gca,'Box','off')

            viewcontrols('axislabels')

         end

      end

   case 'hidectrls'  %hide uicontrols on 2d plots

      h_hideui = findobj(h_fig,'Tag','hideui');
      lbl = get(h_hideui,'Label');
      h_ui = findobj(h_fig,'Type','uicontrol');

      if strcmp(lbl(1,1),'H')
         set(h_hideui,'Label','Show Plot Controls')
         set(h_ui,'Visible','off')
      else
         set(h_hideui,'Label','Hide Plot Controls')
         set(h_ui,'Visible','on')
      end

      drawnow

   end

end


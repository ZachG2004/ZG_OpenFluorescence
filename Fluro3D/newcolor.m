function newcolor(op)
%syntax:  newcolor(op)
%
%Colormap function called by EEMplot
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

if nargin > 0

   if length(op) > 4

      if strcmp(op(1,1:4),'cmap')

         h = findobj(gcf,'Tag','colormap');

         if ~isempty(h)

            opstr = op(1,6:length(op));

            cmapdata = get(h,'UserData');
            curcmap = cmapdata{1};
            cmapdir = cmapdata{2};

            if strcmp(opstr,'rev')

               newcmapdir = cmapdir ~= 1;

               h_rev = findobj(gcf,'Tag','revcmap');
               if newcmapdir == 1
                  set(h_rev,'Checked','off')
               else
                  set(h_rev,'Checked','on')
               end

               newcmapdata = [{curcmap} {newcmapdir}];
               set(h,'UserData',newcmapdata)

               eval(['c = ' curcmap ';'])
               if newcmapdir == 1
                  colormap(c)
               else
                  colormap(flipud(c))
               end

            else

               h_current = findobj(h,'Checked','on');
               h_new = findobj(h,'Tag',op);

               if ~isempty(h_new)

                  set(h_current,'Checked','off')
                  set(h_new,'Checked','on')
                  set(h,'UserData',[{opstr} {cmapdir}]);

                  eval(['c = ' opstr ';'])
                  if cmapdir == 1
                     colormap(c)
                  else
                     colormap(flipud(c))
                  end

               end

            end

         end

      end

   end

end

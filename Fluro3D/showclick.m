function [x,y] = showclick(numdec)
%syntax:  [x,y] = showclick(numdec)
%
%Displays the x and y position of the crosshair pointer for each left-click
%of the mouse in the number of decimal places 'numdec'.  Continues until the
%right button is pressed, then the final values are returned to the Matlab
%workspace.
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

if exist('numdec') ~= 1
   numdec = 2;
end

fstr = ['%0.' int2str(numdec) 'f'];

h_x = uicontrol(gcf, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[2 2 80 18], ...
   'ForegroundColor','k', ...
   'BackgroundColor','w', ...
   'HorizontalAlignment','left', ...
   'String','X:', ...
   'Tag','showclick');

h_y = uicontrol(gcf, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[82 2 80 18], ...
   'ForegroundColor','k', ...
   'BackgroundColor','w', ...
   'HorizontalAlignment','left', ...
   'String','Y:', ...
   'Tag','showclick');

figure(gcf)
drawnow

[x,y,button] = ginput(1);

while button == 1
   set(h_x,'String',['X: ' sprintf(fstr,x)])
   set(h_y,'String',['Y: ' sprintf(fstr,y)])
   drawnow
   [x,y,button] = ginput(1);
end

delete(h_x)
delete(h_y)
drawnow
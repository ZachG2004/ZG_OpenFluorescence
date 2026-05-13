function mousepos(xlbl,ylbl,prec)
%syntax:  mousepos(xlbl,ylbl,prec)
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

pos = get(gca,'CurrentPoint');
ax = axis;
h_x = findobj(gcf,'Tag','xpos');
h_y = findobj(gcf,'Tag','ypos');

if pos(1,1) >= ax(1) & pos(1,1) <= ax(2)
   set(h_x,'String',[xlbl ' = ' num2str(roundsig(pos(1,1),prec))])
end

if pos(1,2) >= ax(3) & pos(1,2) <= ax(4)
   set(h_y,'String',[ylbl ' = ' num2str(roundsig(pos(1,2),prec))])
end

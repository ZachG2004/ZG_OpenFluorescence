function plotlabels(titlestr,xstr,ystr,zstr)
%syntax:  plotlabels(titlestr,xstr,ystr,zstr)
%
%Adds the specified title and axis label strings to the current plot
%and links each string object to the editing function 'textedit.m'.
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

if exist('titlestr') ~= 1
   titlestr = 'Title';
end

if exist('xstr') ~= 1
   xstr = 'X';
end

if exist('ystr') ~= 1
   ystr = 'Y';
end

if exist('zstr') ~= 1
   ax = axis;
   if length(ax) < 4
      zstr = 'Z';
   else
      zstr = '';
   end
end

handlestr = [{'Title'} {'XLabel'} {'YLabel'} {'ZLabel'}];

valuestr = [{titlestr} {xstr} {ystr} {zstr}];

fontsize = [18 12 12 12];

for n = 1:length(handlestr)

   h = get(gca,char(handlestr(n)));
   str = char(valuestr(n));

   if ~isempty(str)
      set(h, ...
         'String',str, ...
         'FontSize',fontsize(n), ...
         'FontWeight','bold', ...
         'ButtonDownFcn','textedit')
   end

end

function num = mlversion
%Returns the version of MATLAB running in numerical form ([majorversion].[minorversion])
%
%syntax: vnum = mlversion
%
%inputs:
%  none
%
%outputs:
%  vnum = version number (e.g. 6.5)
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

v = version;

[v_maj_str,rem] = strtok(v,'.');

v_min_str = strtok(rem,'.');

num = str2num(v_maj_str) + str2num(v_min_str)./10;
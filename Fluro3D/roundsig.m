function out = roundsig(x,sigdig)
%Syntax:  <varname> = roundsig(x,sigdig)
%
%Rounds 'x' to the significant digits 'sigdig'
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
%last modified 10/2/98

if nargin ~= 2

   disp(' '); disp('Too few arguments for function'); disp(' ')

elseif sigdig <= 0 | fix(sigdig) ~= sigdig

   disp(' '); disp('Significant digits must be an integer >= 1'); disp(' ')

else

   if x ~= 0

      out = round(x .* 10^(sigdig - ceil(log10(abs(x))))) ./ ...
         10^(sigdig - ceil(log10(abs(x))));

   else

      out = 0;

   end

end

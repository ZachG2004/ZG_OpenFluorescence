function eem_qse = rmn2qse(eem_rmn,parms)
%syntax:  eem_qse = rmn2qse(eem_rmn,parms)
%
%Converts Raman-normalized fluorescence intensity values [i.e.
%If_sample(cps)/If_diH2O(Ex275/Em303,cps)] to quinine sulfate equivalents
%using a 2nd-order polynomial curve fit of fluorescence (in Raman units)
%on quinine sulfate concentration (in ppb).
%
%'eem_rmn' is a matrix of EEM data, with excitation wavelengths in
%   the first row, emission wavelengths in the first column, and
%   corresponding fluorescence intensity values in Raman units for each
%   ex/em wavelength combination.  The top left cell is ignored but
%   copied to the output matrix.
%
%'parms' is an optional array of curve fit coefficients for a 2nd-order
%   polynomial fit of fluorescence intensity (corrected raman units) on
%   quinine sulfate concentration (ppb).  Coefficients must be ordered
%   from highest to lowest (see polyval.m).  If omitted, default values
%   in the file 'calibration.mat' will be used.
%
%Equation:  If(rmn) = p1*[qs(ppb)]^2 + p2*[qs(ppb)] + p3
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
%last modified 3/14/2000

eem_qse = [];

if nargin == 2  %check for required arguments

   parms = parms(:)';     %format as row vector
   if length(parms) < 3   %fill in missing coefficient values
      parms = [parms zeros(1,3-length(parms))];
   end

   [ex,em,fl_rmn,fl_id] = unwrapeem(eem_rmn);

   fl_qse = real((-1./(2.*parms(1))) * ...
      (parms(2) - sqrt(parms(2)^2 + 4.*parms(1).*fl_rmn - 4.*parms(1).*parms(3))));

   eem_qse = wrapeem(ex,em,fl_qse,fl_id);

else

   error = 1
   disp(' '); disp('Too few arguments for function!'); disp(' ')

end

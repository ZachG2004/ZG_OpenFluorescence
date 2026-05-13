function [eemc,cf_matrix] = cfactor(eem,corrmatrix,method)
%syntax:  [eemc,cf] = cfactor(eem,corrmatrix,method)
%
%Applies excitation and emission correction factors to correct EEM
%   scans for instrument artifacts resulting from wavelength-dependent
%   differences in grating efficiency and PMT response.  WARNING: this
%   correction is only valid for scans collected in 'ratio mode'
%   (S/R data acquisition mode), because most of the excitation
%   correction is accomplished by ratioing PMT signal output to the
%   reference diode to account for spectral variations in Xenon lamp
%   intensity.
%
%'eemdata' is a matrix of EEM data, with excitation wavelengths in
%   the first row, emission wavelengths in the first column, and
%   corresponding fluorescence intensity values for each ex/em
%   wavelength combination.  The top left cell is ignored but copied
%   to the output matrix.
%
%'corrmatrix' is a matrix of excitation/emission correction factors (i.e.
%   wavelength-dependent fluorescence intensity multipliers) in the same
%   orientation as 'eemdata'.
%
%'method' is an optional string argument specifying the interpolation
%   method to use (e.g. 'nearest', 'linear', 'cubic', 'spline')
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

eemc = [];  %initialize output argument

if nargin >= 2  %check for sufficient arguments

   if ~exist('method')
      method = 'linear';  %apply default value if argument omitted
   end

   [ex,em,fl,fl_id] = unwrapeem(eem);
   [cex,cem,correctfactor] = unwrapeem(corrmatrix);

   if ~isempty(ex) & ~isempty(em) & ~isempty(fl)

      %interpolate correction matrix to match data
      cf_matrix = interp2(cex,cem,correctfactor,ex,em,method);

      %apply corrections
      flc = fl .* cf_matrix;

      %wrap up matrix
      eemc = wrapeem(ex,em,flc,fl_id);

   else  %bad input matrix

      disp(' '); disp('Invalid EEM data!'); disp(' ')

   end

else  %insufficient arguments

   disp(' '); disp('Too few arguments for cfactor function!');disp(' ')

end

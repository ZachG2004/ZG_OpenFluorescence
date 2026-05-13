function eem_corblkdil = undilute(eem_cor,df,eem_dil,matchopt)
%syntax:  eem_corblkdil = undilute(eem_cor,df,eem_dil,matchopt)
%
%Calculates undiluted fluorescence after subtration of fractional diluent
%fluorescence.
%
%'eem_cor' is the EEM data matrix to process
%
%'df' is dilution factor (CONCinit/CONCfinal, of A350init/A350final)
%
%'eem_dil' is the EEM data matrix of the diluent
%
%NOTE: 'eem_cor' and 'eem_dil' must be in equivalent units for correct results
%  (i.e. both corrected and converted to QSE, or both raw data in cps)
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
%last modified 9/21/1999

eem_corblkdil = [];

if nargin >= 2

   if ~exist('eem_dil')
      eem_dil = eem_raw;
      eem_dil(2:size(eem_dil,1),2:size(eem_dil,2)) = ones(size(eem_dil,1)-1,size(eem_dil,2)-1);
   end

   if ~exist('matchopt')
      matchopt = 0;
   end

   eem_corblkdil = eem_math('(A-B.*(1-1/C)).*C',[{eem_cor},{eem_dil},{df}],matchopt);

else

   disp(' '); disp('Too few arguments for function!'); disp(' ')

end

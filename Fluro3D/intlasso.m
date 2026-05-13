function [vol,eem_inside] = intlasso(eemdata,lasso,res,tol)
%Syntax:  [vol,eem_inside] = intlasso(eemdata,lasso,res,tol)
%
%Integrates portion of EEM scans within a specified polygon
%
%'eemdata' is a matrix of EEM data, with excitation wavelengths in
%   the first row, emission wavelengths in the first column, and
%   corresponding fluorescence intensity values for each ex/em
%   wavelength combination.  The top left cell is ignored but copied
%   to the output matrix.
%
%'lasso' is a 2-column matrix of ex and em values obtained
%   from the LASSO.M function on a top view (Ex/Em) plot of an EEM
%
%'res' is an optional resolution setting; if 'res' = 0 (default) the
%   integration is performed at the resolution of 'eemdata', but if
%   'res' = 1 the portion of 'eemdata' within the gross lasso boundaries
%   will first be interpolated to a 1nm x 1nm mesh resolution.
%
%'tol' is the tolerance in nm for determining whether points are inside
%   non-rectangular polygons.
%
%'eem_inside' is an output matrix with excitation and emission boundaries
%   flanking the lasso boundaries; fluorescence values outside the lasso
%   boundaries set to 0.
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
%last modified 3/8/2000

error = 0;

if nargin >= 2

   if exist('res') ~= 1  %use default 'res'
      res = 0;
   elseif res > 1
      res = 1;
   end

   if exist('tol') ~= 1
      tol = 0.5;
   end

   %extract eem components
   [ex,em,fl] = unwrapeem(eemdata);

   %cut down eem to polygon boundaries +/- 1 scan interval
   flank = max(abs(ex(2)-ex(1)),abs(em(2)-em(1)));  %get flanking interval
   I_ex = find(ex >= min(lasso(:,1))-flank & ex <= max(lasso(:,1))+flank);
   I_em = find(em >= min(lasso(:,2))-flank & em <= max(lasso(:,2))+flank);

   if res == 0  %use normal resolution and 0.5nm tolerance

      ex_flank = ex(I_ex);
      em_flank = em(I_em);
      flmesh = fl(I_em,I_ex);

   else  %interpolate fluorescence matrix to resolution = 'res', use 10% tolerance

      ex_flank = [min(lasso(:,1))-flank:res:max(lasso(:,1))+flank];
      em_flank = [min(lasso(:,2))-flank:res:max(lasso(:,2))+flank]';
      flmesh = interp2(ex,em,fl,ex_flank,em_flank);

   end

   %form wavelength lookup grids
   [exmesh,emmesh] = meshgrid(ex_flank,em_flank);

   %test for rectangular polygon case
   if size(lasso,1) <= 5
      area_rect = (max(lasso(:,1))-min(lasso(:,1))) .* (max(lasso(:,2))-min(lasso(:,2)));
      area_poly = polyarea(lasso(:,1),lasso(:,2));
      if area_rect == area_poly
         polytype = 'rect';
      else
         polytype = 'nonrect';
      end
   else
      polytype = 'nonrect';
   end

   %get index of eem region within polygon
   if strcmp(polytype,'rect')  %use faster rectangle algorithm

      ex_inside = exmesh <= (max(lasso(:,1))+tol) & exmesh >= (min(lasso(:,1))-tol);
      em_inside = emmesh <= (max(lasso(:,2))+tol) & emmesh >= (min(lasso(:,2))-tol);
      I_inside = find(ex_inside + em_inside == 2);

   else  %use slower universal algorithm

      ex_data = nonneg(exmesh);
      em_data = nonneg(emmesh);

      rowblocks = 5;
      maxrows = size(ex_data,1);
      cols = size(ex_data,2);

      matches = [];

      for n = 1:max(1,ceil(maxrows./rowblocks))
         toprow = rowblocks * (n-1) + 1;
         botrow = min(maxrows,toprow + rowblocks - 1);
         temp = zeros(botrow-toprow+1,cols);
         I = find(insidepoly(ex_data(toprow:botrow,:), ...
            em_data(toprow:botrow,:),lasso(:,1),lasso(:,2),tol));
         temp(I) = 1;
         matches = [matches ; temp];
      end

      if ~isempty(matches)
         I_inside = find(matches);
      end

   end

   %initialize output fluorescence matrix
   fl_inside = zeros(length(em_flank),length(ex_flank));

   %populate eem region within polygon with fluorescence data
   fl_inside(I_inside) = flmesh(I_inside);

   %build output eem
   eem_inside = wrapeem(ex_flank,em_flank,fl_inside);

   %zero out any NaN values
   I_null = find(isnan(fl_inside)); fl_inside(I_null) = 0;

   %integrate under surface
   vol = sum(trapz(em_flank,fl_inside)) .* (ex_flank(2)-ex_flank(1));

else

   clc
   disp(' '); disp(' ')
   disp('Too few arguments for function')
   disp(' '); disp(' ')

end

function [x,y] = circle(x0,y0,r,pts)
%syntax:  [x,y] = circle(x0,y0,r,pts)
%
%Generates coordinates for closed circular polygons of radius 'r'
%with origin coordinates specified by 'x0' and 'y0'.  Vectors of
%origin coordinates must be the same size, and 'r' must be a
%matching vector or scalar (i.e. specifies constant radius).
%
%The polygon will be composed of 'pts' pairs of coordinates with
%the first coordinate repeated at the end to close the polygon
%('pts' defaults to 20 if omitted).  Specify a number of points
%divisible by 4 to ensure that the coordinates [x0 y0+r] and
%[x0 y0-r] are included.
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
%last modified 5/8/1999

x = []; y = [];  %initialize output variables

if nargin >= 3

   if exist('pts') ~= 1  %use default value if 'pts' omitted
      pts = 20;
   else
      pts = ceil(pts./2).*2;  %round up 'pts' to even integer
   end

   %test for valid input dimensions
   if (length(x0) == length(y0)) & ...
      (length(r) == length(x0) | length(r) == 1)

      cols = length(x0);
      hemirows = pts./2+1;

      %transform vectors if necessary
      if size(x0,1) > 1
         x0 = x0';
      end

      if size(y0,1) > 1
         y0 = y0';
      end

      if size(r,1) > 1
         r = r';
      elseif size(r,2) == 1  %replicate scalar radius
         r = ones(1,cols) * r;
      end

      %initialize origin coordinate matrices
      x0 = ones(hemirows,1) * x0;
      y0 = ones(hemirows,1) * y0;

      %prebuild r^2 matrix to increase speed
      r_sq = ones(hemirows,1) * r.^2;

      %calculate top and bottom hemicircle X-coordinate matrices
      x_top = x0 + cos([pi:-pi./(pts./2):0]')*r;
      x_bot = flipud(x_top);

      %calculate top and bottom hemicircle Y-coordinate matrices
      y_top = y0 + real(sqrt(r_sq-(x_top-x0).^2));
      y_bot = y0 - real(sqrt(r_sq-(x_bot-x0).^2));

      %append hemispheres to form output matrices
      x = [x_top ; x_bot(2:size(x_bot,1),:)];
      y = [y_top ; y_bot(2:size(y_bot,1),:)];

   else  %input array mismatch

      disp(' ')
      disp('Input arrays must be the same size!')
      disp(' ')

   end

else  %insufficient arguments

   disp(' ')
   disp('Too few arguments for function!')
   disp(' ')

end

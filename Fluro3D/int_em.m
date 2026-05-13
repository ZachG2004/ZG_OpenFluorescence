function integrals = int_em(eem,ex_array,extrap,showplot)
%syntax:  integrals = int_em(eem,ex_array,extrap,showplot)
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

integrals = [];

if nargin >= 2

   if exist('extrap') ~= 1
      extrap = [];
   elseif length(extrap) == 1
      extrap = repmat(extrap,1,length(ex_array));
   end

   if exist('showplot') ~= 1
      showplot = 0;
   end

   if size(ex_array,2) > 1
      ex_array = ex_array';
   end

   [i,j] = find(repmat(eem(1,:),length(ex_array),1) == repmat(ex_array,1,size(eem,2)));

   if ~isempty(j)

      data = eem(2:size(eem,1),[1 j']);

      if ~isempty(extrap)

         extrapdata = [max(data(:,1))+1:700]';
         extrapdata = [extrapdata zeros(length(extrapdata),size(data,2)-1)];

         for n = 2:size(data,2)
            parms = polyfit(data(size(data,1)-extrap(n-1):size(data,1),1), ...
               data(size(data,1)-extrap(n-1):size(data,1),n),1);
            extrapdata(:,n) = nonneg(polyval(parms,extrapdata(:,1)));
         end

         data = [data ; extrapdata];

      end

      integrals = trapz(data(:,1),data(:,2:size(data,2)));

      if showplot > 0

         plot(data(:,1),data(:,2),'k-')

         hold on
         for n = 3:size(data,2)
            plot(data(:,1),data(:,n),'k-')
         end
         hold off

         ax = axis;
         axis([ax(1:3) ceil(max(max(data(:,2:size(data,2)))))]);

      end

   else

      data = [];

   end



end

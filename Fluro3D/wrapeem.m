function [eemdata,errormsg] = wrapeem(ex,em,fl,fl_id)
%syntax:  [eemdata,errormsg] = wrapeem(ex,em,fl,fl_id)
%
%Concatenates vectors of excitation and emission wavelengths and
%corresponding fluorescence intensity matrix to produce a self-
%contained matrix of EEM data.
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
%last modified 6/11/2004

eemdata = [];
errormsg = '';
cancel = 0;

if nargin >= 3

   ex_size = size(ex);
   em_size = size(em);
   fl_size = size(fl);

   %validate input
   if min(ex_size) > 1 | min(em_size) > 1  %confirm vector format

      cancel = 1;
      errormsg = '''ex'' and ''em'' must be vectors';

   elseif prod(fl_size) ~= (prod(ex_size) .* prod(em_size))  %test for mismatch

      cancel = 1;
      errormsg = 'matrix dimensions do not match';

   else

      %test for nulls in ex/em
      if length(find(isnan(ex))) > 0 | length(find(isnan(em))) > 0

         I_ex = find(~isnan(ex));
         ex = ex(I_ex);

         I_em = find(~isnan(em));
         em = em(I_em);

         fl = fl(I_em,I_ex);

      end

      %check for nonmonotonic vectors
      ex_inc = ex(2:length(ex))-ex(1:length(ex)-1);
      I_ex = find(ex_inc <= 0);

      em_inc = em(2:length(em))-em(1:length(em)-1);
      I_em = find(em_inc <= 0);

      if ~isempty(I_ex) | ~isempty(I_em)

         cancel = 1;
         errormsg = '''ex'' and ''em'' must be monotonically increasing vectors';

      else  %test for vector orientation

         if ex_size(1) > ex_size(2)
            ex = ex';
         end

         if em_size(2) > em_size(1)
            em = em';
         end

      end

   end

   if cancel == 0

      %use default ID label if none specified
      if exist('fl_id') ~= 1
         fl_id = NaN;
      end

      %initialize zero matrix
      eemdata = zeros(length(em)+1,length(ex)+1);

      %assign values
      eemdata(1,1) = fl_id;
      eemdata(1,2:size(eemdata,2)) = ex;
      eemdata(2:size(eemdata,1),1) = em;
      eemdata(2:size(eemdata,1),2:size(eemdata,2)) = fl;

   end

else

   cancel = 1;
   errormsg = 'Too few arguments for function';

end

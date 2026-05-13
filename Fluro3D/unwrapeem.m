function [ex,em,fl,fl_id,errormsg] = unwrapeem(eemdata)
%syntax:  [ex,em,fl,fl_id,errormsg] = unwrapeem(eemdata)
%
%Parses a consolidated matrix of EEM data and returns vectors of
%excitation wavelengths ('ex') and emission wavelengths ('em'), and
%a matrix of fluorescence intensity values ('fl').  Any data in
%eemdata(1,1) is returned as 'fl_id'.
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

ex = [];
em = [];
fl = [];
fl_id = [];
errormsg = '';

cancel = 0;

if nargin > 0

   %validate input
   if size(eemdata,1) < 2 | size(eemdata,2) < 2

      cancel = 1;
      errormsg = 'Input matrix is invalid';

   else

      ex = eemdata(1,2:size(eemdata,2));
      em = eemdata(2:size(eemdata,1),1);
      fl = eemdata(2:size(eemdata,1),2:size(eemdata,2));
      fl_id = eemdata(1,1);

      ex_inc = ex(2:length(ex))-ex(1:length(ex)-1);
      I_ex = find(ex_inc <= 0);

      em_inc = em(2:length(em))-em(1:length(em)-1);
      I_em = find(em_inc <= 0);

      if ~isempty(I_ex) | ~isempty(I_em)  %check for nonmonotonic vectors

         cancel = 1;
         errormsg = 'Input matrix is invalid';

         ex = [];
         em = [];
         fl = [];
         fl_id = [];

      end

   end

else

   cancel = 1;
   errormsg = 'Too few arguments for function';

end

function newcalset(setname,setdate,copyset)
%syntax: newcalset(setname,setdate,copyset)
%
%Adds an calibration set for use with the Fluorescence Toolbox
%(note: the prior version of 'calibration.mat' is backed up as
%'old_calibration.mat')
%
%'setname' is a string to use to name the calibration set (required)
%'setdate' is the date to associate with the set (default = current date)
%'copyset' is the number of the calibration set to copy as a template
%    (default = last set)
%
%(c)2001 by Wade Sheldon
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
%last modified 2-Oct-2001

msg = '';
curpath = pwd;
fn = 'calibration.mat';
pn = pwd;

if nargin >= 1

   if ~exist('setdate')
      setdate = datestr(now,1);
   end

   if ~exist('copyset')
      copyset = [];
   end

   d = dir(fn);

   if length(d) == 0
      [fn,pn] = uigetfile(fn,'Locate the Fluorescence Toolbox calibration file');
   end

   if fn ~= 0

      cd(pn)
      load(fn)

      if exist('calsets') == 1 & exist('scattertol') == 1

         save old_calibration.mat calsets scattertol  %backup latest file

         num = length(calsets);

         if isempty(copyset)
            copyset = num;
         else
            copyset = max(1,min(copyset,num));
         end

         calsets(num+1) = calsets(copyset);

         calsets(num+1).name = setname;
         calsets(num+1).date = setdate;

         save calibration.mat calsets scattertol

         msg = 'new calibration set added, and original sets backed up as ''old_calibration.mat''';

      else

         msg = 'invalid calibration file';

      end

      cd(curpath)

   end

else

   msg = '''setname'' argument was not specified';

end

disp(' '); disp(msg); disp(' ')
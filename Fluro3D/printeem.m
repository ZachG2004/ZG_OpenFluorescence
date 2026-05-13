function printeem(formfact)
%syntax:  printeem(formfactor)
%
%Print function called by 'eemplot', which sets options for
%optimal EEM printing using Matlab's color Windows drivers.
%The 'painters' algorithm will be used unless the plot contains
%elements with interpolated colors, in which case 'zbuffer' will
%be used (300 dpi resolution).
%
%Valid formfactor strings are:
%   'fullport' for full page, portrait
%   'topport' for half page, top
%   'botport' for half page, bottom
%   'clipboard' for copying to the Windows clipboard in metafile format
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
%last modified 6/15/1999

initpos = get(gcf,'PaperPosition');
inittype = get(gcf,'PaperType');
initorient = get(gcf,'PaperOrientation');
dev = '-dwinc -v';

if strcmp(formfact,'fullport')

   pos = [-.6 1.5 9 8];
   newtype = 'usletter';
   neworient = 'portrait';

elseif strcmp(formfact,'topport')

   pos = [0 5.25 7.5 5.25];
   newtype = 'usletter';
   neworient = 'portrait';

elseif strcmp(formfact,'bottomport')

   pos = [0 .25 7.5 5.25];
   newtype = 'usletter';
   neworient = 'portrait';

elseif strcmp(formfact,'clipboard')

   pos = [.25 1.25 8 7.5];
   newtype = 'usletter';
   neworient = 'portrait';
   dev = '-dmeta';

else

   newtype = [];
   pos = [];
   neworient = [];

end

if ~isempty(newtype)

   h_s = findobj(gcf,'Type','surface');
   if ~isempty(h_s)
      rend = '-zbuffer -r300 ';
   else
      rend = '-painters ';
   end

   set(gcf, ...
      'PaperType',newtype, ...
      'PaperOrientation',neworient, ...
      'PaperPosition',pos)

   eval(['print -noui ' rend dev])

   set(gcf, ...
      'PaperType',inittype, ...
      'PaperOrientation',initorient, ...
      'PaperPosition',initpos)

end


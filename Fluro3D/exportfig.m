function exportfig(operation)
%Syntax:  exportfig(operation)
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
%last modified 2/27/2007

global EEMLOADPATH EEMSAVEPATH

curpath = pwd;
h = gcf;

if ~isempty(EEMSAVEPATH)
   lastpath = EEMSAVEPATH;
elseif ~isempty(EEMLOADPATH)
   lastpath = EEMLOADPATH;
else
   lastpath = curpath;
end

switch operation

case 'psbw',
   opt = ' -dps2 -loose -noui';
   spec = '*.ps';

case 'psc',
   opt = ' -dpsc2 -loose -noui';
   spec = '*.ps';

case 'epsbw2',
   opt = ' -deps2 -tiff -loose -noui';
   spec = '*.eps';

case 'epsc2',
   opt = ' -depsc2 -tiff -loose -noui';
   spec = '*.eps';

case 'epsbw1',
   opt = ' -deps -tiff -loose -noui';
   spec = '*.eps';

case 'epsc1',
   opt = ' -depsc -tiff -loose -noui';
   spec = '*.eps';

case 'epsc2',
   opt = ' -dps -tiff -loose -noui';
   spec = '*.ps';

case 'jpeghigh',
   opt = ' -djpeg90 -r300 -noui';
   spec = '*.jpg';

case 'jpegmed',
   opt = ' -djpeg90 -noui';
   spec = '*.jpg';

case 'jpeglow',
   opt = ' -djpeg90 -r72 -noui';
   spec = '*.jpg';

case 'tiffhc',
   opt = ' -dtiff -r300 -noui';
   spec = '*.tif';

case 'tiffhnc',
   opt = ' -dtiffnocompression -r300 -noui';
   spec = '*.tif';

case 'tiffmc',
   opt = ' -dtiff -r150 -noui';
   spec = '*.tif';

case 'tiffmnc',
   opt = ' -dtiffnocompression -r150 -noui';
   spec = '*.tif';

otherwise
   opt = ' -dmfile -noui';
   spec = '*.fit';

end

cd(lastpath);

[filename,pathname] = uiputfile(spec,'Choose a name and directory for the Postscript file');

if filename ~= 0

   figure(h)

   cd(pathname)
   eval(['print ''',filename,'''',opt]);

   EEMSAVEPATH = pathname;

end

cd(curpath);

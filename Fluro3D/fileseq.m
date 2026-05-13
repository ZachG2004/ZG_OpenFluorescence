function [f_files,f_nums,f_base,f_path] = fileseq(f_input,f_path)
%syntax:  [f_files,f_nums,f_base,f_path] = fileseq(f_input,f_path)
%
%Assembles of sorted list of filenames and numerical suffixes for a
%sequence of Datamax export ASCII files.
%
%'f_input' is a filename from the sequence to be analyzed; if omitted
%   it is obtained using a file load dialog box.
%
%'f_path' is the pathname containing the sequence; if omitted the
%   assumed to be the working if 'f_input' is provided, otherwise
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

error = 0;
curpath = pwd;

%initialize outputs
f_files = '';
f_nums = [];

%set default filespec for file dialog
filespec = '*.prn';

if exist('f_path','var') ~= 1
   f_path = curpath;
elseif exist(f_path,'dir') ~= 7
   f_path = curpath;
elseif strcmp(f_path(end),filesep)
   f_path = f_path(1:end-1);  %strip terminal file separator
end

%validate filename
if exist('f_input','var') == 1
   if exist([f_path,filesep,f_input],'file') ~= 2  %check for filename in search path
      filespec = f_input;  %set default filename for dialog to match file if not found
      f_input = '';
   end
else
   f_input = '';
end

if isempty(f_input)  %prompt for a filename in the sequence if not provided

   cd(f_path)
   [f_input,f_path] = uigetfile(filespec,'Select a file in the sequence to import');
   cd(curpath)

   if f_input == 0
      error = 1;
   else  %update working directory to new path
      cd(f_path)
   end

end

if error == 0  %process filename, produce file list

   [path,f_name,f_ext] = fileparts(f_input);  %dissect filename

   %reverse filename (minus extension) and count numerical values at end
   f_rev = fliplr(f_name);
   cnt = 1;
   while ~isnan(str2double(f_rev(1,cnt)))
      cnt = cnt + 1;
   end

   f_base = fliplr(f_rev(1,cnt:length(f_rev)));  %form base filename

   d = dir([f_path,filesep,f_base,'*',f_ext]);  %search for files in sequence using base, ext

   if length(d) > 0

      f_files = cell(length(d),1);  %initialize file list variable

      [f_files{:}] = deal(d.name);  %populate file list

      if length(d) > 1

         %generate matching list of numerical suffixes
         f_nums = str2double(strrep(strrep(upper(f_files),upper(f_base),''),upper(f_ext),''));

         if ~isempty(f_nums)  %sort output arrays if valid sequence found

            [temp,I] = sort(f_nums);
            f_nums = f_nums(I);
            f_files = f_files(I);

         else  %invalid sequence - clear output variables

            f_files = '';
            f_path = '';

         end

      elseif length(d) == 1

         f_nums = 1;

      end

   end

end
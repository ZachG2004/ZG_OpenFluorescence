function [em,fl,ex,ex_slit,em_slit] = parse_sp(fn,pn,instr)
%syntax: [em,fl,ex,ex_slit,em_slit] = parse_sp(fn,pn,instr)
%
%Parses a single Perkin-Elmer spectrum file and returns scan data
%
%Input:
%
%'fn' is filename of .sp file
%
%'pn' is pathname for fn
%
%'instr' is the instrument id (used for parsing the header fields)
%   (default = 'LS-50B')
%
%Output:
%
%'wavelen' is array of emission wavelengths
%
%'fl' is array of fluorescnece intensities
%
%'ex' is scalar excitation wavelength (from the file header)
%
%'ex_slit' is excitation slit size (from the file header)
%
%'em_slit' is emission slit size (from the file header)
%
%
%(c)2007 by Wade Sheldon
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
%last modified: 26-Feb-2007

em = [];
fl = [];
ex = [];
ex_slit = [];
em_slit = [];
curpath = pwd;

if exist('pn','var') ~= 1
   pn = '';
end
if isempty(pn)
   pn = curpath;
elseif exist(pn,'dir') ~= 7
   pn = curpath;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);
end

if exist('fn','var') ~= 1
   fn = '';
   filespec = '*.sp;*.SP';
elseif exist([pn,filesep,fn],'file') ~= 2
   filespec = fn;
   fn = '';
end

if isempty(fn)
   curpath = pwd;
   cd(pn)
   [fn,pn] = uigetfile(filespec,'Select a scan file to load');
   if fn == 0
      fn = '';
   end
   cd(curpath)
end

if ~isempty(fn)

   if exist('instr','var') ~= 1
      instr = 'LS-50B';
   end

   fid = fopen([pn,filesep,fn],'r');

   %parse header
   cnt = 0;
   hdr = 0;
   str = fgetl(fid);
   while ~isnumeric(str)
      cnt = cnt + 1;
      str = deblank(str);
      if strcmp(str,'#DATA')  %check for data section
         hdr = cnt + 3;  %calculate number of header lines
         break
      elseif strcmp(str,instr)  %check for instrument id string
         str = fgetl(fid);  %get next line
         ex = str2double(str); %parse excititation wavelength
         str = fgetl(fid);  %get next line
         ex_slit = str2double(str);  %parse excitation slit size
         str = fgetl(fid);  %get next line
         em_slit = str2double(str);  %parse emission slit size
      end
      str = fgetl(fid);
   end
   fclose(fid);

   try
      %parse data section into numeric arrays
      [em,fl] = textread([pn,filesep,fn],'%f %f','headerlines',hdr);
   catch
      em = [];
      fl = [];
   end

end
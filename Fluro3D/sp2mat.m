function [eem_raw,result] = sp2mat(firstfile,lastfile,pn)
%syntax:  [eem_raw,result] = sp2mat(firstfile,lastfile,path)
%
%Parses multiple Perkin-Elmer LS 50B fluorometer emission scan files and combines them into a single
%excitation/emission matrix for plotting and analysis.
%
%Input arguments are optional, but must be specified in order if used.  Any
%missing arguments will be obtained by prompted user input.
%
%Input arguments:
%
%'firstfile' is the first data file in the sequentially-numbered sequence
%   (e.g. 'data1.sp').
%
%'lastfile' is the last data file in the sequentially-numbered sequence
%   (e.g. 'data53.sp').
%
%'path' is the directory containing the split ASCII data files (e.g.
%   'c:\specdata').  If 'path' is omitted, the current directory is assumed.
%
%Output:
%
%'eem_raw' is a matrix of EEM data, with excitation wavelengths in
%      the first row, emission wavelengths in the first column, and
%      corresponding fluorescence intensity values for each ex/em
%      wavelength combination.
%
%'result' is a string message reporting the results of the operation
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
%last modified: 21-Mar-2007

eem_raw = [];
result = 'Files processed successfully';
curpath = pwd;

if exist('pn','var') ~= 1
   pn = curpath;
elseif exist(pn,'dir') ~= 7
   pn = curpath;
elseif strcmp(pn(end),filesep)
   pn = pn(1:end-1);
end

if exist('firstfile','var') ~= 1
   firstfile = '';
   filespec1 = '*.sp;*.SP';
elseif exist([pn,filesep,firstfile],'file') ~= 2
   filspec1 = firstfile;
   firstfile = '';
end

if exist('lastfile','var') ~= 1
   lastfile = '';
   filespec2 = '*.sp;*.SP';
elseif exist([pn,filesep,lastfile],'file') ~= 2
   filspec2 = lastfile;
   lastfile = '';
end

if isempty(firstfile)
   cd(pn)
   [firstfile,pn] = uigetfile(filespec1,'Select the first scan file to load');
   if firstfile == 0
      firstfile = '';
   end
   cd(curpath)
end

if isempty(lastfile)
   cd(pn)
   [firstfile,pn] = uigetfile(filespec2,'Select the last scan file to load');
   if lastfile == 0
      lastfile = '';
   end
   cd(curpath)
end

if ~isempty(firstfile) & ~isempty(lastfile)

   %parse filenames, numerical suffixes, and extensions
   [tmp,basefile1,ext1] = fileparts(upper(firstfile));

   numdig1 = 0;
   for count = length(basefile1):-1:1
      testdigit = str2double(basefile1(1,count));
      if ~isnan(testdigit)
         numdig1 = numdig1 + 1;
      else
         break
      end
   end

   fnbase1 = basefile1(1:end-numdig1);
   scannum1 = str2num(basefile1(1,count+1:length(basefile1)));
   basefile1 = basefile1(1,1:count);

   [tmp,basefile2,ext2] = fileparts(upper(lastfile));

   numdig2 = 0;
   for count = length(basefile2):-1:1
      testdigit = str2double(basefile2(1,count));
      if ~isnan(testdigit)
         numdig2 = numdig2 + 1;
      else
         break
      end
   end

   fnbase2 = basefile2(1:end-numdig2);
   scannum2 = str2num(basefile2(1,count+1:length(basefile2)));
   basefile2 = basefile2(1,1:count);

   %validate base filenames, index numbers and extensions
   cancel = 0;
   if strcmp(basefile1,basefile2) ~= 1
      cancel = 1;
      result = 'Error - files must all have the same base filename!';
   elseif strcmp(ext1,ext2) ~= 1
      cancel = 1;
      result = 'Error - files must all have the same extension!';
   elseif isempty(scannum1) | isempty(scannum2)
      cancel = 1;
      result = 'Error - files must have numerical filename suffixes!';
   elseif numdig1 ~= numdig2
      cancel = 1;
      result = 'Error - numerical file suffixes must have consistent numbers of digits!';
   elseif ~strcmp(fnbase1,fnbase2)
      cancel = 1;
      result = 'Error - base filenames must be consistent!';
   elseif scannum2 < scannum1  %file order reversed
      temp = scannum1;
      scannum1 = scannum2;
      scannum2 = temp;
   end

   if cancel == 0

      %parse first file
      [em0,fl0,ex0] = parse_sp(firstfile,pn);

      if ~isempty(em0)

         %init eem
         eem_raw = [NaN,ex0;em0,fl0];

         %loop through remaining files
         for cnt = scannum1+1:scannum2
            fn = [fnbase1,sprintf(['%0',int2str(numdig1),'d'],cnt),ext1];
            if exist([pn,filesep,fn],'file') == 2
               [em,fl,ex] = parse_sp(fn,pn);
               if ~isempty(em)
                  if length(em) == length(em0)
                     if sum(em~=em0) == 0
                        eem_raw = [eem_raw , [ex ; fl]];
                     else
                        eem_raw = [];
                        result = ['Error - emission wavelengths in ''',fn,''' are different'];
                        break
                     end
                  else
                     eem_raw = [];
                     result = ['Error - emission wavelength range in ''',fn,''' is different'];
                     break
                  end
               else
                  eem_raw = [];
                  result = ['Error - ''',fn,''' could not be parsed'];
                  break
               end
            else
               eem_raw = [];
               result = ['Error - intermediate file ''',fn,''' does not exist!'];
               break
            end
         end

      end

   end

else
   result = 'No scan files were imported';
end
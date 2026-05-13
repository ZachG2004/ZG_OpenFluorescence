function [eem_raw,result] = prn2mat(wavestart,waveend,waveint,firstfile,lastfile,workpath)
%syntax:  [eem_raw,result] = prn2mat(wavestart,waveend,waveint, ...
%             firstfile,lastfile,path)
%
%Parses multiple fluorometer emission scan files and combines them into a single
%excitation/emission matrix for plotting and analysis.
%
%Input arguments are optional, but must be specified in order if used.  Any
%missing arguments will be obtained by prompted user input.
%
%Input arguments:
%
%'wavestart' is the starting excitation wavelength.
%
%'waveend' is the ending excitation wavelength.
%
%'waveinnt' is the excitation wavelength interval.
%
%'firstfile' is the first data file in the sequentially-numbered sequence
%   (e.g. 'data_1.prn').
%
%'lastfile' is the last data file in the sequentially-numbered sequence
%   (e.g. 'data_41.prn').
%
%'path' is the directory containing the split ASCII data files (e.g.
%   'c:\specdata').  If 'path' is omitted, the current directory is assumed.
%
%'eem_raw' is a matrix of EEM data, with excitation wavelengths in
%      the first row, emission wavelengths in the first column, and
%      corresponding fluorescence intensity values for each ex/em
%      wavelength combination.
%
%'result' is a string message reporting the results of the operation
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

%initialize variables
curpath = pwd;
cancel = 0;
eem_raw = [];
result = 'Files processed successfully';

%use current directory as default path if not specified
if exist('workpath') ~= 1
   workpath = curpath;
else
   try
      cd(workpath)
   catch
      cancel = 1;
      result = 'Error! Invalid pathname';
   end
end

if nargin < 5 & cancel == 0  %identify and prompt for missing arguments

   clc; disp(' ')

   if exist('wavestart') ~= 1
      wavestart = str2num(input('Enter starting excitation wavelength: ','s'));
   end

   if exist('waveend') ~= 1
      waveend = str2num(input('Enter ending excitation wavelength: ','s'));
   end

   if exist('waveint') ~= 1
      waveint = str2num(input('Enter wavelength interval: ','s'));
   end

   clc;

   if exist('firstfile') ~= 1

      [firstfile,path1] = uigetfile('*.prn','Select first scan file in series');

      if firstfile == 0
         cancel = 1;
      end

   else

      path1 = [pwd filesp];

   end

   if cancel == 0  %prompt for last input filename

      if exist('lastfile') ~= 1

         cd(path1)

         [lastfile,path2]= uigetfile('*.prn','Select last scan file in series');

         if lastfile == 0
            cancel = 1;
            result = 'Function cancelled from file dialog box';
         elseif strcmp(upper(path1),upper(path2)) ~= 1
            cancel = 1;
            result = 'Error - files cannot span multiple directories!';
         else
            workpath = path1;
         end

      else

         workpath = curpath;

      end

   end

else  %validate filename arguments

   if exist(firstfile)~=2 | exist(lastfile)~=2
      cancel = 1;
      result = 'Error - invalid input filename!';
   end

end

if cancel == 0  %validate wavelength parameters

   waverng = waveend-wavestart;

   if isstr(wavestart) | isstr(waveend) | isstr(waveint)
      cancel = 1;
      result = 'Error - one or more parameters invalid!';
   elseif wavestart > waveend
      cancel = 1;
      result = 'Error - invalid starting and ending wavelengths!';
   elseif (wavestart~=waveend) & (waverng - waveint.*round(waverng./waveint)) > 1e-6
      cancel = 1;
      result = 'Error - wavelength intervals must be uniform!';
   end

end

if cancel == 0  %process filenames

   %parse filenames, numerical suffixes, and extensions
   [basefile1,ext1] = strtok(upper(firstfile),'.');

   for count = length(basefile1):-1:1
      testdigit = str2num(basefile1(1,count));
      if isempty(testdigit)
         break
      end
   end

   scannum1 = str2num(basefile1(1,count+1:length(basefile1)));
   basefile1 = basefile1(1,1:count);

   [basefile2,ext2] = strtok(upper(lastfile),'.');

   for count = length(basefile2):-1:1
      testdigit = str2num(basefile2(1,count));
      if isempty(testdigit)
         break
      end
   end

   scannum2 = str2num(basefile2(1,count+1:length(basefile2)));
   basefile2 = basefile2(1,1:count);

   %validate base filenames, index numbers and extensions
   if strcmp(basefile1,basefile2) ~= 1
      cancel = 1;
      result = 'Error - files must all have the same base filename!';
   elseif strcmp(ext1,ext2) ~= 1
      cancel = 1;
      result = 'Error - files must all have the same extension!';
   elseif isempty(scannum1) | isempty(scannum2)
      cancel = 1;
      result = 'Error - files must have numerical filename suffixes!';
   elseif scannum2 < scannum1  %file order reversed
      temp = scannum1;
      scannum1 = scannum2;
      scannum2 = temp;
   end

   %validate number of files against wavelength parameters
   if cancel == 0
      numints = round((waveend-wavestart)./waveint + 1);
      if (scannum2 - scannum1 + 1) ~= numints
         cancel = 1;
         result = 'Error - number of files must equal number of wavelength intervals!';
      end
   end

end

if cancel == 0  %load and process files

   error = 0;

   ex_wavelen = linspace(wavestart,waveend,numints);

   filenums = [scannum1:scannum2];

   mlversion = version;
   try
      cd(workpath)
      if strcmp(mlversion(1),'5')
         newscan = load([basefile1,int2str(filenums(1)),ext1],'-ASCII');
      else
         newscan = dlmread([basefile1,int2str(filenums(1)),ext1]);
      end
   catch
      error = 1;
   end

   if error == 0

      %extract emission wavelengths from first scan
      em_wavelen = newscan(:,1);

      %initialize output matrix to NaN
      numrows = length(em_wavelen) + 1;
      numcols = length(ex_wavelen) + 1;
      eem_raw = ones(numrows,numcols) .* NaN;

      %assign em/ex wavelengths to left/top boundaries
      eem_raw(1,2:numcols) = ex_wavelen;
      eem_raw(2:numrows,1:2) = newscan;

      %load remaining scan files
      for n=2:length(filenums)

         error = 0;  %reset error flag
         mlversion = version;

         try
            if strcmp(mlversion(1),'5')
               newscan = load([basefile1,int2str(filenums(n)),ext1],'-ASCII');
            else
               newscan = dlmread([basefile1,int2str(filenums(n)),ext1]);
            end
         catch
            error = 1;
         end

         %test for conformity of new data
         if error == 0
            if size(newscan,1) ~= (numrows - 1)
               error = 1;
            elseif sum(newscan(:,1) ~= em_wavelen) > 0
               error = 1;
            end
         end

         %incorporate scan data if no errors detected, otherwise leave as NaN
         if error == 0
            eem_raw(2:numrows,n+1) = newscan(:,2);
         end

      end

      %save default eem file based on base filename
      %save([basefile1,'xx.mat'],'eem_raw')

      badcols = find(isnan(eem_raw(2,:)));

      if ~isempty(badcols)
         result = ['Warning - ' int2str(length(badcols)) ...
               ' scan file(s) were corrupt or missing!'];
      end

   else  %first file load failed

      cancel = 1;
      result = 'Error - invalid file format!';

   end

end

cd(curpath)
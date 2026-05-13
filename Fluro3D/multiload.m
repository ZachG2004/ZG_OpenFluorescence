function multiload(initfile,pathname)
%syntax:  multiload(initfile,pathname)
%
%Loads multiple EEM plots selected from a list box dialog
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

global EEMLOADPATH
curpath = pwd;
cancel = 0;
error = 0;

if nargin == 0

   if ~isempty(EEMLOADPATH)
      cd(EEMLOADPATH)
   end

   [initfile,pathname] = uigetfile('*.plt','Select Initial EEM file to load');

   cd(curpath)

   if initfile == 0
      cancel = 1;
   else
      EEMLOADPATH = pathname;
   end

elseif exist('pathname') ~= 1

   pathname = pwd;

end

if cancel == 0  %check for cancel

   cd(pathname)

   if exist(initfile) == 2

      d = dir('*.plt');
      validfiles = zeros(1,length(d));

      if size(d,1) > 0

         filelist = {d.name};

         for n = 1:size(filelist,2)
            if ~isempty(who('-file',char(filelist{n}),'save_cdata'))
               validfiles(n) = 1;
               if strcmp(char(filelist{n}),initfile) == 1
                  sel = n;
               end
            end
         end

         I = find(validfiles);

         if ~isempty(I)

            [x,I_s] = sortrows(upper(char(filelist{I})));

            filelist = {filelist{I(I_s)}};
            sel = find(I(I_s) == sel);

            screenres = get(0,'ScreenSize');

            sel = listdialog('Name','Select EEMs', ...
               'PromptString','Select one or more EEMS to display', ...
               'ListString',filelist, ...
               'InitialValue',sel, ...
               'ListSize',[350 min(screenres(4)*.6,140+10*length(I))], ...
               'OKString','Plot EEMs', ...
               'CancelString','Cancel');

            if ~isempty(sel)

               drawnow

               for n = 1:length(sel)
                  loadscan('newfig',char(filelist{sel(n)}));
               end

               drawnow

            end

         else

            error = 1;

         end

      else

         error = 1;

      end


   end

   cd(curpath)

   if error == 1

      messagebox('init','No valid EEM plots in selected directory')

   end

end

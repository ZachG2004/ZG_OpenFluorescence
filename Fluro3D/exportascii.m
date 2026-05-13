function exportascii(eem,op)
%syntax:  exportascii(eem,format)
%
%Exports the EEM matrix specified by 'eem' as a tab-delimitted ASCII file
%in the format specified by 'format' ('matrix' or 'xyz')
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

if nargin == 0  %get 'eem' from active plot
   eem = [];
end

if isempty(eem)

   if strcmp(get(gcf,'Tag'),'eemplotfig')  %surface plot

      h_s = findobj(gcf,'Type','surface');

      if ~isempty(h_s)
         eem = get(h_s,'UserData');
      else
         eem = [];
      end

   elseif strcmp(get(gcf,'Tag'),'exemplotfig')  %line plot

      eem = get(gcf,'UserData');

   end

   h_info = findobj(gcf,'Tag','eeminfo');  %get metadata

   if ~isempty(h_info)
      info = get(h_info,'UserData');
   else
      info = '';
   end

end

if ~exist('op')  %default to matrix format
   op = 'matrix';
end

if ~isempty(eem)

   curpath = pwd;

   global EEMLOADPATH EEMSAVEPATH

   if ~isempty(EEMSAVEPATH)
      lastpath = EEMSAVEPATH;
   elseif ~isempty(EEMLOADPATH)
      lastpath = EEMLOADPATH;
   else
      lastpath = curpath;
   end

   cd(lastpath)

   [fn,pn] = uiputfile('*.txt','Select filename and location');

   if fn ~= 0

      cd(pn)

      fid = fopen(fn,'wt');

      if length(info) > 1

         units = fliplr([strtok(fliplr(info{2}),'(') '(']);

         desc = info{1};

         fprintf(fid,'Description\t%s\r',deblank(desc(1,:)));
         for n = 2:size(desc,1)
            fprintf(fid,'\t%s\r',deblank(desc(n,:)));
         end

         fprintf(fid,'EEM type\t%s\r',info{2});
         fprintf(fid,'Scan date\t%s\r',info{3});
         fprintf(fid,'Excitation\t%s\r',info{4});
         fprintf(fid,'Emission\t%s\r',info{5});
         fprintf(fid,'Calibration\t%s\r',info{6});
         fprintf(fid,'Slit settings\t%s\r',info{7});
         fprintf(fid,'Dilution\t%s\r',info{8});

      else
         fprintf(fid,'Description\t%s\r','(no metadata available)');
         units = '';
      end

      switch op

      case('xyz')

         [ex,em] = meshgrid(eem(1,2:size(eem,2)),eem(2:size(eem,1),1));
         fl = eem(2:size(eem,1),2:size(eem,2));

         fprintf(fid,'\r%s\t%s\t%s\r', ...
            'Excitation(nm)','Emission(nm)',['Fluorescence' units]);
         fprintf(fid,'%0.1f\t%0.1f\t%0.5f\r',[ex(:) em(:) fl(:)]');

      otherwise

         fprintf(fid,'Row 1\t%s\rCol 1\t%s\rData\t%s\r\r', ...
            'Excitation(nm)','Emission(nm)',['Fluorescence' units]);
         fprintf(fid,'\t%0.1f',eem(1,2:size(eem,2)));

         for n = 2:size(eem,1)

            fprintf(fid,'\r%0.1f',eem(n,1));
            fprintf(fid,'\t%0.5f',eem(n,2:size(eem,2)));

         end

      end

      fclose(fid);

      EEMSAVEPATH = pn;

   end

   cd(curpath)

end

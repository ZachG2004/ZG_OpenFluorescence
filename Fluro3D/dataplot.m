function dataplot(type,eemstruct)
%syntax:  dataplot(type,eemstruct)
%
%Plots EEM or single excitation/emission scan data in fluorescence data file.
%If provided, 'eemstruct' must be a valid EEM structure as produced by
%'importscan'.
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

if nargin == 0
   type = 'surfnewfig';
end

error = 0;
cancel = 0;
errormsg = '';

if exist('eemstruct')  %data provided

   if isstruct(eemstruct)
      eem = eemstruct;
   else
      eem = [];
      error = 1;
      errormsg = 'Not a valid EEM variable';
   end

else  %query for filename

   curpath = pwd;
   global EEMLOADPATH EEMSAVEPATH

   if ~isempty(EEMLOADPATH)
      cd(EEMLOADPATH)
   elseif ~isempty(EEMSAVEPATH)
      cd(EEMSAVEPATH)
   end

   [fn,pn] = uigetfile('*.eem; *.plt','Select Fluorescence Data File to Plot');
   drawnow

   if fn ~= 0  %filename returned
      cd(pn)
      eval(['load ''' fn ''' -mat'],'error = 1;')
      EEMLOADPATH = pn;
      cd(curpath)
   else  %cancelled by user
      cancel = 1;
   end

end

if error == 0 & cancel == 0

   %initialize variables
   plotdata = [];
   plottype = '';
   caltype = '';
   plottitle = '';
   zlbl = 'Fluorescence';
   info = {'no information available'};

   %initialize lookup cell arrays
   str = [{'Raw Scan Data (cps)'} {'Scatter-corrected, Calibrated Data (ppb QSE)'} ...
         {'Dilution- & Scatter-corrected, Calibrated Data (ppb QSE)'}];
   zlblstr = [{'Fluorescence (cps)'} {'Fluorescence (QSE)'} {'Fluorescence (QSE)'}];

   if exist('eem') == 1  %check for structure variable

      %initialize specialized lookup arrays
      eemtypes = [~isempty(eem.raw) ~isempty(eem.corrected) ~isempty(eem.blanked)];
      lookupstr = [{'eem.raw'} {'eem.corrected'} {'eem.blanked'}];
      calstr = [{'none'} {eem.calibration} {eem.calibration}];

      I = find(eemtypes);

      if length(I) > 1  %prompt for variables to plot

         if length(findobj) > 1
            h = gcf;
            if strcmp(get(h,'Tag'),'dlgToolbox') ~= 1
               figpos = get(h,'Position');
               listpos = [max(10,figpos(1)+figpos(3)./2-175) max(50,figpos(2)+figpos(4)./2-70) ...
                     350 150];
            else
               listpos = [0 0 350 150];
            end
         else
            h = [];
            listpos = [0 0 350 150];
         end

         I_sel = listdialog('Name','Select Data', ...
            'SelectionMode','single', ...
            'ListString',str(I), ...
            'InitialValue',length(I), ...
            'PromptString','Select data to plot', ...
            'ListSize',listpos);

         if ~isempty(h)
            figure(h)
         end
          drawnow

         if isempty(I_sel)  %dialog cancelled by user
            cancel = 1;
         end

      elseif length(I) == 1

         I_sel = I;

      else  %no data to plot

         cancel = 1;

      end

      if cancel == 0

         plottitle = deblank(eem.description(1,:));
         eval(['plotdata = ' char(lookupstr(I_sel)) ';'])

         if isfield(eem,'type')
            eemtype = eem.type;
         else
            eemtype = 'data';
         end

         %assemble excitation/emission wavelength strings
         if size(eem.raw,2) > 2
            exstr = [num2str(eem.raw(1,2)) '-' num2str(eem.raw(1,size(eem.raw,2))) ...
               'nm by ' num2str(eem.raw(1,3)-eem.raw(1,2)) 'nm'];
         else
            exstr = [num2str(eem.raw(1,2)) 'nm'];
         end

         if size(eem.raw,1) > 2
            emstr = [num2str(eem.raw(2,1)) '-' num2str(eem.raw(size(eem.raw,1),1)) ...
               'nm by ' num2str(eem.raw(4,1)-eem.raw(3,1)) 'nm'];
         else
            emstr = [num2str(eem.raw(2,1)) 'nm'];
         end

         if strcmp(eemtype,'data')
            caltype = char(calstr(I_sel));
            plottype = char(str(I_sel));
            zlbl = char(zlblstr(I_sel));
            info = {[eem.description] ...
               [plottype] ...
               [eem.date] ...
               [exstr] ...
               [emstr] ...
               [caltype] ...
               [num2str(eem.slits(1)) 'nm Excitation, ' num2str(eem.slits(2)) 'nm Emission'] ...
               [num2str(eem.df)]};
         else
            zlbl = 'Fluorescence';
            info = {[eem.description] ...
               ['Calculated EEM'] ...
               [eem.date] ...
               [exstr] ...
               [emstr] ...
               ['N/A'] ...
               ['N/A'] ...
               ['N/A']};
         end

      end

   elseif exist('save_eemorig')  %check for plot file variable

      plotdata = save_eemorig;

      if isstruct(save_title)
         plottitle = save_title.String;
      else
         plottitle = save_title;
      end

      if isstruct(save_zlabel)
         zlbl = save_zlabel.String;
      else
         zlbl = save_zlabel;
      end

      if exist('save_eeminfo')
         if length(save_eeminfo) >= 7
            slitstr = save_eeminfo{7};
         else
            slitstr = 'not available';
         end
      else
         slitstr = '5nm Excitation, 5nm Emission';
      end

      info = {[plottitle] ...
            ['not available'] ...
            ['not available'] ...
            [num2str(plotdata(1,2)) '-' num2str(plotdata(1,size(plotdata,2))) 'nm by ' num2str(plotdata(1,4)-plotdata(1,3)) 'nm'] ...
            [num2str(plotdata(2,1)) '-' num2str(plotdata(size(plotdata,1),1)) 'nm by ' num2str(plotdata(4,1)-plotdata(3,1)) 'nm'] ...
            ['not available'] ...
            [slitstr] ...
            ['not available']};

   elseif exist('eem_raw')  %check for outdated EEM data file variable

      eemtypes = [exist('eem_raw') exist('eem_cor') exist('eem_corblkdil')];
      lookupstr = [{'eem_raw'} {'eem_cor'} {'eem_corblkdil'}];

      I = find(eemtypes);

      if length(I) > 1

         if length(findobj) > 1
            h = gcf;
            if strcmp(get(h,'Tag'),'dlgToolbox') ~= 1
               figpos = get(h,'Position');
               listpos = [max(10,figpos(1)+figpos(3)./2-175) max(50,figpos(2)+figpos(4)./2-70) ...
                     350 150];
            else
               listpos = [0 0 350 150];
            end
         else
            h = [];
            listpos = [0 0 350 150];
         end

         I_sel = listdialog('Name','Select Data', ...
            'SelectionMode','single', ...
            'ListString',str(I), ...
            'InitialValue',length(I), ...
            'PromptString','Select data to plot', ...
            'ListSize',listpos);

         if ~isempty(h)
            figure(h)
         end

         drawnow

         if isempty(I_sel)

            cancel = 1;

         end

      elseif length(I) == 1

         I_sel = I;

      else  %no data to plot

         cancel = 1;

      end

      if cancel == 0

         plottitle = ['Data in ' fn];
         plottype = char(str(I_sel));
         zlbl = char(zlblstr(I_sel));
         eval(['plotdata = ' char(lookupstr(I_sel)) ';'])
         if exist('df')
            dfstr = num2str(df);
         else
            dfstr = 'not available';
         end

         info = {[plottitle] ...
               [plottype] ...
               ['not available'] ...
               [num2str(plotdata(1,2)) '-' num2str(plotdata(1,size(plotdata,2))) 'nm by ' num2str(plotdata(1,4)-plotdata(1,3)) 'nm'] ...
               [num2str(plotdata(2,1)) '-' num2str(plotdata(size(plotdata,1),1)) 'nm by ' num2str(plotdata(4,1)-plotdata(3,1)) 'nm'] ...
               ['not available'] ...
               ['5nm Excitation, 5nm Emission'] ...
               [dfstr]};

      end

   end

   if ~isempty(plotdata)

      switch type
      case 'line' %2d line plot

         exem_plot('em',plotdata,[],plottitle);

      case 'surfnewfig'  %3d surface plot as new figure

         eemplot('newfig',plotdata,0,plottitle,zlbl);

      case 'surfnewplot'  %3d surface plot in same figure

         eemplot('newplot',plotdata,0,plottitle,zlbl);

      case 'surfupdate'  %update existing 3d surface plot

         h_s = findobj(gcf,'Type','surface');

         if ~isempty(h_s)

            [ex,em,fl] = unwrapeem(plotdata);

            h_t = get(gca,'Title');
            set(h_t,'String',plottitle)

            set(h_s, ...
               'UserData',plotdata, ...
               'XData',ex, ...
               'YData',em, ...
               'ZData',fl, ...
               'CData',fl)

            clip3d('update',h_s);

         end

      end

      h_info = findobj(gcf,'Tag','eeminfo');
      if ~isempty(h_info)
         set(h_info,'UserData',info)
      end

   else  %invalid data file

      if cancel == 0  %check for dialog cancel

         errormsg = [fn ' is not a valid fluorescence data file'];

      end

   end

elseif cancel == 0  %invalid matlab file

   errormsg = [fn ' is not a valid Matlab file'];

end

if ~isempty(errormsg)

   errorbox('init',errormsg)

end

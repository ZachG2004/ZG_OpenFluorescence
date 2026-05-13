function importscan(op)
%EEM scan raw data import function
%
%Prompts for file and correction option information to import a set of
%ASCII export files from ISA's Datamax software and assemble raw and
%corrected EEM fluorescence scans.
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
   op = 'init';
end

if strcmp(op,'init')  %create/activate dialog

   if length(findobj) > 1
      h_fig = gcf;
   else
      h_fig = [];
   end

   h_dlg = findobj('Tag','dlgImportScan');  %check for prior instance

   if ~isempty(h_dlg)  %if dialog already open - update stored data and activate

      storedvals = get(h_dlg,'UserData');
      storedvals{1} = h_fig;
      set(h_dlg,'UserData',storedvals)

      figure(h_dlg)

      importscan('newscan')

   else  %new dialog

      loaderror = 0;
      try
         load('calibration.mat');
      catch
         loaderror = 1;
      end

      if loaderror == 1  %cancel dialog

         errorbox('init',['Cannot open dialog - calibration file ''calibration.mat''' ...
               'could not be loaded'])

      else  %create dialog box

         calsetnum = length(calsets);

         correctstr = ['[' num2str(scattertol(1,1)) ' ' num2str(scattertol(1,2)) ';' ...
               num2str(scattertol(2,1)) ' ' num2str(scattertol(2,2)) ';' ...
               num2str(scattertol(3,1)) ' ' num2str(scattertol(3,2)) ';' ...
               num2str(scattertol(4,1)) ' ' num2str(scattertol(4,2)) ']'];

         calsetstr = [char(calsets.date) repmat(' -- ',calsetnum,1) char(calsets.name)];

         ramanstr = ['Raman Peak (Ex' num2str(calsets(calsetnum).ramanwave(1)) ...
               '/Em' num2str(calsets(calsetnum).ramanwave(2)) ')'];

         slits = calsets(calsetnum).qsparms(1:2,:)';

         I = find(slits(:,1)==5 & slits(:,2)==5);
         if ~isempty(I)
            slitval = I(1);
         else
            slitval = size(slits,1);
         end

         slitstr = [num2str(slits(1,1)) 'nm Ex, ' num2str(slits(1,2)) 'nm Em Slits'];
         for n = 2:size(slits,1)
            slitstr = [slitstr '|' ...
                  num2str(slits(n,1)) 'nm Ex, ' num2str(slits(n,2)) 'nm Em Slits'];
         end

         screenres = get(0,'ScreenSize');

         h_dlg = figure('Visible','off', ...
            'Name','Import Scan', ...
            'Units','pixels', ...
            'Renderer','zbuffer', ...
            'Color',[0.88 0.88 0.88], ...
            'Position',[screenres(3)-370 50 360 510], ...
            'MenuBar','none', ...
            'NumberTitle','off', ...
            'KeyPressFcn','figure(gcf)', ...
            'Resize','off', ...
            'ToolBar','none', ...
            'Tag','dlgImportScan', ...
            'UserData',[{h_fig} {calsets} {scattertol}]);

         axis off

         bgcolor = [0.9 0.9 0.9];

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.8 .8 .8], ...
            'ForegroundColor',[.8 0 0], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[5 484 350 18], ...
            'String','Sample Scan');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'Position',[15 460 50 18], ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'String','First File');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 433 50 18], ...
            'String','Last File');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[65 460 250 22], ...
            'HorizontalAlignment','left', ...
            'Tag','editFirstFile', ...
            'UserData',cell(1,5), ...
            'Callback','importscan(''file1'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[65 433 250 22], ...
            'HorizontalAlignment','left', ...
            'Tag','editLastFile', ...
            'Callback','importscan(''file2'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 410 60 18], ...
            'String','Description');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[75 370 275 58], ...
            'Min',1, ...
            'Max',3, ...
            'HorizontalAlignment','left', ...
            'String','(default)', ...
            'Tag','editDesc', ...
            'Callback','importscan(''desc'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 340 120 18], ...
            'String','Starting Excitation (nm)');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 315 120 18], ...
            'String','Excitation Interval (nm)');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 290 120 18], ...
            'String','Ending Excitation (nm)');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[135 340 50 20], ...
            'HorizontalAlignment','left', ...
            'Tag','editWaveStart', ...
            'UserData',cell(1,3), ...
            'Callback','importscan(''wave1'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[135 315 50 20], ...
            'HorizontalAlignment','left', ...
            'Tag','editWaveInt', ...
            'CallBack','importscan(''wave2'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[135 290 50 20], ...
            'HorizontalAlignment','left', ...
            'Tag','editWaveEnd', ...
            'CallBack','importscan(''wave3'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','popup', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[210 345 140 22], ...
            'HorizontalAlignment','left', ...
            'String',slitstr, ...
            'Value',slitval, ...
            'UserData',slits, ...
            'Tag','popSlit');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','checkbox', ...
            'BackgroundColor',bgcolor, ...
            'Position',[210 324 120 18], ...
            'HorizontalAlignment','left', ...
            'String','Autofill Wavelengths', ...
            'Value',1, ...
            'Tag','checkAutoFill', ...
            'TooltipString','Fill in missing wavelengths or intervals automatically', ...
            'Callback','importscan(''autofill'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','checkbox', ...
            'BackgroundColor',bgcolor, ...
            'Position',[210 305 120 18], ...
            'HorizontalAlignment','left', ...
            'String','Save Automatically', ...
            'Value',1, ...
            'TooltipString','Save file as ''<basename>.eem'' after importing', ...
            'Tag','checkAutoSave');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','checkbox', ...
            'BackgroundColor',bgcolor, ...
            'Position',[210 285 120 18], ...
            'HorizontalAlignment','left', ...
            'String','Plot After Import', ...
            'TooltipString','Plot the imported data as a 3d surface or line', ...
            'Value',1, ...
            'Tag','checkAutoPlot');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.8 .8 .8], ...
            'ForegroundColor',[.8 0 0], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[5 247 350 18], ...
            'String','Diluent Scan');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 218 70 18], ...
            'String','Diluent EEM');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[85 218 228 22], ...
            'HorizontalAlignment','left', ...
            'String','none', ...
            'Tag','editDil', ...
            'UserData',[], ...
            'Callback','importscan(''diluent'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 189 150 18], ...
            'String','Dilution Factor (Vtot/Vsample)');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Enable','off', ...
            'String',1, ...
            'Position',[165 189 60 20], ...
            'HorizontalAlignment','left', ...
            'Tag','editDF', ...
            'Callback','importscan(''status'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.8 .8 .8], ...
            'ForegroundColor',[.8 0 0], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[5 148 350 18], ...
            'String','Correction Options');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 118 150 18], ...
            'Tag','txtRaman', ...
            'String',ramanstr);

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[165 117 85 22], ...
            'HorizontalAlignment','left', ...
            'Tag','editRaman', ...
            'UserData',calsets(calsetnum).ramanwave, ...
            'Callback','importscan(''raman'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 87 100 18], ...
            'String','Scatter Corrections', ...
            'Tag','txtScatter', ...
            'UserData',correctstr);

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'Enable','on', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[115 86 175 22], ...
            'String',correctstr, ...
            'HorizontalAlignment','left', ...
            'Tag','editScatter', ...
            'UserData',correctstr, ...
            'Callback','importscan(''scatter'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[297 86 50 22], ...
            'Enable','on', ...
            'String','Edit', ...
            'FontWeight','normal', ...
            'Tag','cmdScatter', ...
            'TooltipString','Edit scatter peak correction tolerances', ...
            'Callback',['scatterdlg(''init'',' correctstr ')']);

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 55 75 18], ...
            'String','Calibration Set');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','popupmenu', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[92 55 255 20], ...
            'String',calsetstr, ...
            'Tag','popCal', ...
            'Value',calsetnum, ...
            'CallBack','importscan(''calset'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Enable','off', ...
            'FontWeight','bold', ...
            'Position',[294 5 64 26], ...
            'String','Proceed', ...
            'Tag','cmdProceed', ...
            'Callback','importscan(''eval'')', ...
            'TooltipString','Import the files and create EEM');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontWeight','bold', ...
            'Position',[148 5 64 26], ...
            'String','Clear', ...
            'Tag','cmdNew', ...
            'Callback','importscan(''clear'')', ...
            'TooltipString','Clear fields');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontWeight','bold', ...
            'Position',[2 5 64 26], ...
            'String','Close', ...
            'Tag','cmdClose', ...
            'Callback',['confirmdlg(''init'',''Close the Import Scan Window?  ' ...
               '(data will not be saved)'',''importscan(''''close'''')'')'], ...
            'TooltipString','Close the dialog box');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Position',[322 462 28 20], ...
            'String','...', ...
            'Tag','cmdBrowseScan', ...
            'TooltipString','Browse for scan file', ...
            'CallBack','importscan(''browse_scan'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Position',[320 220 28 20], ...
            'String','...', ...
            'Tag','cmdBrowseDil', ...
            'TooltipString','Browse for diluent EEM file', ...
            'CallBack','importscan(''browse_dil'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Position',[258 119 28 20], ...
            'String','...', ...
            'Tag','cmdBrowseRaman', ...
            'TooltipString','Calculate Raman peak from scan file', ...
            'Callback','importscan(''browse_raman'')');

         set(h_dlg,'Visible','on')

      end

   end

else

   %get key handles
   h_dlg = findobj('Tag','dlgImportScan');

   h_file1 = findobj(h_dlg,'Tag','editFirstFile');
   h_file2 = findobj(h_dlg,'Tag','editLastFile');
   h_desc = findobj(h_dlg,'Tag','editDesc');

   h_wavestart = findobj(h_dlg,'Tag','editWaveStart');
   h_waveint = findobj(h_dlg,'Tag','editWaveInt');
   h_waveend = findobj(h_dlg,'Tag','editWaveEnd');

   h_autofill = findobj(h_dlg,'Tag','checkAutoFill');
   autofill = get(h_autofill,'Value');

   %get filename editbox values
   fn1 = deblank(get(h_file1,'String'));
   fn2 = deblank(get(h_file2,'String'));

   %get wavelength editbox values
   wavedata = get(h_wavestart,'UserData');
   wavestart = str2num(get(h_wavestart,'String'));
   waveint = str2num(get(h_waveint,'String'));
   waveend = str2num(get(h_waveend,'String'));

   %get stored file list data
   filedata = get(h_file1,'UserData');
   filelist = filedata{1};
   filenums = filedata{2};
   basename = filedata{3};
   fileindex = filedata{4};
   pathname = filedata{5};

   if strcmp(op,'close')  %close dialog box

      storedvals = get(h_dlg,'UserData');
      h_fig = storedvals{1};

      close(h_dlg)

      if ~isempty(h_fig)
         if length(findobj) > 2
            figure(h_fig)
         end
      end

      drawnow

   elseif strcmp(op(1,1:4),'file')  %handle filename editbox callbacks

      errormsg = '';

      if strcmp(op,'file1')  %evaluate first file edit box

         if ~isempty(fn1)

            fn1 = upper(fn1);
            set(h_file1,'String',fn1)

            curpath = pwd;
            pn = pwd;

            if length(dir(fn1)) == 0  %file not found in current directory - check cached path

               global EEMLOADPATH
               if ~isempty(EEMLOADPATH)
                  pn = EEMLOADPATH;
                  cd(EEMLOADPATH)
               end

               if length(dir(fn1)) == 0

                  [fn1,pn] = uigetfile(fn1,'Locate file in Datamax export sequence');

                  if fn1 == 0  %cancelled - clear edit box
                     fn1 = '';
                     set(h_file1,'String','','UserData',cell(1,5))
                  else
                     EEMLOADPATH = pn;
                  end

               end

               cd(curpath)

            end

            if ~isempty(fn1) & isempty(fn2)  %validate entered filename, autofill lastfile

               [f_files,f_nums,f_base,pn] = fileseq(fn1,pn);

               if length(f_files) > 0

                  set(h_file1, ...
                     'String',upper(char(f_files{f_nums(1)})), ...
                     'UserData',[{f_files} {f_nums} {f_base} {find(f_nums)} {pn}])

                  [tmp,fn_base1,ext] = fileparts(f_files{1});  %get ascii file extension

                  %set(h_desc,'String','(default)')

                  if length(f_files) > 1  %sequence of files

                     %read ex range, interval from PE LS 50B files
                     if strcmpi(ext,'.sp')
                        [em,fl,ex1,ex_slit,em_slit] = parse_sp(f_files{1},pn);
                        [em,fl,ex2] = parse_sp(f_files{end},pn);
                        ex_int = (ex2-ex1)./(length(f_files)-1);
                     else
                        ex1 = [];
                        ex2 = [];
                        ex_int = [];
                     end

                     set(h_file2, ...
                        'String',upper(char(f_files{length(f_files)})), ...
                        'Enable','on')

                     if strcmp(deblank(get(h_waveint,'String')),'N/A')
                        set(h_waveint,'String','','Enable','on')
                        set(h_waveend,'String','','Enable','on')
                        drawnow
                     else
                        set(h_waveint,'Enable','on')
                        set(h_waveend,'Enable','on')
                     end

                     if strcmpi(ext,'.sp')
                        set(h_wavestart,'String',num2str(ex1))
                        set(h_waveend,'String',num2str(ex2))
                        set(h_waveint,'String',num2str(ex_int))
                     elseif ~isempty(wavestart) & ~isempty(waveint)
                        set(h_waveend,'String','')
                        importscan('wave3')
                     end

                     missing = (f_nums(length(f_nums))-f_nums(1)+1) - length(f_files);
                     if missing > 0
                        messagebox('init', ...
                           ['The export file sequence is incomplete (' ...
                              num2str(missing) ' file(s) are missing)'], ...
                           [], ...
                           'Warning', ...
                           [0 0 .8]);
                     end

                   else  %single file - disable sequence-related dialogs

                     set(h_file2, ...
                        'String','N/A', ...
                        'Enable','off')
                     set(h_waveint, ...
                        'String','N/A', ...
                        'Enable','off')
                     set(h_waveend, ...
                        'String','N/A', ...
                        'Enable','off')

                  end

               else  %bad file

                  errormsg = ['''' fn1 ''' could not be parsed'];

               end

            elseif ~isempty(fn1) & ~isempty(fn2) & ~isempty(filelist) %check/update file list

               %check for editbox/stored filename mismatches
               if strcmp(fn1,char(filelist(fileindex(1)))) ~= 1

                  %get file number by dissecting file entry
                  filename = fliplr(strtok(fn1,'.'));
                  n = 1;
                  while ~isempty(str2num(filename(n)))
                     n = n + 1;
                  end

                  num = str2num(fliplr(filename(1:n-1)));
                  newbase = fliplr(filename(n:length(filename)));

                  if strcmp(upper(basename),upper(newbase)) ~= 1  %new basename - clear lastfile

                     set(h_file1,'UserData',cell(1,5))
                     set(h_file2,'String','')
                     importscan('file1')

                  elseif num ~= fileindex(1)  %new first file - update list

                     if num > fileindex(length(fileindex))  %first file past last file
                        I = find(filenums == num);
                        set(h_file2,'String',upper(char(filelist(I(1)))))
                     else
                        I = find(filenums >= num & filenums <= fileindex(length(fileindex)));
                     end

                     %update stored data, description
                     if ~isempty(I)
                        set(h_file1,'UserData',[{filelist},{filenums},{basename},{I},{pathname}])
                        if autofill == 1
                           set(h_wavestart,'String','')
                           importscan('wave')
                        end
                     else
                        errormsg = ['''' fn1 ''' could not be parsed']
                     end

                  end

               end

            end

         end

      else  %evaluate last file edit box entry

         if ~isempty(fn2) & ~isempty(filelist)

            fn2 = upper(fn2);
            set(h_file2,'String',fn2)

            if strcmp(fn2,upper(char(filelist(fileindex(length(fileindex)))))) ~= 1

               %get file number by dissecting file entry
               filename = fliplr(strtok(fn2,'.'));
               n = 1;
               while ~isempty(str2num(filename(n)))
                  n = n + 1;
               end

               num = str2num(fliplr(filename(1:n-1)));
               newbase = fliplr(filename(n:length(filename)));

               if strcmp(upper(newbase),upper(basename)) ~= 1

                  errormsg = ['''' fn2 ''' is not a valid file in the sequence'];

               elseif num ~= fileindex(length(fileindex))  %new ending file - update list

                  if num > filenums(length(filenums))  %past end of file list
                     set(h_file2,'String',upper(char(filelist(length(filelist)))))
                  elseif num < filenums(fileindex(1))  %last file before first file
                     num = fileindex(1);
                     set(h_file2,'String',upper(char(filelist(fileindex(1)))))
                  end

                  %update file index
                  I = find(filenums >= fileindex(1) & filenums <= num);

                  %update stored data, description
                  if ~isempty(I)
                     set(h_file1,'UserData',[{filelist},{filenums},{basename},{I},{pathname}])
                     if autofill == 1
                        set(h_waveend,'String','')
                        importscan('wave')
                     end
                  else
                     errormsg = ['''' fn2 ''' is not a valid file in the sequence'];
                  end

               end

            end

         end

      end

      if ~isempty(errormsg)
         messagebox('init', ...
            errormsg, ...
            [], ...
            'Warning', ...
            [0 0 .8])
      end

      importscan('status')

   elseif strcmp(op(1,1:4),'wave')  %evaluate wavelength editbox callbacks

      %check for autofill flag
      if autofill == 1

         %validate wavelengths & autofill if appropriate
         if ~isempty(filenums)
            if isempty(wavestart) | isempty(waveint) | isempty(waveend)  %check autofill
               if ~isempty(wavestart) & ~isempty(waveint)  %autofill ending wavelength
                  waveend = wavestart + (filenums(fileindex(length(fileindex)))-filenums(fileindex(1)))*waveint;
                  set(h_waveend,'String',num2str(waveend))
               elseif ~isempty(waveend) & ~isempty(waveint)  %autofill starting wavelength
                  wavestart = waveend - (filenums(fileindex(length(fileindex)))-filenums(fileindex(1)))*waveint;
                  set(h_wavestart,'String',num2str(wavestart))
               elseif ~isempty(waveend) & ~isempty(wavestart)  %autofill interval
                  waveint = (waveend - wavestart) ./ (filenums(fileindex(length(fileindex)))-filenums(fileindex(1)));
                  set(h_waveint,'String',num2str(waveint))
               end
            end
         end

         %set filename validation flags
         updatefile1 = 0;
         updatefile2 = 0;
         updateint = 0;
         if ~isempty(filenums) & length([wavestart waveint waveend]) == 3
            if isempty(wavedata{1})
               updatefile1 = 1;
            elseif wavestart ~= wavedata{1}
               updatefile1 = 1;
            end
            if isempty(wavedata{3})
               updatefile2 = 1;
            elseif waveend ~= wavedata{3}
               updatefile2 = 1;
            end
            if isempty(wavedata{2})
               updateint = 1;
            elseif waveint ~= wavedata{2}
               updateint = 1;
            end
         end

         %update stored wavelength data
         set(h_wavestart,'UserData',[{wavestart},{waveint},{waveend}])

         filelist = filedata{1};

         if ~isempty(filelist)

            if length(filelist) > 1  %test for file sequence

               numscans = round((waveend - wavestart) ./ waveint + 1);

               if updatefile1 == 1   %update first file

                  newstart = filenums(fileindex(length(fileindex))) - numscans + 1;

                  if newstart < filenums(1)  %bad start - update wavestart first
                     wavestart = waveend - waveint .* (filenums(fileindex(length(fileindex)))-filenums(1));
                     set(h_wavestart,'String',num2str(wavestart))
                     importscan('wave')
                  elseif wavestart > waveend  %starting wavelength > ending - update
                     wavestart = waveend;
                     set(h_wavestart,'String',num2str(wavestart))
                     importscan('wave')
                  else  %update first file
                     I = find(filenums >= newstart & filenums <= filenums(fileindex(length(fileindex))));
                     if ~isempty(I)
                        filedata{4} = I;
                        set(h_file1,'String',upper(char(filelist(I(1)))))
                        importscan('file1')
                     end
                  end

               elseif updatefile2 == 1  %update last file

                  newend = filenums(fileindex(1)) + numscans - 1;

                  if newend > filenums(length(filenums))  %bad end - update waveend first
                     waveend = wavestart + waveint .* (filenums(length(filenums))-filenums(fileindex(1)));
                     set(h_waveend,'String',num2str(waveend))
                     importscan('wave')
                  elseif waveend < wavestart  %ending wavelength < starting - update
                     waveend = wavestart;
                     set(h_waveend,'String',num2str(waveend))
                     importscan('wave')
                  else
                     I = find(filenums >= filenums(fileindex(1)) & filenums <= newend);
                     if ~isempty(I)
                        filedata{4} = I;
                        set(h_file2,'String',upper(char(filelist(I(length(I))))))
                        importscan('file2')
                     end
                  end

               elseif updateint == 1  %update interval

                  if numscans ~= length(fileindex)  %bad interval

                     waveend = wavestart + (waveint * (length(fileindex)-1));
                     set(h_waveend,'String',num2str(waveend))
                     set(h_wavestart,'UserData',[{wavestart},{waveint},{waveend}])

                  end

               end

            end

         end

      end

      importscan('status')

   elseif strcmp(op,'status')  %evaluate status of 'Proceed' button

      h_edit = findobj(h_dlg,'Style','edit');
      h_proc = findobj(h_dlg,'Tag','cmdProceed');

      %test for entries in all fields
      allfields = 1;
      for n = 1:length(h_edit)
         if isempty(deblank(get(h_edit(n),'String')))
            allfields = 0;
            break
         end
      end

      if allfields == 1
         set(h_proc,'Enable','on')
      else
         set(h_proc,'Enable','off')
      end

   elseif strcmp(op,'calset')

      h_calset = findobj(h_dlg,'Tag','popCal');
      h_ramanstr = findobj(h_dlg,'Tag','txtRaman');
      h_raman = findobj(h_dlg,'Tag','editRaman');
      h_slits = findobj(h_dlg,'Tag','popSlit');
      oldslitval = get(h_slits,'Value');
      oldslitmat = get(h_slits,'UserData');
      warningstr = '';

      storedvals = get(h_dlg,'UserData');
      calsets = storedvals{2};

      setnum = get(h_calset,'Value');

      ramanstr = ['Raman Peak (Ex' num2str(calsets(setnum).ramanwave(1)) ...
            '/Em' num2str(calsets(setnum).ramanwave(2)) ')'];

      ramanwave = get(h_raman,'UserData');

      slits = calsets(setnum).qsparms(1:2,:)';

      slitval = find(slits(:,1)==oldslitmat(oldslitval,1) & ...
         slits(:,2)==oldslitmat(oldslitval,2));

      if isempty(slitval)
         slitval = size(slits,1);
         warningstr = str2mat('Slit settings reset to default values because the', ...
            'prior values are not valid for this calibration set');
      end

      slitstr = [num2str(slits(1,1)) 'nm Ex, ' num2str(slits(1,2)) 'nm Em Slits'];
      for n = 2:size(slits,1)
         slitstr = [slitstr '|' ...
               num2str(slits(n,1)) 'nm Ex, ' num2str(slits(n,2)) 'nm Em Slits'];
      end

      set(h_slits,'String',slitstr,'Value',slitval,'UserData',slits);
      set(h_ramanstr,'String',ramanstr)

      if sum(calsets(setnum).ramanwave == ramanwave) < 2  %different Raman ref
         set(h_raman,'String','','UserData',calsets(setnum).ramanwave)
         warningstr = str2mat(warningstr, ...
            'Raman peak value reset because the reference wavelength', ...
            'does not match the wavelength for this calibration set');
      end

      drawnow

      if ~isempty(warningstr)
         messagebox('init',warningstr,'','Warning',[.8 0 0])
      end

   elseif strcmp(op,'eval')

      error = 0;

      if length(filelist) > 1

         %validate wavelengths against file list
         numscans = round((waveend-wavestart)./waveint + 1);

         if numscans ~= length(fileindex)
            error = 1;
            errorbox('init','Wavelength values are invalid for the file sequence')
         end

      end

      if error == 0

         set(h_dlg,'Pointer','watch')

         %initialize eem variable
         eem = struct('type','data', ...
            'description','', ...
            'date','', ...
            'calibration','', ...
            'scatterpeaks',[], ...
            'scattertol',[], ...
            'ramanwave',[], ...
            'raman',[], ...
            'slits',[], ...
            'qsparms',[], ...
            'raw',[], ...
            'corrected',[], ...
            'blanked',[], ...
            'diluent',[], ...
            'df',[]);

         caldata = get(h_dlg,'UserData');
         calsets = caldata{2};

         h_cal = findobj(h_dlg,'Tag','popCal');
         calset = get(h_cal,'Value');

         eem.scatterpeaks = calsets(calset).scatterpeaks;

         eem.description = deblank(get(h_desc,'String'));
         if strcmp(eem.description,'(default)')  %use default description
            if length(filelist) > 1  %file sequence
               eem.description = ['Scan series ' char(filelist{fileindex(1)}) ...
                  ' through ' char(filelist{fileindex(length(fileindex))})];
            else
               eem.description = ['Scan data in ' char(filelist{1})];
            end
         end

         eem.calibration = [calsets(calset).name ' (' calsets(calset).date ')'];

         h_scatter = findobj(h_dlg,'Tag','editScatter');
         eem.scattertol = str2num(get(h_scatter,'String'));

         h_raman = findobj(h_dlg,'Tag','editRaman');
         eem.ramanwave = get(h_raman,'UserData');
         eem.raman = str2num(get(h_raman,'String'));

         h_slits = findobj(h_dlg,'Tag','popSlit');
         slitval = get(h_slits,'Value');
         slitdata = get(h_slits,'UserData');
         eem.slits = slitdata(slitval,:);

         h_dil = findobj(h_dlg,'Tag','editDil');
         eem.diluent = get(h_dil,'UserData');

         h_df = findobj(h_dlg,'Tag','editDF');
         eem.df = str2num(get(h_df,'String'));

         if length(filelist) > 1  %process file sequence

            [tmp,basefn,ext] = fileparts(filelist{fileindex(1)});

            if strcmpi(ext,'.sp')
               eem.raw = sp2mat(char(filelist{fileindex(1)}),char(filelist{fileindex(length(fileindex))}), ...
                  pathname);
            else
               eem.raw = prn2mat(wavestart,waveend,waveint, ...
                  char(filelist{fileindex(1)}),char(filelist{fileindex(length(fileindex))}), ...
                  pathname);
            end

         else  %single file - load and format as eem

            error = 0;
            curpath = pwd;
            mlversion = version;
            try
               cd(pathname)
               if strcmp(mlversion(1),'5')
                  data = load(char(filelist{1}),'ASCII');
               else
                  data = dlmread(char(filelist{1}));
               end
               cd(curpath)
            catch
               error = 1;
            end

            if error == 0
               if size(data,2) == 2
                  eem.raw = [NaN wavestart ; data];
               end
            end

            waveint = 0;
            waveend = wavestart;

         end

         if ~isempty(eem.raw) & ~isempty(eem.raman) & ~isempty(eem.scattertol) & ~isempty(eem.slits)

            qsmatrix = calsets(calset).qsparms;
            qscol = find(qsmatrix(1,:)==eem.slits(1) & qsmatrix(2,:)==eem.slits(2));
            if ~isempty(qscol)
               if ~isnan(qsmatrix(3,qscol))
                  eem.qsparms = qsmatrix(3:5,qscol);
               end
            end

            if ~isempty(eem.qsparms)  %test for valid quinine sulfate curve-fit parameters

               warning off
               if sum(sum(eem.scattertol)) > 0  %test for correction
                  eem.corrected = rmn2qse(cfactor(cleanscan(eem_math('A./B',[{eem.raw},{eem.raman}]), ...
                     eem.scattertol,eem.scatterpeaks),calsets(calset).correctmatrix),eem.qsparms);
                  if ~isempty(eem.df) & ~isempty(eem.diluent)  %unblank correct scan
                     eem.blanked = undilute(eem.corrected,eem.df,eem.diluent);
                  end
               end

               set(h_dlg,'Pointer','arrow')

               h_autosave = findobj(h_dlg,'Tag','checkAutoSave');
               autosave = get(h_autosave,'Value');

               curpath = pwd;
               error = 0;

               cd(pathname)

               fileinfo = dir(filelist{fileindex(1)});
               eem.date = fileinfo.date;

               if autosave == 1
                  try
                     save([basename,'.eem'],'eem');
                  catch
                     error = 1;
                  end
               else
                  [fn,pn] = uiputfile([basename '.eem'],'Save imported scan data');
                  if fn ~= 0
                     fn = [strtok(fn,'.') '.eem'];
                     try
                        cd(pn)
                        save(fn,'eem')
                     catch
                        error = 1;
                     end
                  end
               end
               cd(curpath)

               drawnow

               h_autoplot = findobj(h_dlg,'Tag','checkAutoPlot');
               autoplot = get(h_autoplot,'Value');

               if autoplot == 1

                  if size(eem.raw,2) == 2
                     dataplot('line',eem);
                  else
                     dataplot('surfnewfig',eem);
                  end

               end

               if error == 1
                  errorbox('init','Error writing data file to disk')
               end

            else  %no matching qsparms for slit sizes
               set(h_dlg,'Pointer','watch')
               errorbox('init','Invalid slit sizes for selected calibration set')
            end

         else
            set(h_dlg,'Pointer','arrow')
            errorbox('init','EEM cannot be created - confirm entries')
         end

      end

   elseif strcmp(op(1,1:4),'brow')  %process calls to browse for files

      switch op(1,8:length(op))
      case 'raman'
         promptstr = 'Select a Water Raman scan file';
         filespec = '*.prn;*.sp;*.SP;*.eem';
      case 'scan'
         promptstr = 'Select an ASCII scan file from the series to import';
         filespec = '*.prn;*.sp;*.SP';
      case 'dil'
         promptstr = 'Select an EEM file for the diluent';
         filespec = '*.eem';
      otherwise
         promptstr = '';
         filespec = '';
      end

      if ~isempty(filespec)

         curpath = pwd;

         global EEMLOADPATH
         if ~isempty(EEMLOADPATH)
            pn = EEMLOADPATH;
         else
            pn = curpath;
         end

         cd(pn)

         [fn1,pn] = uigetfile(filespec,promptstr);
         drawnow

         if fn1 ~= 0

            cd(pn)
            EEMLOADPATH = pn;
            error = 0;
            errormsg = '';

            switch op(1,8:length(op))

            case 'raman'

               h_raman = findobj(h_dlg,'Tag','editRaman');
               ramanwave = get(h_raman,'UserData');
               data = [];
               val = [];
               [pn,fn,fext] = fileparts(fn1);

               if strcmpi(fext,'.eem')  %EEM file

                  load(fn1,'-mat');
                  data = eem.raw;

               else  %assume ASCII file

                  data = [];
                  if strcmpi(fext,'.sp')  %LS 50B file
                     [em,fl,ex] = parse_sp(fn1,pn);
                     if ~isempty(em)
                        data = [NaN ex ; em fl];
                     end
                  else  %DataMax file
                     mlversion = version;
                     try
                        if strcmp(mlversion(1),'5')
                           data = load(fn1,'ASCII');
                        else
                           data = dlmread(fn1);
                        end
                     catch
                        error = 1;
                     end
                     if error == 0
                        if size(data,2) == 2
                           data = [NaN ramanwave(1) ; data(:,1:2)];
                        else
                           data = [];
                        end
                     else
                        data = [];
                     end
                  end

               end

               cd(curpath)

               val = [];
               if ~isempty(data)
                  I_ex = find(data(1,:) == ramanwave(1));  %find appropriate data column
                  if ~isempty(I_ex)  %determine peak emission using lookup or 1D interpolation
                     try
                        val = interp1(data(2:size(data,1),1),data(2:size(data,1),I_ex(1)),ramanwave(2),'spline');
                     catch
                        error = 1;
                     end
                  end
               end

               if ~isempty(val)
                  valstr = num2str(val);
                  h_raman = findobj(h_dlg,'Tag','editRaman');
                  set(h_raman,'String',valstr)
                  importscan('raman')
               else
                  errormsg = str2mat(['''' fn1 ''' does not contain valid emmission data at ' ...
                     num2str(ramanwave(1)) 'nm'],'(the Raman reference excitation wavelength)');
               end

            case 'scan'

               cd(curpath)
               %post filename to editbox, clear other fields and stored data
               set(h_file1,'String',upper(fn1),'UserData',cell(1,5))
               set(h_file2,'String','')
               %set(h_desc,'String','(default)')

               %proceed to file entry sub
               importscan('file1')

            case 'dil'

               cd(curpath)

               %post filename to editbox, clear stored data
               h_dil = findobj(h_dlg,'Tag','editDil');
               set(h_dil,'String',fn1,'UserData',[])

               %proceed to diluent sub
               importscan('diluent')

            end

            if ~isempty(errormsg)
               messagebox('init', ...
                  errormsg, ...
                  [], ...
                  'Error', ...
                  [.8 0 0]);
            end

         end

         cd(curpath)

      end

   elseif strcmp(op,'desc')  %validate description editbox entry

      if isempty(deblank(get(h_desc,'String')))
         set(h_desc,'String','(default)')
      end

   elseif strcmp(op,'diluent')  %validate diluent editbox, manage DF editbox

      h_dil = findobj(h_dlg,'Tag','editDil');
      h_df = findobj(h_dlg,'Tag','editDF');
      fn = deblank(get(h_dil,'String'));

      if isempty(fn)

         set(h_dil,'String','none','UserData',[])
         set(h_df,'String','1','Enable','off')

      else

         curpath = pwd;
         error = 0;
         errormsg = '';

         if exist(fn) ~= 2  %file not in search path

            global EEMLOADPATH
            cd(EEMLOADPATH)

            if exist(fn) ~= 2

               [fn2,pn] = uigetfile(fn,'Locate diluent EEM data file');

               if fn2 == 0  %cancelled by user

                  error = 1;
                  set(h_dil,'String','none','UserData',[])
                  set(h_df,'String','1','Enable','off')

               else  %file located - update filename

                  cd(curpath)
                  fn = fn2;

                  set(h_dil,'String',fn,'UserData',[])
                  set(h_df,'Enable','on')

               end

            end

         end

         if error == 0  %file located - load and validate

            try
               load(fn,'-mat');
            catch
               error = 1;
            end

            if error == 0

               eemdata = [];

               if exist('eem') == 1

                  if isfield(eem,'corrected')

                     if ~isempty(eem.corrected)
                        eemdata = eem(1).corrected;
                     else
                        error = 1;
                        errormsg = ['''' fn ''' does not contain a corrected EEM scan'];
                     end

                  else
                     error = 1;
                     errormsg = ['''' fn ''' does not contain a corrected EEM scan'];
                  end

               else
                  error = 1;
                  errormsg = ['''' fn ''' is not a valid EEM data file'];
               end

            else
               error = 1;
               errormsg = ['''' fn ''' could not be loaded'];
            end

            if error == 0

               set(h_dil,'UserData',eemdata)
               set(h_df,'Enable','on')

            end

         end

         cd(curpath)

         importscan('status')

         if ~isempty(errormsg)

            errorbox('init',errormsg)

         end

      end

   elseif strcmp(op,'raman')  %validate Raman entry

      h_raman = findobj(h_dlg,'Tag','editRaman');
      str = deblank(get(h_raman,'String'));

      if ~isempty(str)

         raman = str2num(str);
         error = 0;

         if isempty(raman)  %not a valid number
            error = 1;
         elseif sum(size(raman)) > 2  %not a scalar
            error = 1;
         end

         if error == 1  %validation failed
            set(h_raman,'String','')
            errorbox('init','Invalid Raman peak value')
         end

      end

      importscan('status')

   elseif strcmp(op,'scatter')  %validate scatter tolerance array

      h_scatter = findobj(h_dlg,'Tag','editScatter');
      str = get(h_scatter,'String');

      if ~isempty(str)

         scatter = str2num(str);
         error = 0;

         if isempty(scatter)
            error = 1;
         elseif size(scatter,1) ~= 4 | size(scatter,2) ~= 2
            error = 1;
         end

         if error == 0  %valid data - update stored values
            set(h_scatter,'UserData',str)
         else  %bad data - restore last valid string
            set(h_scatter,'String',get(h_scatter,'UserData'))
            errorbox('init','Invalid scatter correction array');
         end

      else

         set(h_scatter,'String','[0 0;0 0;0 0;0 0]')

      end

      importscan('status')

   elseif strcmp(op,'autofill')

      if autofill == 1

         importscan('wave3')

      end

   elseif strcmp(op,'clear')  %clear fields

      storedvals = get(h_dlg,'UserData');
      calsets = storedvals{2};
      scattertol = storedvals{3};

      correctstr = ['[' num2str(scattertol(1,1)) ' ' num2str(scattertol(1,2)) ';' ...
         num2str(scattertol(2,1)) ' ' num2str(scattertol(2,2)) ';' ...
         num2str(scattertol(3,1)) ' ' num2str(scattertol(3,2)) ';' ...
         num2str(scattertol(4,1)) ' ' num2str(scattertol(4,2)) ']'];

      calset = length(calsets);

      ramanstr = ['Raman Peak (Ex' num2str(calsets(calset).ramanwave(1)) ...
         '/Em' num2str(calsets(calset).ramanwave(2)) ')'];
        ramanvalstr = '';
      ramanwave = calsets(calset).ramanwave;

      slits = calsets(calset).qsparms(1:2,:)';

        slitval = find(slits(1,1)==5 & slits(1,2)==5);
      if isempty(slitval)
         slitval = size(slits,1);
      end

      slitstr = [num2str(slits(1,1)) 'nm Ex, ' num2str(slits(1,2)) 'nm Em Slits'];
      for n = 2:size(slits,1)
         slitstr = [slitstr '|' ...
         num2str(slits(n,1)) 'nm Ex, ' num2str(slits(n,2)) 'nm Em Slits'];
        end

      h_edit = findobj(h_dlg,'Style','edit');
      h_proc = findobj(h_dlg,'Tag','cmdProceed');
      h_df = findobj(h_dlg,'Tag','editDF');
      h_scatter = findobj(h_dlg,'Tag','editScatter');
      h_scatterstr = findobj(h_dlg,'Tag','txtScatter');
      h_slit = findobj(h_dlg,'Tag','popSlit');
      h_cal = findobj(h_dlg,'Tag','popCal');

      set(h_edit,'String','','Enable','on')
      set(h_desc,'String','(default)')
      set(h_file1,'UserData',cell(1,5))
      set(h_wavestart,'UserData',cell(1,3))
      set(h_df,'String','1','Enable','off')
      set(h_scatter,'String',get(h_scatterstr,'UserData'))
      set(h_slit,'String',slitstr,'Value',slitval,'UserData',slits)
      set(h_cal,'Value',calset)
      set(h_proc,'Enable','off')

      importscan('diluent')  %reset diluent fields

   end

end

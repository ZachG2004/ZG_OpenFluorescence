function importedit(op,eemfile)
%EEM data file import/edit dialog function for the Fluorescence Toolbox
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

if ~exist('op')
   op = 'init';
end

if strcmp(op,'init')  %create/refocus dialog box

   if length(findobj) > 1
      h_fig = gcf;
      h_dlg = findobj('Tag','dlgImpEdit');
   else
      h_fig = [];
      h_dlg = [];
   end

   if ~isempty(h_dlg)  %dialog open - shift focus

      figure(h_dlg)
      drawnow

   else  %create new dialog

      if length(findobj) > 1
         h_fig = gcf;
      else
         h_fig = [];
      end

      loaderror = 0;
      try
         load('calibration.mat');
      catch
         loaderror = 1;
      end

      if loaderror == 1  %cancel dialog - no cal file

         errorbox('init',['Cannot open dialog - calibration file ''calibration.mat''' ...
            'could not be loaded'])

      else  %continue to build dialog

         curpath = pwd;
         error = 0;

         correctstr = ['[' int2str(scattertol(1,1)) ' ' int2str(scattertol(1,2)) ';' ...
            int2str(scattertol(2,1)) ' ' int2str(scattertol(2,2)) ';' ...
            int2str(scattertol(3,1)) ' ' int2str(scattertol(3,2)) ';' ...
            int2str(scattertol(4,1)) ' ' int2str(scattertol(4,2)) ']'];

         calset = length(calsets);

         ramanstr = ['Raman Peak (Ex' int2str(calsets(calset).ramanwave(1)) ...
            '/Em' int2str(calsets(calset).ramanwave(2)) ')'];
         ramanvalstr = '';
         ramanwave = calsets(length(calsets)).ramanwave;

         slits = calsets(1).qsparms(1:2,:)';

         slitval = find(slits(1,1)==5 & slits(1,2)==5);
         if isempty(slitval)
            slitval = size(slits,1);
         end

         ctrlvis = 'on';

         calsetstr = [char(calsets.date) char(ones(length(calsets),1).*' ') ...
            char(calsets.name)];

         bgcolor = [0.8 0.8 0.8];
         frameclr = [0.9 0.9 0.9];
         screenres = get(0,'ScreenSize');

         h_dlg = figure('Visible','off', ...
            'Units','pixels', ...
            'Position',[screenres(3)-455 50 450 520], ...
            'Color',bgcolor, ...
            'MenuBar','none', ...
            'ToolBar','none', ...
            'Name','Import/Edit EEM', ...
            'NumberTitle','off', ...
            'DefaultUiControlUnits','pixels', ...
            'Tag','dlgImpEdit', ...
            'KeyPressFcn','figure(gcf)', ...
            'Resize','off', ...
            'UserData',[{h_fig} {calsets} {scattertol}]);

         axis off

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0.8 0 0], ...
            'Position',[4 290 442 225], ...
            'String','Scan File Information', ...
            'Style','text');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0.8 0 0], ...
            'Position',[4 204 442 82], ...
            'String','Instrument/Optical Corrections', ...
            'Style','text');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0.8 0 0], ...
            'Position',[4 118 442 81], ...
            'String','Fluorescence Intensity Calibration', ...
            'Style','text');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'FontWeight','bold', ...
            'ForegroundColor',[0.8 0 0], ...
            'Position',[4 37 442 76], ...
            'String','Sample Dilution Correction', ...
            'Style','text');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[15 471 60 20], ...
            'String','File Name', ...
            'Style','text');

         h_editFile = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'Position',[80 473 328 20], ...
            'Style','edit', ...
            'String','', ...
            'Tag','editFile', ...
            'UserData',cell(1,2));

         h_cmdBrowseFile = uicontrol('Parent',h_dlg, ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[410 474 30 20], ...
            'String','...', ...
            'Tag','cmdBrowseFile', ...
            'Callback','importedit(''brow_eem'')', ...
            'UserData','import', ...
            'TooltipString','Browse for data file');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[15 440 60 20], ...
            'String','Description', ...
            'Style','text');

         h_editDesc = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'Position',[80 372 360 90], ...
            'Style','edit', ...
            'Min',1, ...
            'Max',3, ...
            'String','(automatic)', ...
            'Callback','importedit(''desc'')', ...
            'Tag','editDesc');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[12 324 70 20], ...
            'String','Excitation (nm)', ...
            'Style','text');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[12 299 70 20], ...
            'String','Emission (nm)', ...
            'Style','text');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[90 344 50 20], ...
            'String','Minimum', ...
            'Style','text');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[145 344 50 20], ...
            'String','Maximum', ...
            'Style','text');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[200 344 50 20], ...
            'String','Interval', ...
            'Style','text');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'Position',[255 344 50 20], ...
            'String','Slit Size', ...
            'Style','text');

         h_editExMin = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[90 327 50 20], ...
            'Style','edit', ...
            'String','', ...
            'Callback','importedit(''wave_exmin'')', ...
            'Enable',ctrlvis, ...
            'Tag','editExMin', ...
            'UserData',cell(2,4));

         h_editExMax = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[145 327 50 20], ...
            'Style','edit', ...
            'String','', ...
            'Callback','importedit(''wave_exmax'')', ...
            'Enable',ctrlvis, ...
            'Tag','editExMax');

         h_editExInt = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[200 327 50 20], ...
            'Style','edit', ...
            'String','', ...
            'Callback','importedit(''wave_exint'')', ...
            'Enable',ctrlvis, ...
            'Tag','editExInt');

         h_editExSlit = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[255 327 50 20], ...
            'Style','edit', ...
            'String','', ...
            'Callback','importedit(''wave_exslit'')', ...
            'Enable',ctrlvis, ...
            'Tag','editExSlit');

         h_editEmMin = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[90 302 50 20], ...
            'Style','edit', ...
            'String','', ...
            'Callback','importedit(''wave_emmin'')', ...
            'Enable',ctrlvis, ...
            'Tag','editEmMin');

         h_editEmMax = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[145 302 50 20], ...
            'Style','edit', ...
            'String','', ...
            'Callback','importedit(''wave_emmax'')', ...
            'Enable',ctrlvis, ...
            'Tag','editEmMax');

         h_editEmInt = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[200 302 50 20], ...
            'Style','edit', ...
            'String','', ...
            'Callback','importedit(''wave_emint'')', ...
            'Enable',ctrlvis, ...
            'Tag','editEmInt');

         h_editEmSlit = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[255 302 50 20], ...
            'Style','edit', ...
            'String','', ...
            'Callback','importedit(''wave_emslit'')', ...
            'Enable',ctrlvis, ...
            'Tag','editEmSlit');

         h_chkAutoFill = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'Position',[320 326 120 20], ...
            'String','Autofill Wavelengths', ...
            'Style','checkbox', ...
            'Tag','chkAutoFill', ...
            'TooltipString','Automatically fill wavelength fields as values are entered', ...
            'Value',1);

         h_chkResample = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'Position',[320 301 120 20], ...
            'String','Allow Matrix Resizing', ...
            'Style','checkbox', ...
            'Tag','chkResample', ...
            'TooltipString','Allow matrix resizing by truncation/interpolation', ...
            'Value',0);

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[15 240 85 20], ...
            'String','Calibration Set', ...
            'Style','text');

         h_popCalSet = uicontrol('Parent',h_dlg, ...
            'Style','popupmenu', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[99 243 340 20], ...
            'String',calsetstr, ...
            'Value',calset, ...
            'Tag','popCalSet', ...
            'Enable',ctrlvis, ...
            'TooltipString','Select set of calibration parameters to use for calculations');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[14 212 125 20], ...
            'String','Scatter Removal Settings', ...
            'Style','text');

         h_editScatter = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[142 215 220 20], ...
            'HorizontalAlignment','left', ...
            'Style','edit', ...
            'String',correctstr, ...
            'Enable',ctrlvis, ...
            'Callback','importedit(''scatter'')', ...
            'Tag','editScatter', ...
            'UserData',correctstr);

         h_cmdEditScatter = uicontrol('Parent',h_dlg, ...
            'FontSize',9, ...
            'Position',[366 215 45 20], ...
            'String','Edit', ...
            'Tag','cmdScatter', ...
            'Enable',ctrlvis, ...
            'TooltipString','Edit scatter removal tolerance settings', ...
            'Callback',['scatterdlg(''init'',' correctstr ')']);

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[15 154 100 20], ...
            'String','Calibration Scheme', ...
            'Style','text');

         h_popCalType = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[116 156 323 20], ...
            'String',['No calibration (units = cps)|' ...
            'Raman Ex275/Em303 Normalized (units = raman)|' ...
            'Raman Normalized & Quinine Sulfate Calibrated (units = qse)'], ...
            'Style','popupmenu', ...
            'Callback','importedit(''scheme'')', ...
            'Enable',ctrlvis, ...
            'Tag','popCalType', ...
            'Value',3, ...
            'UserData',[{''};{'raman'};{'raman|qs'}]);

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[15 124 150 20], ...
            'String',ramanstr, ...
            'Style','text');

         h_editRaman = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Position',[166 126 80 20], ...
            'String','', ...
            'Style','edit', ...
            'Enable',ctrlvis, ...
            'UserData',ramanwave, ...
            'Callback','importedit(''status'')', ...
            'Tag','editRaman');

         h_cmdBrowseRaman = uicontrol('Parent',h_dlg, ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[252 126 30 20], ...
            'String','...', ...
            'Tag','cmdBrowseRaman', ...
            'Enable',ctrlvis, ...
            'Callback','importedit(''brow_raman'')', ...
            'TooltipString','Browse for Raman scan file');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[15 71 70 20], ...
            'String','Diluent EEM', ...
            'Style','text');

         h_cmdBrowseDil = uicontrol('Parent',h_dlg, ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[395 73 30 20], ...
            'String','...', ...
            'Tag','cmdBrowseDil', ...
            'Enable',ctrlvis, ...
            'Callback','importedit(''brow_dil'')', ...
            'TooltipString','Browse for diluent EEM data file');

         h_editDiluent = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'HorizontalAlignment','left', ...
            'Position',[90 73 300 20], ...
            'Style','edit', ...
            'String','(none)', ...
            'Enable',ctrlvis, ...
            'Callback','importedit(''diluent'')', ...
            'Tag','editDiluent');

         h1 = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',frameclr, ...
            'ForegroundColor',[0 0 0.8], ...
            'HorizontalAlignment','left', ...
            'Position',[15 41 155 20], ...
            'String','Dilution Factor (Vtotal/Vsample)', ...
            'Style','text');

         h_editDF = uicontrol('Parent',h_dlg, ...
            'BackgroundColor',[1 1 1], ...
            'Enable','off', ...
            'Position',[175 43 60 20], ...
            'String','1', ...
            'Style','edit', ...
            'Enable','off', ...
            'Tag','editDF');

         h_cmdProceed = uicontrol('Parent',h_dlg, ...
            'Position',[384 5 60 24], ...
            'Enable','off', ...
            'String','Proceed', ...
            'Tag','cmdProceed', ...
            'TooltipString','Accept changes and create EEM data file', ...
            'Callback','importedit(''eval'')');

         h_cmdClear = uicontrol('Parent',h_dlg, ...
            'Position',[200 5 60 24], ...
            'String','Clear', ...
            'Tag','cmdClear', ...
            'TooltipString','Clear all dialog entries', ...
            'Callback','importedit(''clear'')');

         h_cmdClose = uicontrol('Parent',h_dlg, ...
            'Position',[5 5 60 24], ...
            'String','Close', ...
            'Tag','cmdClose', ...
            'TooltipString','Close dialog box and discard changes', ...
            'Callback','importedit(''close'')');

         set(h_editEmMin,'UserData',[h_editExMin h_editExMax h_editExInt h_editExSlit; ...
            h_editEmMin h_editEmMax h_editEmInt h_editEmSlit])

         set(h_dlg,'Visible','on');

         if exist('eemfile') ~= 1

            drawnow

         else

            curpath = pwd;
            fn = '';
            pn = curpath;
            clear eem  %clear eem variable within scope

            if exist(eemfile) == 2  %look for file in current directory

               pn = curpath;
               fn = eemfile;

            else  %try alternate directories

               global EEMLOADPATH EEMSAVEPATH

               if ~isempty(EEMLOADPATH)
                  cd(EEMLOADPATH)
                  if exist(eemfile) == 2
                     fn = eemfile;
                     pn = EEMLOADPATH;
                  elseif ~isempty(EEMSAVEPATH)
                     cd(EEMSAVEPATH)
                     if exist(eemfile) == 2
                        fn = eemfile;
                        pn = EEMSAVEPATH;
                     end
                  end
               end

            end

            if ~isempty(fn)

               try
                  load(fn,'-mat');
               catch
                  error = 1;
               end
               cd(curpath)

               if error == 0
                  if exist('eem') == 1
                     if ~isstruct(eem)
                        error = 1;
                     end
                  else
                     error = 1;
                  end
               end

               if error == 0

                  %correct outdated eemfile structure
                  if ~isfield(eem,'type')
                     eem.type = 'data';
                  end
                  if ~isfield(eem,'ramanwave')
                     eem.ramanwave = [275 303];
                  end

                  set(h_editFile,'String',fn,'UserData',[{eem},{fn},{pn}])

                  importedit('newfile')

               else  %bad file

                  errormsg = ['''' fn ''' is not a valid EEM data file'];

               end

            end

         end

      end

   end

else  %evaluate callbacks

   h_dlg = findobj('Tag','dlgImpEdit');

   h_mode = findobj(h_dlg,'Tag','cmdBrowseFile');
   mode = get(h_mode,'UserData');

   h_file = findobj(h_dlg,'Tag','editFile');
   filedata = get(h_file,'UserData');
   eem = filedata{1};

   h_wave = findobj(h_dlg,'Tag','editExMin');
   wavedata = get(h_wave,'UserData');

   h_waveh = findobj(h_dlg,'Tag','editEmMin');
   waveh = get(h_waveh,'UserData');

   h_desc = findobj(h_dlg,'Tag','editDesc');

   if strcmp(op,'close')

      h_fig = get(h_dlg,'UserData');

      close(h_dlg)
      drawnow

      if ~isempty(h_fig)
         figure(h_fig); drawnow
      end

   elseif strcmp(op,'clear')  %clear fields

      storedvals = get(h_dlg,'UserData');
      calsets = storedvals{2};
      scattertol = storedvals{3};

      h_edit = findobj(h_dlg,'Style','edit');
      h_proc = findobj(h_dlg,'Tag','cmdProceed');
      h_df = findobj(h_dlg,'Tag','editDF');
      h_scatter = findobj(h_dlg,'Tag','editScatter');
      h_scatterstr = findobj(h_dlg,'Tag','txtScatter');
      h_editscatter = findobj(h_dlg,'Tag','cmdScatter');
      h_cal = findobj(h_dlg,'Tag','popCalSet');
      h_caltype = findobj(h_dlg,'Tag','popCalType');
      h_cmd = [findobj(h_dlg,'Tag','cmdScatter'); ...
         findobj(h_dlg,'Tag','cmdBrowseDiluent'); ...
         findobj(h_dlg,'Tag','cmdBrowseRaman')];

      correctstr = ['[' int2str(scattertol(1,1)) ' ' int2str(scattertol(1,2)) ';' ...
         int2str(scattertol(2,1)) ' ' int2str(scattertol(2,2)) ';' ...
         int2str(scattertol(3,1)) ' ' int2str(scattertol(3,2)) ';' ...
         int2str(scattertol(4,1)) ' ' int2str(scattertol(4,2)) ']'];

      calset = length(calsets);
      caltypes = get(h_caltype,'UserData');

      ramanstr = ['Raman Peak (Ex' int2str(calsets(calset).ramanwave(1)) ...
         '/Em' int2str(calsets(calset).ramanwave(2)) ')'];
      ramanvalstr = '';
      ramanwave = calsets(calset).ramanwave;

      set(h_edit,'String','','Enable','on')
      set(h_desc,'String','(default)')
      set(h_file,'UserData',cell(1,3))
      set(waveh(1,1),'UserData',cell(2,4))
      set(h_df,'String','1','Enable','off')
      set(h_scatter,'String',correctstr,'UserData',correctstr)
      set(h_cal,'Value',calset,'Enable','on')
      set(h_caltype,'Value',size(caltypes,1),'Enable','on')
      set(h_proc,'Enable','off')
      set(h_cmd,'Enable','on')

      importedit('diluent')  %reset diluent fields

   elseif strcmp(op,'eval')

   elseif strcmp(op(1,1:4),'wave')

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

      elseif ~isempty(eem)

         set(h_scatter,'String',get(h_scatter,'UserData'))

      end

      importedit('status')

   elseif strcmp(op,'desc')  %manage description edit box (maintain nonblank status)

      h_desc = findobj(h_dlg,'Tag','editDesc');
      desc = get(h_desc,'String');

      if isempty(desc)
         set(h_desc,'String',' ');
      end

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

   elseif strcmp(op,'diluent')  %validate diluent editbox, manage DF editbox

      h_dil = findobj(h_dlg,'Tag','editDiluent');
      h_df = findobj(h_dlg,'Tag','editDF');
      fn = deblank(get(h_dil,'String'));

      if isempty(fn)

         set(h_dil,'String','none','UserData',[])
         set(h_df,'String','1','Enable','off')

      elseif strcmp(mode,'edit') & length(findstr([fn blanks(7)],'default')) >= 1  %use default in EEM file

         if isempty(eem)
            set(h_dil,'String','none','UserData',[])
            set(h_df,'String','1','Enable','off')
         else
            set(h_dil,'String','(default)','UserData',eem.diluent)
            if ~isempty(eem.diluent)
               set(h_df,'String',num2str(eem.df),'Enable','on')
            else
               set(h_df,'String','1','Enable','off')
            end
         end

      elseif strcmp(mode,'import') & length(findstr([fn blanks(4)],'none')) >= 1

         set(h_dil,'String','none','UserData',[])
         set(h_df,'String','1','Enable','off')

      else  %validate file entry

         curpath = pwd;
         error = 0;
         errormsg = '';

         if exist(fn) ~= 2  %file not in search path

            global EEMLOADPATH EEMSAVEPATH
            if ~isempty(EEMLOADPATH)
               cd(EEMLOADPATH)
            elseif ~isempty(EEMSAVEPATH)
               cd(EEMSAVEPATH)
            end

            if exist(fn) ~= 2

               [fn2,pn] = uigetfile(fn,'Locate diluent EEM data file');

               if fn2 == 0  %cancelled by user

                  error = 1;
                  set(h_dil,'String','none','UserData',[])
                  set(h_df,'String','1','Enable','off')

               else  %file located - update filename

                  cd(pn)
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

         if ~isempty(errormsg)

            errorbox('init',errormsg)

         end

      end

      importedit('status')

   elseif strcmp(op(1,1:4),'brow')  %process calls to browse for files

      switch op(1,6:length(op))
         case 'raman'
            promptstr = 'Select an ASCII Raman scan file';
            filespec = '*.prn;*.eem';
         case 'eem'
            promptstr = 'Select an EEM data file to load';
            filespec = '*.eem';
         case 'dil'
            promptstr = 'Select an EEM file for the diluent';
            filespec = '*.eem';
         otherwise
            promptstr = '';
            filespec = '';
      end

      if ~isempty(filespec)

         curpath = pwd;

         global EEMLOADPATH EEMSAVEPATH
         if ~isempty(EEMLOADPATH)
            cd(EEMLOADPATH)
         elseif ~isempty(EEMSAVEPATH)
            cd(EEMSAVEPATH)
         end

         [fn,pn] = uigetfile(filespec,promptstr);
         drawnow

         if fn ~= 0

            cd(pn)
            EEMLOADPATH = pn;
            error = 0;
            errormsg = '';

            switch op(1,6:length(op))

               case 'raman'

                  h_raman = findobj(h_dlg,'Tag','editRaman');
                  ramanwave = get(h_raman,'UserData');
                  if isempty(ramanwave)
                     ramanwave = [275 303];
                  end

                  val = [];

                  [tmp,basefn,fext] = fileparts(fn);

                  if strcmpi(fext,'.eem')  %EEM file

                     clear eem
                     load(fn,'-mat');
                     data = eem.raw;

                  else  %assume ASCII file

                     try
                        data = dlmread(fn);
                     catch
                        data = [];
                        error = 1;
                     end

                     if error == 0
                        if size(data,2) == 2
                           data = [NaN ramanwave(1) ; data(:,1:2)];
                        else
                           data = [];
                        end
                     end

                  end

                  cd(curpath)

                  if ~isempty(data)

                     I_ex = find(data(1,:) == ramanwave(1));

                     if ~isempty(I_ex)
                        eval(['val = interp1(data(2:size(data,1),1),' ...
                           'data(2:size(data,1),I_ex(1)),ramanwave(2),''spline'');'], ...
                           'error = 1;')
                     end

                  end

                  if ~isempty(val)
                     valstr = num2str(val);
                     h_raman = findobj(h_dlg,'Tag','editRaman');
                     set(h_raman,'String',valstr)
                     importedit('raman')
                  else
                     errormsg = str2mat(['''' fn ''' does not contain valid emmission data at ' ...
                        int2str(ramanwave(1)) 'nm'],'(the Raman reference excitation wavelength)');
                  end

               case 'eem'

                  clear eem  %clear eem variable within scope
                  try
                     load(fn,'-mat');
                  catch
                     error = 1;
                  end
                  cd(curpath)

                  if error == 0
                     if exist('eem') == 1
                        if ~isstruct(eem)
                           error = 1;
                        end
                     else
                        error = 1;
                     end
                  end

                  if error == 0

                     %correct outdated eemfile structure
                     if ~isfield(eem,'type')
                        eem.type = 'data';
                     end
                     if ~isfield(eem,'ramanwave')
                        eem.ramanwave = [275 303];
                     end

                     filedata{1} = eem;
                     filedata{2} = fn;
                     filedata{3} = pn;
                     set(h_file,'String',fn,'UserData',filedata)
                     set(h_mode,'UserData','edit')
                     importedit('newfile')

                  else  %bad file

                     errormsg = ['''' fn ''' is not a valid EEM data file'];

                  end

               case 'dil'

                  %post filename to editbox, clear stored data
                  h_dil = findobj(h_dlg,'Tag','editDiluent');
                  set(h_dil,'String',fn,'UserData',[])

                 cd(curpath)

                  %proceed to diluent sub
                  importedit('diluent')

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

   elseif strcmp(op,'newfile')

      h_proc = findobj(h_dlg,'Tag','cmdProceed');
      h_slit = findobj(h_dlg,'Tag','popSlit');
      h_dil = findobj(h_dlg,'Tag','editDiluent');
      h_df = findobj(h_dlg,'Tag','editDF');
      h_scatter = findobj(h_dlg,'Tag','editScatter');
      h_scatterstr = findobj(h_dlg,'Tag','txtScatter');
      h_cal = findobj(h_dlg,'Tag','popCalSet');
      h_ramanstr = findobj(h_dlg,'Tag','txtRaman');
      h_raman = findobj(h_dlg,'Tag','editRaman');
      h_cmd = [findobj(h_dlg,'Tag','cmdScatter'); ...
         findobj(h_dlg,'Tag','cmdBrowseDil'); ...
         findobj(h_dlg,'Tag','cmdBrowseRaman')];

      storedvals = get(h_dlg,'UserData');
      calsets = storedvals{2};
      scattertol = storedvals{3};

      h_wavehvec = [waveh(1,:)' ; waveh(2,:)'];
      ex = [{eem.raw(1,2)},{eem.raw(1,min(3,size(eem.raw,2)))-eem.raw(1,2)},{eem.raw(1,size(eem.raw,2))},{eem.slits(1)}];
      em = [{eem.raw(2,1)},{eem.raw(min(3,size(eem.raw,1)),1)-eem.raw(2,1)},{eem.raw(size(eem.raw,1),1)},{eem.slits(2)}];

      if strcmp(eem.type,'data')

         correctstr = ['[' int2str(eem.scattertol(1,1)) ' ' int2str(eem.scattertol(1,2)) ';' ...
            int2str(eem.scattertol(2,1)) ' ' int2str(eem.scattertol(2,2)) ';' ...
            int2str(eem.scattertol(3,1)) ' ' int2str(eem.scattertol(3,2)) ';' ...
            int2str(eem.scattertol(4,1)) ' ' int2str(eem.scattertol(4,2)) ']'];

         caldate = strtok(fliplr(strtok(fliplr(eem.calibration),'(')),')');
         calset = find(strcmp(cellstr(char(calsets.date)),caldate));
         if ~isempty(calset)
            calset = calset(length(calset));
         else
            calset = length(calsets);
         end

         if ~isfield(eem,'ramanwave')  %update outdated eem file
            eem.ramanwave = [275 303];
         end

         ramanstr = ['Raman Peak (Ex' int2str(eem.ramanwave(1)) ...
            '/Em' int2str(eem.ramanwave(2)) ')'];
         ramanvalstr = num2str(eem.raman);

         if ~isempty(eem.diluent)
            dilstr = '(default)';
            dfstatus = 'on';
         else
            dilstr = 'none';
            dfstatus = 'off';
         end

         set(h_wavehvec,{'String'},[ex' ; em'])
         set(h_desc,'String',eem.description)
         set(h_dil,'String',dilstr,'UserData',eem.diluent,'Enable','on')
         set(h_df,'String',num2str(eem.df),'Enable',dfstatus)
         set(h_scatter,'String',correctstr,'Enable','on','UserData',correctstr)
         set(h_scatterstr,'UserData',correctstr)
         set(h_cal,'Value',calset,'Enable','on')
         set(h_ramanstr,'String',ramanstr)
         set(h_raman,'String',num2str(eem.raman),'Enable','on')
         set(h_cmd,'Enable','on')
         set(h_proc,'Enable','on')

      else  %calculated EEM

         correctstr = '[0 0;0 0;0 0;0 0]';

         [temp,caldate] = strtok(eem.calibration,'(');

         calset = 1;

         ramanstr = ['Raman Peak (Ex' int2str(calsets(1).ramanwave(1)) ...
            '/Em' int2str(calsets(1).ramanwave(2)) ')'];
         ramanvalstr = 'N/A';

         set(h_wavehvec,{'String'},[ex' ; em'])
         set(h_desc,'String',eem.description)
         set(h_exstart,'String',num2str(ex{1}),'UserData',ex)
         set(h_exend,'String',num2str(ex{2}))
         set(h_emstart,'String',num2str(em{1}),'UserData',em)
         set(h_emend,'String',num2str(em{2}))
         set(h_slit,'String',slitstr,'Value',slitval,'UserData',slits,'Enable','off')
         set(h_dil,'String','N/A','UserData',eem.diluent,'Enable','off')
         set(h_df,'String','N/A','Enable','off')
         set(h_scatter,'String',correctstr,'Enable','off','UserData',correctstr)
         set(h_scatterstr,'UserData',correctstr)
         set(h_cal,'Value',1,'Enable','off')
         set(h_ramanstr,'String',ramanstr)
         set(h_raman,'String','N/A','Enable','off')
         set(h_cmd,'Enable','off')
         set(h_proc,'Enable','on')

      end

      set(h_file,'UserData',[{eem},{filedata{2}},{filedata{3}}])

      drawnow

   end

end

function edit_eem(op,eemfile)
%Opens EEM data file for editing description and correction parameters
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

   h_dlg = findobj('Tag','dlgEditEEM');  %check for prior instance

   if ~isempty(h_dlg)  %if dialog already open restore focus

      figure(h_dlg)

   else  %new dialog

      curpath = pwd;

      if exist('eemfile') == 1
         if exist(eemfile) == 2
            eval(['load ''' eemfile ''' -mat'])
            eempath = curpath;
         else
            global EEMLOADPATH EEMSAVEPATH
            if ~isempty(EEMLOADPATH)
               cd(EEMLOADPATH)
               if exist(eemfile) == 2
                  eval(['load ''' eemfile ''' -mat'])
                  eempath = EEMLOADPATH;
               else
                  eem = [];
               end
               cd(curpath)
            elseif ~isempty(EEMSAVEPATH)
               cd(EEMSAVEPATH)
               if exist(eemfile) == 2
                  eval(['load ''' eemfile ''' -mat'])
                  eempath = EEMSAVEPATH;
               else
                  eem = [];
               end
               cd(curpath)
            else
               eem = [];
            end
         end
      else
         eem = [];
      end

      if isempty(eem)
         eemfile = '';
         eempath = '';
      end

      if length(findobj) > 1
         h_fig = gcf;
      else
         h_fig = [];
      end

      loaderror = 0;
      try
         load calibration.mat;
      catch
         loaderror = 1;
      end

      if loaderror == 1  %cancel dialog

         errorbox('init',['Cannot open dialog - calibration file ''calibration.mat''' ...
               'could not be loaded'])

      else  %create dialog box

         calsetnum = length(calsets);
         calsetmatch = 1;

         if ~isempty(eem)

            if ~isfield(eem,'type')  %update old eem file
               eem.type = 'data';
            end

            if strcmp(eem.type,'data')  %check for compatable eem type

               correctstr = ['[' num2str(eem.scattertol(1,1)) ' ' num2str(eem.scattertol(1,2)) ';' ...
                     num2str(eem.scattertol(2,1)) ' ' num2str(eem.scattertol(2,2)) ';' ...
                     num2str(eem.scattertol(3,1)) ' ' num2str(eem.scattertol(3,2)) ';' ...
                     num2str(eem.scattertol(4,1)) ' ' num2str(eem.scattertol(4,2)) ']'];

               %determine calset by date
               caldate = strtok(fliplr(strtok(fliplr(eem.calibration),'(')),')');

               calset = find(strcmp(cellstr(char(calsets.date)),caldate));

               if isempty(calset)
                  calset = calset(length(calset));  %select most recent calset matching date
               else
                  calset = calsetnum;  %use last calset
                  calsetmatch = 0;
               end

               if ~isempty(eem.diluent)
                  dilstr = '(default)';
                  dfstatus = 'on';
               else
                  dilstr = 'none';
                  dfstatus = 'off';
               end

               ramanvalstr = num2str(eem.raman);

               procstatus = 'on';
               ctrlvis = 'on';

            else  %calculated EEM

               calset = calsetnum;  %use last calset

               if ~isfield(eem,'ramanwave')  %apply default for outdated eems
                  eem.ramanwave = [275 303];
               end

               correctstr = '[0 0;0 0;0 0;0 0]';

               ramanvalstr = 'N/A';

               dilstr = 'N/A';
               dfstatus = 'off';
               cntrlvis = 'off';
               procstatus = 'on';

            end

            ex = [{eem.raw(1,2)},{eem.raw(1,size(eem.raw,2))}];
            em = [{eem.raw(2,1)},{eem.raw(size(eem.raw,1),1)}];

            if ~isfield(eem,'ramanwave')  %update outdated eem file
               eem.ramanwave = [275 303];
            end

         else  %use default settings

            eem = struct('type','data', ...
               'description','', ...
               'date','', ...
               'calibration','', ...
               'scatterpeaks',[], ...
               'scattertol',[], ...
               'ramanwave',calsets(calsetnum).ramanwave, ...
               'raman',[], ...
               'slits',[], ...
               'qsparms',[], ...
               'raw',[], ...
               'corrected',[], ...
               'blanked',[], ...
               'diluent',[], ...
               'df',1);

            ex = cell(1,2);
            em = cell(1,2);

            correctstr = ['[' num2str(scattertol(1,1)) ' ' num2str(scattertol(1,2)) ';' ...
                  num2str(scattertol(2,1)) ' ' num2str(scattertol(2,2)) ';' ...
                  num2str(scattertol(3,1)) ' ' num2str(scattertol(3,2)) ';' ...
                  num2str(scattertol(4,1)) ' ' num2str(scattertol(4,2)) ']'];

            ramanvalstr = '';

            calset = calsetnum;

            dilstr = 'none';
            dfstatus = 'off';
            procstatus = 'off';
            ctrlvis = 'on';

         end

           ramanstr = ['Raman Peak (Ex' num2str(calsets(calset).ramanwave(1)) ...
            '/Em' num2str(calsets(calset).ramanwave(2)) ')'];

         slits = calsets(calset).qsparms(1:2,:)';

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

           calsetstr = [char(calsets.date) repmat(' -- ',calsetnum,1) char(calsets.name)];

         screenres = get(0,'ScreenSize');

         h_dlg = figure('Visible','off', ...
            'Name','EEM Editor', ...
            'Units','pixels', ...
            'Renderer','zbuffer', ...
            'Color',[0.88 0.88 0.88], ...
            'Position',[screenres(3)-410 50 400 510], ...
            'MenuBar','none', ...
            'NumberTitle','off', ...
            'KeyPressFcn','figure(gcf)', ...
            'Resize','off', ...
            'ToolBar','none', ...
            'Tag','dlgEditEEM', ...
            'UserData',[{h_fig} {calsets} {scattertol}]);

         axis off

         bgcolor = [0.9 0.9 0.9];

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.8 .8 .8], ...
            'ForegroundColor',[.8 0 0], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[5 482 390 18], ...
            'String','Sample Scan');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'Position',[15 452 60 18], ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'String','EEM File');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'Enable','off', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[75 452 280 22], ...
            'HorizontalAlignment','left', ...
            'String',eemfile, ...
            'Tag','editFile', ...
            'UserData',[{eem},{eemfile},{eempath}]);

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 428 60 18], ...
            'String','Description');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[75 377 315 71], ...
            'Min',1, ...
            'Max',3, ...
            'HorizontalAlignment','left', ...
            'String',eem.description, ...
            'Tag','editDesc', ...
            'Callback','edit_eem(''desc'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 346 120 18], ...
            'String','Starting Excitation (nm)');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 321 120 18], ...
            'String','Ending Excitation (nm)');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[210 346 110 18], ...
            'String','Starting Emission (nm)');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[210 321 110 18], ...
            'String','Ending Emission (nm)');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[135 345 50 22], ...
            'HorizontalAlignment','left', ...
            'String',num2str(ex{1}), ...
            'Tag','editExStart', ...
            'UserData',ex, ...
            'Callback','edit_eem(''wave_ex1'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[135 320 50 22], ...
            'HorizontalAlignment','left', ...
            'String',num2str(ex{2}), ...
            'Tag','editExEnd', ...
            'CallBack','edit_eem(''wave_ex2'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[323 345 50 22], ...
            'HorizontalAlignment','left', ...
            'String',num2str(em{1}), ...
            'Tag','editEmStart', ...
            'UserData',em, ...
            'Callback','edit_eem(''wave_em1'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[323 320 50 22], ...
            'HorizontalAlignment','left', ...
            'String',num2str(em{2}), ...
            'Tag','editEmEnd', ...
            'CallBack','edit_eem(''wave_em2'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[40 286 30 18], ...
            'String','Slits');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','popup', ...
            'Enable','off', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[70 285 130 22], ...
            'HorizontalAlignment','left', ...
            'String',slitstr, ...
            'Value',slitval, ...
            'UserData',slits, ...
            'Tag','popSlit');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','checkbox', ...
            'BackgroundColor',bgcolor, ...
            'Position',[250 285 120 18], ...
            'HorizontalAlignment','left', ...
            'String','Plot After Edit', ...
            'TooltipString','Plot the edited EEM as a 3d surface or line', ...
            'Value',1, ...
            'Tag','chkAutoPlot');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.8 .8 .8], ...
            'ForegroundColor',[.8 0 0], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[5 247 390 18], ...
            'String','Diluent Scan');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 218 70 18], ...
            'String','Diluent EEM');

         h1 = uicontrol('Parent',h_dlg, ...
            'Enable',ctrlvis, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[85 218 268 22], ...
            'HorizontalAlignment','left', ...
            'String',dilstr, ...
            'Tag','editDil', ...
            'UserData',eem.diluent, ...
            'Callback','edit_eem(''diluent'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 189 150 18], ...
            'String','Dilution Factor (Vtot/Vsample)');

         h1 = uicontrol('Parent',h_dlg, ...
            'Enable',ctrlvis, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Enable',dfstatus, ...
            'String',num2str(eem.df), ...
            'Position',[165 189 60 20], ...
            'HorizontalAlignment','left', ...
            'Tag','editDF', ...
            'Callback','edit_eem(''dfact'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',[.8 .8 .8], ...
            'ForegroundColor',[.8 0 0], ...
            'FontSize',9, ...
            'FontWeight','bold', ...
            'Position',[5 148 390 18], ...
            'String','Correction Options');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','text', ...
            'BackgroundColor',bgcolor, ...
            'FontWeight','normal', ...
            'HorizontalAlignment','left', ...
            'Position',[15 118 150 18], ...
            'String',ramanstr, ...
            'Tag','txtRaman');

         h1 = uicontrol('Parent',h_dlg, ...
            'Enable',ctrlvis, ...
            'Style','edit', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[165 117 85 22], ...
            'HorizontalAlignment','left', ...
            'String',ramanvalstr, ...
            'Tag','editRaman', ...
            'UserData',eem.ramanwave, ...
            'Callback','edit_eem(''raman'')');

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
            'Enable',ctrlvis, ...
            'Style','edit', ...
            'Enable','on', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[115 86 215 22], ...
            'String',correctstr, ...
            'HorizontalAlignment','left', ...
            'Tag','editScatter', ...
            'UserData',correctstr, ...
            'Callback','edit_eem(''scatter'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Position',[337 86 50 22], ...
            'Enable','on', ...
            'String','Edit', ...
            'FontWeight','normal', ...
            'Enable',ctrlvis, ...
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
            'Enable',ctrlvis, ...
            'Style','popupmenu', ...
            'BackgroundColor',[1 1 1], ...
            'Position',[92 55 295 20], ...
            'String',calsetstr, ...
            'Tag','popCal', ...
            'Value',calset, ...
            'CallBack','edit_eem(''calset'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'Enable',procstatus, ...
            'FontWeight','bold', ...
            'Position',[334 5 64 26], ...
            'String','Proceed', ...
            'Tag','cmdProceed', ...
            'Callback','edit_eem(''eval'')', ...
            'TooltipString','Create new EEM file with current settings');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontWeight','bold', ...
            'Position',[168 5 64 26], ...
            'String','Clear', ...
            'Tag','cmdNew', ...
            'Callback','edit_eem(''clear'')', ...
            'TooltipString','Clear fields');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontWeight','bold', ...
            'Position',[2 5 64 26], ...
            'String','Close', ...
            'Tag','cmdClose', ...
            'Callback',['confirmdlg(''init'',''Close the EEM Editor?  ' ...
               '(changes will not be saved)'',''edit_eem(''''close'''')'')'], ...
            'TooltipString','Close the dialog box');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Position',[360 454 28 20], ...
            'String','...', ...
            'Tag','cmdBrowseEEM', ...
            'TooltipString','Browse for EEM data file', ...
            'CallBack','edit_eem(''browse_eem'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Position',[360 220 28 20], ...
            'String','...', ...
            'Enable',ctrlvis, ...
            'Tag','cmdBrowseDil', ...
            'TooltipString','Browse for diluent EEM file', ...
            'CallBack','edit_eem(''browse_dil'')');

         h1 = uicontrol('Parent',h_dlg, ...
            'Style','pushbutton', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Position',[258 119 28 20], ...
            'String','...', ...
            'Enable',ctrlvis, ...
            'Tag','cmdBrowseRaman', ...
            'TooltipString','Calculate Raman peak from scan file', ...
            'Callback','edit_eem(''browse_raman'')');

         set(h_dlg,'Visible','on')

         if calsetmatch == 0
            messagebox('init', ...
               'Warning - no matching calibration set was found (using last set)', ...
               '', ...
               'Warning', ...
               [.8 0 0])
         end

      end

   end

else

   %get key handles
   h_dlg = findobj('Tag','dlgEditEEM');

   h_file = findobj(h_dlg,'Tag','editFile');
   h_desc = findobj(h_dlg,'Tag','editDesc');

   h_exstart = findobj(h_dlg,'Tag','editExStart');
   h_exend = findobj(h_dlg,'Tag','editExEnd');
   h_emstart = findobj(h_dlg,'Tag','editEmStart');
   h_emend = findobj(h_dlg,'Tag','editEmEnd');

   %get filename editbox value
   filedata = get(h_file,'UserData');
   eem = filedata{1};

   if strcmp(op,'close')  %close dialog box

      storedvals = get(h_dlg,'UserData');
      h_fig = storedvals{1};

      close(h_dlg)

      if ~isempty(h_fig)
         if length(findobj) > 2
            figure(h_fig)
         end
      end

   elseif strcmp(op(1,1:4),'wave')  %evaluate wavelength editbox callbacks

      ex = get(h_exstart,'UserData');
      em = get(h_emstart,'UserData');

      switch op
      case 'wave_ex1'
         h = h_exstart;
         minval = ex{1};
         maxval = str2num(get(h_exend,'String'));
      case 'wave_ex2'
         h = h_exend;
         minval = str2num(get(h_exstart,'String'));
         maxval = ex{2};
      case 'wave_em1'
         h = h_emstart;
         minval = em{1};
         maxval = str2num(get(h_emend,'String'));
      case 'wave_em2'
         h = h_emend;
         minval = str2num(get(h_emstart,'String'));
         maxval = em{2};
      otherwise
         h = [];
      end

      if ~isempty(h)

         val = str2num(get(h,'String'));

         if isempty(val)
            set(h,'String',num2str(minval))
         elseif val < minval
            set(h,'String',num2str(minval))
         elseif val > maxval
            set(h,'String',num2str(maxval))
         end

         drawnow

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

   elseif strcmp(op,'eval')

      error = 0;

      origeem = eem;  %buffer original eem data

      set(h_dlg,'Pointer','watch')

      ex_rng = [str2num(get(h_exstart,'String')) str2num(get(h_exend,'String'))];
      em_rng = [str2num(get(h_emstart,'String')) str2num(get(h_emend,'String'))];
      [ex,em,fl] = unwrapeem(origeem.raw);
      I_ex = find(ex >= ex_rng(1) & ex <= ex_rng(2));
      I_em = find(em >= em_rng(1) & em <= em_rng(2));

      if strcmp(eem.type,'data')

         h_cal = findobj(h_dlg,'Tag','popCal');
         h_scatter = findobj(h_dlg,'Tag','editScatter');
         h_raman = findobj(h_dlg,'Tag','editRaman');

         caldata = get(h_dlg,'UserData');
         calsets = caldata{2};
         calset = get(h_cal,'Value');  %get calibration set #

         h_slits = findobj(h_dlg,'Tag','popSlit');
         slitval = get(h_slits,'Value');
         slitdata = get(h_slits,'UserData');

         h_dil = findobj(h_dlg,'Tag','editDil');
         h_df = findobj(h_dlg,'Tag','editDF');

         %initialize new eem variable
         eem = struct('type','data', ...
            'description',deblank(get(h_desc,'String')), ...
            'date',origeem.date, ...
            'calibration',[calsets(calset).name ' (' calsets(calset).date ')'], ...
            'scatterpeaks',calsets(calset).scatterpeaks, ...
            'scattertol',str2num(get(h_scatter,'String')), ...
            'ramanwave',origeem.ramanwave, ...
            'raman',str2num(get(h_raman,'String')), ...
            'slits',slitdata(slitval,:), ...
            'qsparms',[], ...
            'raw',wrapeem(ex(I_ex),em(I_em),fl(I_em,I_ex)), ...
            'corrected',[], ...
            'blanked',[], ...
            'diluent',get(h_dil,'UserData'), ...
            'df',str2num(get(h_df,'String')));

         if ~isempty(eem.raw) & ~isempty(eem.raman) & ~isempty(eem.scattertol) & ~isempty(eem.slits)

            qsmatrix = calsets(calset).qsparms;
            qscol = find(qsmatrix(1,:)==eem.slits(1) & qsmatrix(2,:)==eem.slits(2));
            if ~isempty(qscol)
               if ~isnan(qsmatrix(3,qscol))
                  eem.qsparms = qsmatrix(3:5,qscol);
               end
            end

            if sum(sum(eem.scattertol)) > 0  %test for valid correction parameters

               warning off
               eem.corrected = rmn2qse(cfactor(cleanscan(eem_math('A./B',[{eem.raw},{eem.raman}]), ...
                     eem.scattertol,eem.scatterpeaks),calsets(calset).correctmatrix),eem.qsparms);

                 if ~isempty(eem.df) & ~isempty(eem.diluent)
                    eem.blanked = undilute(eem.corrected,eem.df,eem.diluent);
               end

            end

         end

      else  %calculated EEM

         %initialize new eem variable
         eem = struct('type',origeem.type, ...
            'description',deblank(get(h_desc,'String')), ...
            'date',origeem.date, ...
            'calibration',[], ...
            'scatterpeaks',[], ...
            'scattertol',[], ...
            'ramanwave',[], ...
            'raman',[], ...
            'slits',[], ...
            'qsparms',[], ...
            'raw',wrapeem(ex(I_ex),em(I_em),fl(I_em,I_ex)), ...
            'corrected',[], ...
            'blanked',[], ...
            'diluent',[], ...
            'df',[]);

      end

        if strcmp(eem.description,'(default)')  %use default description
           eem.description = origeem.description;
      end

      set(h_dlg,'Pointer','arrow')

      fn = filedata{2};
      pn = filedata{3};

      global EEMSAVEPATH EEMLOADPATH
      curpath = pwd;
      error = 0;

      if ~isempty(pn)
         cd(pn)
      elseif ~isempty(EEMSAVEPATH)
         cd(EEMSAVEPATH)
      elseif ~isempty(EEMLOADPATH)
         cd(EEMLOADPATH)
      end

      [fn,pn] = uiputfile(fn,'Select filename and location for editted EEM');
      if fn ~= 0
         fn = [strtok(fn,'.') '.eem'];
         cd(pn)
         save(fn,'eem')
         cd(curpath)
      end

      drawnow

      h_autoplot = findobj(h_dlg,'Tag','chkAutoPlot');
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

   elseif strcmp(op(1,1:4),'brow')  %process calls to browse for files

      switch op(1,8:length(op))
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

            switch op(1,8:length(op))

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
                  edit_eem('raman')
               else
                  errormsg = str2mat(['''' fn ''' does not contain valid emmission data at ' ...
                     num2str(ramanwave(1)) 'nm'],'(the Raman reference excitation wavelength)');
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

                  edit_eem('newfile')

               else  %bad file

                  errormsg = ['''' fn ''' is not a valid EEM data file'];

               end

            case 'dil'

               %post filename to editbox, clear stored data
               h_dil = findobj(h_dlg,'Tag','editDil');
               set(h_dil,'String',fn,'UserData',[])

               cd(curpath)

               %proceed to diluent sub
               edit_eem('diluent')

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
      h_dil = findobj(h_dlg,'Tag','editDil');
      h_df = findobj(h_dlg,'Tag','editDF');
      h_scatter = findobj(h_dlg,'Tag','editScatter');
      h_scatterstr = findobj(h_dlg,'Tag','txtScatter');
      h_cal = findobj(h_dlg,'Tag','popCal');
      h_ramanstr = findobj(h_dlg,'Tag','txtRaman');
      h_raman = findobj(h_dlg,'Tag','editRaman');
      h_cmd = [findobj(h_dlg,'Tag','cmdScatter'); ...
            findobj(h_dlg,'Tag','cmdBrowseDil'); ...
            findobj(h_dlg,'Tag','cmdBrowseRaman')];

      storedvals = get(h_dlg,'UserData');
      calsets = storedvals{2};
      scattertol = storedvals{3};

      ex = [{eem.raw(1,2)},{eem.raw(1,size(eem.raw,2))}];
      em = [{eem.raw(2,1)},{eem.raw(size(eem.raw,1),1)}];

      if strcmp(eem.type,'data')

         correctstr = ['[' num2str(eem.scattertol(1,1)) ' ' num2str(eem.scattertol(1,2)) ';' ...
            num2str(eem.scattertol(2,1)) ' ' num2str(eem.scattertol(2,2)) ';' ...
            num2str(eem.scattertol(3,1)) ' ' num2str(eem.scattertol(3,2)) ';' ...
            num2str(eem.scattertol(4,1)) ' ' num2str(eem.scattertol(4,2)) ']'];

         caldate = strtok(fliplr(strtok(fliplr(eem.calibration),'(')),')');
         calset = find(strcmp(cellstr(char(calsets.date)),caldate));
         if ~isempty(calset)
            calset = calset(length(calset));
         else
            calset = 1;
         end

         if ~isfield(eem,'ramanwave')  %update outdated eem file
            eem.ramanwave = [275 303];
         end

         ramanstr = ['Raman Peak (Ex' num2str(eem.ramanwave(1)) ...
            '/Em' num2str(eem.ramanwave(2)) ')'];
         ramanvalstr = num2str(eem.raman);

          slits = calsets(calset).qsparms(1:2,:)';

         slitval = find(slits(:,1)==eem.slits(1) & slits(:,2)==eem.slits(2));
         if isempty(slitval)
              slitval = size(slits,1);
         end

         slitstr = [num2str(slits(1,1)) 'nm Ex, ' num2str(slits(1,2)) 'nm Em Slits'];
         for n = 2:size(slits,1)
            slitstr = [slitstr '|' ...
            num2str(slits(n,1)) 'nm Ex, ' num2str(slits(n,2)) 'nm Em Slits'];
         end

         if ~isempty(eem.diluent)
            dilstr = '(default)';
            dfstatus = 'on';
         else
            dilstr = 'none';
            dfstatus = 'off';
         end

         set(h_desc,'String',eem.description)
         set(h_exstart,'String',num2str(ex{1}),'UserData',ex)
         set(h_exend,'String',num2str(ex{2}))
         set(h_emstart,'String',num2str(em{1}),'UserData',em)
         set(h_emend,'String',num2str(em{2}))
         set(h_slit,'String',slitstr,'Value',slitval,'UserData',slits,'Enable','on')
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

         ramanstr = ['Raman Peak (Ex' num2str(calsets(1).ramanwave(1)) ...
            '/Em' num2str(calsets(1).ramanwave(2)) ')'];
         ramanvalstr = 'N/A';

          slits = calsets(1).qsparms(1:2,:)';

         slitval = find(slits(1,1)==5 & slits(1,2)==5);
         if isempty(slitval)
              slitval = size(slits,1);
         end

         slitstr = [num2str(slits(1,1)) 'nm Ex, ' num2str(slits(1,2)) 'nm Em Slits'];
         for n = 2:size(slits,1)
            slitstr = [slitstr '|' ...
            num2str(slits(n,1)) 'nm Ex, ' num2str(slits(n,2)) 'nm Em Slits'];
         end

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

   elseif strcmp(op,'desc')  %validate description editbox entry

      if isempty(deblank(get(h_desc,'String')))
         set(h_desc,'String','(default)')
      end

   elseif strcmp(op,'dfact')

      h_df = findobj(h_dlg,'Tag','editDF');
      str = deblank(get(h_df,'String'));

      if isempty(str)
         set(h_df,'String','1');
      end

      edit_eem('status')

   elseif strcmp(op,'diluent')  %validate diluent editbox, manage DF editbox

      h_dil = findobj(h_dlg,'Tag','editDil');
      h_df = findobj(h_dlg,'Tag','editDF');
      fn = deblank(get(h_dil,'String'));

      if isempty(fn)
         fn = '(default)';
      end

      if strcmp(fn,'(default)')  %use default in EEM file

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

      edit_eem('status')

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
            set(h_raman,'String',num2str(eem.raman))  %reset default raman
            errorbox('init','Invalid Raman peak value')
         end

      elseif ~isempty(eem)

         set(h_raman,'String',num2str(eem.raman))  %reset default raman

      end

      edit_eem('status')

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

      edit_eem('status')

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

      if ~isfield(eem,'ramanwave')
         ramanwave = [275 303];
      end

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
      h_slit = findobj(h_dlg,'Tag','popSlit');
      h_cal = findobj(h_dlg,'Tag','popCal');
      h_cmd = [findobj(h_dlg,'Tag','cmdScatter'); ...
            findobj(h_dlg,'Tag','cmdBrowseDil'); ...
            findobj(h_dlg,'Tag','cmdBrowseRaman')];

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

      set(h_edit,'String','','Enable','on')
      set(h_desc,'String','(default)')
      set(h_file,'UserData',cell(1,3),'Enable','off')
      set(h_exstart,'UserData',cell(1,2))
      set(h_emstart,'UserData',cell(1,2))
      set(h_df,'String','1','Enable','off')
      set(h_scatter,'String',correctstr,'UserData',correctstr)
      set(h_slit,'String',slitstr,'Value',slitval,'UserData',slits,'Enable','on')
      set(h_cal,'Value',calset,'Enable','on')
      set(h_proc,'Enable','off')
      set(h_cmd,'Enable','on')

      edit_eem('diluent')  %reset diluent fields

   end

end

function surfintegrate(op,h_fig)
%syntax:  surfintegrate(op,h_fig)
%
%Surface integration dialog called by 'eemplot'.
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

warning off %disable spurious divide-by-zero warnings in 'inside.m'

if nargin == 0  %default to open dialog box
   op = 'init';
end

if strcmp(op,'init')  %initialize or activate integration dialog

   if exist('h_fig') ~= 1
      h_fig = gcf;
   end

   h_dlg = findobj('Tag','surfintdlg');  %check for prior instance of dialog

   if ~isempty(h_dlg)  %create new dialog box

      h_oldfig = get(h_dlg,'UserData');  %get handle of prior EEM figure

      set(h_dlg,'UserData',h_fig);  %update stored figure handle

      figure(h_dlg)  %activate dialog
      drawnow

      %clear intregration field
      h_integral = findobj(h_dlg,'Tag','integralval');
      set(h_integral,'String','')

      surfintegrate('update')

      if h_oldfig ~= h_fig
         %clear existing polygon lines on prior figure
         h_line = findobj(h_oldfig,'Tag','polyline');
         if ~isempty(h_line)
            delete(h_line)
         end
      end

   else

      %get global polygon data or load defaults
      global POLYDATA POLYROW POLYSELECT
      if ~isempty(POLYDATA)
         polydata = POLYDATA;
         val = POLYROW;
         rowsel = POLYSELECT;
      else
         if exist('polydata.mat') == 2
            load polydata
            val = lastval;
         else
            polydata = [{'-none-'} {1} {''} {[]}];
            val = 1;
         end
         rowsel = ones(size(polydata,1),1);
         POLYDATA = polydata;
         POLYROW = val;
         POLYSELECT = rowsel;
      end

      %parse polygon database information
      namelist = char(polydata{1,1});
      for n = 2:size(polydata,1)
         namelist = [namelist '|' char(polydata{n,1})];
      end

      shapeval = polydata{val,2};

      createdstr = polydata{val,3};

      if ~isempty(polydata{val,4})
         polygon = polydata{val,4};
         exmin = num2str(roundsig(min(polygon(:,1)),5));
         exmax = num2str(roundsig(max(polygon(:,1)),5));
         emmin = num2str(roundsig(min(polygon(:,2)),5));
         emmax = num2str(roundsig(max(polygon(:,2)),5));
      else
         exmin = '';
         exmax = '';
         emmin = '';
         emmax = '';
      end

      %set UI property constants
      if shapeval == 4
         enableedit = 'on';
      else
         enableedit = 'off';
      end

      if val == 1
         buttonstatus = 'off';
      else
         buttonstatus = 'on';
      end

      screen = get(0,'ScreenSize');

      %create GUI
      h_dlg = figure( ...
         'Visible','off', ...
         'Name','Surface Integration', ...
         'Units','pixels', ...
         'Position',[screen(3)-500 50 500 250], ...
         'MenuBar','none', ...
         'Resize','off', ...
         'NumberTitle','off', ...
         'DefaultUiControlUnits','normal', ...
         'KeyPressFcn','figure(gcf)', ...
         'Tag','surfintdlg', ...
         'UserData',h_fig);

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.01 .85 .114 .1], ...
         'String','Load', ...
         'Tag','pathcache', ...
         'TooltipString','Load a new polygon data file', ...
         'UserData','', ...
         'Callback','surfintegrate(''loadpoly'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.134 .85 .114 .1], ...
         'String','Save', ...
         'TooltipString','Save polygon data to disk', ...
         'Callback','surfintegrate(''savepoly'')');

      uicontrol(h_dlg, ...
         'Enable',buttonstatus, ...
         'Style','pushbutton', ...
         'Position',[.258 .85 .114 .1], ...
         'String','Create', ...
         'TooltipString','Create a new polygon using the mouse', ...
         'Tag','createpoly', ...
         'UserData',[], ...
         'Callback','surfintegrate(''createpoly'')');

      uicontrol(h_dlg, ...
         'Enable','on', ...
         'Style','pushbutton', ...
         'Position',[.382 .85 .114 .1], ...
         'String','Edit', ...
         'Tag','editbutton', ...
         'UserData',0, ...
         'TooltipString','Edit selected polygon', ...
         'Callback','surfintegrate(''editpoly'')');

      uicontrol(h_dlg, ...
         'Enable',buttonstatus, ...
         'Style','pushbutton', ...
         'Position',[.506 .85 .114 .1], ...
         'String','Rename', ...
         'TooltipString','Rename the current polygon', ...
         'Tag','buttonstatus', ...
         'Callback','surfintegrate(''name_init'')');

      uicontrol(h_dlg, ...
         'Enable',buttonstatus, ...
         'Style','pushbutton', ...
         'Position',[.63 .85 .114 .1], ...
         'String','Delete', ...
         'TooltipString','Delete the current polygon', ...
         'Tag','buttonstatus', ...
         'Callback','surfintegrate(''deletepoly'')');

      uicontrol(h_dlg, ...
         'Enable',buttonstatus, ...
         'Style','togglebutton', ...
         'Value',0, ...
         'Position',[.754 .85 .114 .1], ...
         'String','Show', ...
         'TooltipString','Show the current polygon on the active figure', ...
         'Tag','showpoly', ...
         'UserData',[], ...
         'Callback','surfintegrate(''showpoly'')');

      uicontrol(h_dlg, ...
         'Enable',buttonstatus, ...
         'Style','pushbutton', ...
         'Position',[.878 .85 .114 .1], ...
         'String','EEM', ...
         'TooltipString','Choose an EEM figure to use for surface integration', ...
         'Callback','surfintegrate(''pickeem'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.02 .05 .12 .1], ...
         'String','Close', ...
         'TooltipString','Close the dialog box (without saving data!)', ...
         'Tag','polycolor', ...
         'UserData',[1 1 1], ...
         'Callback','surfintegrate(''close'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Enable','off', ...
         'Position',[.18 .05 .12 .1], ...
         'String','Undo', ...
         'Tag','undobutton', ...
         'TooltipString','Restore polygon data prior to the last edit or deletion', ...
         'Callback','surfintegrate(''undo'')', ...
         'UserData',cell(1,3));

      uicontrol(h_dlg, ...
         'Style','toggle', ...
         'Position',[.37 .05 .12 .1], ...'
         'String','Normal Res', ...
         'Value',1, ...
         'BackgroundColor',[0 1 0], ...
         'TooltipString',['Perform surface integrations at default EEM resolution'], ...
         'Tag','res_norm', ...
         'UserData',0, ...
         'Callback','surfintegrate(''res_norm'')');

      uicontrol(h_dlg, ...
         'Style','toggle', ...
         'Position',[.49 .05 .12 .1], ...'
         'String','High Res', ...
         'Value',0, ...
         'TooltipString',['Perform surface integrations at 1nm EEM resolution'], ...
         'Tag','res_high', ...
         'Callback','surfintegrate(''res_high'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.62 .05 .12 .1], ...
         'String','Integrate', ...
         'Tag','buttonstatus', ...
         'TooltipString','Integrate under the surface bounded by the current polygon', ...
         'Callback','surfintegrate(''integrate'')');

      uicontrol(h_dlg, ...
         'Style','frame', ...
         'Position',[.75 .02 .24 .19], ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 0 0]);

      uicontrol(h_dlg, ...
         'Style','frame', ...
         'Position',[.01 .25 .98 .55], ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 .8 .8]);

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.02 .72 .96 .06], ...
         'String','Current Polygon Information', ...
         'FontWeight','bold', ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.9 .9 .9], ...
         'HorizontalAlignment','center', ...
         'Tag','lastval', ...
         'UserData',[]);

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.02 .6 .7 .06], ...
         'String','Polygon Name', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.76 .6 .22 .06], ...
         'String','Polygon Type', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','popup', ...
         'Position',[.02 .52 .7 .08], ...
         'String',namelist, ...
         'Value',val, ...
         'TooltipString','Select a polygon from a drop-down list', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'HorizontalAlignment','left', ...
         'Tag','polyname', ...
         'Callback','surfintegrate(''newpoly'')', ...
         'UserData',[{polydata} {rowsel}]);

      uicontrol(h_dlg, ...
         'Style','popup', ...
         'Enable','off', ...
         'Position',[.76 .52 .22 .08], ...
         'String','  |Freeform|Circle|Rectangle', ...
         'Value',shapeval, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','polyshape', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.02 .4 .3 .06], ...
         'String','Created', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.34 .4 .145 .06], ...
         'String','Min Ex', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.505 .4 .145 .06], ...
         'String','Max Ex', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.67 .4 .145 .06], ...
         'String','Min Em', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.835 .4 .145 .06], ...
         'String','Max Em', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','edit', ...
         'Enable','off', ...
         'Position',[.02 .315 .3 .085], ...
         'String',createdstr, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','polydate', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','edit', ...
         'Enable','off', ...
         'Position',[.34 .315 .145 .085], ...
         'String',exmin, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','wave1', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','edit', ...
         'Enable','off', ...
         'Position',[.505 .315 .145 .085], ...
         'String',exmax, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','wave2', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','edit', ...
         'Enable','off', ...
         'Position',[.67 .315 .145 .085], ...
         'String',emmin, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','wave3', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','edit', ...
         'Enable','off', ...
         'Position',[.835 .315 .145 .085], ...
         'String',emmax, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','wave4', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.77 .13 .2 .06], ...
         'String','Result', ...
         'FontWeight','bold', ...
         'ForegroundColor',[1 1 1], ...
         'BackgroundColor',[.8 0 0], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.77 .05 .2 .07], ...
         'String','', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','integralval', ...
         'HorizontalAlignment','center');

      set(h_dlg,'Visible','on'); drawnow

      surfintegrate('plotpoly')

   end

else  %dialog open - process callbacks

   %get primary handles
   h = findobj('Tag','surfintdlg');
   h_fig = get(h,'UserData');

   %get stored polygon matrix database
   h_polyname = findobj(h,'Tag','polyname');
   storedvals = get(h_polyname,'UserData');
   polydata = storedvals{1};
   rowsel = storedvals{2};
   val = get(h_polyname,'Value');

   if strcmp(op,'close')  %close dialog box

      %update shared data
      global POLYDATA POLYROW POLYSELECT
      POLYDATA = polydata;
      POLYROW = val;
      POLYSELECT = rowsel;

      close(h)
      drawnow

      tags = [{'namedlg'} {'polyvertdlg'} {'newpolydialog'}];

      for n = 1:length(tags)
         h = findobj('Tag',char(tags{n}));
         close(h)
      end

      h_line = findobj(h_fig,'Tag','polyline');
      if ~isempty(h_line)
           delete(h_line)
      end

      h_intmulti = findobj('Tag','surfintmultidlg');
      if ~isempty(h_intmulti)
         figure(h_intmulti)
         surfintmulti('reset')
      else
         figure(h_fig)
      end

   elseif strcmp(op,'undo')  %restore data prior to last edit/deletion

      h_undo = findobj(h,'Tag','undobutton');
      undodata = get(h_undo,'UserData');

      h_lastval = findobj(h,'Tag','lastval');

      if ~isempty(undodata{1})
         set(h_polyname,'Value',undodata{2}, ...
            'UserData',[{undodata{1}} {undodata{3}}])
         set(h_lastval,'UserData',undodata{2})
         set(h_undo,'UserData',cell(1,3))
      end

      surfintegrate('newdata')

   elseif strcmp(op,'integrate')  %perform selected integration on current surface plot

      h_integral = findobj(h,'Tag','integralval');
      set(h_integral,'String','')

      h_res = findobj(h,'Tag','res_norm');
      res = get(h_res,'UserData');

      polygon = polydata{val,4};
      vol = [];

      if ~isempty(polygon)

         h_s = findobj(h_fig,'Type','surface');

         if ~isempty(h_s)

            eem = get(h_s,'UserData');
            if isempty(eem)
               eem = wrapeem(get(h_s,'XData'),get(h_s,'YData'),get(h_s,'ZData'));
            end

            if ~isempty(eem)
               set(h,'Pointer','watch')
               vol = intlasso(eem,polygon,res);
               set(h,'Pointer','arrow')
            end

         end

      end

      if ~isempty(vol)
         set(h_integral,'String',num2str(vol,'%0.2f'))
      else
         set(h_integral,'String','')
      end

   elseif strcmp(op,'pickeem')  %select EEM figure for integrations

      h_eems = sort(findobj('Tag','eemplotfig'));
      fignames = cell(1,length(h_eems));
      sellist = 1;

      for n = 1:length(h_eems)
         fignames{n} = get(h_eems(n),'Name');
         if h_eems(n) == h_fig
            sellist = n;
         end
      end

      figpos = get(h,'Position');

      figsel = listdialog('Name','EEM Figure Selection', ...
         'PromptString','Choose the EEM plot to use for integrations from the list', ...
         'ListString',fignames, ...
         'SelectionMode','single', ...
         'ListSize',[figpos(1)+90 figpos(2)+120 400 150], ...
         'InitialValue',sellist);

      if ~isempty(figsel)

         set(h,'UserData',h_eems(figsel));

         figure(h_eems(figsel))

         figure(h)

         drawnow

         %clear existing polygon line
         h_line = findobj(h_fig,'Tag','polyline');
         if ~isempty(h_line)
             delete(h_line)
         end

         surfintegrate('update')

      end

   elseif strcmp(op,'update')

      %clear integral field
      h_integral = findobj(h,'Tag','integralval');
      set(h_integral,'String','')

      surfintegrate('plotpoly')

   elseif strcmp(op,'loadpoly') | strcmp(op,'savepoly')  %load/save polygon data file

      error = 0;
      errormsg = '';
      curpath = pwd;

      global EEMTOOLSPATH
      if ~isempty(EEMTOOLSPATH)
         lastpath = EEMTOOLSPATH;
      else
         lastpath = curpath;
      end

      try
         cd(lastpath)
      catch
         error = 1;
         errormsg = 'Invalid pathname';
      end

      if error == 0

         if strcmp(op,'loadpoly')

            [filename,pathname] = uigetfile('*.mat','Select new polygon data file');

            if filename ~= 0

               h_undo = findobj(h,'Tag','undobutton');
               set(h_undo,'UserData',[{polydata} {val}])

               clear polydata

               cd(pathname)
               try
                  load(filename)
               catch
                  error = 1;
                  errormsg = 'Invalid data file';
               end

               if error == 0

                  if exist('polydata') ~= 1 | exist('lastval') ~= 1
                     error = 1;
                     errormsg = 'Invalid data file';
                  elseif size(polydata,2) ~= 4
                     error = 1;
                     errormsg = 'Invalid polygon data in file';
                  end

               end

               if error == 0

                  rowsel = ones(size(polydata,1),1);
                  set(h_polyname,'UserData',[{polydata} {rowsel}])

                  h_lastval = findobj(h,'Tag','lastval');
                  set(h_lastval,'UserData',lastval)

                  surfintegrate('newdata')

               end

            end

         else  %save polygon data

            [filename,pathname] = uiputfile('*.mat','Select polygon data file to save');

            if filename ~= 0

               lastval = val;

               cd(pathname)
               eval(['save ''' filename ''' polydata lastval'], ...
                  'error = 1; errormsg = ''Errors encountered saving polygon data'';')
               cd(curpath)

            end

         end

      end

      cd(curpath)

      if error ~= 0

         errorbox('init',errormsg)

      end

   elseif strcmp(op,'newpoly')  %parse polygon data and fill database fields

      %get field handles
      h_polyshape = findobj(h,'Tag','polyshape');
      h_polydate = findobj(h,'Tag','polydate');
      h_wave1 = findobj(h,'Tag','wave1');
      h_wave2 = findobj(h,'Tag','wave2');
      h_wave3 = findobj(h,'Tag','wave3');
      h_wave4 = findobj(h,'Tag','wave4');
      h_integral = findobj(h,'Tag','integralval');

      %test for invalid row selection
      if val > size(polydata,1)
         val = size(polydata,1);
      end

      %test for presence of polygon data matrix
      if ~isempty(polydata{val,4})
         polygon = polydata{val,4};
         exmin = num2str(roundsig(min(polygon(:,1)),5));
         exmax = num2str(roundsig(max(polygon(:,1)),5));
         emmin = num2str(roundsig(min(polygon(:,2)),5));
         emmax = num2str(roundsig(max(polygon(:,2)),5));
      else
         exmin = '';
         exmax = '';
         emmin = '';
         emmax = '';
      end

      %update field contents
      set(h_polyshape,'Value',polydata{val,2})
      set(h_polydate,'String',char(polydata{val,3}))
      set(h_wave1,'String',exmin)
      set(h_wave2,'String',exmax)
      set(h_wave3,'String',emmin)
      set(h_wave4,'String',emmax)
      set(h_integral,'String','')

      %update command button status
      surfintegrate('buttonvis')

      %show/hide polygons according to setting
      surfintegrate('plotpoly')

   elseif strcmp(op,'newdata')  %process new polygon data

      h_lastval = findobj(h,'Tag','lastval');
      lastval = min(get(h_lastval,'UserData'),size(polydata,1));

      %sort polygon data
      namestr = char(polydata{:,1});    %retrieve polygon names into str matrix
      temp = double(namestr(:,1:3));    %convert 3 cols of matrix to numerical equivalents
      temp = [temp(:,1)*1e6 + temp(:,2)*1e3 + temp(:,3)];  %form weighted singe #
      [temp,I] = sort(temp(2:size(temp,1),:));  %sort rows 2 to end
      I = [1 ; I + ones(length(I),1)];  %shift index to account for field #1
      polydata = polydata(I,:);         %apply sorted index
      rowsel = rowsel(I);
      lastval = find(I == lastval);     %relocated original row selection

      %parse polygon names into uicontrol string
      namelist = char(polydata{1,1});
      for n = 2:size(polydata,1)
         namelist = [namelist '|' char(polydata{n,1})];
      end

      %update uicontrol string
      set(h_polyname, ...
         'String',namelist, ...
         'UserData',[{polydata} {rowsel}], ...
         'Value',lastval)

      %update remaining fields
      surfintegrate('newpoly')

   elseif strcmp(op,'deletepoly')  %delete current polygon data from list

      %backup original data
      h_undo = findobj(h,'Tag','undobutton');
      set(h_undo,'UserData',[{polydata} {val} {rowsel}])

      h_lastval = findobj(h,'Tag','lastval');

      %perform deletion - update row selection
      if val < size(polydata,1)
         polydata = [polydata(1:val-1,:) ; polydata(val+1:size(polydata,1),:)];
         rowsel = [rowsel(1:val-1) ; rowsel(val+1:length(rowsel))];
         set(h_lastval,'UserData',val)
      else
         polydata = polydata(1:val-1,:);
         rowsel = rowsel(1:val-1);
         set(h_lastval,'UserData',val-1)
      end

      %store new polygon data
      set(h_polyname,'UserData',[{polydata} {rowsel}])

      %process new data
      surfintegrate('newdata')

   elseif strcmp(op,'showpoly')  %toggle drawing of polygon on the EEM figure

      h_show = findobj(h,'Tag','showpoly');
      showval = get(h_show,'Value');

      if showval == 0
         h_undo = findobj(h,'Tag','undobutton');
         set(h_show, ...
            'BackgroundColor',get(h_undo,'BackgroundColor'), ...
            'UserData',[])
      else
         set(h_show,'BackgroundColor',[0 1 0])
         newcolor = uisetcolor('Choose a Polygon Color');
         if length(newcolor) == 3
            set(h_show,'UserData',newcolor)
         else
            set(h_show, ...
               'Value',0, ...
               'BackgroundColor',get(h_undo,'BackgroundColor'), ...
               'UserData',[])
         end
      end

      surfintegrate('plotpoly')

   elseif strcmp(op,'plotpoly')  %draw current polygon on the EEM figure

      h_show = findobj(h,'Tag','showpoly');
      showval = get(h_show,'Value');

      %clear existing polygon line
      h_line = findobj(h_fig,'Tag','polyline');
        if ~isempty(h_line)
           delete(h_line)
      end

      if showval == 1

         h_axes = findobj(h_fig,'Type','axes');

         if ~isempty(h_axes)

            if strcmp(get(h_axes(1),'Tag'),'Colorbar') ~= 1
               h_ax = h_axes(1);
            else
               h_ax = h_axes(2);
            end

            zlim = get(h_ax,'ZLim');
            polygon = polydata{val,4};

            if ~isempty(polygon)

               newcolor = get(h_show,'UserData');

               if isempty(newcolor)
                  newcolor = uisetcolor('Choose a Polygon Color');
               end

               if length(newcolor) == 3

                  line('Parent',h_ax, ...
                     'XData',polygon(:,1), ...
                     'YData',polygon(:,2), ...
                     'ZData',ones(size(polygon,1),1).*(zlim(2)+2*eps), ...
                     'LineWidth',1, ...
                     'Color',newcolor, ...
                     'Tag','polyline', ...
                     'ButtonDownFcn','uisetcolor(gcbo,''Change Polygon Color'');');

                  drawnow

               end

            end

         end

      end

   elseif strcmp(op,'editpoly')  %edit current polygon

      h_edit = findobj(h,'Tag','editbutton');
      set(h_edit,'UserData',1)

      h_createpoly = findobj(h,'Tag','createpoly');
      set(h_createpoly,'UserData',[])

      surfintegrate('createpoly')

   elseif strcmp(op,'createpoly')  %create new polygon

      h_createpoly = findobj(h,'Tag','createpoly');
      h_edit = findobj(h,'Tag','editbutton');
      editval = get(h_edit,'UserData');  %get primary edit flag

      polyflag = get(h_createpoly,'UserData');  %get backup flag
      set(h_createpoly,'UserData',[1 1])

      if editval == 0  %'create' event
         initvals = [];
      else  %'edit' event
         if ~isempty(polyflag)  %check for prior cancellation
            set(h_edit,'UserData',0)  %clear flag
            initvals = [];
         else
            if val > 1  %check for valid data row
               initvals = [{polydata{val,1}} {polydata{val,2}} ...
                  {polydata{val,3}} {polydata{val,4}}];
            else
               initvals = [];
            end
         end
      end

      h_lastval = findobj(h,'Tag','lastval');
      set(h_lastval,'UserData',[])

      createpoly('init', ...
         'surfintegrate(''createpolyeval'')', ...
         h_fig, ...
         h_createpoly, ...
         initvals)

   elseif strcmp(op,'createpolyeval')  %add newly created polygon to database

      h_createpoly = findobj(h,'Tag','createpoly');
      newpoly = get(h_createpoly,'Userdata');
      set(h_createpoly,'UserData',[])

      h_edit = findobj(h,'Tag','editbutton');
      editval = get(h_edit,'UserData');  %get edit flag
      set(h_edit,'UserData',0)  %reset edit flag

      if ~isempty(newpoly)

         %backup current data
         h_undo = findobj(h,'Tag','undobutton');
         set(h_undo,'UserData',[{polydata} {val} {rowsel}])

         %append/replace new polygon data to matrix, store updates
         if editval == 0

            polydata = [polydata ; newpoly];
            rowsel = [rowsel ; 1];
            rownum = size(polydata,1);

         else

            polydata{val,1} = newpoly{1,1};
            polydata{val,2} = newpoly{1,2};
            polydata{val,3} = newpoly{1,3};
            polydata{val,4} = newpoly{1,4};
            rownum = val;

         end

           %set stored row position to new row
          h_lastval = findobj(h,'Tag','lastval');
           set(h_lastval,'UserData',rownum)

         %update store values
         set(h_polyname,'UserData',[{polydata} {rowsel}])

         %update data display
         surfintegrate('newdata')

      end

   elseif strcmp(op(1,1:4),'name')  %polygon renaming dialog subroutine

      if strcmp(op,'name_init')

         %clear prior instances of dialog
         h_namedlg = findobj('Tag','namedlg');
         if ~isempty(h_namedlg)
            close(h_namedlg)
         end

         screen = get(0,'ScreenSize');

         h_namedlg = figure( ...
            'Visible','off', ...
            'Name','Rename Polygon', ...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'Resize','off', ...
            'Units','pixels', ...
            'Position',[screen(3)-340 350 320 100], ...
            'DefaultUiControlUnits','normal', ...
            'Tag','namedlg');

         bgcolor = get(h_namedlg,'Color');

         uicontrol(h_namedlg, ...
            'Style','text', ...
            'Position',[.02 .63 .96 .2], ...
            'String','Polygon Name', ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',bgcolor);

         uicontrol(h_namedlg, ...
            'Style','edit', ...
            'Position',[.02 .40 .96 .23], ...
            'String',polydata{val,1}, ...
            'HorizontalAlignment','left', ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[1 1 1], ...
            'Tag','polyname', ...
            'Callback','surfintegrate(''name_eval'')');

         uicontrol(h_namedlg, ...
            'Style','pushbutton', ...
            'Position',[0 0 .22 .25], ...
            'String','Cancel', ...
            'Callback','surfintegrate(''name_cancel'')');

         uicontrol(h_namedlg, ...
            'Style','pushbutton', ...
            'Position',[.78 0 .22 .25], ...
            'String','Proceed', ...
            'Tag','cmdProceed', ...
            'UserData',[], ...
            'Callback','surfintegrate(''name_eval'')');

         set(h_namedlg,'Visible','on')

      else

         h_namedlg = findobj('Tag','namedlg');

         if strcmp(op,'name_cancel')

            close(h_namedlg)
            figure(h)

         elseif strcmp(op,'name_eval')

            h_edit = findobj(h_namedlg,'Tag','polyname');
            polydata{val,1} = deblank(get(h_edit,'String'));

            close(h_namedlg)
            figure(h)
            drawnow

              %set stored row position to new row
             h_lastval = findobj(h,'Tag','lastval');
              set(h_lastval,'UserData',val)

            %update store values
            set(h_polyname,'UserData',[{polydata} {rowsel}])

            %update data display
            surfintegrate('newdata')

         end

      end

   elseif strcmp(op(1,1:4),'res_')

      h_norm = findobj(h,'Tag','res_norm');
      h_high = findobj(h,'Tag','res_high');
      h_undo = findobj(h,'Tag','undobutton');

      curres = get(h_norm,'UserData');
      clearint = 0;

      if strcmp(op,'res_norm')

         if curres ~= 0
            clearint = 1;
         end

         set(h_norm, ...
            'Value',1, ...
            'BackgroundColor',[0 1 0], ...
            'UserData',0)

         set(h_high, ...
            'Value',0, ...
            'BackgroundColor',get(h_undo,'BackgroundColor'))

      else

         if curres ~= 1
            clearint = 1;
         end

         set(h_high, ...
            'Value',1, ...
            'BackgroundColor',[0 1 0])

         set(h_norm, ...
            'Value',0, ...
            'BackgroundColor',get(h_undo,'BackgroundColor'), ...
            'UserData',1)

      end

      if clearint == 1
         h_integral = findobj(h,'Tag','integralval');
         set(h_integral,'String','')
      end

   elseif strcmp(op,'buttonvis')  %manage command button enable status

      %get handles
      h_buttons = findobj(h,'Tag','buttonstatus');
      h_show = findobj(h,'Tag','showpoly');
      h_edit = findobj(h,'Tag','editbutton');
      h_undo = findobj(h,'Tag','undobutton');
      h_push = findobj(h,'Style','pushbutton');

      %get shape type for current polygon
      h_polyshape = findobj(h,'Tag','polyshape');
      shape = get(h_polyshape,'Value');

      %get undo data
      undodata = get(h_undo,'UserData');

      if val == 1  %null polygon - disable data-dependent command buttons
         set(h_buttons,'Enable','off')
         set(h_edit,'Enable','off')
         set(h_show,'Enable','off')
      else  %enable all buttons
         set(h_push,'Enable','on')
         set(h_show,'Enable','on')
         set(h_polyname,'Enable','on')
      end

      %disable undo button if no undo data exists
      if isempty(undodata{1})
           set(h_undo,'Enable','off')
      end

   end

end

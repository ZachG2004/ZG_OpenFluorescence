function surfintmulti(op)
%Multiple-peak surface integration dialog called by 'eemplot'.
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

if nargin == 0  %open dialog

   h_fig = gcf;

   h_dlg = findobj('Tag','surfintmultidlg');

   if ~isempty(h_dlg)  %prior instance of dialog box - update only

      h_oldfig = get(h_dlg,'UserData');

      set(h_dlg,'UserData',h_fig)

      figure(h_dlg)
      drawnow

      h_integrals = findobj(h_dlg,'Tag','integrals');
      integrals = get(h_integrals,'UserData');
      set(h_integrals,'UserData',cell(size(integrals,1),1))

      surfintmulti('update')

      %clear existing polygon lines on prior figure
      h_line = findobj(h_oldfig,'Tag','polyline');
      if ~isempty(h_line)
         delete(h_line)
      end

   else  %create dialog

      %get current polygon database
      global POLYDATA POLYROW POLYSELECT

      if ~isempty(POLYDATA)
         polydata = POLYDATA;
         polyrow = POLYROW;
         if polyrow > size(polydata,1)
            POLYROW = size(polydata,1);
         end
         if ~isempty(POLYSELECT)
            rowsel = POLYSELECT;
         else
            rowsel = ones(size(polydata,1),1);
         end
      else
         %no current database - use defaults
         if exist('polydata.mat') == 2
            load polydata
            polyrow = lastval;
         else
            polydata = [{'-none-'} {1} {''} {[]}];
            polyrow = 1;
         end
         rowsel = ones(size(polydata,1),1);  %set default to all checked
         POLYDATA = polydata;
         POLYROW = polyrow;
         POLYSELECT = rowsel;
      end

      maxrow = size(polydata,1);

      screen = get(0,'screensize');

      h_dlg = figure( ...
         'Visible','off', ...
         'Name','Multiple-peak Surface Integration', ...
         'Units','pixels', ...
         'Renderer','zbuffer', ...
         'Color',[.88 .88 .88], ...
         'Position',[screen(3)-500 50 500 420], ...
         'MenuBar','none', ...
         'Resize','off', ...
         'NumberTitle','off', ...
         'DefaultUiControlUnits','normal', ...
         'KeyPressFcn','figure(gcf)', ...
         'Tag','surfintmultidlg', ...
         'UserData',h_fig);

      bgcolor = [0.9 0.9 0.9];

      h_cmdLoad = uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.015 .93 .13 .06], ...
         'String','Load', ...
         'TooltipString','Load a new polygon data file', ...
         'Tag','pathcache', ...
         'UserData','', ...
         'Callback','surfintmulti(''load'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.155 .93 .13 .06], ...
         'String','Edit', ...
         'TooltipString',['Launch interactive integration dialog to ' ...
            'define/edit polygons'], ...
         'Callback','surfintmulti(''edit'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.295 .93 .13 .06], ...
         'String','All', ...
         'TooltipString','Select all polygons for integration', ...
         'Callback','surfintmulti(''sel_all'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.435 .93 .13 .06], ...
         'String','None', ...
         'TooltipString','Clear all polygon selections', ...
         'Callback','surfintmulti(''sel_none'')');

      uicontrol(h_dlg, ...
         'Style','togglebutton', ...
         'Position',[.575 .93 .13 .06], ...
         'String','Show', ...
         'Value',0, ...
         'TooltipString','Show selected polygons on current EEM figure', ...
         'Tag','showpoly', ...
         'Callback','surfintmulti(''showpoly'')');

      uicontrol(h_dlg, ...
         'Style','togglebutton', ...
         'Position',[.715 .93 .13 .06], ...
         'String','Log', ...
         'Value',0, ...
         'TooltipString','Log results of all integrations to a text file', ...
         'Tag','logdata', ...
         'UserData',cell(1,3), ...
         'Callback','surfintmulti(''logbtn'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.855 .93 .13 .06], ...
         'String','EEM', ...
         'TooltipString','Select EEM plot to use for integrations', ...
         'Callback','surfintmulti(''pickeem'')');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.005 .86 .08 .045], ...
         'String','Select', ...
         'HorizontalAlignment','center', ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0], ...
         'FontWeight','bold', ...
         'Tag','rowsel', ...
         'UserData',rowsel);

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.1 .86 .67 .045], ...
         'String','Polygon Name', ...
         'HorizontalAlignment','center', ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0], ...
         'FontWeight','bold', ...
         'Tag','polydata', ...
         'UserData',polydata);

      h_handles = uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.78 .86 .16 .045], ...
         'String','Integral', ...
         'HorizontalAlignment','center', ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0], ...
         'FontWeight','bold', ...
         'Tag','rowhandles');

      h_rows = cell(10,3);

      for n = 1:10

         rowpos = .81 - .06*(n-1);

         if n <= maxrow
            rowvis = 'on';
         else
            rowvis = 'off';
         end

         h_name = uicontrol(h_dlg, ...
            'Style','edit', ...
            'Position',[.1 rowpos .67 .05], ...
            'String','', ...
            'Enable','off', ...
            'Visible',rowvis, ...
            'HorizontalAlignment','left', ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'Tag',['row' int2str(n)], ...
            'ButtonDownFcn',['surfintmulti(''view' int2str(n) ''')']);

         h_int = uicontrol(h_dlg, ...
            'Style','edit', ...
            'Position',[.78 rowpos .16 .05], ...
            'Enable','off', ...
            'Visible',rowvis, ...
            'String','', ...
            'HorizontalAlignment','right', ...
            'BackgroundColor',[1 1 1], ...
            'ForegroundColor',[0 0 0], ...
            'Tag',['integral' int2str(n)]);

         h_sel = uicontrol(h_dlg, ...
            'Style','checkbox', ...
            'Position',[.034 rowpos .035 .05], ...
            'String','', ...
            'Value',0, ...
            'TooltipString','Click to toggle polygon status (check to include)', ...
            'Enable',rowvis, ...
            'BackgroundColor',bgcolor, ...
            'ForegroundColor',[1 1 1], ...
            'Tag',['polysel' int2str(n)], ...
            'Callback',['surfintmulti(''incl_' int2str(n) ''')']);

         h_rows{n,1} = h_sel;
         h_rows{n,2} = h_name;
         h_rows{n,3} = h_int;

      end

      set(h_handles,'UserData',h_rows)

      if size(polydata,1) > 10
         slidervis = 'on';
      else
         slidervis = 'off';
      end

      slidermax = max(2,maxrow-1);

      uicontrol(h_dlg, ...
         'Style','slider', ...
         'Position',[.95 .27 .035 .6], ...
         'Enable',slidervis, ...
         'Min',1, ...
         'Max',slidermax, ...
         'SliderStep',[1./(slidermax-1) 10./(slidermax-1)], ...
         'Value',slidermax, ...
         'Tag','slider', ...
         'UserData',[polyrow max(2,polyrow-9)], ...
         'Callback','surfintmulti(''slidermove'')');

      uicontrol(h_dlg, ...
         'Style','frame', ...
         'Position',[.01 .07 .98 .185], ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 .8 .8]);

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.02 .205 .7 .04], ...
         'String','Current Polygon', ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.76 .205 .22 .04], ...
         'String','Polygon Type', ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.02 .165 .7 .04], ...
         'String','', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'HorizontalAlignment','left', ...
         'Tag','polyname');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.76 .165 .22 .04], ...
         'String','', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','polyshape', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.02 .12 .3 .04], ...
         'String','Created', ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.34 .12 .145 .04], ...
         'String','Min Ex', ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.505 .12 .145 .04], ...
         'String','Max Ex', ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.67 .12 .145 .04], ...
         'String','Min Em', ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.835 .12 .145 .04], ...
         'String','Max Em', ...
         'ForegroundColor',[.8 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.02 .08 .3 .04], ...
         'String','', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','polydate', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.34 .08 .145 .04], ...
         'String','', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','wave1', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.505 .08 .145 .04], ...
         'String','', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','wave2', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.67 .08 .145 .04], ...
         'String','', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','wave3', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[.835 .08 .145 .04], ...
         'String','', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'Tag','wave4', ...
         'HorizontalAlignment','center');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[0 0 .15 .06], ...'
         'String','Close', ...
         'TooltipString','Close dialog box and return to active plot', ...
         'Callback','surfintmulti(''close'')');

      uicontrol(h_dlg, ...
         'Style','toggle', ...
         'Position',[.56 .005 .13 .05], ...'
         'String','Normal Res', ...
         'Value',1, ...
         'BackgroundColor',[0 1 0], ...
         'TooltipString',['Perform surface integrations at default EEM resolution'], ...
         'Tag','res_norm', ...
         'UserData',0, ...
         'Callback','surfintmulti(''res_norm'')');

      uicontrol(h_dlg, ...
         'Style','toggle', ...
         'Position',[.69 .005 .13 .05], ...'
         'String','High Res', ...
         'Value',0, ...
         'TooltipString',['Perform surface integrations at 1nm EEM resolution'], ...
         'Tag','res_high', ...
         'Callback','surfintmulti(''res_high'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[.85 0 .12 .06], ...'
         'String','Integrate', ...
         'TooltipString',['Perform surface integrations on active figure ', ...
            'for all selected polygons'], ...
         'Callback','surfintmulti(''integrate'')', ...
         'Tag','integrals', ...
         'UserData',cell(maxrow,1));

      set(h_dlg,'Visible','on'); drawnow

      surfintmulti('update')

   end

else

   h_dlg = findobj('Tag','surfintmultidlg');
   h_fig = get(h_dlg,'UserData');

   h_polydata = findobj(h_dlg,'Tag','polydata');
   polydata = get(h_polydata,'UserData');

   h_rowsel = findobj(h_dlg,'Tag','rowsel');
   rowsel = get(h_rowsel,'UserData');

   h_integral = findobj(h_dlg,'Tag','integrals');
   integralval = get(h_integral,'UserData');

   h_slider = findobj(h_dlg,'Tag','slider');
   sliderdata = get(h_slider,'UserData');

   maxrow = size(polydata,1);
   rownum = sliderdata(1);
   toprow = sliderdata(2);

   h_rowhandles = findobj(h_dlg,'Tag','rowhandles');
   h_handles = get(h_rowhandles,'UserData');

   if strcmp(op,'close')  %close dialog

      global POLYDATA POLYROW POLYSELECT
      POLYDATA = polydata;
      POLYROW = rownum;
      POLYSELECT = rowsel;

      close(h_dlg)
      figure(h_fig)
      drawnow

      %clear existing polygon lines
      h_line = findobj(h_fig,'Tag','polyline');
      if ~isempty(h_line)
         delete(h_line)
      end

   elseif strcmp(op,'update')  %update polygon fields

      for n = 1:10

         currow = toprow + n - 1;

         if maxrow >= currow  %valid row
            set(h_handles{n,2}, ...
               'Visible','on', ...
               'String',char(polydata{currow,1}))
            set(h_handles{n,3}, ...
               'Visible','on', ...
               'String',num2str(integralval{currow},'%0.2f'))
            set(h_handles{n,1}, ...
               'Value',rowsel(currow), ...
               'Enable','on')
         else
            set(h_handles{n,2}, ...
               'Visible','off', ...
               'String','')
            set(h_handles{n,3}, ...
               'Visible','off', ...
               'String','')
            set(h_handles{n,1}, ...
               'Value',0, ...
               'Enable','off')
         end

      end

      surfintmulti('info')

   elseif strcmp(op,'info')  %update info fields for current polygon

      polyname = ['  ' char(polydata{rownum,1})];

      shapetable = [{''} {'Freeform'} {'Circle'} {'Rectangle'}];
      shapestr = char(shapetable(polydata{rownum,2}));

      dstr = polydata{rownum,3};

      if ~isempty(polydata{rownum,4})
         polygon = polydata{rownum,4};
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

      h_name = findobj(h_dlg,'Tag','polyname');
      h_shape = findobj(h_dlg,'Tag','polyshape');
      h_created = findobj(h_dlg,'Tag','polydate');
      h_wave1 = findobj(h_dlg,'Tag','wave1');
      h_wave2 = findobj(h_dlg,'Tag','wave2');
      h_wave3 = findobj(h_dlg,'Tag','wave3');
      h_wave4 = findobj(h_dlg,'Tag','wave4');

      h_row = [];
      for n = 1:10
         h_row = [h_row ; h_handles{n,2}];
      end

      h_newrow = findobj(h_dlg,'Tag',['row' int2str(rownum-toprow+1)]);

      set(h_row,'BackgroundColor',[1 1 1])
      set(h_newrow,'BackgroundColor',[1 1 0])
      set(h_name,'String',polyname)
      set(h_created,'String',dstr)
      set(h_shape,'String',shapestr)
      set(h_wave1,'String',exmin)
      set(h_wave2,'String',exmax)
      set(h_wave3,'String',emmin)
      set(h_wave4,'String',emmax)

      drawnow

      surfintmulti('polyvis')

      drawnow

   elseif strcmp(op(1,1:4),'view')  %process polygon title clicks

      newrow = toprow+str2num(op(5:length(op)))-1;
      set(h_slider,'UserData',[newrow toprow]);

      surfintmulti('info')

   elseif strcmp(op,'slidermove')  %update row pointers after slider moved

       sliderval = max(2,maxrow-1) - get(h_slider,'Value') + 1;
      newtop = sliderval + 1;
      newrow = rownum;

      if newrow < newtop
         newrow = newtop;
      elseif  newrow > newtop + 9
         newrow = newtop + 9;
      end

      set(h_slider, ...
         'UserData',[newrow newtop])

      surfintmulti('update')

   elseif strcmp(op(1,1:4),'incl')  %update polygon selection array

      currow = str2num(op(1,6:length(op)));

      h_sel = findobj(h_dlg,'Tag',['polysel' int2str(currow)]);

      rowsel(toprow+currow-1) = get(h_sel,'Value');

      set(h_rowsel,'UserData',rowsel)

      surfintmulti('polyvis')

   elseif strcmp(op,'integrate')

      I_sel = find(rowsel);
      h_res = findobj(h_dlg,'Tag','res_norm');
      res = get(h_res,'UserData');

      if ~isempty(I_sel)

         h_s = findobj(h_fig,'Type','surface');

         if ~isempty(h_s)

            eem = get(h_s,'UserData');
            if isempty(eem)
               eem = wrapeem(get(h_s,'XData'),get(h_s,'YData'),get(h_s,'ZData'));
            end

            if ~isempty(eem)

               set(gcf,'Pointer','watch')

               for n = 1:length(I_sel)

                  polygon = polydata{I_sel(n),4};
                  warning off  %turn of spurious divide by zero warnings

                  if ~isempty(polygon)
                     integralval{I_sel(n)} = intlasso(eem,polygon,res);
                  else
                     integralval{I_sel(n)} = [];
                  end

               end

               set(h_integral,'UserData',integralval)
               set(h_dlg,'Pointer','arrow')

               h_log = findobj(h_dlg,'Tag','logdata');
               logval = get(h_log,'Value');

               if logval == 0
                  surfintmulti('update')
               else
                  logdata = get(h_log,'UserData');
                  logdata{3} = I_sel;
                  set(h_log,'UserData',logdata)
                  surfintmulti('logdata')
               end

            end

         end

      end

   elseif strcmp(op(1,1:4),'res_')

      h_norm = findobj(h_dlg,'Tag','res_norm');
      h_high = findobj(h_dlg,'Tag','res_high');
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
            'BackgroundColor',get(h_integral,'BackgroundColor'))
      else
         if curres ~= 1
            clearint = 1;
         end
         set(h_high, ...
            'Value',1, ...
            'BackgroundColor',[0 1 0])
         set(h_norm, ...
            'Value',0, ...
            'BackgroundColor',get(h_integral,'BackgroundColor'), ...
            'UserData',1)
      end

      if clearint == 1
         set(h_integral,'UserData',cell(maxrow,1))
         surfintmulti('update')
      end

   elseif strcmp(op,'load') %load polygon data file

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

         [filename,pathname] = uigetfile('*.mat','Select new polygon data file');

         if filename ~= 0

            cd(pathname)
            try
               load(filename)
            catch
               error = 1;
               errormsg = 'Invalid data file';
            end

            if error == 0

               if exist('polydata') ~= 1
                  error = 1;
                  errormsg = 'Invalid data file';
               elseif size(polydata,2) ~= 4
                  error = 1;
                  errormsg = 'Invalid polygon data in file';
               end

            end

            if error == 0

               global POLYDATA POLYROW POLYSELECT
               POLYDATA = polydata;
               POLYROW = lastval;
               POLYSELECT = ones(size(polydata,1),1);

               surfintmulti('reset')

            end

         end

      end

      cd(curpath)

      if error ~= 0

         errorbox('init',errormsg)

      end

   elseif strcmp(op,'edit')  %open interactive integration dialog

      global POLYDATA POLYROW POLYSELECT
      POLYDATA = polydata;
      POLYROW = rownum;
      POLYSELECT = rowsel;

      surfintegrate('init',h_fig)

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

      figpos = get(h_dlg,'Position');

      figsel = listdialog('Name','EEM Figure Selection', ...
         'PromptString','Choose the EEM plot to use for integrations from the list', ...
         'ListString',fignames, ...
         'SelectionMode','single', ...
         'ListSize',[figpos(1)+90 figpos(2)+300 400 150], ...
         'InitialValue',sellist);

      if ~isempty(figsel)  %check for cancellation

         set(h_dlg,'UserData',h_eems(figsel))
         set(h_integral,'UserData',cell(maxrow,1)) %clear integral fields

         figure(h_eems(figsel))
         figure(h_dlg)

         drawnow

         surfintmulti('update')

         %clear existing polygon lines on prior EEM
         h_line = findobj(h_fig,'Tag','polyline');
         if ~isempty(h_line)
            delete(h_line)
         end

      end

   elseif strcmp(op(1,1:4),'sel_')  %bulk selection of polygons

      if strcmp(op,'sel_all')
         newval = 1;
      else
         newval = 0;
      end

      %update stored data
      rowsel = ones(maxrow,1).*newval;

      global POLYSELECT
      POLYSELECT = rowsel;

      set(h_rowsel,'UserData',rowsel)

      %update visible rows
      h_sel = findobj(h_dlg,'Tag',['polysel' int2str(1)]);

      visrows = maxrow - toprow + 1;
      for n = 2:visrows
         h_sel = [h_sel ; findobj(h_dlg,'Tag',['polysel' int2str(n)])];
      end

      set(h_sel,'Value',newval)  %update visible rows

      surfintmulti('polyvis')

   elseif strcmp(op,'logbtn')  %toggle color of data logging button to reflect state

      h_log = findobj(h_dlg,'Tag','logdata');
      logval = get(h_log,'Value');

      if logval == 0
         set(h_log, ...
            'BackgroundColor',get(h_integral,'BackgroundColor'), ...
            'UserData',cell(1,3))
      else
         set(h_log, ...
            'BackgroundColor',[0 1 0], ...
            'UserData',[{[]} {[]} {find(rowsel)}])
         drawnow
         surfintmulti('logdata')
      end

   elseif strcmp(op,'logdata')  %log integration data to text file

      h_log = findobj(h_dlg,'Tag','logdata');

      logdata = get(h_log,'UserData');
      pathname = logdata{1};
      filename = logdata{2};
      I_int = logdata{3};

      curpath = pwd;

      error = 0;
      cancel = 0;

      if ~isempty(I_int) & ~isempty(cat(1,integralval{:}))

         if isempty(pathname)

            h_path = findobj(h_dlg,'Tag','pathcache');

            lastpath = get(h_path,'UserData');
            if isempty(lastpath)
               h_path2 = findobj(h_fig,'Tag','pathcache');
               lastpath = get(h_path2,'UserData');
               if isempty(lastpath)
                  lastpath = curpath;
               end
            end

            try
               cd(lastpath)
            catch
               cancel = 1;
            end

            if cancel == 0

               [filename,pathname] = uiputfile('log.txt', ...
                  'Select file for logging integration data');

               if filename ~= 0
                  logdata{1} = pathname;
                  logdata{2} = filename;
                  set(h_log,'UserData',logdata)    %store pathname/filename
                  set(h_path,'UserData',pathname)  %update path cache
                  figure(h_dlg)
               else
                  cancel = 1;
               end

            end

         end

         if cancel == 0

            %get integration time
            [dstr,tstr] = strtok(datestr(now));
            tstr = strtok(tstr);

            %get plot title
            h_axes = findobj(h_fig,'Type','axes');
            if ~isempty(h_axes)
               if strcmp(get(h_axes(1),'Tag'),'Colorbar') ~= 1
                  h_title = get(h_axes(1),'Title');
               else
                  h_title = get(h_axes(2),'Title');
               end
               if ~isempty(h_title)
                  figtitle = get(h_title,'String');
               else
                  figtitle = '(unknown)';
               end
            else
               figtitle = '(unknown)';
            end

            %get integration resolution
            h_res = findobj(h_dlg,'Tag','res_norm');
            res = get(h_res,'UserData');
            if res == 0
               resstr = 'Standard';
            else
               resstr = '1nm x 1nm';
            end

            cd(pathname)

            error = 0;
            fid = fopen(filename,'a');

            %print header - trap file errors
            try
               fprintf(fid,'EEM Plot:\t%s\rDate:\t%s\rTime:\t%s\r\r',figtitle,dstr,tstr);
            catch
               error = 1;
            end

            if error == 0

               fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r','Polygon', ...
                  'Format','Created','EXmin(nm)','EXmax(nm)','EMmin(nm)', ...
                  'EMmax(nm)','Area(nm^2)','Resolution','Surface Vol');

               shapetable = [{''} {'Freeform'} {'Circle'} {'Rectangle'}];

               for n = 1:length(I_int)

                  pos = I_int(n);
                  polygon = polydata{pos,4};

                  if ~isempty(polygon)

                     polyname = polydata{pos,1};
                     polytype = char(shapetable{polydata{pos,2}});
                     polydate = polydata{pos,3};
                     vol = integralval{pos};

                     %calculate polygon bounds
                     ex_min = min(polygon(:,1));
                     ex_max = max(polygon(:,1));
                     em_min = min(polygon(:,2));
                     em_max = max(polygon(:,2));

                     %calculate polygon surface area
                     switch polytype
                        case 'Freeform'
                           surfarea = polyarea(polygon(:,1),polygon(:,2));
                        case 'Circle'
                           surfarea = pi .* (mean([(ex_max-ex_min),(em_max-em_min)])./2).^2;
                        case 'Rectangle'
                           surfarea = (ex_max-ex_min) .* (em_max-em_min);
                        otherwise
                           surfarea = NaN;
                     end

                     fprintf(fid,'%s\t%s\t%s\t%0.2f\t%0.2f\t%0.2f\t%0.2f\t%0.2f\t%s\t%0.2f\r',polyname, ...
                        polytype,polydate,ex_min,ex_max,em_min,em_max,surfarea,resstr,vol);

                  end

               end

               fprintf(fid,'\r\r');
               fclose(fid);

            end

         end

         cd(curpath)

      end

      if error == 0

         %reset integral index
         logdata{3} = [];
         set(h_log,'UserData',logdata)

         surfintmulti('update')  %update dialog after finished logging

      else  %file error - shut off logging and send error message

         %clear bad file info
         logdata{1} = '';
         logdata{2} = '';
         set(h_log,'UserData',logdata)

         messagebox('init', ...
            str2mat(['The file ''' filename ''' could not be created or accessed'], ...
            'because it is in use by another application.', ...
            'Press ''OK'' and select a new log file.'), ...
            'surfintmulti(''logdata'')', ...
            'File Error', ...
            [.8 0 0])

      end

   elseif strcmp(op,'reset')  %update stored data and slider to reflect new data

      global POLYDATA POLYROW POLYSELECT

      maxrow = size(POLYDATA,1);

      if isempty(POLYSELECT)
         POLYSELECT = ones(maxrow,1);
      elseif length(POLYSELECT) ~= maxrow
         POLYSELECT = ones(maxrow,1);
      end

      set(h_polydata,'UserData',POLYDATA)
      set(h_integral,'UserData',cell(maxrow,1))
      set(h_rowsel,'UserData',POLYSELECT)

      if maxrow > 10
         slidervis = 'on';
      else
         slidervis = 'off';
      end

      slidermax = max(2,maxrow-1);

      set(h_slider, ...
         'Enable',slidervis, ...
         'Min',1, ...
         'Max',slidermax, ...
         'SliderStep',[1./(slidermax-1) 10./(slidermax-1)], ...
         'Value',slidermax, ...
         'UserData',[POLYROW max(2,POLYROW-9)])

      surfintmulti('update')

   elseif strcmp(op,'showpoly')  %toggle show polygon status

      h_show = findobj(h_dlg,'Tag','showpoly');
      val = get(h_show,'Value');

      if val == 0  %deselection

         set(h_show,'BackgroundColor',get(h_integral,'BackgroundColor'))

         surfintmulti('polyvis')

      else

         set(h_show,'BackgroundColor',[0 1 0])

         newcolor = uisetcolor('Choose a polygon color');

         if length(newcolor) == 3

            set(h_show,'UserData',newcolor)

            surfintmulti('polyvis')

         else

            set(h_show, ...
               'BackgroundColor',get(h_integral,'BackgroundColor'), ...
               'Value',0, ...
               'UserData',[])

         end

      end

   elseif strcmp(op,'polyvis')  %manage display of polygons on active EEM

      h_show = findobj(h_dlg,'Tag','showpoly');
      showval = get(h_show,'Value');

      h_axes = findobj(h_fig,'Type','axes');

      %clear existing polygon lines
      h_line = findobj(h_fig,'Tag','polyline');
      if ~isempty(h_line)
         delete(h_line)
      end

      if showval == 1

         if ~isempty(h_axes)

            if strcmp(get(h_axes(1),'Tag'),'Colorbar') ~= 1
               h_ax = h_axes(1);
            else
               h_ax = h_axes(2);
            end

            zlim = get(h_ax,'ZLim');
            I_sel = find(rowsel);

            if ~isempty(I_sel)  %check for polygon selections

               newcolor = get(h_show,'UserData');
               if isempty(newcolor)
                  newcolor = uisetcolor('Choose a polygon color');
               end

               if length(newcolor) == 3

                  for n = 1:length(I_sel)

                     polygon = polydata{I_sel(n),4};

                     if ~isempty(polygon)
                        line('Parent',h_ax, ...
                           'XData',polygon(:,1), ...
                           'YData',polygon(:,2), ...
                           'ZData',ones(size(polygon,1),1).*(zlim(2)+eps), ...
                           'LineWidth',1, ...
                           'Color',newcolor, ...
                           'Tag','polyline', ...
                           'ButtonDownFcn','uisetcolor(gcbo,''Change Polygon Color'');');
                     end

                  end

                  drawnow

               end

            end

         end

      end

   end

end

function contourlines(op,contourvals,linecolor,fontsize)
%syntax:  contourlines(op,contourvals,linecolor,fontsize)
%
%Contour line function called by 'eemplot'.
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
%last modified 9/26/1999

if nargin == 0
   op = 'dialog';
end

%get relevent handles
h_dlg = findobj('Tag','contourdlg');

if ~isempty(h_dlg)
   h_fig = get(h_dlg,'UserData');
else
   h_fig = gcf;
end

h_conopt = findobj(h_fig,'Tag','contouropt');  %get contour type flag
h_s = findobj(h_fig,'Type','surface');

if strcmp(op,'dialog')

   %evaluate contour information to update/build dialog
   contourdata = get(h_conopt,'UserData');
   if isempty(contourdata)  %set default values
      contourdata = [{[]} {[0 0 0]} {8}];
   elseif length(contourdata) == 2  %update outdated vals
      contourdata = [{contourdata{1}} {contourdata{2}} {0}];
      set(h_conopt,'UserData',contourdata)
   end

   if length(contourdata{1}) == 1  %fixed number of contours
      contourtype = 2;
      lbl = [{'Number'} {''} {''}];
      vals = [{num2str(contourdata{1})} {''} {''}];
      vis = [{'on'} {'off'} {'off'}];
   elseif length(contourdata{1}) == 3  %contour range
      contourtype = 3;
      contourvals = contourdata{1};
      lbl = [{'Start'} {'End'} {'Interval'}];
      vals = [{num2str(contourvals(1))} {num2str(contourvals(2))} ...
            {num2str(contourvals(3))}];
      vis = [{'on'} {'on'} {'on'}];
   else  %automatic contours
      contourtype = 1;
      lbl = [{''} {''} {''}];
      vals = [{''} {''} {''}];
      vis = [{'off'} {'off'} {'off'}];
   end

   colorval = contourdata{2};

   if ~isempty(h_s)
      zdata = (get(h_s,'ZData'));
      zmin = floor(min(min(zdata)));
      zmax = ceil(max(max(zdata)));
      zint = round((zmax-zmin)./20);
   else
      zmin = 0;
      zmax = 0;
      zint = 0;
   end

   defaultdata = [{[]} {[0 0 0]} {0}; ...
         {[20]} {[0 0 0]} {0}; ...
         {[zmin zmax zint]} {[0 0 0]} {0}];
   defaultdata(contourtype,1:3) = contourdata;

   if ~isempty(h_dlg)  %dialog box open - update figure handle & activate

      figure(h_dlg)

      set(h_dlg, ...
         'Visible','on', ...
         'UserData',h_fig)

      h_color = findobj(h_dlg,'Tag','colorbox');
      set(h_color,'BackgroundColor',colorval)

      h_type = findobj(h_dlg,'Tag','contourpopup');
      set(h_type,'Value',contourtype)

      for n = 1:3
         h_lbl = findobj(h_dlg,'Tag',['label' int2str(n)]);
         h_edit = findobj(h_dlg,'Tag',['edit' int2str(n)]);
         set(h_lbl, ...
            'Visible',char(vis(n)), ...
            'String',char(lbl(n)))
         set(h_edit, ...
            'Visible',char(vis(n)), ...
            'String',char(vals(n)))
      end

   else  %generate dialog box

      screen = get(0,'ScreenSize');

      h_dlg = figure( ...
         'Visible','off', ...
         'Units','pixels', ...
         'Position',[max(0,screen(3)-350) 200 350 130], ...
         'DefaultUiControlUnits','pixels', ...
         'Menubar','none', ...
         'NumberTitle','off', ...
         'Resize','off', ...
         'KeypressFcn','figure(gcf)', ...
         'Name','Contour Line Options', ...
         'Tag','contourdlg', ...
         'UserData',h_fig);

      bgcolor = get(h_dlg,'Color');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[15 90 75 22], ...
         'String','Line Color', ...
         'Callback','contourlines(''pickcolor'')');

      uicontrol(h_dlg, ...
         'Style','frame', ...
         'Position',[100 90 25 22], ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',colorval, ...
         'Tag','colorbox');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[150 89 150 18], ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',bgcolor, ...
         'String','Contour Label Fontsize (pts)');

      uicontrol(h_dlg, ...
         'Style','edit', ...
         'Position',[300 89 35 21], ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'String',num2str(contourdata{3}), ...
         'Tag','clabelfontsize');

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[15 58 95 16], ...
         'String','Contour Levels', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',bgcolor);

      uicontrol(h_dlg, ...
         'Style','popup', ...
         'Position',[15 39 98 20], ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[1 1 1], ...
         'String','Automatic|Fixed Number|Value Range', ...
         'Value',contourtype, ...
         'Tag','contourpopup', ...
         'UserData',defaultdata, ...
         'Callback','contourlines(''picktype'')');

      for n = 1:3

         uicontrol(h_dlg, ...
            'Style','text', ...
            'Visible',char(vis(n)), ...
            'Position',[120+75*(n-1) 58 70 16], ...
            'String',char(lbl(n)), ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',get(h_dlg,'Color'), ...
            'Tag',['label' int2str(n)]);

         uicontrol(h_dlg, ...
            'Style','edit', ...
            'Visible',char(vis(n)), ...
            'Position',[120+75*(n-1) 38 70 21], ...
            'ForegroundColor',[0 0 0], ...
            'BackgroundColor',[1 1 1], ...
            'String',char(vals(n)), ...
            'Tag',['edit' int2str(n)], ...
            'Callback','contourlines(''updatevals'')');

      end

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[0 0 60 23], ...
         'String','Cancel', ...
         'Callback','contourlines(''cancel'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[145 0 60 23], ...
         'String','Default', ...
         'Tag','cmdDefault', ...
         'UserData',defaultdata, ...
         'Callback','contourlines(''defaults'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[290 0 60 23], ...
         'String','Accept', ...
         'Callback','contourlines(''eval'')');

      set(h_dlg,'Visible','on'); drawnow

   end

else

   %get additional handles
   h_con = findobj(h_fig,'Tag','contours');
   h_clbl = findobj(h_fig,'Tag','contourlbls');
   h_show = findobj(h_conopt,'Tag','contourshow');
   h_hide = findobj(h_conopt,'Tag','contourhide');

   %check for missing input arguments
   if exist('contourvals') ~= 1
      contourvals = [];
   end

   if exist('linecolor') ~= 1
      linecolor = [0 0 0];
   end

   if exist('fontsize') ~= 1
      fontsize = 0;
   end

   if strcmp(op,'clear')  %remove contour lines

      %update menubar
      set(h_conopt,'UserData',[{[]} {[0 0 0]} {8}])
      set(h_show,'Checked','off','UserData',[{[]} {[]} {[]}])
      set(h_hide,'Checked','on')

      %clear contour lines
      if ~isempty(h_con)
         delete(h_con)
         if ~isempty(h_clbl)
            delete(h_clbl)
         end
         drawnow
      end

   elseif strcmp(op,'add')  %add/replace contour lines

      %clear pre-existing contour lines
      if ~isempty(h_con)
         delete(h_con)
         if ~isempty(h_clbl)
            delete(h_clbl)
         end
      end

      if ~isempty(h_s)

         %get surface data
         x = get(h_s,'XData');
         y = get(h_s,'YData');
         z = get(h_s,'ZData');
         zmax = max(max(z));

         hold on

         %generate contours
         if ~isempty(contourvals)
            [c_con,h_con] = contour(x,y,z,contourvals,'k-');
         else
            [c_con,h_con] = contour(x,y,z,'k-');
         end

         %generate contour labels
         if fontsize > 0
            h_clbl = clabel(c_con,h_con,'labelspacing',288);
         else
            h_clbl = [];
         end

         %adjust vertical position, add locator tag
         if ~isempty(h_con)
            for n = 1:length(h_con)
               xdata = get(h_con(n),'XData');
               set(h_con(n), ...
                  'LineStyle','-', ...
                  'Color',linecolor, ...
                  'ZData',ones(1,length(xdata)).*(zmax+eps), ...
                  'Tag','contours')
            end
            if ~isempty(h_clbl)
               for n = 1:length(h_clbl)
                  pos = get(h_clbl(n),'Position');
                  set(h_clbl(n), ...
                     'FontSize',fontsize, ...
                     'Color',linecolor, ...
                     'Position',[pos(1:2) (zmax+eps)], ...
                     'Tag','contourlbls')
               end
            end
         end

         hold off
         drawnow

      end

      %update menubar
      if length(contourvals) > 1
         newdata = [min(contourvals) max(contourvals) contourvals(2)-contourvals(1)];
      else
         newdata = contourvals;
      end

      set(h_conopt,'UserData',[{newdata} {linecolor} {fontsize}])
      set(h_show,'Checked','on','UserData',[{c_con} {h_con} {h_clbl}])
      set(h_hide,'Checked','off')

   elseif strcmp(op,'update')  %adjust vertical position of contours

      if ~isempty(h_con)

         zmax = max(max(get(h_s,'ZData')));

         %adjust vertical position
         for n = 1:length(h_con)
            xdata = get(h_con(n),'XData');
            set(h_con(n),'ZData',ones(1,length(xdata)).*(zmax+eps))
         end

         %adjust contour labels
         if ~isempty(h_clbl)
            for n = 1:length(h_clbl)
               pos = get(h_clbl(n),'Position');
                set(h_clbl(n),'Position',[pos(1:2) (zmax+eps)])
            end
         end

         drawnow

      end

   elseif strcmp(op,'pickcolor')  %open color picker dialog

      h_color = findobj(h_dlg,'Tag','colorbox');

      colorval = get(h_color,'BackgroundColor');

      c = uisetcolor(colorval,'Select a contour line color');

      set(h_color,'BackgroundColor',c)

   elseif strcmp(op,'updatevals')  %validate new entries, update stored data

      h_font = findobj(h_dlg,'Tag','clabelfontsize');
      fontsize = str2num(get(h_font,'String'));

      h_type = findobj(h_dlg,'Tag','contourpopup');
      contourtype = get(h_type,'Value');
      contourdata = get(h_type,'UserData');
      newdata = contourdata{contourtype,1};

      switch contourtype
      case 2
         h_edit1 = findobj(h_dlg,'Tag','edit1');
         val = str2num(get(h_edit1,'String'));
         if ~isempty(val)
            newdata = val;
         end
      case 3
         for n = 1:3
            h_edit = findobj(h_dlg,'Tag',['edit' int2str(n)]);
            val = str2num(get(h_edit,'String'));
            if ~isempty(val)
               newdata(n) = val;
            end
         end
      otherwise
         newdata = [];
      end

      contourdata(contourtype,1:2) = [{newdata} {contourdata{contourtype,2}}];
      set(h_type,'UserData',contourdata)

   elseif strcmp(op,'picktype')  %manage edit box values, visibility

      h_type = findobj(h_dlg,'Tag','contourpopup');
      contourtype = get(h_type,'Value');
      contourdata = get(h_type,'UserData');
      contourvals = contourdata{contourtype,1};

      switch contourtype
      case 2  %fixed number of contours
         lbl = [{'Number'} {''} {''}];
         vals = [{num2str(contourvals(1))} {''} {''}];
         vis = [{'on'} {'off'} {'off'}];
      case 3  %contour range
         lbl = [{'Start'} {'End'} {'Interval'}];
         vals = [{num2str(contourvals(1))} ...
               {num2str(contourvals(2))} ...
               {num2str(contourvals(3))}];
         vis = [{'on'} {'on'} {'on'}];
      otherwise  %automatic contours
         lbl = [{''} {''} {''}];
         vals = [{''} {''} {''}];
         vis = [{'off'} {'off'} {'off'}];
      end

      for n = 1:3
         h_lbl = findobj(h_dlg,'Tag',['label' int2str(n)]);
         h_edit = findobj(h_dlg,'Tag',['edit' int2str(n)]);
         set(h_lbl, ...
            'Visible',char(vis(n)), ...
            'String',char(lbl(n)))
         set(h_edit, ...
            'Visible',char(vis(n)), ...
            'String',char(vals(n)))
      end

   elseif strcmp(op,'cancel')

      close(h_dlg)
      figure(h_fig)

   elseif strcmp(op,'defaults')

      h_default = findobj(h_dlg,'Tag','cmdDefault');
      defaults = get(h_default,'UserData');

      h_type = findobj(h_dlg,'Tag','contourpopup');
      set(h_type, ...
         'Value',1, ...
         'UserData',defaults)

      h_color = findobj(h_dlg,'Tag','colorbox');
      set(h_color,'BackgroundColor',[0 0 0])

      contourlines('picktype')

   elseif strcmp(op,'eval')

      h_font = findobj(h_dlg,'Tag','clabelfontsize');
      fontsize = str2num(get(h_font,'String'));

      h_type = findobj(h_dlg,'Tag','contourpopup');
      contourtype = get(h_type,'Value');

      h_color = findobj(h_dlg,'Tag','colorbox');
      colorval = get(h_color,'BackgroundColor');

      switch contourtype
      case 2
         h_edit1 = findobj(h_dlg,'Tag','edit1');
         newdata = str2num(get(h_edit1,'String'));
      case 3
         newdata = [NaN NaN NaN];
         for n = 1:3
            h_edit = findobj(h_dlg,'Tag',['edit' int2str(n)]);
            val = str2num(get(h_edit,'String'));
            if ~isempty(val)
               newdata(n) = val;
            end
         end
         if ~isempty(find(isnan(newdata)))
            newdata = [];  %revert to automatic labels if invalid entries
         end
      otherwise
         newdata = [];
      end

      close(h_dlg)

      figure(h_fig)

      drawnow

      set(h_conopt,'UserData',[{newdata} {colorval} {fontsize}])

      if length(newdata) == 1
         contourval = newdata;
      elseif length(newdata) == 3
         contourval = [newdata(1):newdata(3):newdata(2)];
      else
         contourval = [];
      end

      contourlines('add',contourval,colorval,fontsize)

   end

end

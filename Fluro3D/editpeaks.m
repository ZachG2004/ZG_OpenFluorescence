function editpeaks(op)
%Peak label editing dialog
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

%handle non-dialog operations first
if strcmp(op,'hide')  %clear all peaklabels

   h_opt = findobj(gcf,'Tag','peaklabelopt');
   h_show = findobj(h_opt,'Tag','showpeaklabels');
   h_hide = findobj(h_opt,'Tag','hidepeaklabels');

   set(h_show,'Checked','off')
   set(h_hide,'Checked','on')

   h = findobj(gcf,'Tag','peaklabels');
   if ~isempty(h)
      delete(h)
   end

   drawnow

elseif strcmp(op,'update')  %update z-axis position of peaklabels

   h_opt = findobj(gcf,'Tag','peaklabelopt');

   if ~isempty(h_opt)
      h_t = findobj(gcf,'Tag','peaklabels');  %get label handles
   else
      h_t = [];
   end

   if ~isempty(h_t)

      zlims = get(gca,'ZLim');

      for n = 1:length(h_t)
         pos = get(h_t(n),'Position');
         set(h_t(n),'Position',[pos(1:2) max(zlims)+1])
      end

      clip3d  %run axis clipping function to work around ML text clipping bug

   end

elseif strcmp(op,'color')  %change color of peaklabels en masse

   h_fig = gcf;
   h_opt = findobj(h_fig,'Tag','peaklabelopt');

   if ~isempty(h_opt)
      h_show = findobj(h_opt,'Tag','showpeaklabels');
      peaklbls = get(h_opt,'UserData');
   else
      peaklbls = [];
   end

   if ~isempty(peaklbls)

      c = uisetcolor(peaklbls(1).Color);

      if sum(c == peaklbls(1).Color) < 3  %update colors

         [peaklbls.Color] = deal([c]);
         set(h_opt,'UserData',peaklbls)

         h_t = findobj(h_fig,'Tag','peaklabels');

         if ~isempty(h_t)
            set(h_t,{'Color'},repmat({c},length(h_t),1))
         end

         drawnow

      end

   end

elseif strcmp(op,'init')  %create peaklabel dialog

   %close prior instances of dialog
   h_dlg = findobj('Tag','dlgPeakLabels');
   if ~isempty(h_dlg)
      close(h_dlg)
   end

   h_fig = gcf;

   if exist('peaklabels.mat') == 2

      load peaklabels
      peaklbl = peaklbls(1);

      defpeaklbls = [peaklbls ; repmat(peaklbl,51-length(peaklbls),1)];

   else

      %define label template
      peaklbl = struct('FontName','Helvetica', ...
         'FontSize',14, ...
         'FontWeight','bold', ...
         'FontAngle','normal', ...
         'Color',[0 0 0], ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','middle', ...
         'Rotation',0, ...
         'Units','data', ...
         'Clipping','on', ...
         'Visible','off', ...
         'Tag','peaklabels', ...
         'Position',[0 0 0], ...
         'String','', ...
         'Interpreter','tex', ...
         'ButtonDownFcn','', ...
         'UserData','auto');

      defpeaklbls = [];

   end

   %get stored peaklabels
   h_labels = findobj(h_fig,'Tag','peaklabelopt');
   if ~isempty(h_labels)
      peaklbls = get(h_labels,'UserData');
   else
      peaklbls = [];
   end

   %pad current peaklabels to 51 rows
   if ~isempty(peaklbls)
      peaklbls = [peaklbls ; repmat(peaklbls(1),51-length(peaklbls),1)];
   elseif ~isempty(defpeaklbls)
      peaklbls = defpeaklbls;
   else
      peaklbls = repmat(peaklbl,51,1);
   end

   %use alternate defaults if necessary
   if isempty(defpeaklbls)
      if ~isempty(peaklbls)
         defpeaklbls = peaklbls;
      else
         defpeaklbls = repmap(peaklbl,51,1);
      end
   end

   vis = {peaklbls(2:length(peaklbls)).Visible}';
   disp = strcmp(vis,'on');

   screenres = get(0,'ScreenSize');

   h_dlg = figure('Name','Peak Labels', ...
      'Visible','off', ...
      'Position',[(screenres(3)-520)./2 (screenres(4)-260)./2 520 280], ...
      'Color',[0.88 0.88 0.88], ...
      'KeyPressFcn','figure(gcf)', ...
      'MenuBar','none', ...
      'NumberTitle','off', ...
      'Renderer','zbuffer', ...
      'RendererMode','manual', ...
      'Resize','off', ...
      'Tag','dlgPeakLabels', ...
      'ToolBar','none', ...
      'DefaultuicontrolUnits','pixels', ...
      'UserData',h_fig);

   bgcolor = [.9 .9 .9];

   h1 = uicontrol('Parent',h_dlg, ...
      'BackgroundColor',[0.8 0.8 0.8], ...
      'ForegroundColor',[0.8 0 0], ...
      'FontWeight','bold', ...
      'Position',[5 250 510 18], ...
      'String','Select or Edit Peak Labels to Display on Plot', ...
      'Style','text');

   h1 = uicontrol('Parent',h_dlg, ...
      'BackgroundColor',bgcolor, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[6 221 50 18], ...
      'String','Show', ...
      'Style','text', ...
      'Tag','txtDisp', ...
      'UserData',disp);

   h1 = uicontrol('Parent',h_dlg, ...
      'BackgroundColor',bgcolor, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[56 221 50 18], ...
      'String','Ex(nm)', ...
      'Style','text');

   h1 = uicontrol('Parent',h_dlg, ...
      'BackgroundColor',bgcolor, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[111 221 50 18], ...
      'String','Em(nm)', ...
      'Style','text');

   h1 = uicontrol('Parent',h_dlg, ...
      'BackgroundColor',bgcolor, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[166 221 70 18], ...
      'String','Fluor(nm)', ...
      'Style','text');

   h1 = uicontrol('Parent',h_dlg, ...
      'BackgroundColor',bgcolor, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[241 221 150 18], ...
      'String','Label String', ...
      'Style','text');

   h1 = uicontrol('Parent',h_dlg, ...
      'BackgroundColor',bgcolor, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[396 221 40 18], ...
      'String','Size', ...
      'Style','text');

   h1 = uicontrol('Parent',h_dlg, ...
      'BackgroundColor',bgcolor, ...
      'FontWeight','bold', ...
      'ForegroundColor',[0 0 0.8], ...
      'Position',[441 221 45 18], ...
      'String','Color', ...
      'Style','text');

   uihandles = cell(5,7);

   for n = 1:5

      if ~isempty(peaklbls(n+1).String)
         xstr = num2str(peaklbls(n+1).Position(1));
         ystr = num2str(peaklbls(n+1).Position(2));
         if strcmp(peaklbls(n+1).UserData,'auto')
            zstr = 'auto';
         else
            zstr = num2str(peaklbls(n+1).Position(3));
         end
         lblstr = peaklbls(n+1).String;
         font = num2str(peaklbls(n+1).FontSize);
         c = peaklbls(n+1).Color;
         enableval = 'on';
      else
         xstr = '';
         ystr = '';
         zstr = '';
         lblstr = '';
         font = '';
         c = peaklbls(1).Color;
         enableval = 'off';
      end

      if sum(c == [1 1 1]) ~= 3;
         bg = [1 1 1];
      else
         bg = [.5 .5 .5];
      end

      rowpos = 192 - 28*(n-1);

      h1 = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',bgcolor, ...
         'Position',[26 rowpos+5 15 15], ...
         'Style','checkbox', ...
         'Callback',['editpeaks(''disp' int2str(n) ''')'], ...
         'Value',disp(n));

      h2 = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[56 rowpos 50 22], ...
         'Style','edit', ...
         'String',xstr, ...
         'Callback',['editpeaks(''xpos' int2str(n) ''')']);

      h3 = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[111 rowpos 50 22], ...
         'Style','edit', ...
         'String',ystr, ...
         'Callback',['editpeaks(''ypos' int2str(n) ''')']);

      h4 = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[166 rowpos 70 22], ...
         'Style','edit', ...
         'String',zstr, ...
         'CallBack',['editpeaks(''zpos' int2str(n) ''')']);

      h5 = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[241 rowpos 150 22], ...
         'Style','edit', ...
         'HorizontalAlignment','left', ...
         'String',lblstr, ...
         'CallBack',['editpeaks(''lbl' int2str(n) ''')']);

      h6 = uicontrol('Parent',h_dlg, ...
         'BackgroundColor',[1 1 1], ...
         'Position',[396 rowpos 40 22], ...
         'Style','edit', ...
         'String',font, ...
         'CallBack',['editpeaks(''font' int2str(n) ''')']);

      h7 = uicontrol('Parent',h_dlg, ...
         'Position',[441 rowpos 45 24], ...
         'Enable',enableval, ...
         'BackgroundColor',bg, ...
         'ForegroundColor',c, ...
         'String','Color', ...
         'Tag',['cmdColor' int2str(n)], ...
         'CallBack',['editpeaks(''colr' int2str(n) ''')']);

      uihandles(n,:) = [{h1},{h2},{h3},{h4},{h5},{h6},{h7}];

   end

   h1 = uicontrol('Parent',h_dlg, ...
      'Max',46, ...
      'Min',1, ...
      'Position',[495 80 20 140], ...
      'SliderStep',[1/45 5/45], ...
      'Style','slider', ...
      'Tag','slrRow', ...
      'Value',46, ...
      'UserData',1, ...
      'CallBack','editpeaks(''scroll'')');

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','text', ...
      'String','Global Font Attributes', ...
      'FontWeight','bold', ...
      'Position',[215 46 150 18], ...
      'ForegroundColor',[0 0 .8], ...
      'BackgroundColor',bgcolor);

   h1 = uicontrol('Parent',h_dlg, ...
      'Position',[360 45 76 24], ...
      'String','Font Style', ...
      'Tag','cmdDefFont', ...
      'TooltipString','Change font, font style, and size of all labels', ...
      'CallBack','editpeaks(''font0'')');

   c = peaklbls(1).Color;
   if sum(c == [1 1 1]) ~= 3;
      bg = [1 1 1];
   else
      bg = [.5 .5 .5];
   end

   h1 = uicontrol('Parent',h_dlg, ...
      'Position',[441 45 45 24], ...
      'BackgroundColor',bg, ...
      'ForegroundColor',c, ...
      'String','Color', ...
      'Tag','cmdColor0', ...
      'TooltipString','Change color of all peak labels', ...
      'CallBack','editpeaks(''colr0'')');

   h1 = uicontrol('Parent',h_dlg, ...
      'Style','checkbox', ...
      'Position',[26 47 100 18], ...
      'BackgroundColor',bgcolor, ...
      'ForegroundColor',[0 0 .8], ...
      'String','Save as defaults', ...
      'TooltipString','Save these values to disk as default peak labels', ...
      'Value',0, ...
      'Tag','chkSave');

   h1 = uicontrol('Parent',h_dlg, ...
      'Position',[5 5 60 25], ...
      'String','Cancel', ...
      'Tag','cmdCancel', ...
      'Callback','editpeaks(''close'')', ...
      'TooltipString','Close dialog box and discard changes', ...
      'UserData',uihandles);

   h1 = uicontrol('Parent',h_dlg, ...
      'Position',[(520-60)./2 5 60 25], ...
      'String','Defaults', ...
      'Tag','cmdDefault', ...
      'Callback',['confirmdlg(''init'',''Restore Default Labels?  ' ...
         '(changes will be overwritten)'',''editpeaks(''''default'''')'')'], ...
      'TooltipString','Restore default peak labels (overwrite existing)', ...
      'UserData',defpeaklbls);

   h1 = uicontrol('Parent',h_dlg, ...
      'Position',[(520-65) 5 60 25], ...
      'String','Apply', ...
      'Tag','cmdApply', ...
      'Callback','editpeaks(''apply'')', ...
      'TooltipString','Close dialog box and display selected labels', ...
      'UserData',peaklbls);

   set(h_dlg,'Visible','on')
   drawnow

else  %process dialog callbacks

   h_dlg = findobj('Tag','dlgPeakLabels');

   h_apply = findobj(h_dlg,'Tag','cmdApply');
   peaklbls = get(h_apply,'UserData');

   h_slr = findobj(h_dlg,'Tag','slrRow');
   toprow = get(h_slr,'UserData');

   h_cancel = findobj(h_dlg,'Tag','cmdCancel');
   uih = get(h_cancel,'UserData');

   if strcmp(op,'close')

      h_fig = get(h_dlg,'UserData');

      close(h_dlg)

      if ~isempty(h_fig)
         figure(h_fig)
      end

      drawnow

   elseif strcmp(op,'apply')

      h_savedef = findobj(h_dlg,'Tag','chkSave');
      savedef = get(h_savedef,'Value');

      h_fig = get(h_dlg,'UserData');

      close(h_dlg)

      if ~isempty(h_fig)
         figure(h_fig)
         h_labels = findobj(h_fig,'Tag','peaklabelopt');
      end

      drawnow

      if ~isempty(h_labels)

         h_show = findobj(gcf,'Tag','showpeaklabels');
         h_hide = findobj(gcf,'Tag','hidepeaklabels');

         zlims = get(gca,'ZLim');
         lblheight = max(zlims)+1;

         I_lbl = find(~cellfun('isempty',{peaklbls.String}'));
         I_auto = find(strcmp({peaklbls(I_lbl).UserData}','auto'));

         pos = {peaklbls(I_lbl(I_auto)).Position}';
         pos = cat(1,pos{:});
         pos(:,3) = lblheight;  %substitute zlims+1 for z position

         for n = 1:length(I_auto)
            peaklbls(I_lbl(I_auto(n))).Position = pos(n,:);
         end

         peaklbls = peaklbls([1 ; I_lbl]);

         set(h_labels,'UserData',peaklbls)
         set(h_show,'Checked','on')
         set(h_hide,'Checked','off')

         h_lbls = findobj(h_fig,'Tag','peaklabels');
         if ~isempty(h_lbls)
            delete(h_lbls);
         end

         for n = 1:length(I_lbl)
            h = text(0,0,0,'');
            set(h,peaklbls(I_lbl(n)))
         end

         if savedef == 1  %save new peak labels as defaults

            curpath = pwd;

            global EEMTOOLSPATH
            if ~isempty(EEMTOOLSPATH)
               cd(EEMTOOLSPATH)
            end

            if exist('peaklabels.mat') == 2

               save peaklabels peaklbls

            else  %can't locate pref file - prompt for name

               [fn,pn] = uigetfile('peaklabels.mat','Locate Default Peak Labels File');

               if fn ~= 0
                  cd(pn)
                  save peaklabels peaklbls
               end

            end

            cd(curpath)

         end

         clip3d  %run axis clipping function to work around ML clipping bug

      end

   elseif strcmp(op,'scroll')

      newrow = get(h_slr,'Max') - round(get(h_slr,'Value')) + 1;

      if newrow ~= toprow  %scroll values

         set(h_slr,'UserData',newrow)
         datarows = [newrow+1:newrow+5]';

         %form string cell array, get index of blanks
         lbl = {peaklbls(datarows).String}';
         I_blank = cellfun('isempty',lbl);

         %form value array for display checks
         vis = {peaklbls(datarows).Visible}';
         disp = strcmp(vis,'on');

         %parse positions, form string cell arrays
         pos = [peaklbls(datarows).Position]';
         xstr = cellstr(num2str(pos(1:3:13)));
         ystr = cellstr(num2str(pos(2:3:14)));
         zstr = cellstr(num2str(pos(3:3:15)));

         %get fontsize & color
         font = cellstr(num2str([peaklbls(datarows).FontSize]'));
         c = {peaklbls(datarows).Color}';
         bg = repmat({[1 1 1]},5,1);
         I_c = find(sum(cat(1,c{:})') == 3)';
         bg(I_c,:) = {[.5 .5 .5]};

         %apply auto flags
         I_auto = strcmp({peaklbls(datarows).UserData}','auto');
         zstr(I_auto) = {'auto'};

         %clear strings for rows with blank labels
         enableval = repmat({'on'},5,1);
         enableval(I_blank) = {'off'};
         xstr(I_blank) = {''};
         ystr(I_blank) = {''};
         zstr(I_blank) = {''};
         font(I_blank) = {''};

         %update uicontrol fields
         set([uih{:,1}]',{'Value'},num2cell(disp))
         set([uih{:,2}]',{'String'},xstr)
         set([uih{:,3}]',{'String'},ystr)
         set([uih{:,4}]',{'String'},zstr)
         set([uih{:,5}]',{'String'},lbl)
         set([uih{:,6}]',{'String'},font)
         set([uih{:,7}]',[{'ForegroundColor'},{'BackgroundColor'},{'Enable'}], ...
            [c bg enableval])

         drawnow

      end

   elseif strcmp(op(1,1:4),'disp')

      visstr = [{'off'},{'on'}];
      row = str2num(op(1,5));
      val = get(uih{row,1},'Value');

      peaklbls(toprow+row).Visible = visstr{val+1};
      set(h_apply,'UserData',peaklbls)

   elseif strcmp(op(1,1:4),'xpos')

      row = str2num(op(1,5));
      xpos = str2num(get(uih{row,2},'String'));

      if isempty(xpos)
         xpos = 0;
         set(uih{row,2},'String','0')
         drawnow
      end

      peaklbls(toprow+row).Position(1) = xpos;
      set(h_apply,'UserData',peaklbls)

   elseif strcmp(op(1,1:4),'ypos')

      row = str2num(op(1,5));
      ypos = str2num(get(uih{row,3},'String'));

      if isempty(ypos)
         ypos = 0;
         set(uih{row,3},'String','0')
         drawnow
      end

      peaklbls(toprow+row).Position(2) = ypos;
      set(h_apply,'UserData',peaklbls)

   elseif strcmp(op(1,1:4),'zpos')

      row = str2num(op(1,5));
      zpos = str2num(get(uih{row,4},'String'));

      if isempty(zpos)
         zpos = 0;
         set(uih{row,4},'String','auto')
         peaklbls(toprow+row).UserData = 'auto';
         drawnow
      else
         peaklbls(toprow+row).UserData = 'man';
      end

      peaklbls(toprow+row).Position(3) = zpos;
      set(h_apply,'UserData',peaklbls)

   elseif strcmp(op(1,1:3),'lbl')

      row = str2num(op(1,4));
      datarow = toprow+row;
      str = deblank(get(uih{row,5},'String'));

      if isempty(str)  %turn off visibility for empty strings

         set(uih{row,1},'Value',0)
         set(uih{row,2},'String','')
         set(uih{row,3},'String','')
         set(uih{row,4},'String','')
         set(uih{row,6},'String','')

         c = peaklbls(1).Color;
         if sum(c == [1 1 1]) ~= 3
            bg = [1 1 1];
         else
            bg = [.5 .5 .5];
         end
         set(uih{row,7},'ForegroundColor',c,'BackgroundColor',bg,'Enable','off')

         peaklbls(datarow).Position = [0 0 0];
         peaklbls(datarow).Color = peaklbls(1).Color;
         peaklbls(datarow).FontSize = peaklbls(1).FontSize;

      else  %apply default styles

         %only overwrite existing checkmark if no prior string (new entry)
         if isempty(peaklbls(datarow).String)
            set(uih{row,1},'Value',1)
         else
            set(uih{row,1},'Value',strcmp(peaklbls(datarow).Visible,'on'))
         end

         pos = peaklbls(datarow).Position;
         set(uih{row,2},'String',num2str(pos(1)))
         set(uih{row,3},'String',num2str(pos(2)))
         if strcmp(peaklbls(datarow).UserData,'auto')
            set(uih{row,4},'String','auto')
         else
            set(uih{row,4},'String',num2str(pos(3)))
         end

         set(uih{row,6},'String',num2str(peaklbls(datarow).FontSize))

         c = peaklbls(datarow).Color;
         if sum(c == [1 1 1]) ~= 3
            bg = [1 1 1];
         else
            bg = [.5 .5 .5];
         end
         set(uih{row,7},'ForegroundColor',c,'BackgroundColor',bg,'Enable','on')

      end

      peaklbls(datarow).String = str;
      set(h_apply,'UserData',peaklbls)

      editpeaks(['disp' int2str(row)])

   elseif strcmp(op(1,1:4),'colr') %set color properties

      row = str2num(op(1,5));

      c = uisetcolor;

      if length(c) == 3  %color selected (not cancelled)

         if sum(c == [1 1 1]) ~= 3;
            bg = [1 1 1];
         else
            bg = [.5 .5 .5];
         end

         if row == 0

            [peaklbls.Color] = deal(c);

            h = findobj(h_dlg,'Tag','cmdColor0');
            set(h,'ForegroundColor',c,'BackgroundColor',bg)

            set(h_apply,'UserData',peaklbls)

            %invoke scroll method without value change to redraw fields
            set(h_slr,'UserData',0)
            editpeaks('scroll')

         elseif ~isempty(peaklbls(toprow+row).String)

            set(uih{row,7},'ForegroundColor',c,'BackgroundColor',bg)
            drawnow

            peaklbls(toprow+row).Color = c;
            set(h_apply,'UserData',peaklbls)

         end

      end

   elseif strcmp(op(1,1:4),'font')  %apply fontsize changes

      row = str2num(op(1,5));

      if row == 0  %default values

         h = findobj(h_dlg,'Tag','cmdDefFont');

         fontdef = uisetfont(struct('FontName',peaklbls(1).FontName, ...
            'FontUnits','points', ...
            'FontSize',peaklbls(1).FontSize, ...
            'FontWeight',peaklbls(1).FontWeight, ...
            'FontAngle',peaklbls(1).FontAngle));

         if isstruct(fontdef)  %check for cancel

            [peaklbls.FontName] = deal(fontdef.FontName);
            [peaklbls.FontSize] = deal(fontdef.FontSize);
            [peaklbls.FontWeight] = deal(fontdef.FontWeight);
            [peaklbls.FontAngle] = deal(fontdef.FontAngle);

            set(h_apply,'UserData',peaklbls)

            set(h_slr,'UserData',0)
            editpeaks('scroll')

         end

      else  %individual values

         val = str2num(get(uih{row,6},'String'));

         if ~isempty(val)
            peaklbls(toprow+row).FontSize = val;
         else
            set(uih{row,6},'String',num2str(peaklbls(1).FontSize))
            drawnow
         end

      end

      set(h_apply,'UserData',peaklbls)

   elseif strcmp(op,'default')

      h_def = findobj(h_dlg,'Tag','cmdDefault');
      peaklbls = get(h_def,'UserData');

      h_savedef = findobj(h_dlg,'Tag','chkSave');

      set(h_apply,'UserData',peaklbls)

      set(h_slr,'UserData',0)

      h_font0 = findobj(h_dlg,'Tag','editFont0');
      h_color0 = findobj(h_dlg,'Tag','cmdColor0');

      c = peaklbls(1).Color;
      if sum(c == [1 1 1]) ~= 3
         bg = [1 1 1];
      else
         bg = [.5 .5 .5];
      end

      set(h_font0,'String',num2str(peaklbls(1).FontSize))
      set(h_color0,'ForegroundColor',c,'BackgroundColor',bg)
      set(h_savedef,'Value',0)

      editpeaks('scroll')

   end

end

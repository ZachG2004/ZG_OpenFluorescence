function exem_plot(op,eemdata,axlims,plotname)
%syntax:  exem_plot(op,eemdata,axlims,plotname)
%
%Generates a 2D plot of the EEM matrix 'eemdata' as either an
%excitation scan or an emission scan (plot orientation can be
%changed at runtime).  Scans can be overlain for comparison and
%Area under the curve can be calculated interactively between any
%wavelength endpoints using trapezoidal integration.
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
%last modified 10/6/2001

if strcmp(op,'ex') | strcmp(op,'em')

   info = {'no information available'};

   if exist('eemdata') ~= 1

      h_s = findobj(gcf,'Type','surface');

      if ~isempty(h_s)

         h_t = get(gca,'Title');
         plotname = get(h_t,'String');

         eemdata = get(h_s,'UserData');
         if isempty(eemdata)
            xdata = get(h_s,'XData');
            ydata = get(h_s,'YData');
            zdata = get(h_s,'ZData');
            eemdata = wrapeem(xdata,ydata,zdata);
         end

         h_eeminfo = findobj(gcf,'Tag','eeminfo');
         if ~isempty(h_eeminfo)
            info = get(h_eeminfo,'UserData');
         end

      else

         eemdata = [];

      end

   end

   if ~isempty(eemdata)

      %check for single wavelength scan (disable ex-plot button)
      if size(eemdata,2) <= 2
         op = 'em';
         ex_buttonvis = 'off';
      else
         ex_buttonvis = 'on';
      end

      if size(eemdata,1) <= 2
         op = 'ex';
         em_buttonvis = 'off';
      else
         em_buttonvis = 'on';
      end

      %set properties for emission or excitation scan
      if strcmp(op,'em')
         if exist('plotname') ~= 1
            plotname = 'Emission Scan';
         end
         ex_ctrl = 'on';
         ex_forecolor = [0 0 0];
         ex_init = num2str(eemdata(1,2));
         ex_stored = 1;
         em_ctrl = 'off';
         em_init = '';
         em_stored = [];
         em_button = 1;
         ex_button = 0;
         em_buttonbg = [0 1 0];
         ex_buttonbg = [.8 .8 .8];
      else
         if exist('plotname') ~= 1
            plotname = 'Excitation Scan';
         end
         ex_ctrl = 'off';
         ex_forecolor = [0 0 .8];
         ex_init = '';
         ex_stored = [];
         em_ctrl = 'on';
         em_init = num2str(eemdata(2,1));
         em_stored = 1;
         em_button = 0;
         ex_button = 1;
         ex_buttonbg = [0 1 0];
         em_buttonbg = [.8 .8 .8];
      end

      screen = get(0,'screensize');
      if screen(3) >= 800
         screenres = [(screen(3)-800)*.5 (screen(4)-600)*.5 800 600];
      else
         screenres = screen;
      end

      h_fig = figure('Visible','off', ...
         'Units','pixels', ...
         'Position',[.1*screenres(3)+screenres(1) .08*screenres(4)+screenres(2) ...
            screenres(3) screenres(4)], ...
         'Color',[1 1 1], ...
         'Menubar','none', ...
         'PaperPosition',[.5 2 8 7], ...
         'NumberTitle','off', ...
         'DefaultUiControlUnits','normal', ...
         'Name',plotname, ...
         'WindowButtonDownFcn','exem_plot(''click'')', ...
         'WindowButtonUpFcn','', ...
         'Pointer','crosshair', ...
         'Tag','exemplotfig', ...
         'UserData',eemdata);

      mnuFile = uimenu(h_fig, ...
         'Label','File');

      mnuView = uimenu(h_fig, ...
         'Label','View');

      mnuHelp = uimenu(h_fig, ...
         'Label','Help');

      mnuFileExport = uimenu(mnuFile, ...
         'Label','Export Plot');

      uimenu(mnuFileExport, ...
         'Label','Copy to Clipboard', ...
         'Callback','printeem(''clipboard'')');

      mnuFileExpPS = uimenu(mnuFileExport, ...
         'Separator','on', ...
         'Label','Postscript file');

      mnuFileExpJpeg = uimenu(mnuFileExport, ...
         'Label','JPeg file');

      mnuFileExpTiff = uimenu(mnuFileExport, ...
         'Label','TIFF file');

      uimenu(mnuFileExpPS, ...
         'Label','Postscript (color)', ...
         'Callback','exportfig(''psc'')');

      uimenu(mnuFileExpPS, ...
         'Label','Postscript (monochrome)', ...
         'Callback','exportfig(''psbw'')');

      uimenu(mnuFileExpPS, ...
         'Label','EPS level 2 (color)', ...
         'Callback','exportfig(''epsc2'')');

      uimenu(mnuFileExpPS, ...
         'Label','EPS level 2 (monochrome)', ...
         'Callback','exportfig(''epsbw2'')');

      uimenu(mnuFileExpPS, ...
         'Label','EPS level 1 (color)', ...
         'Callback','exportfig(''epsc1'')');

      uimenu(mnuFileExpPS, ...
         'Label','EPS level 1 (monochrome)', ...
         'Callback','exportfig(''epsbw1'')');

      uimenu(mnuFileExpJpeg, ...
         'Label','High Resolution', ...
         'Callback','exportfig(''jpeg90'')');

      uimenu(mnuFileExpJpeg, ...
         'Label','Normal Resolution', ...
         'Callback','exportfig(''jpeg75'')');

      uimenu(mnuFileExpJpeg, ...
         'Label','Low Resolution', ...
         'Callback','exportfig(''jpeg50'')');

      uimenu(mnuFileExpTiff, ...
         'Label','Compressed', ...
         'Callback','exportfig(''tiffc'')');

      uimenu(mnuFileExpTiff, ...
         'Label','Uncompressed', ...
         'Callback','exportfig(''tiffnc'')');

      uimenu(mnuFileExport, ...
         'Label','Matlab Plot File', ...
         'Callback','exportfig(''mfile'')');

      mnuFileExportData = uimenu(mnuFile, ...
         'Label','Export Data');

      uimenu(mnuFileExportData, ...
         'Label','ASCII matrix (spreadsheet)', ...
         'Callback','exportascii([],''matrix'')');

      uimenu(mnuFileExportData, ...
         'Label','ASCII XYZ triplets (plotting program)', ...
         'Callback','exportascii([],''xyz'')');

      mnuFilePrint = uimenu(mnuFile, ...
         'Label','Print', ...
         'Separator','on');

      mnuFilePrintPort = uimenu(mnuFilePrint, ...
         'Label','Portrait');

      mnuFilePrintLand = uimenu(mnuFilePrint, ...
         'Label','Landscape');

      uimenu(mnuFilePrintPort, ...
         'Label','Full Page', ...
         'Callback','exem_plot(''print_portfull'')');

      uimenu(mnuFilePrintPort, ...
         'Label','Top Half', ...
         'Callback','exem_plot(''print_porttop'')');

      uimenu(mnuFilePrintPort, ...
         'Label','Bottom Half', ...
         'Callback','exem_plot(''print_portbottom'')');

      uimenu(mnuFilePrintLand, ...
         'Label','Full Page', ...
         'Callback','exem_plot(''print_landfull'')');

      uimenu(mnuFilePrintLand, ...
         'Label','Left Half', ...
         'Callback','exem_plot(''print_landleft'')');

      uimenu(mnuFilePrintLand, ...
         'Label','Right Half', ...
         'Callback','exem_plot(''print_landright'')');

      uimenu(mnuFile, ...
         'Label','Page Setup', ...
         'Callback','pagedlg');

      uimenu(mnuFile, ...
         'Label','Print Preview', ...
         'Callback','printpreview');

      uimenu(mnuFile, ...
         'Label','Close', ...
         'Separator','on', ...
         'Callback','close(gcf);drawnow');

      uimenu(mnuView, ...
         'Label','Axis Properties', ...
         'Callback','newaxisdlg');

      uimenu(mnuView, ...
         'Label','Hide Plot Controls', ...
         'Separator','on', ...
         'Tag','hideui', ...
         'Callback','plottoggle(''hidectrls'')');

      uimenu(mnuHelp, ...
         'Label','Toolbox Window', ...
         'Callback','fltoolbox');

      uimenu(mnuHelp, ...
         'Label','EEM Information', ...
         'Separator','on', ...
         'Callback','eeminfo(''init'')', ...
         'Tag','eeminfo', ...
         'UserData',info);

      uicontrol(h_fig, ...
         'Style','togglebutton', ...
         'Position',[.91 .85 .08 .05], ...
         'String','Zoom', ...
         'Value',0, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'Tag','zoom', ...
         'Callback','exem_plot(''zoom'')');

      uicontrol(h_fig, ...
         'Style','togglebutton', ...
         'Position',[.91 .8 .08 .05], ...
         'String','Probe', ...
         'Value',1, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[0 1 0], ...
         'Tag','probe', ...
         'Callback','exem_plot(''probe'')');

      uicontrol(h_fig, ...
         'Style','togglebutton', ...
         'Position',[.91 .75 .08 .05], ...
         'String','Integrate', ...
         'Value',0, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'Tag','integrate', ...
         'UserData',1, ...
         'Callback','exem_plot(''integrate'')');

      uicontrol(h_fig, ...
         'Style','frame', ...
         'Position',[.9 .6 .096 .11], ...
         'ForegroundColor','k', ...
         'BackgroundColor','w');

      uicontrol(h_fig, ...
         'Style','text', ...
         'Position',[.902 .65 .092 .045], ...
         'String','Ex (nm)', ...
         'ForegroundColor','k', ...
         'BackgroundColor','w', ...
         'Tag','box1_lbl');

      uicontrol(h_fig, ...
         'Style','edit', ...
         'Enable',ex_ctrl, ...
         'Position',[.907 .605 .082 .045], ...
         'String',ex_init, ...
         'ForegroundColor','k', ...
         'BackgroundColor','w', ...
         'Tag','box1', ...
         'UserData',ex_stored, ...
         'Callback','exem_plot(''edit_ex'')');

      uicontrol(h_fig, ...
         'Style','frame', ...
         'Position',[.9 .45 .096 .11], ...
         'ForegroundColor','k', ...
         'BackgroundColor','w');

      uicontrol(h_fig, ...
         'Style','text', ...
         'Position',[.902 .5 .092 .045], ...
         'String','Em (nm)', ...
         'ForegroundColor','k', ...
         'BackgroundColor','w', ...
         'Tag','box2_lbl');

      uicontrol(h_fig, ...
         'Style','edit', ...
         'Enable',em_ctrl, ...
         'Position',[.907 .455 .082 .045], ...
         'String',em_init, ...
         'ForegroundColor','k', ...
         'BackgroundColor','w', ...
         'Tag','box2', ...
         'UserData',em_stored, ...
         'Callback','exem_plot(''edit_em'')');

      uicontrol(h_fig, ...
         'Style','frame', ...
         'Position',[.9 .3 .096 .11], ...
         'ForegroundColor','k', ...
         'BackgroundColor','w');

      uicontrol(h_fig, ...
         'Style','text', ...
         'Position',[.902 .35 .092 .045], ...
         'String','Fluor', ...
         'ForegroundColor','k', ...
         'BackgroundColor','w', ...
         'Tag','box3_lbl');

      uicontrol(h_fig, ...
         'Style','edit', ...
         'Enable','off', ...
         'Position',[.907 .305 .082 .045], ...
         'String','', ...
         'ForegroundColor','k', ...
         'BackgroundColor','w', ...
         'Tag','box3');

      uicontrol(h_fig, ...
         'Style','togglebutton', ...
         'Position',[0 0 .08 .05], ...
         'String','Ex Plot', ...
         'Value',ex_button, ...
         'Enable',ex_buttonvis, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',ex_buttonbg, ...
         'Tag','plotex', ...
         'Callback','exem_plot(''plotex'')');

      uicontrol(h_fig, ...
         'Style','togglebutton', ...
         'Position',[.08 0 .08 .05], ...
         'String','Em PLot', ...
         'Value',em_button, ...
         'Enable',em_buttonvis, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',em_buttonbg, ...
         'Tag','plotem', ...
         'Callback','exem_plot(''plotem'')');

      uicontrol(h_fig, ...
         'Style','pushbutton', ...
         'Position',[.228 0 .1 .05], ...
         'String','Axis Limits', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'Callback','newaxisdlg');

      if exist('axlims') == 1
         if ~isempty(axlims)
            lockval = 1;
            backcolor = [0 1 0];
         else
            lockval = 0;
            backcolor = [.8 .8 .8];
         end
      else
         lockval = 0;
         backcolor = [.8 .8 .8];
      end

      uicontrol(h_fig, ...
         'Style','togglebutton', ...
         'Position',[.396 0 .15 .05], ...
         'String','Lock Axis Limits', ...
         'Value',lockval, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',backcolor, ...
         'Tag','lockaxis', ...
         'Callback','exem_plot(''lockaxis'')');

      uicontrol(h_fig, ...
         'Style','togglebutton', ...
         'Position',[.614 0 .12 .05], ...
         'String','Overlay Plots', ...
         'Value',0, ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'Tag','overlay', ...
         'Callback','exem_plot(''overlay'')');

      uicontrol(h_fig, ...
         'Style','pushbutton', ...
         'Position',[.8 0 .05 .05], ...
         'String','|<', ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'Tag','firstbutton', ...
         'Enable','off', ...
         'Callback','exem_plot(''first'')');

      uicontrol(h_fig, ...
         'Style','pushbutton', ...
         'Position',[.85 0 .05 .05], ...
         'String','<', ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'Tag','prevbutton', ...
         'Enable','off', ...
         'Callback','exem_plot(''prev'')');

      uicontrol(h_fig, ...
         'Style','pushbutton', ...
         'Position',[.9 0 .05 .05], ...
         'String','>', ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'Tag','nextbutton', ...
         'Enable','on', ...
         'Callback','exem_plot(''next'')');

      uicontrol(h_fig, ...
         'Style','pushbutton', ...
         'Position',[.95 0 .05 .05], ...
         'String','>|', ...
         'FontWeight','bold', ...
         'ForegroundColor',[0 0 0], ...
         'BackgroundColor',[.8 .8 .8], ...
         'Tag','lastbutton', ...
         'Enable','on', ...
         'Callback','exem_plot(''last'')');

      set(h_fig,'Visible','on')

      exem_plot('plot')

   else  %too few arguments

      disp(' '); disp('Too few arguments for function!'); disp(' ')

   end

else

   h = gcf;
   eemdata = get(h,'UserData');

   h_box1 = findobj(h,'Tag','box1');
   h_box2 = findobj(h,'Tag','box2');
   h_box3 = findobj(h,'Tag','box3');

   [ex,em,fl] = unwrapeem(eemdata);
   ex_current = get(h_box1,'UserData');
   em_current = get(h_box2,'UserData');

   if isempty(ex_current)
      plottype = 'ex';
   else
      plottype = 'em';
   end

   if strcmp(op,'edit_ex')  %process 'Ex' editbox entries

      entry = str2num(get(h_box1,'String'));

      h_integ = findobj(h,'Tag','integrate');
      integ = get(h_integ,'Value');

      if integ == 0  %probe/zoom mode

         %validate new entry
         if ~isempty(entry)

            ex_new = find(ex == entry);

            if isempty(ex_new)

               if entry < min(ex)
                  entry = min(ex);
               elseif entry > max(ex)
                  entry = max(ex);
               else
                  entry = interp1(ex,ex,entry,'nearest');
               end

               ex_new = find(ex == entry);

               if isempty(ex_new)
                  ex_new = ex_current;
               end

            end

         else

            ex_new = ex_current;

         end

         set(h_box1, ...
            'String',num2str(ex(ex_new)), ...
            'UserData',ex_new)

         if ex_new ~= ex_current
            exem_plot('plot')
         end

      else  %integration mode

         if strcmp(plottype,'em')
            if entry < em(1)
               entry = em(1);
            elseif entry > em(length(em))
               entry = em(length(em));
            end
         else
            if entry < ex(1)
               entry = ex(1);
            elseif entry > ex(length(ex))
               entry = ex(length(ex));
            end
         end

         set(h_box1,'String',num2str(entry))

         set(h_integ,'UserData',1)  %update active box flag

         h_line1 = findobj(gca,'Tag','line1');
         if isempty(h_line1)
            h_line1 = line([entry entry],get(gca,'YLim'), ...
               'Color',[0 .8 0], ...
               'Tag','line1');
         else
            set(h_line1, ...
               'XData',[entry entry], ...
               'YData',get(gca,'YLim'))
         end

         exem_plot('sum')

      end

   elseif strcmp(op,'edit_em')

      entry = str2num(get(h_box2,'String'));

      h_integ = findobj(h,'Tag','integrate');
      integ = get(h_integ,'Value');

      if integ == 0  %probe/zoom mode

         %validate new entry
         if ~isempty(entry)

            em_new = find(em == entry);

            if isempty(em_new)

               if entry < min(em)
                  entry = min(em);
               elseif entry > max(em)
                  entry = max(em);
               else
                  entry = interp1(em',em',entry,'nearest');
               end

               em_new = find(em == entry);

               if isempty(em_new)
                  em_new = em_current;
               end

            end

         else

            em_new = em_current;

         end

         set(h_box2, ...
            'String',num2str(em(em_new)), ...
            'UserData',em_new)

         if em_new ~= em_current
            exem_plot('plot')
         end

      else  %integration mode

         if strcmp(plottype,'em')
            if entry < em(1)
               entry = em(1);
            elseif entry > em(length(em))
               entry = em(length(em));
            end
         else
            if entry < ex(1)
               entry = ex(1);
            elseif entry > ex(length(ex))
               entry = ex(length(ex));
            end
         end

         set(h_box2,'String',num2str(entry))

         set(h_integ,'UserData',2)  %update active box flag

         h_line2 = findobj(gca,'Tag','line2');
         if isempty(h_line2)
            h_line2 = line([entry entry],get(gca,'YLim'), ...
               'Color',[.9 0 0], ...
               'Tag','line2');
         else
            set(h_line2, ...
               'XData',[entry entry], ...
               'YData',get(gca,'YLim'))
         end

         exem_plot('sum')

      end

   elseif strcmp(op,'first')  %move to beginning wavelength

      if strcmp(plottype,'ex')
         set(h_box2,'UserData',1)
      else
         set(h_box1,'UserData',1)
      end

      exem_plot('plot')

   elseif strcmp(op,'prev')  %move to previous wavelength

      if strcmp(plottype,'ex')
         newval = max(1,em_current-1);
         set(h_box2,'UserData',newval)
      else
         newval = max(1,ex_current-1);
         set(h_box1,'UserData',newval)
      end

      exem_plot('plot')

   elseif strcmp(op,'next')  %move to next wavelength

      if strcmp(plottype,'ex')
         maxval = length(em);
         newval = min(maxval,em_current+1);
         set(h_box2,'UserData',newval)
      else
         maxval = length(ex);
         newval = min(maxval,ex_current+1);
         set(h_box1,'UserData',newval)
      end

      exem_plot('plot')

   elseif strcmp(op,'last')  %move to ending wavelength

      if strcmp(plottype,'ex')
         set(h_box2,'UserData',length(em))
      else
         set(h_box1,'UserData',length(ex))
      end

      exem_plot('plot')

   elseif strcmp(op,'click')  %process mouse clicks on plot

      curax = gca;
      axpos = get(curax,'CurrentPoint');

      xlim = get(curax,'XLim');
      ylim = get(curax,'YLim');

      oob = 0;

      mouse_x = roundsig(axpos(1,1),3);

      if mouse_x < xlim(1) | mouse_x > xlim(2)
         oob = 1;
      end

      mouse_y = roundsig(axpos(1,2),5);

      if mouse_y < ylim(1) | mouse_y > ylim(2)
         oob = 1;
      end

      h_integ = findobj(h,'Tag','integrate');
      integ = get(h_integ,'Value');

      if integ == 0  %probe mode

         if oob == 0  %check for out of bounds click before updating values

            if strcmp(plottype,'em')
               if ~isempty(h_box2)
                  set(h_box2,'String',num2str(mouse_x))
               end
            else
               if ~isempty(h_box1)
                  set(h_box1,'String',num2str(mouse_x))
               end
            end

            if ~isempty(h_box3)
               set(h_box3,'String',num2str(mouse_y))
            end

         end

      else  %integration mode

         %set oob clicks to extrema
         mouse_x = min(max(roundsig(axpos(1,1),3),xlim(1)),xlim(2));
         mouse_y = min(max(roundsig(axpos(1,2),3),ylim(1)),ylim(2));

         currentbox = get(h_integ,'UserData');

         if currentbox == 1

            h_line1 = findobj(curax,'Tag','line1');
            if isempty(h_line1)
               h_line1 = line([mouse_x mouse_x],ylim, ...
                  'Color',[0 .8 0], ...
                  'Tag','line1');
            else
               set(h_line1, ...
                  'XData',[mouse_x mouse_x], ...
                  'YData',ylim)
            end

            set(h_box1,'String',num2str(mouse_x))
            set(h_integ,'UserData',2)

         else

            h_line2 = findobj(curax,'Tag','line2');
            if isempty(h_line2)
               h_line2 = line([mouse_x mouse_x],ylim, ...
                  'Color',[.9 0 0], ...
                  'Tag','line2');
            else
               set(h_line2, ...
                  'XData',[mouse_x mouse_x], ...
                  'YData',ylim)
            end

            set(h_box2,'String',num2str(mouse_x))
            set(h_integ,'UserData',1)

         end

         exem_plot('sum')

      end

   elseif strcmp(op,'sum')  %perform integration

      h_integ = findobj(h,'Tag','integrate');
      integ = get(h_integ,'Value');
      activebox = get(h_integ,'UserData');

      val1 = str2num(get(h_box1,'String'));
      val2 = str2num(get(h_box2,'String'));

      if strcmp(plottype,'ex')
         wavelen = ex;
         minval = min(ex);
         maxval = max(ex);
      else
         wavelen = em;
         minval = min(em);
         maxval = max(em);
      end

      integstr = '';

      if ~isempty(val1) & ~isempty(val2)
         if val2 > val1
            if strcmp(plottype,'ex')
               if val1 < ex(1)
                  val1 = ex(1);
               end
               if val2 > ex(length(ex))
                  val2 = ex(length(ex));
               end
               exdata = [val1:.5:val2];
               fldata = interp1(ex,fl(em_current,:),exdata,'spline');
               integval = trapz(exdata,fldata);
            else
               if val1 < em(1)
                  val1 = em(1);
               end
               if val2 > em(length(em))
                  val2 = em(length(em));
               end
               emdata = [val1:.5:val2];
               fldata = interp1(em,fl(:,ex_current),emdata,'spline');
               integval = trapz(emdata,fldata);
            end
            integstr = num2str(integval);
         end
      end

      set(h_box3,'String',integstr)

   elseif strcmp(op,'plotex') | strcmp(op,'plotem')  %switch plot types

      h_plotex = findobj(h,'Tag','plotex');
      h_plotem = findobj(h,'Tag','plotem');

      h_lockaxis = findobj(h,'Tag','lockaxis');
      h_zoom = findobj(h,'Tag','zoom');
      h_integ = findobj(h,'Tag','integrate');
      h_probe = findobj(h,'Tag','probe');
      h_lbl1 = findobj(h,'Tag','box1_lbl');
      h_lbl2 = findobj(h,'Tag','box2_lbl');
      h_lbl3 = findobj(h,'Tag','box3_lbl');

      h_line1 = findobj(gca,'Tag','line1');
      h_line2 = findobj(gca,'Tag','line2');

      set(h_lbl1,'String','Ex (nm)')
      set(h_lbl2,'String','Em (nm)')
      set(h_lbl3,'String','Fluor')

      set(h_box3,'String','')

      set(h_lockaxis, ...
         'BackgroundColor',[.8 .8 .8], ...
         'Value',0)

      set(h_zoom, ...
         'BackgroundColor',[.8 .8 .8], ...
         'Value',0)

      set(h_integ, ...
         'Value',0, ...
         'BackgroundColor',[.8 .8 .8], ...
         'UserData',1)

      set(h_probe, ...
         'BackgroundColor',[0 1 0], ...
         'Value',1)

      if ~isempty(h_line1)
         delete(h_line1)
      end

      if ~isempty(h_line2)
         delete(h_line2)
      end

      h_xlbl = get(gca,'XLabel');

      if strcmp(op,'plotex')  %ex plot

         set(h_plotex, ...
            'Value',1, ...
            'BackgroundColor',[0 1 0])

         set(h_plotem, ...
            'Value',0, ...
            'BackgroundColor',[.8 .8 .8])

         set(h_box1, ...
            'String','', ...
            'Enable','off', ...
            'UserData',[])

         set(h_box2, ...
            'String',num2str(em(1)), ...
            'Enable','on', ...
            'UserData',1)

         set(h_xlbl,'String','Excitation Wavelength (nm)')

      else  %em plot

         set(h_plotem, ...
            'Value',1, ...
            'BackgroundColor',[0 1 0])

         set(h_plotex, ...
            'Value',0, ...
            'BackgroundColor',[.8 .8 .8])

         set(h_box1, ...
            'String',num2str(ex(1)), ...
            'Enable','on', ...
            'UserData',1)

         set(h_box2, ...
            'String','', ...
            'Enable','off', ...
            'UserData',[])

         set(h_xlbl,'String','Emission Wavelength (nm)')

      end

      exem_plot('plot')

   elseif strcmp(op,'overlay')  %set overlay mode - manage buttons & flags

      h_overlay = findobj(h,'Tag','overlay');

      overlay = get(h_overlay,'Value');

      if overlay == 0
         exem_plot('plot')
         set(h_overlay,'BackgroundColor',[.8 .8 .8])
      else
         set(h_overlay,'BackgroundColor',[0 1 0])
      end

   elseif strcmp(op,'lockaxis')  %set axis lock mode - manage buttons & flags

      h_lock = findobj(h,'Tag','lockaxis');

      lockaxis = get(h_lock,'Value');

      if lockaxis == 1

         set(h_lock,'BackgroundColor',[0 1 0])

         zoom off

      else

         set(h_lock,'BackgroundColor',[.8 .8 .8])

         h_zoom = findobj(h,'Tag','zoom');
         zoomval = get(h_zoom,'Value');
         if zoomval == 1
            zoom on
         end

         exem_plot('plot')

      end

   elseif strcmp(op,'zoom') | strcmp(op,'probe') | strcmp(op,'integrate')

      h_zoom = findobj(h,'Tag','zoom');
      h_probe = findobj(h,'Tag','probe');
      h_integ = findobj(h,'Tag','integrate');

      h_box1lbl = findobj(h,'Tag','box1_lbl');
      h_box2lbl = findobj(h,'Tag','box2_lbl');
      h_box3lbl = findobj(h,'Tag','box3_lbl');

      h_line1 = findobj(gca,'Tag','line1');
      h_line2 = findobj(gca,'Tag','line2');

      if ~isempty(h_line1)
         delete(h_line1)
      end

      if ~isempty(h_line2)
         delete(h_line2)
      end

      if strcmp(op,'zoom') | strcmp(op,'probe')

         set(h_box1lbl,'String','Ex (nm)')
         set(h_box2lbl,'String','Em (nm)')
         set(h_box3lbl,'String','Fluor')

         if strcmp(plottype,'em')
            set(h_box1, ...
               'String',num2str(ex(ex_current)), ...
               'Enable','on')
            set(h_box2, ...
               'String','', ...
               'Enable','off')
         else
            set(h_box1, ...
               'String','', ...
               'Enable','off')
            set(h_box2, ...
               'String',num2str(em(em_current)), ...
               'Enable','on')
         end

         set(h_box3,'String','')

         if strcmp(op,'zoom')

            set(h_zoom,'Value',1,'BackgroundColor',[0 1 0])
            set(h_probe,'Value',0,'BackgroundColor',[.8 .8 .8])
            set(h_integ,'Value',0,'BackgroundColor',[.8 .8 .8])

            set(gcf,'WindowButtonDownFcn','');

            h_lock = findobj(h,'Tag','lockaxis');
            lockaxis = get(h_lock,'Value');
            if lockaxis == 0
               zoom on
            end

         else

            zoom off

            set(h_zoom,'Value',0,'BackgroundColor',[.8 .8 .8])
            set(h_probe,'Value',1,'BackgroundColor',[0 1 0])
            set(h_integ,'Value',0,'BackgroundColor',[.8 .8 .8])

            set(gcf,'WindowButtonDownFcn','exem_plot(''click'')','Pointer','crosshair');

         end

      else  %integration mode

         h_overlay = findobj(h,'Tag','overlay');
         overlay = get(h_overlay,'Value');

         if overlay == 1
            set(h_overlay,'Value',0)
            exem_plot('overlay')
         end

         if strcmp(plottype,'ex')
            wavelen = em(em_current);
            minval = min(ex);
            maxval = max(min(wavelen,max(ex)),min(ex));
         else
            wavelen = ex(ex_current);
            minval = min(max(wavelen,min(em)),max(em));
            maxval = max(em);
         end

         zoom off

         set(h_box1lbl,'String','Start')
         set(h_box2lbl,'String','End')
         set(h_box3lbl,'String',['Area ' num2str(wavelen) 'nm'])

         set(h_zoom, ...
            'Value',0, ...
            'BackgroundColor',[.8 .8 .8])
         set(h_probe, ...
            'Value',0, ...
            'BackgroundColor',[.8 .8 .8])
         set(h_integ, ...
            'Value',1, ...
            'BackgroundColor',[0 1 0], ...
            'UserData',1)

         set(gcf,'WindowButtonDownFcn','exem_plot(''click'')','Pointer','crosshair');

         set(h_box1, ...
            'String',num2str(minval), ...
            'Enable','on')
         set(h_box2, ...
            'String',num2str(maxval), ...
            'Enable','on')
         set(h_box3,'String','')

         exem_plot('edit_ex')

         exem_plot('edit_em')

      end

      exem_plot('buttons')

   elseif strcmp(op,'plot')  %create/update plot

      h_overlay = findobj(h,'Tag','overlay');
      overlay = get(h_overlay,'Value');

      h_zoom = findobj(h,'Tag','zoom');
      zoomval = get(h_zoom,'Value');

      h_lock = findobj(h,'Tag','lockaxis');
      lockaxis = get(h_lock,'Value');

      if lockaxis == 1
         axlims = axis;
      else
         axlims = [];
      end

      if overlay == 1
         hold on
      else
         hold off
      end

      h_ax = findobj(h,'Tag','exem_plot');

      if ~isempty(h_ax)  %plot exists - get axis label and title properties

         h_xlbl = get(h_ax,'XLabel');
         xlblstr = get(h_xlbl,'String');
         xlblfont = get(h_xlbl,'FontName');
         xlblweight = get(h_xlbl,'FontWeight');
         xlblsize = get(h_xlbl,'FontSize');
         xlblcolor = get(h_xlbl,'Color');

         h_ylbl = get(h_ax,'YLabel');
         ylblstr = get(h_ylbl,'String');
         ylblfont = get(h_ylbl,'FontName');
         ylblweight = get(h_ylbl,'FontWeight');
         ylblsize = get(h_ylbl,'FontSize');
         ylblcolor = get(h_ylbl,'Color');

         h_title = get(h_ax,'Title');
         plotname = get(h_title,'String');
         titlefont = get(h_title,'FontName');
         titleweight = get(h_title,'FontWeight');
         titlesize = get(h_title,'FontSize');
         titlecolor = get(h_title,'Color');

         if ~isempty(axlims)
            xticks = get(gca,'XTick');
            xticklbl = get(gca,'XTickLabel');
            yticks = get(gca,'YTick');
            yticklbl = get(gca,'YTickLabel');
         else
            xticks = [];
            xticklbl = '';
            yticks = [];
            yticklbl = '';
         end

      else  %new plot

         plotname = get(h,'Name');
         titlefont = 'Times New Roman';
         titleweight = 'bold';
         titlesize = 18;
         titlecolor = [0 0 0];

         if strcmp(plottype,'em')
            xlblstr = 'Emission Wavelength (nm)';
         else
            xlblstr = 'Excitation Wavelength (nm)';
         end

         xlblfont = 'Times New Roman';
         xlblweight = 'bold';
         xlblsize = 14;
         xlblcolor = [0 0 0];

         ylblstr = 'Fluorescence Intensity';
         ylblfont = 'Times New Roman';
         ylblweight = 'bold';
         ylblsize = 14;
         ylblcolor = [0 0 0];

      end

      if strcmp(plottype,'em')
         ex_str = num2str(roundsig(ex(ex_current),3));
         em_str = '';
         plot(em,fl(:,ex_current),'k-')
      else
         ex_str = '';
         em_str = num2str(roundsig(em(em_current),3));
         plot(ex,fl(em_current,:),'k-')
      end

      if zoomval == 1 & lockaxis == 0
         zoom on
      else
         zoom off
      end

      h_ax = gca;

      h_xlbl = get(h_ax,'XLabel');
      h_ylbl = get(h_ax,'YLabel');
      h_title = get(h_ax,'Title');

      set(h_ax, ...
         'Position',[.15 .2 .7 .7], ...
         'Tag','exem_plot')

      if ~isempty(axlims)  %use stored axis limits
         axis(axlims)
         if ~isempty(xticks)
            set(gca, ...
               'XTick',xticks, ...
               'YTick',yticks, ...
               'XTickLabel',xticklbl, ...
               'YTickLabel',yticklbl)
         end
      else  %use default axis limits
         if strcmp(plottype,'ex')
            axis([min(nonneg(ex)) max(nonneg(ex)) ...
                  floor(min(fl(em_current,:))) max(1,ceil(max(fl(em_current,:))))])
         else
            axis([min(nonneg(em)) max(nonneg(em)) ...
                  floor(min(fl(:,ex_current))) max(1,ceil(max(fl(:,ex_current))))])
         end
      end

      set(h_xlbl, ...
         'String',xlblstr, ...
         'FontName',xlblfont, ...
         'FontWeight',xlblweight, ...
         'FontSize',xlblsize, ...
         'Color',xlblcolor, ...
         'Interpreter','none', ...
         'ButtonDownFcn','textedit')

      set(h_ylbl, ...
         'String',ylblstr, ...
         'FontName',ylblfont, ...
         'FontWeight',ylblweight, ...
         'FontSize',ylblsize, ...
         'Color',ylblcolor, ...
         'Interpreter','none', ...
         'ButtonDownFcn','textedit')

      set(h_title, ...
         'String',plotname, ...
         'FontName',titlefont, ...
         'FontWeight',titleweight, ...
         'FontSize',titlesize, ...
         'Color',titlecolor, ...
         'Interpreter','none', ...
         'ButtonDownFcn','textedit')

      set(h_box1,'String',ex_str)
      set(h_box2,'String',em_str)
      set(h_box3,'String','')

      drawnow

      exem_plot('buttons')

   elseif strcmp(op(1,1:4),'prin')  %print plot

      curpos = get(gcf,'PaperPosition');
      curtype = get(gcf,'PaperType');
      curorient = get(gcf,'PaperOrientation');

      switch op

      case 'print_portfull'

         pos = [.5 2 8 7];
         newtype = 'usletter';
         neworient = 'portrait';

      case 'print_porttop'

         pos = [.5 5 7.5 5.5];
         newtype = 'usletter';
         neworient = 'portrait';

      case 'print_portbottom'

         pos = [.5 0 7.5 5.5];
         newtype = 'usletter';
         neworient = 'portrait';

      case 'print_landfull'

         pos = [.5 .5 10 8];
         newtype = 'usletter';
         neworient = 'landscape';

      case 'print_landleft'

         pos = [0 .75 6 6.5];
         newtype = 'usletter';
         neworient = 'landscape';

      case 'print_landright'

         pos = [5 .75 6 6.5];
         newtype = 'usletter';
         neworient = 'landscape';

      otherwise

         pos = curpos;
         newtype = curtype;
         neworient = curorient;

      end

      set(gcf, ...
         'PaperType',newtype, ...
         'PaperOrientation',neworient, ...
         'PaperPosition',pos)

      print -noui -dwinc -v

      set(gcf, ...
         'PaperType',curtype, ...
         'PaperOrientation',curorient, ...
         'PaperPosition',curpos)

   elseif strcmp(op,'buttons')  %update button status according to mode

      h_first = findobj(h,'Tag','firstbutton');
      h_prev = findobj(h,'Tag','prevbutton');
      h_next = findobj(h,'Tag','nextbutton');
      h_last = findobj(h,'Tag','lastbutton');
      h_lockaxis = findobj(h,'Tag','lockaxis');
      h_overlay = findobj(h,'Tag','overlay');

      h_integ = findobj(h,'Tag','integrate');
      integ = get(h_integ,'Value');

      if integ == 0  %probe/zoom mode

         if strcmp(plottype,'ex')
            val = em_current;
            maxval = length(em);
         else
            val = ex_current;
            maxval = length(ex);
         end

         if val == maxval
            set(h_next,'Enable','off')
            set(h_last,'Enable','off')
            set(h_first,'Enable','on')
            set(h_prev,'Enable','on')
         elseif val == 1
            set(h_next,'Enable','on')
            set(h_last,'Enable','on')
            set(h_first,'Enable','off')
            set(h_prev,'Enable','off')
         else
            set(h_next,'Enable','on')
            set(h_last,'Enable','on')
            set(h_first,'Enable','on')
            set(h_prev,'Enable','on')
         end

         set(h_lockaxis,'Enable','on')
         set(h_overlay,'Enable','on')

      else

         set(h_next,'Enable','off')
         set(h_last,'Enable','off')
         set(h_first,'Enable','off')
         set(h_prev,'Enable','off')
         set(h_lockaxis,'Enable','off')
         set(h_overlay,'Enable','off')

      end

   end

end

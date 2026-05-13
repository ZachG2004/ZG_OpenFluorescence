function sliceplot(op,intstyle)
%syntax:  sliceplot(op,intstyle)
%
%Creates a single excitation or emission plot based on the last
%position clicked on in an EEM plot
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
%last modified 7/13/2001

h_fig = gcf;
error = 0;
eem = [];

if exist('op') ~= 1
   op = 'emplot';
end

if exist('intstyle') ~= 1
   type = 'none';
end

if strcmp(op,'emplot') | strcmp(op,'explot')

   if strcmp(get(h_fig,'Tag'),'eemplotfig')  %check for valid figure

      h_s = findobj(h_fig,'Type','surface');
      if ~isempty(h_s)
         eemdata = get(h_s,'UserData');
         if ~isempty(eemdata)
            [ex,em,fl] = unwrapeem(eemdata);
         else
            error = 1;
         end
      else
         error = 1;
      end

      if error == 0  %valid EEM data found

         h_ex = findobj(h_fig,'Tag','lambda-ex');
         exval = str2num(get(h_ex,'String'));

         h_em = findobj(h_fig,'Tag','lambda-em');
         emval = str2num(get(h_em,'String'));

         if strcmp(op,'emplot') & ~isempty(exval)  %em plot

            switch intstyle
            case 'linear'
               method = 'linear';
            case 'cubic'
               method = 'cubic';
            case 'spline'
               method = 'spline';
            otherwise  %no surface interpolation, nearest value
               method = 'linear';
               [val,I] = min(abs(ex-exval));
               exval = ex(I);
            end

            eem = wrapeem(exval,em,interp2(ex,em,fl,exval,em,method));
            xlbl = 'Emission (nm)';
            ylbl = ['Fluorescence at ' num2str(exval) 'nm Excitation'];
            x = em;
            y = interp2(ex,em,fl,exval,em,method);
            mouselbl = 'Em';

         elseif strcmp(op,'explot') & ~isempty(emval)  %ex plot

            switch intstyle
            case 'linear'
               method = 'linear';
            case 'cubic'
               method = 'cubic';
            case 'spline'
               method = 'spline';
            otherwise  %no surface interpolation, nearest value
               method = 'linear';
               [val,I] = min(abs(em-emval));
               emval = ex(I);
            end

            eem = wrapeem(ex,emval,interp2(ex,em,fl,ex,emval,method));
            xlbl = 'Excitation (nm)';
            ylbl = ['Fluorescence at ' num2str(emval) 'nm Emission'];
            x = ex;
            y = interp2(ex,em,fl,ex,emval,method);
            mouselbl = 'Ex';

         end

         if ~isempty(eem)

            %get title from current plot
            h_t = get(gca,'Title');
            titlestr = get(h_t,'String');

            h_plot = findobj('Tag','sliceplot');
            figpos = get(h_fig,'Position');
            screenres = get(0,'ScreenSize');
            plotpos = [min(screenres(3)-550,figpos(1)+200) ...
                  min(screenres(4)-450,figpos(2)+50) 550 450];

            if ~isempty(h_plot)

               figure(h_plot)
               cla
               set(h_plot,'Position',plotpos)

            else

               h_plot = figure('Name','EEM Slice Plot', ...
                  'Units','pixels', ...
                  'Position',plotpos, ...
                  'Color',[1 1 1], ...
                  'KeyPressFcn','figure(gcf)', ...
                  'NumberTitle','off', ...
                  'Menubar','none', ...
                  'Toolbar','none', ...
                  'Tag','sliceplot');

               uicontrol('Parent',h_plot, ...
                  'Style','pushbutton', ...
                  'Units','pixels', ...
                  'Position',[0 0 50 25], ...
                  'String','Full Plot', ...
                  'TooltipString','Open slice data as an indpendent 2D plot', ...
                  'Callback','sliceplot(''full'')');

               h_x = uicontrol('Parent',h_plot, ...
                  'Style','text', ...
                  'Units','pixels', ...
                  'Position',[350 0 90 18], ...
                  'HorizontalAlignment','center', ...
                  'ForegroundColor',[0 0 .8], ...
                  'BackgroundColor',[1 1 1], ...
                  'String','', ...
                  'Tag','xpos');

               h_y = uicontrol('Parent',h_plot, ...
                  'Style','text', ...
                  'Units','pixels', ...
                  'Position',[450 0 90 18], ...
                  'HorizontalAlignment','center', ...
                  'ForegroundColor',[0 0 .8], ...
                  'BackgroundColor',[1 1 1], ...
                  'String','', ...
                  'Tag','ypos');

            end

            set(h_plot, ...
               'Pointer','crosshair', ...
               'WindowButtonDownFcn',['mousepos(''' mouselbl ''',''Fluor'',4)'], ...
               'UserData',[{eem},{op}])

            plot(x,y,'k-')
            set(gca,'Position',[.15 .2 .7 .65])

            set(get(gca,'Title'), ...
               'String',titlestr, ...
               'Fontsize',14, ...
               'Fontweight','bold', ...
               'ButtonDownFcn','textedit')
            set(get(gca,'XLabel'), ...
               'String',xlbl, ...
               'Fontsize',10, ...
               'Fontweight','bold', ...
               'ButtonDownFcn','textedit')
            set(get(gca,'YLabel'), ...
               'String',ylbl, ...
               'Fontsize',10, ...
               'Fontweight','bold', ...
               'ButtonDownFcn','textedit')
            zoom off

         end

      end

   end

elseif strcmp(op,'full')  %open as full 2D plot

   h_plot = findobj('Tag','sliceplot');
   titlestr = get(get(gca,'Title'),'String');

   data = get(h_plot,'UserData');
   if strcmp(data{2},'emplot')
      plottype = 'em';
   else
      plottype = 'ex';
   end

   exem_plot(plottype,data{1},[],get(get(gca,'Title'),'String'));

end


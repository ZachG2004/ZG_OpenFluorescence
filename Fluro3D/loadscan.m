function [h_s,save_eem] = loadscan(plottype,filename,pathname)
%syntax:  [h_s,eem] = loadscan(plottype,filename,pathname)
%
%Loads a 3d fluorescence matrix scan data file saved using 'savescan' and
%automatically runs the 'eemplot' function to regenerate the plot.  If
%no file or path names are provided, a dialog box will prompt for the
%file and directory.  If only the file name is provided, the working
%directory will be used as the path.
%
%The output arguments are the graphics handles of the surface object
%returned from the 'eemplot' function and the corresponding EEM data.
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

cancel = 0;
curpath = pwd;
global EEMLOADPATH EEMSAVEPATH

%initialize output variables
save_eem = [];
h_s = [];

if ~exist('plottype')
   plottype = 'newfig';
end

if exist('filename') ~= 1
   filename = '';
end

if exist('pathname') ~= 1

   if ~isempty(filename)
      pathname = curpath;
   elseif ~isempty(EEMLOADPATH)
      pathname = EEMLOADPATH;
   elseif ~isempty(EEMSAVEPATH)
      pathname = EEMSAVEPATH;
   else
      pathname = curpath;
   end

end

if isempty(filename)

   try
      cd(pathname)
   catch
      cancel = 1;
   end

   if cancel == 0

      [filename,pathname] = uigetfile('*.plt','Select EEM Scan File to Load');

      if filename == 0
         cancel = 1;
      else
         drawnow  %refresh control panel
      end

   end

end

if cancel == 0

   EEMLOADPATH = pathname;

   error = 0;
   try
      cd(pathname)
   catch
      error = 1;
   end

   if error == 0

      try
         load(filename,'-mat');
      catch
         error = 1;
      end

      if error == 1

         errorbox('init','Load cancelled - file not found or filename invalid!')
         cancel = 1;

      elseif exist('save_title') ~= 1

         errorbox('init','Load cancelled - invalid SCANSAVE data file!')
         cancel = 1;

      end

   else

      errorbox('init','Load cancelled - invalid path!')
      cancel = 1;

   end

end

cd(curpath)

if cancel == 0  %process options and generate surface plot

   if exist('save_zlabel') ~= 1
      save_zlabel = 'Fluorescence';
   end

   if isempty(save_eem)
      save_eem = [NaN save_ex ; save_em save_fl];
   end

   if strcmp(plottype,'update')  %get settings from current plot/replace stored values

      plottype = 'newplot';

      h_surf = findobj(gca,'Type','surface');

      if ~isempty(h_surf)

         [az,el] = view;
         save_azel = [az el];
         save_axis = axis;
         save_zlim = get(gca,'ZLim');
         save_edge = get(h_surf,'EdgeColor');
         save_facecol = get(h_surf,'FaceColor');
         save_mesh = get(h_surf,'MeshStyle');
         save_xtick = get(gca,'XTick');
         save_ytick = get(gca,'YTick');
         save_ztick = get(gca,'ZTick');

         h_cmap = findobj(gcf,'Tag','colormap');
         if ~isempty(h_cmap)
            save_cmap = get(h_cmap,'UserData');
         else
            save_cmap = [{'cmap_jet(128)'} {1}];
         end

         save_title = get(get(gca,'Title'));
         save_xlabel = get(get(gca,'XLabel'));
         save_ylabel = get(get(gca,'YLabel'));
         save_zlabel = get(get(gca,'ZLabel'));

         axisfont = struct('fontangle','','fontname','','fontsize','','fontweight','');
         axisfont.fontangle = get(gca,'FontAngle');
         axisfont.fontname = get(gca,'FontName');
         axisfont.fontsize = get(gca,'FontSize');
         axisfont.fontweight = get(gca,'FontWeight');

         cbarfont = struct('fontangle','','fontname','','fontsize','','fontweight','');
         h_cbar = findobj(gcf,'Type','axes','Tag','Colorbar');
         if ~isempty(h_cmap)
            cbarfont.fontangle = get(h_cbar,'FontAngle');
            cbarfont.fontname = get(h_cbar,'FontName');
            cbarfont.fontsize = get(h_cbar,'FontSize');
            cbarfont.fontweight = get(h_cbar,'FontWeight');
         else
            cbarfont.fontangle = 'normal';
            cbarfont.fontname = 'Helvetica';
            cbarfont.fontsize = 9;
            cbarfont.fontweight = 'normal';
         end

         h_peaklabelopt = findobj(gcf,'Tag','peaklabelopt');
         if ~isempty(h_peaklabelopt)
            save_peaks = [];
            h_show = findobj(h_peaklabelopt,'Tag','showpeaklabels');
            save_showpeaks = get(h_show,'Checked');
            save_peaklabels = get(h_peaklabelopt,'UserData');
         end

         h_polygons = findobj(gca,'Tag','polyline');
         if ~isempty(h_polygons)
            save_polys = get(h_polygons);
         else
            save_polys = [];
         end

         h_cbar = findobj(gcf,'Tag','hidecbar');
         if ~isempty(h_cbar)
            lbl = get(h_cbar,'Label');
            if strcmp(lbl(1,1),'H')
               save_cbaropt = 1;
            else
               save_cbaropt = 0;
            end
         end

         h_grid = findobj(gcf,'Tag','hidegrid');
         if ~isempty(h_grid)
            lbl = get(h_grid,'Label');
            if strcmp(lbl(1,1),'H')
               save_grid = 1;
            else
               save_grid = 0;
            end
         end

         h_contour = findobj(gcf,'Tag','contouropt');
         h_contourshow = findobj(h_contour,'Tag','contourshow');
         save_contour = get(h_contourshow,'Checked');
         save_contourdata = get(h_contour,'UserData');

         h_bar = findobj(gcf,'Tag','Colorbar');
         colorscheme = struct('figclr',get(gcf,'Color'), ...
            'axisclr',get(gca,'Color'), ...
            'uniclr',[], ...
            'titleclr',get(get(gca,'Title'),'Color'), ...
            'xclr',get(gca,'xcolor'), ...
            'xlclr',get(get(gca,'XLabel'),'Color'), ...
            'yclr',get(gca,'ycolor'), ...
            'ylclr',get(get(gca,'YLabel'),'Color'), ...
            'zclr',get(gca,'zcolor'), ...
            'zlclr',get(get(gca,'ZLabel'),'Color'), ...
            'cbarclr',get(h_bar,'XColor'));

         cmat = [colorscheme.titleclr ; colorscheme.xclr ; colorscheme.yclr ; ...
            colorscheme.zclr ; colorscheme.cbarclr];
         if length(find(diff(cmat)~=0)) == 0  %check for color differences
            colorscheme.uniclr = colorscheme.titleclr;
         end

         h_l = findobj(gca,'type','light');
         if ~isempty(h_l)
            h_l = h_l(1);  %get first light only
            [lightaz,lightel] = lightangle(h_l);
            save_lightval = [1,lightaz,lightel];
         else
            save_lightval = [0,90,65];
         end

      end

     end

   %generate surface plot
   if isstruct(save_title)  %check for new style label storage
      titlestr = save_title.String;
      zlabelstr = save_zlabel.String;
   else  %update old file version
      titlestr = save_title;
      zlabelstr = save_zlabel;
      save_title = struct('String',titlestr, ...
         'Color',[0 0 0], ...
         'FontName','Times New Roman', ...
         'FontWeight','bold', ...
         'FontAngle','normal', ...
         'Interpreter','none', ...
         'FontSize',max(10,min(20,round(1000 ./ length(titlestr)))));
      save_xlabel = struct('String','Excitation (nm)', ...
         'Color',[0 0 0], ...
         'FontName','Helvetica', ...
         'FontWeight','bold', ...
         'FontAngle','normal', ...
         'Interpreter','none', ...
         'FontSize',10);
      save_ylabel = struct('String','Emission (nm)', ...
         'Color',[0 0 0], ...
         'FontName','Helvetica', ...
         'FontWeight','bold', ...
         'FontAngle','normal', ...
         'Interpreter','none', ...
         'FontSize',10);
      save_zlabel = struct('String',zlabelstr, ...
         'Color',[0 0 0], ...
         'FontName','Helvetica', ...
         'FontWeight','bold', ...
         'FontAngle','normal', ...
         'Interpreter','none', ...
         'FontSize',10);
      save_cbarlabel = struct('String','', ...
         'Color',[0 0 0], ...
         'FontName','Helvetica', ...
         'FontWeight','bold', ...
         'FontAngle','normal', ...
         'Interpreter','none', ...
         'FontSize',10);
   end

   h_s = eemplot(plottype,save_eem,save_zlim,titlestr, ...
      zlabelstr,save_azel,save_axis);

   %apply stored axis tick settings
   if exist('save_xtick') == 1
      set(gca, ...
         'XTick',save_xtick, ...
         'YTick',save_ytick, ...
         'ZTick',save_ztick)
   end

   %apply stored axis direction settings
   if exist('save_xdir') == 1
      set(gca, ...
         'XDir',save_xdir, ...
         'YDir',save_ydir, ...
         'ZDir',save_zdir)
   else  %use old defaults
      set(gca, ...
         'XDir','reverse', ...
         'YDir','reverse', ...
         'ZDir','normal')
   end

   view(save_azel) %ensure view not reset by 'eemplot'

   %apply stored surface appearance options
   set(h_s, ...
      'EdgeColor',save_edge, ...
      'FaceColor',save_facecol, ...
      'MeshStyle',save_mesh, ...
      'LineWidth',.1)

   %restore colordata and backed-up surface data
   if exist('save_eemorig') == 1 && exist('save_cdata') == 1
      set(h_s, ...
         'CData',save_cdata, ...
         'UserData',save_eemorig)
   end

   %process stored colormap data
   if exist('save_cmap') == 1

      %get handles
      h_cmap = findobj(gcf,'Tag','colormap');
      h_rev = findobj(gcf,'Tag','revcmap');
      h_new = findobj(h_cmap,'Tag',['cmap_' save_cmap{1}]);

      if ~isempty(h_new) %check for valid colormap handle

         %manage menu settings
         set(h_cmap,'UserData',save_cmap)
         h_current = findobj(h_cmap,'Checked','on');
         set(h_current,'Checked','off')
         set(h_new,'Checked','on')

         if save_cmap{2} == 1
            set(h_rev,'Checked','off')
         else
            set(h_rev,'Checked','on')
         end

         %apply new colormap and reversal setting
         eval(['c = ' save_cmap{1} ';'])
         if save_cmap{2} == 1  %normal
            colormap(c)
         else
            colormap(flipud(c))  %reversed
         end

      end

   end

   %show/hide colorbar
   if exist('save_cbaropt') == 1
      h_cbaropt = findobj(gcf,'Tag','hidecbar');
      if ~isempty(h_cbaropt)
         h_bar = findobj(gcf,'Tag','Colorbar');
         h_barobj = findobj(h_bar);
         if save_cbaropt == 0 | strcmp(save_cbaropt,'hide')
            set(h_cbaropt,'Label','Show Color Bar')
            set(h_barobj,'Visible','off')
         else
            set(h_cbaropt,'Label','Hide Color Bar')
            set(h_barobj,'Visible','on')
         end
      end
   end

   %apply color scheme, axis labels
   if exist('colorscheme') ~= 1
      colorscheme = struct('figclr',[1 1 1], ...
         'axisclr',[1 1 1], ...
         'uniclr',[0 0 0], ...
         'titleclr',[0 0 0], ...
         'xclr',[0 0 0], ...
         'xlclr',[0 0 0], ...
         'yclr',[0 0 0], ...
         'ylclr',[0 0 0], ...
         'zclr',[0 0 0], ...
         'zlclr',[0 0 0], ...
         'cbarclr',[0 0 0]);
   else
      cmat = [colorscheme.titleclr ; colorscheme.xclr ; colorscheme.yclr ; ...
            colorscheme.zclr ; colorscheme.cbarclr];
      if length(find(diff(cmat)~=0)) == 0  %check for color differences
         colorscheme.uniclr = colorscheme.titleclr;
      end
   end

   set(gcf,'Color',colorscheme.figclr)

   set(gca, ...
      'Color',colorscheme.axisclr, ...
      'XColor',colorscheme.xclr, ...
      'YColor',colorscheme.yclr, ...
      'ZColor',colorscheme.zclr)

   if exist('axisfont') == 1
       if not(or(strcmpi(axisfont.fontangle, 'normal'),strcmpi(axisfont.fontangle, 'italic')))
           axisfont.fontangle = 'normal';
       end
       if not(strcmpi(axisfont.fontname, "Helvetica"))
           axisfont.fontname = "Helvetica";
       end
       if not(isscalar(axisfont.fontsize))
           axisfont.fontsize= 12;
       end
       if not(strcmpi(axisfont.fontweight, 'bold'))
           axisfont.fontweight='bold';
       end
      set(gca, ...
         'FontAngle',axisfont.fontangle, ...
         'FontName',axisfont.fontname, ...
         'FontSize',axisfont.fontsize, ...
         'FontWeight',axisfont.fontweight)
   end

   set(h_bar, ...
      'Color',colorscheme.cbarclr);

   if exist('cbarfont') == 1
       %'Color',[0 0 0], ...
       %'FontName','Helvetica', ...
       %'FontWeight','bold', ...
       %'FontAngle','normal', ...
       %'Interpreter','none', ...
       %'FontSize',14);

      if not(or(strcmpi(cbarfont.fontangle, 'normal'),strcmpi(cbarfont.fontangle, 'italic')))
        cbarfont.fontangle = 'normal';
      end
      if not(strcmpi(cbarfont.fontname, "Helvetica"))
          cbarfont.fontname = "Helvetica";
      end
      if not(isscalar(cbarfont.fontsize))
          cbarfont.fontsize= 12;
      end
      if not(strcmpi(cbarfont.fontweight, 'bold'))
          cbarfont.fontweight='bold';
      end
      set(h_bar, ...
         'FontAngle',cbarfont.fontangle, ...
         'FontName',cbarfont.fontname, ...
         'FontSize',cbarfont.fontsize, ...
         'FontWeight',cbarfont.fontweight)
   end

   h_bar = findobj(gcf,'Tag','Colorbar');
   hndls = [get(gca,'Title') ; get(gca,'XLabel') ; get(gca,'YLabel') ; ...
         get(gca,'ZLabel') ; get(h_bar,'YLabel')];
   varname = [{'save_title'},{'save_xlabel'},{'save_ylabel'},{'save_zlabel'} ...
         {'save_cbarlabel'}];

   for n = 1:length(hndls)
      eval(['s = ' char(varname(n)) ';'])
      set(hndls(n), ...
         'Color',s.Color, ...
         'String',s.String, ...
         'FontName',s.FontName, ...
         'FontSize',s.FontSize, ...
         'FontWeight',s.FontWeight, ...
         'FontAngle',s.FontAngle, ...
         'Interpreter',s.Interpreter)
   end

   %regenerate gridstate
   if exist('save_grid') == 1
      h_grid = findobj(gcf,'Tag','hidegrid');
      if ~isempty(h_grid)
         if save_grid == 0
            set(h_grid,'Label','Show Grid Lines')
            grid off
         else
            set(h_grid,'Label','Hide Grid Lines')
            grid on
         end
      end
   end

   %regenerate saved polygon line objects
   if exist('save_polys') == 1
      if ~isempty(save_polys)
         for n = 1:size(save_polys,1)
         line('XData',save_polys(n).XData, ...
            'YData',save_polys(n).YData, ...
            'ZData',save_polys(n).ZData, ...
            'Color',save_polys(n).Color, ...
            'LineWidth',save_polys(n).LineWidth, ...
            'Clipping','on', ...
            'EraseMode','normal', ...
            'Tag','polyline')
         end
      end
   end

   %regenerate contour lines
   if exist('save_contour') == 1

      h_con = findobj(gcf,'Tag','contouropt');
      h_conshow = findobj(h_con,'Tag','contourshow');
      h_conhide = findobj(h_con,'Tag','contourhide');

      if strcmp(save_contour,'on')

         set(h_conshow,'Checked','on')
         set(h_conhide,'Checked','off')

         cdata = save_contourdata{1};
         if length(cdata) == 3
            clevels = [cdata(1):cdata(3):cdata(2)];
         elseif ~isempty(cdata)
            clevels = cdata(1);
         else
            clevels = [];
         end

         if length(save_contourdata) == 2;  %update contourdata to new format
            save_contourdata = [{save_contourdata{1}},{save_contourdata{2}},{0}];
         end

         contourlines('add',clevels,save_contourdata{2},save_contourdata{3});

      else

         set(h_conshow,'Checked','off')
         set(h_conhide,'Checked','on')

      end

   end

   %regenerate saved peak label objects
   lblflag = 0;
   if exist('save_peaklabels') == 1

      h_peaks = findobj(gcf,'Tag','peaklabelopt');
      h_show = findobj(gcf,'Tag','showpeaklabels');
      h_hide = findobj(gcf,'Tag','hidepeaklabels');

      set(h_peaks,'UserData',save_peaklabels)

      if strcmp(save_showpeaks,'on')
         set(h_show,'Checked','on')
         set(h_hide,'Checked','off')
         lblflag = 1;
      else
         set(h_show,'Checked','off')
         set(h_hide,'Checked','on')
      end

   elseif exist('save_peaks') == 1

      h_peaks = findobj(gcf,'Tag','peaklabelopt');
      h_show = findobj(h_peaks,'Tag','showpeaklabels');
      h_hide = findobj(h_peaks,'Tag','hidepeaklabels');

      if ~isempty(save_peaks)

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

         save_peaklabels = repmat(peaklbl,length(save_peaks)+1,1);

           for n = 1:size(save_peaks,1)
            save_peaklabels(n+1).Position = save_peaks(n).Position;
            save_peaklabels(n+1).String = save_peaks(n).String;
            save_peaklabels(n+1).FontSize = save_peaks(n).FontSize;
            save_peaklabels(n+1).FontWeight = save_peaks(n).FontWeight;
            save_peaklabels(n+1).Color = save_peaks(n).Color;
            save_peaklabels(n+1).Visible = 'on';
         end

         set(h_peaks,'UserData',save_peaklabels)
         set(h_show,'Checked','on')
         set(h_hide,'Checked','off')
         lblflag = 1;

      else

         if exist('peaklabels.mat') == 2
            load peaklabels
            set(h_peaks,'UserData',peaklbls)
         end

         set(h_show,'Checked','off')
         set(h_hide,'Checked','on')

      end

   end

   if exist('save_eeminfo')
      h_eeminfo = findobj(gcf,'Tag','eeminfo');
      if ~isempty(h_eeminfo)
         set(h_eeminfo,'UserData',save_eeminfo)
      end
   end

   viewcontrols('clearfields');

   if lblflag == 1
      for n = 2:length(save_peaklabels)
         h = text(0,0,0,'');
         set(h,save_peaklabels(n))
      end
   end

   if exist('save_lightval')  %apply lighting
      if save_lightval(1) == 1
         h_l = light;
         lightangle(h_l,save_lightval(2),save_lightval(3))
      end
   end

   clip3d

end

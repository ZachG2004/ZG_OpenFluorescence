function savescan(filename,pathname)
%syntax:  savescan(filename,pathname)
%
%Saves 3d fluorescence matrix scan data and view properties in the current
%figure window for use with 'LOADSCAN' and 'EEMPLOT' functions.  If 'filename'
%and 'pathname' are both omitted a dialog box will prompt for the file
%information; if only the file name is provided the file will be saved in the
%current working directory.
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
%last modified 6/26/2006

cancel = 0;
curpath = pwd;
global EEMLOADPATH EEMSAVEPATH

if exist('filename') ~= 1

   filename = [];

end

if exist('pathname') ~= 1

   if ~isempty(filename)
      pathname = curpath;
   elseif ~isempty(EEMSAVEPATH)
      pathname = EEMSAVEPATH;
   elseif ~isempty(EEMLOADPATH)
      pathname = EEMLOADPATH;
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

      [filename,pathname] = uiputfile('*.plt', ...
         'Enter name and directory for plot file',300,200);

      if filename == 0
         cancel = 1;
      else
         [pn,fn] = fileparts(filename);
         filename = [fn '.plt'];
      end

   end

end

if cancel == 0

   h_surf = findobj(gca,'Type','surface');

   if ~isempty(h_surf)

      [az,el] = view;
      ex = get(h_surf,'XData');
      em = get(h_surf,'YData');
      fl = get(h_surf,'ZData');
      save_eem = [NaN ex ; em fl];
      save_cdata = get(h_surf,'CData');
      save_eemorig = get(h_surf,'UserData');
      save_azel = [az el];
      save_axis = axis;
      save_zlim = get(gca,'ZLim');
      save_edge = get(h_surf,'EdgeColor');
      save_facecol = get(h_surf,'FaceColor');
      save_mesh = get(h_surf,'MeshStyle');
      save_xtick = get(gca,'XTick');
      save_ytick = get(gca,'YTick');
      save_ztick = get(gca,'ZTick');
      save_xdir = get(gca,'XDir');
      save_ydir = get(gca,'YDir');
      save_zdir = get(gca,'ZDir');

      axisfont = struct('fontangle','','fontname','','fontsize','','fontweight','');
      axisfont.fontangle = get(gca,'FontAngle');
      axisfont.fontname = get(gca,'FontName');
      axisfont.fontsize = get(gca,'FontSize');
      axisfont.fontweight = get(gca,'FontWeight');

      h_cmap = findobj(gcf,'Tag','colormap');
      if ~isempty(h_cmap)
         save_cmap = get(h_cmap,'UserData');
      else
         save_cmap = [{'cmap_jet(128)'} {1}];
      end

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

      h_bar = findobj(gcf,'Tag','Colorbar');
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
      h_eeminfo = findobj(gcf,'Tag','eeminfo');

      save_contour = get(h_contourshow,'Checked');
      save_contourdata = get(h_contour,'UserData');
      save_eeminfo = get(h_eeminfo,'UserData');

      save_title = get(get(gca,'Title'));
      save_xlabel = get(get(gca,'XLabel'));
      save_ylabel = get(get(gca,'YLabel'));
      save_zlabel = get(get(gca,'ZLabel'));
      save_cbarlabel = get(get(h_bar,'YLabel'));

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

   else

      errorbox('init','No valid surface object on current axis to save!')
      cancel = 1;

   end

end

if cancel == 0

   error = 0;

   try
      cd(pathname)
   catch
      error = 1;
   end

   if error == 0

      try
         save(filename,'save_eem','save_eemorig','save_azel','save_axis', ...
            'save_zlim','save_title','save_zlabel','save_edge','save_facecol','save_mesh', ...
            'save_xtick','save_ytick','save_ztick','save_showpeaks','save_peaklabels', ...
            'save_polys','save_cbaropt','save_grid','save_contour','save_contourdata', ...
            'save_xdir','save_ydir','save_zdir','save_eeminfo','save_cmap','save_cdata', ...
            'save_xlabel','save_ylabel','save_cbarlabel','save_lightval','colorscheme','axisfont','cbarfont')
      catch
         error = 1;
      end

      if error == 1

   errorbox('init','Invalid filename - plot not saved!')

      else

         EEMSAVEPATH = pathname;

      end

   else

      errorbox('init','Invalid pathname - plot not saved!');

   end

end

cd(curpath)


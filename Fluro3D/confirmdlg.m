function confirmdlg(op,querystr,callback)
%syntax:  confirmdlg(op,querystr,callback)
%
%Confirmation dialog that executes 'callback' statement if the
%'OK' button is pressed
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
%last modified 10/7/2001

if nargin == 0
   op = 'init';
end

if strcmp(op,'init')

   if length(findobj) > 1
      h_dlg = findobj('Tag','dlgConfirm');
      if ~isempty(h_dlg)
         close(h_dlg)
      end
      h_fig = gcf;
   else
      h_fig = [];
   end

   if exist('querystr') & exist('callback')

      screenres = get(0,'ScreenSize');

      figwidth = max(min(length(querystr).*9,screenres(3)),200);

      if length(findobj) > 1
         figpos = get(gcf,'Position');
         center = [figpos(1)+figpos(3)./2 figpos(2)+figpos(4)./2];
         if center(1)+figwidth./2 > screenres(3)
            center(1) = screenres(3)-figwidth./2-5;
         end
      else
         center = [screenres(3)./2 screenres(4)./2];
      end

      h_dlg = figure('Name','Confirmation', ...
         'Color',[0.9 0.9 0.9], ...
         'Visible','off', ...
         'Units','pixels', ...
         'Position',[center(1)-figwidth./2 center(2)-40 figwidth 80], ...
         'Menubar','none', ...
         'NumberTitle','off', ...
         'Resize','off', ...
         'DefaultUiControlUnits','pixels', ...
         'KeypressFcn','confirmdlg(''cancel'')', ...
         'Tag','dlgConfirm', ...
         'UserData',h_fig);

      bgcolor = [0.9 0.9 0.9];

      uicontrol(h_dlg, ...
         'Style','text', ...
         'Position',[1 40 figwidth-2 25], ...
         'String',querystr, ...
         'FontSize',12, ...
         'FontWeight','bold', ...
         'HorizontalAlignment','center', ...
         'BackgroundColor',bgcolor, ...
         'ForegroundColor',[0 0 0]);

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[figwidth.*0.33-30 10 60 25], ...
         'FontWeight','bold', ...
         'String','Cancel', ...
         'Callback','confirmdlg(''cancel'')');

      uicontrol(h_dlg, ...
         'Style','pushbutton', ...
         'Position',[figwidth.*0.66-30 10 60 25], ...
         'String','OK', ...
         'FontWeight','normal', ...
         'Tag','cmdOK', ...
         'UserData',callback, ...
         'Callback','confirmdlg(''ok'')');

      set(h_dlg,'Visible','on')

   end

else

   h_dlg = findobj('Tag','dlgConfirm');
   h_OK = findobj(h_dlg,'Tag','cmdOK');

   h_fig = get(h_dlg,'UserData');
   callback = get(h_OK,'UserData');

   close(h_dlg)

   if strcmp(op,'cancel')

      if ~isempty(h_fig)
         figure(h_fig)
      end

   elseif strcmp(op,'ok')

      eval(callback)

   end

   drawnow

end

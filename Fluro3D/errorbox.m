function errorbox(op,message)
%syntax:  errorbox(op,message)
%
%Generates a simple message box to acknowledge error conditions.  The
%single 'OK' button simply closes the box and shifts focus back to the
%eliciting figure window.  If op is 'init' the errorbox is created with
%the string in 'message' displayed.
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
%last modified 11/30/1999

if nargin > 0

   if strcmp(op,'init')

      if length(findobj)>1
         h = gcf;
      else
         h = [];
      end

      if exist('message') ~= 1
         message = '';
      end

      if isempty(message)
         message = 'Error encountered';
      end

      %set screen resolution constant (maximum 800x600)
      screen = get(0,'screensize');
      screenres = screen(3:4);

      figwidth = min(screenres(1)-10,max(length(message).*7,150));

      h_error = figure( ...
         'Units','pixels', ...
         'Position',[(screenres(1)-figwidth)./2 (screenres(2)-50)./2 figwidth 75], ...
         'Color',[.8 0 0], ...
         'Name','Error Message', ...
         'Menubar','none', ...
         'NumberTitle','off', ...
         'KeypressFcn','errorbox(''close'')', ...
         'WindowStyle','modal', ...
         'Resize','off', ...
         'Tag','errorbox', ...
         'UserData',h);

      set(gca, ...
         'Visible','off', ...
         'Position',[0 .3 1 .7])

      uicontrol(h_error, ...
         'Style','pushbutton', ...
         'Units','pixels', ...
         'String','OK', ...
         'Position',[(figwidth-50)./2 5 50 25], ...
         'Callback','errorbox close');

      text(.5,.6,message, ...
         'FontName','Helvetica', ...
         'FontWeight','bold', ...
         'FontSize',10, ...
         'Color','w', ...
         'Interpreter','none', ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','middle')

   elseif strcmp(op,'close')

      h_error = findobj('Tag','errorbox');

      h = get(h_error,'UserData');

      close(h_error)

      if ~isempty(h)
         figure(h)
      end

   end

end





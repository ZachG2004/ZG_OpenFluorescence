function messagebox(op,message,callback,dialogtitle,bgcolor)
%syntax:  messagebox(op,message,callback,dialogtitle,bgcolor)
%
%Generates a multiline message box.  If op is 'init' the message box is
%created with the string in 'message' displayed.  The single 'OK' button
%closes the box, shifts focus back to the eliciting figure window, and
%issues the optional 'callback' statement.  The optional arguments
%'dialogtitle' and 'bgcolor' specify the window title and background color
%of the messaage box, resp.
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

      if length(findobj) > 1
         h = gcf;
      else
         h = [];
      end

      if exist('message') ~= 1
         message = '';
      end

      if exist('callback') ~= 1
         callback = '';
      end

      if exist('dialogtitle') ~= 1
         dialogtitle = 'Message';
      end

      if exist('bgcolor') ~= 1
         bgcolor = [0 0 .8];
      end

      %set screen resolution constant (maximum 800x600)
      screen = get(0,'screensize');
      screenres = screen(3:4);

      lines = size(message,1);
      figw = min(screenres(1)-10,max(length(message).*7,150));
      figh = 75 + (lines-1).*18;
      lineheight = 18./(figh-30);

      h_msg = figure( ...
         'Visible','off', ...
         'Units','pixels', ...
         'Position',[(screenres(1)-figw)./2 (screenres(2)-figh)./2 ...
            figw figh], ...
         'Name',dialogtitle, ...
         'Color',bgcolor, ...
         'NumberTitle','off', ...
         'MenuBar','none', ...
         'KeyPressFcn','messagebox(''close'')', ...
         'WindowStyle','modal', ...
         'Resize','off', ...
         'Tag','messagebox', ...
         'UserData',h);

      set(gca, ...
         'Visible','off', ...
         'Position',[0 30./figh 1 1-40./figh])

      uicontrol(h_msg, ...
         'Style','pushbutton', ...
         'Units','pixels', ...
         'String','OK', ...
         'Position',[(figw-50)./2 5 50 25], ...
         'Tag','callback', ...
         'UserData',callback, ...
         'Callback','messagebox(''close'')');

      for n = 1:lines

         str = deblank(message(n,:));

         text(0.5,1-lineheight*n,str, ...
            'FontName','Helvetica', ...
            'FontWeight','bold', ...
            'FontSize',10, ...
            'Color','w', ...
            'Interpreter','none', ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle')

      end

      set(h_msg,'Visible','on')
      drawnow

   elseif strcmp(op,'close')

      h_msg = findobj('Tag','messagebox');
      h_callback = findobj(h_msg,'Tag','callback');

      h = get(h_msg,'UserData');
      callback = get(h_callback,'UserData');

      close(h_msg)

      if ~isempty(h)
         figure(h)
      end

      if ~isempty(callback)
         eval(callback)
      end

      drawnow

   end

end





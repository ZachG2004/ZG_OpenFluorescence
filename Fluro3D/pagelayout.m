function pagelayout(op,pos)
%syntax:  pagelayout(op,pos)
%
%Creates or updates a page layout figure for printing up to 9 EEM
%scan plots.
%
%'op' is the operation to perform.  Valid operations are:
%    'land' - initializes a figure in landscape orientation
%    'port' - initializes a figure in portrait orientation
%    'activate' - activates the subplot at the specified position
%    'clear' - clears the subplot in the specified position
%    'copyplot' - copies the current axes object of the current figure
%         to the specified position on the page layout figure
%
%'pos' is plot position, which is an integer specifying the position
%    to update.  If 'op' is 'land' or 'port', this value is used with
%    the subplot command to establish the total number of position
%    slots.  Valid positions are 1, 2, 3, 4, 6, and 9.
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
%last modified 4/9/1999

error = 0;
validpos = [1 2 3 4 6 9];

if nargin ~= 2

   error = 1;
   errormsg = 'Too few arguments for function';

end

if error == 0

   I_pos = find(pos == validpos);

   if sum(I_pos) == 0

      error = 1;
      errormsg = 'Invalid position - valid values are 1, 2, 3, 4, 6 and 9';

   end

end

if error == 0

   op = lower(op);

   if strcmp(op,'port') | strcmp(lower(op),'land')

      screenres = get(0,'ScreenSize');
      figtopoffset = 50;
      figbottomoffset = 40;

      h = findobj('Name','Scan Layout');

      if ~isempty(h)

         error = 1;
         errormsg = 'Invalid command - Scan Layout figure already exists!';

      elseif strcmp(op,'port')

         figheight = screenres(4)-(figbottomoffset+figtopoffset);
         figwidth = figheight*8.5/11;
         figleft = (screenres(3)-figwidth)*0.5;
         figbottom = figbottomoffset;
         orient = 'portrait';
         paperpos = [0 0 8.5 11];

         switch(pos)
         case 1
            figformat = [1 1];
         case 2
            figformat = [2 1];
         case 3
            figformat = [3 1];
         case 4
            figformat = [2 2];
         case 6
            figformat = [3 2];
         otherwise
            figformat = [3 3];
         end

      else

         figheight = screenres(4)-(figbottomoffset+figtopoffset);
         figwidth = figheight*11/8.5;
         figleft = (screenres(3)-figwidth)*0.5;
         figbottom = (screenres(4)-figheight)*0.5;
         orient = 'landscape';
         paperpos = [0 0 11 8.5];

         switch(pos)
         case 1
            figformat = [1 1];
         case 2
            figformat = [1 2];
         case 3
            figformat = [1 3];
         case 4
            figformat = [2 2];
         case 6
            figformat = [2 3];
         otherwise
            figformat = [3 3];
         end

      end

      if error == 0;

         figure('Units','pixels', ...
            'NumberTitle','off', ...
            'Name','Page Layout', ...
            'Position',[figleft figbottom figwidth figheight], ...
            'UserData',figformat, ...
            'PaperOrientation',orient, ...
            'PaperPosition',paperpos);

      end

   else

      h = findobj('Name','Page Layout');

      if ~isempty(h)

         figformat = get(h,'UserData');

         if strcmp(op,'clear') | strcmp(op,'activate')

            figure(h)
            subplot(figformat(1),figformat(2),pos)

            if strcmp(op,'clear')
               delete(gca)
               subplot(figformat(1),figformat(2),pos)
            end

            ax = axis;

            if sum(ax(1:4)==[0 1 0 1])==4
               axis off
            end

         elseif strcmp(op,'copyplot')

            h_ax = gca;
            h_bar = findobj(gcf,'Tag','Colorbar');
            axunits = get(h_ax,'Units');
            set(h_ax,'Units','normal')
            axpos = get(h_ax,'Position');
            set(h_ax,'Units',axunits)

            figure(h)
            subplot(figformat(1),figformat(2),pos)
            axis off

            newaxpos = get(gca,'Position');
            h_new = copyobj(h_ax,h);
            set(h_new,'Position',newaxpos);

            fontscale = max(1,min(1,axpos(4).*1.2).*max(figformat));

            %get handles for all text elements
            h_text = h_new;
            h_text = [h_text ; get(h_new,'XLabel')];
            h_text = [h_text ; get(h_new,'YLabel')];
            h_text = [h_text ; get(h_new,'ZLabel')];
            h_text = [h_text ; get(h_new,'Title')];
            h_temp = findobj(h_new,'Type','text');

            if ~isempty(h_temp)
               h_text = [h_text ; h_temp];
            end

            if ~isempty(h_bar)
               h_newbar = colorbar;
               h_text = [h_text ; h_newbar];
            end

            %apply font scalefactor to text elements
            for n = 1:length(h_text)
               oldsize = get(h_text(n),'FontSize');
               set(h_text(n),'FontSize',oldsize./fontscale)
            end

         else

            error = 1;
            errormsg = ['The option ''' op ''' is not recognized'];

         end

      else

         error = 1;
         errormsg = 'Invalid option - Scan Layout figure does not exist';

      end

   end

end

if error == 1

   errorbox('init',errormsg)

end
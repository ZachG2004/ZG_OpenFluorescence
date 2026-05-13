function eems_out = matcheems(eems_in,matchopt)
%syntax:  eems_out = matcheems(eems_in,matchopt)
%
%Matches the densities and excitation/emission ranges of multiple
%EEM scans to facilitate plotting and calculation.
%
%'eems_in' is a cell array containing matrices of EEM data (i.e.
%   excitation wavelengths in the first row, emission wavelengths
%   in the first column, and corresponding fluorescence intensity
%   values for each ex/em wavelength combination).
%
%'matchopt' specifies how to handle matrix density mismatches.  If 'matchopt'
%   is 0 (default) the higher density matrices will be reduced to match the
%   lowest density matrix prior to division.  If 'matchopt' is 1 the lower
%   density matrices will promoted to match the highest density matrix
%   using bicubic interpolation.
%
%'eems_out' is a cell array containing matched matrices of EEM data
%
%Note that the output matrices will be truncated as necessary if
%the excitation/emission ranges of the input matrices do not match, and
%invalid EEM matrices will be returned as empty cells in the cell array.
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
%last modified 3/12/2000

if iscell(eems_in) & length(eems_in) >= 2  %check input matrix

   %initialize output variable
   eems_out = cell(size(eems_in));

   %initialize error flag
   error = 0;

   %apply default matchopt if omitted
   if ~exist('matchopt')
      matchopt = 0;
   end

   %initialize loop variables
   waverng = [0 1000 0 1000];
   waveinc = [1000 0 1000 0];

   %determine overlapping Ex and Em ranges across scans
   for n = 1:length(eems_in)

      [ex,em] = unwrapeem(eems_in{n});

      if ~isempty(ex)

         %form array of max starting ex, min ending ex, max starting em, min ending em
         waverng = [max(ex(1),waverng(1)) min(ex(length(ex)),waverng(2)) ...
            max(em(1),waverng(3)) min(em(length(em)),waverng(4))];

         %form array of min ex inc, max ex inc, min em inc, max em inc
         waveinc = [min(ex(2)-ex(1),waveinc(1)) max(ex(2)-ex(1),waveinc(2)) ...
               min(em(2)-em(1),waveinc(3)) max(em(2)-em(1),waveinc(4))];

      end

   end

   %generate appropriate ex/em arrays for resampling
   if matchopt == 1  %use minimum increment, bicubic interpolation flag
      exinc = waveinc(1);
      eminc = waveinc(3);
      method = 'cubic';
   else  %use maximum increment, default interpolation flag
      exinc = waveinc(2);
      eminc = waveinc(4);
      method = 'linear';
   end
   ex_new = [waverng(1):exinc:waverng(2)];
   em_new = [waverng(3):eminc:waverng(4)]';

   %truncate matrices to match overlapping ex/em range & resample
   for n = 1:length(eems_in)

      if sum(size(eems_in{n})) > 2  %matrix

         %extract EEM components
         [ex,em,fl,fl_id] = unwrapeem(eems_in{n});

         if ~isempty(ex)  %check for valid matrix

            %truncate matrix to match new limits
            I_ex = find(ex >= waverng(1) & ex <= waverng(2));
            I_em = find(em >= waverng(3) & em <= waverng(4));
            ex = ex(I_ex);
            em = em(I_em);
            exmatch = sum([waverng(1) exinc waverng(2)] ~= ...
               [ex(1) ex(min(2,length(ex)))-ex(1) ex(length(ex))]);
            emmatch = sum([waverng(3) eminc waverng(4)] ~= ...
               [em(1) em(min(2,length(em)))-em(1) em(length(em))]);

            %resample using appropriate technique and wrap output
            if exmatch == 0 & emmatch == 0   %matching parameters - reindex only
               fl = fl(I_em,I_ex);
            else  %interpolate
               fl = interp2(ex,em,fl(I_em,I_ex),ex_new,em_new,method);
            end
              eems_out{n} = wrapeem(ex_new,em_new,fl,fl_id);

         end

      else  %scalar (store unmodified in output cell array)

         eems_out{n} = eems_in{n};

      end

   end

end

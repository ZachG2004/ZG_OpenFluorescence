function [eem_blanc,eem_cor,correct,eem_filter] = cleanscanlez_NEW_LAPIERRE_2(eem,blanc,correct,parms,baseopt)

%function [eem_blanc,maxpos,eem_cor,correct,eem_filter] = cleanscanlez(eem,blanc,correct,parms,baseopt)
%syntax:  [eem_cor,correct,eem_filter] = cleanscan(eem,tol,coeff,baseopt)
%
%Corrects an excitation-emission matrix fluorometer scan (EEM) to remove
%specific optical aberrations (i.e. 1st-order Rayleigh scatter, 2nd-order
%Rayleigh scatter (i.e. overtones) and their associated Raman scatter peaks).
%If tolerances <1000 are specified in the 'correct' matrix, fluorescence
%values in scatter regions (i.e. peak emission +/- tolerance in nm for each
%excitation wavelength) are excised and replaced by interpolation of the
%surrounding data using a three-dimensional Delaunay triangulation method.  If
%tolerances >=1000 are specified, values in the corresponding portion of the EEM
%will be replaced with a constant value specified by 'baseopt' (i.e. truncated).
%Tolerance values of 0 can be used to selectively disable correction of the
%corresponding scatter peaks.
%
%Input arguments:
%
%   'eem' is a matrix of EEM data, with excitation wavelengths in
%      the first row, emission wavelengths in the first column, and
%      corresponding fluorescence intensity values for each ex/em
%      wavelength combination.  The top left cell is ignored but copied
%      to the output matrix in case it contains information.  Note that
%      single emission and single excitation scans are supported, but
%      they must be in 'eem' format as described (i.e. must include the
%      excitation or emission wavelength in the first row or column, resp.)
%
%   'tol' is an n row by 2 column matrix of correction tolerances in nm.
%      Columns specify tolerances below (left col) and above (right col) the
%      peak emission at each excitation wavelength.  Typical row assignments
%      are as follows:
%         row 1: primary Rayleigh scatter
%         row 2: primary Raman scatter
%         row 3: secondary Rayleigh scatter
%         row 4: secondary Raman scatter
%      Use tolerances >=1000 to truncate corresponding portions of an EEM and
%      set truncated values to 'baseopt' (note: truncation overrides excising)
%      Typical example with truncation of emissions below excitation wavelength:
%         [1000  12; ...
%          16    16; ...
%          18    18; ...
%          18    18]
%
%   'coeff' is a matrix of polynomial curve fit coefficients which describe
%      the excitation wavelength-dependent emission wavelength for each
%      scatter peak.  Coefficients must be in rows and ordered appropriately for
%      the 'polyval' function (i.e. x^n, x^(n-1), ... , constant).  Row assignments
%      must match the 'tol' matrix, but any power polynomial can be specified.
%      Typical example for a second-order polynomial matching 'tol' above:
%          [0        1.0000  0; ...
%           0.0006   0.8711  18.7770; ...
%           0        2.0000  0; ...
%           -0.0001  2.4085  -47.2965]
%      equivalent to:  0x^2 + 1x + 0, 0.0006x^2 + 0.8711x + 18.777, etc.
%
%   'baseopt' specifies optional baseline value to substitute for values in
%      truncated scan regions.  Default value is 0
%
%Output parameters:
%
%   'eem_cor' is a matrix the same dimensions as 'eem' containing corrected
%      fluorescence intensity values.
%
%   'correct' is the correction matrix reflecting any changes following validation
%
%   'eem_filter' is the filter matrix used to correct 'eem' (i.e. a matrix of ones
%      and zeros the same dimensions as 'eem_cor', with zeros representing values
%      in scatter regions which were excised or truncated).
%
%(c)2001 by Wade Sheldon
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
%last modified 10/5/2001

%initialize outputs
eem_cor = [];
eem_filter = [];
eem_blanc = [];
maxpos = []

eem_blanc(1,1:size(eem,2)) = eem(1,1:size(eem,2));
eem_blanc(1:size(eem,1),1) = eem(1:size(eem,1),1);
eem_blanc(2:size(eem,1),2:size(eem,2)) = eem(2:size(eem,1),2:size(eem,2)) - blanc(2:size(blanc,1),2:size(blanc,2));

if nargin >= 3  %check for minimum number of arguments

   if ~exist('baseopt')  %assign default baseopt
      baseopt = 0;
   end

   if size(correct,2) < 2  %single column format - replicate values
        correct = {correct correct};
   end

   cancel = 0;

   %validate input arguments
   [ex,em,fl,fl_id] = unwrapeem(eem_blanc);

   if isempty(fl)  %validate data matrix
      cancel = 1;
      errormsg = 'EEM data matrix is invalid';
   elseif size(parms,1) ~= size(correct,1)  %validate polyfit parms
      cancel = 1;
      errormsg = 'Curve-fit coefficient matrix does not match correction matrix'
   end

   if cancel == 0  %proceed with analysis

      %form observed emission matrix
      em_obs = repmat(em,1,length(ex));

      %initialize filter matrices
      filt_excise = ones(size(em_obs));
      filt_trunc = zeros(size(em_obs));

      %loop through correction parameters for each peak
      for n = 1:size(correct,1)

         if correct(n,1) > 0 | correct(n,2) > 0  %test for no-filter condition

            peaks = polyval(parms(n,:),ex);  %get array of scatter peak emissions

            %form appropriate filter matrices for emissions below scatter peak
            if correct(n,1) < 1000  %excise
               em_below = (em_obs - repmat(peaks-correct(n,1),length(em),1)) <= 0;
            else  %truncate
               %create logical index the same dimensions as em_obs, with vals below
               %the scatter peak lower limit = 1, update truncation filter
               em_below = (em_obs - repmat(peaks,length(em),1)) <= 0;
               filt_trunc(em_below) = 1;
            end

            %form appropriate filter matrices for emissions above scatter peak
            if correct(n,2) < 1000  %excise
               em_above = (em_obs - repmat(peaks+correct(n,2),length(em),1)) >= 0;
            else  %truncate
               %create logical index the same dimensions as em_obs, with vals above
               %the scatter peak lower limit = 1, update truncation filter
               em_above = (em_obs - repmat(peaks,length(em),1)) >= 0;
               filt_trunc(em_above) = 1;
            end

            %update excise filter matrix using combination of logical indices (excise region = 0)
            filt_excise = filt_excise .* (em_below + em_above);

         end

      end

      %substitute 'baseopt' for truncated values
      fl(filt_trunc == 1) = baseopt;

      %update master filter to account for truncations
      filt_excise(filt_trunc == 1) = 1;

      %get index of excised values
      I_excise = find(filt_excise == 0);

      %excise values and grid data to reconstitute EEM if necessary
      if ~isempty(I_excise)

         %replace zeros with NaN
         fl(I_excise) = NaN;

         %form matched ex, em, fl vectors
         em_vec = reshape(em*ones(1,length(ex)),length(em)*length(ex),1);
         ex_vec = reshape(ones(length(em),1)*ex,length(em)*length(ex),1);
         fl_vec = reshape(fl,length(em)*length(ex),1);

         %get index of valid data points
         I_valid = find(~isnan(fl_vec));

         %interpolate using 2D or 3D algorithm as appropriate
         if size(fl,2) > 1

            if size(fl,1) > 1  %EEM matrix

               %grid valid data points to form new EEM
               fl = griddata(ex_vec(I_valid),em_vec(I_valid),fl_vec(I_valid),ex,em);

            else  %excitation scan

               %interpolate single ex scan
               fl = interp1(ex_vec(I_valid),fl_vec(I_valid),ex,'spline');

            end

         else  %emission scan

            %interpolate single em scan
            fl = interp1(em_vec(I_valid),fl_vec(I_valid),em,'spline');

         end

         %zero out any nulls or negative or near-zero values
         fl = nonneg(fl);

      end

      %assemble output EEM
      eem_cor = wrapeem(ex,em,fl,fl_id);

      %assemble total correction filter in EEM form
      filt_excise = filt_excise .* (filt_trunc < 1);
      eem_filter = wrapeem(ex,em,filt_excise);

   end

else

   errormsg = 'Too few arguments for function';
   cancel = 1;

end

if cancel ~= 0

   clc
   disp(' '); disp(' ')
   disp(errormsg)
   disp(' '); disp(' ')

end

h_s = eemplot('newfig',eem_cor)

% %Extrait la matrice des intensit? de fluorescence de H1
% flH1 = eem_cor(172:212,12:16);
% eemH1 = [];
% eemH1(1:41,1:5) = flH1;
% %Extrait l'excitation, l'emission et l'intensit? fluorescente du pic max de
% %la MODH1
% maxposH1 = [];
% maxH1 = max(max(eemH1)); % Valeur maximale de eemH1: intensit? maximale de fluorescence.
% exmaxH1 = []; % Matrice vide
% emmaxH1 = [];
% k = 1;
% l = 1;
% disp(' ')
% for i = 1:size(eemH1,1) % Boucle parcourant chaque ?l?ment de eemH1
% for j = 1:size(eemH1,2)
% if eemH1(i,j) == maxH1 % Si un ?l?ment de eemH1 = max(eemH1), alors il le place dans une autre matrice
% emmaxH1(k) = i; % Cette matrice-l?
% k=k+1;
% exmaxH1(l) = j;
% j=j+1;
% end
% end
% end
% maxposH1 = [310+exmaxH1(end).*10 419+emmaxH1(end) max(max(eemH1))];
% 
% %Extrait la matrice des intensit? de fluorescence de H2
% flH2 = eem_cor(172:212,2:5);
% eemH2 = [];
% eemH2(1:41,1:4) = flH2;
% %Extrait l'excitation, l'emission et l'intensit? fluorescente du pic max de
% %la MODH2
% maxposH2 = [];
% maxH2 = max(max(eemH2)); % Valeur maximale de eemH2: intensit? maximale de fluorescence.
% exmaxH2 = []; % Matrice vide
% emmaxH2 = [];
% k = 1;
% l = 1;
% disp(' ')
% for i = 1:size(eemH2,1) % Boucle parcourant chaque ?l?ment de eemH2
% for j = 1:size(eemH2,2)
% if eemH2(i,j) == maxH2 % Si un ?l?ment de eemH2 = max(eemH2), alors il le place dans une autre matrice
% emmaxH2(k) = i; % Cette matrice-l?
% k=k+1;
% exmaxH2(l) = j;
% j=j+1;
% end
% end
% end
% maxposH2 = [210+exmaxH2(end).*10 419+emmaxH2(end) max(max(eemH2))];
% 
% %Extrait la matrice des intensit? de fluorescence du P1
% flP1 = eem_cor(117:137,2:4);
% eemP1 = [];
% eemP1(1:21,1:3) = flP1;
% %Extrait l'excitation, l'emission et l'intensit? fluorescente du pic max du
% %P1
% maxposP1 = [];
% maxP1 = max(max(eemP1)); % Valeur maximale de eemP1: intensit? maximale de fluorescence.
% exmaxP1 = []; % Matrice vide
% emmaxP1 = [];
% k = 1;
% l = 1;
% disp(' ')
% for i = 1:size(eemP1,1) % Boucle parcourant chaque ?l?ment de eemP1
% for j = 1:size(eemP1,2)
% if eemP1(i,j) == maxP1 % Si un ?l?ment de eemP1 = max(eemP1), alors il le place dans une autre matrice
% emmaxP1(k) = i; % Cette matrice-l?
% k=k+1;
% exmaxP1(l) = j;
% j=j+1;
% end
% end
% end
% maxposP1 = [210+exmaxP1(end)*10 364+emmaxP1(end) max(max(eemP1))];
% 
% %Extrait la matrice des intensit? de fluorescence du Tryptophane-Like 1
% flTrp1 = eem_cor(82:112,6:10);
% eemTrp1 = [];
% eemTrp1(1:31,1:5) = flTrp1;
% %Extrait l'excitation, l'emission et l'intensit? fluorescente du pic max du
% %Trp-Like 1
% maxposTrp1 = [];
% maxTrp1 = max(max(eemTrp1)); % Valeur maximale de eemTrp1: intensit? maximale de fluorescence.
% exmaxTrp1 = []; % Matrice vide
% emmaxTrp1 = [];
% k = 1;
% l = 1;
% disp(' ')
% for i = 1:size(eemTrp1,1) % Boucle parcourant chaque ?l?ment de eemTrp1
% for j = 1:size(eemTrp1,2)
% if eemTrp1(i,j) == maxTrp1 % Si un ?l?ment de eemTrp1 = max(eemTrp1), alors il le place dans une autre matrice
% emmaxTrp1(k) = i; % Cette matrice-l?
% k=k+1;
% exmaxTrp1(l) = j;
% j=j+1;
% end
% end
% end
% maxposTrp1 = [250+exmaxTrp1(end).*10 329+emmaxTrp1(end) max(max(eemTrp1))];
% 
% %Extrait la matrice des intensit? de fluorescence du Tryptophane-Like 2
% flTrp2 = eem_cor(82:112,2:5);
% eemTrp2 = [];
% eemTrp2(1:31,1:4) = flTrp2;
% %Extrait l'excitation, l'emission et l'intensit? fluorescente du pic max du
% %Trp-Like 2
% maxposTrp2 = [];
% maxTrp2 = max(max(eemTrp2)); % Valeur maximale de eemTrp2: intensit? maximale de fluorescence.
% exmaxTrp2 = []; % Matrice vide
% emmaxTrp2 = [];
% k = 1;
% l = 1;
% disp(' ')
% for i = 1:size(eemTrp2,1) % Boucle parcourant chaque ?l?ment de eemTrp2
% for j = 1:size(eemTrp2,2)
% if eemTrp2(i,j) == maxTrp2 % Si un ?l?ment de eemTrp2 = max(eemTrp2), alors il le place dans une autre matrice
% emmaxTrp2(k) = i; % Cette matrice-l?
% k=k+1;
% exmaxTrp2(l) = j;
% j=j+1;
% end
% end
% end
% maxposTrp2 = [210+exmaxTrp2(end).*10 329+emmaxTrp2(end) max(max(eemTrp2))];
% 
% %Extrait la matrice des intensit? de fluorescence du Tyrosine-Like 1
% flTyr1 = eem_cor(32:72,5:9);
% eemTyr1 = [];
% eemTyr1(1:41,1:5) = flTyr1;
% %Extrait l'excitation, l'emission et l'intensit? fluorescente du pic max du
% %Tyr-Like 1
% maxposTyr1 = [];
% maxTyr1 = max(max(eemTyr1)); % Valeur maximale de eemTyr1: intensit? maximale de fluorescence.
% exmaxTyr1 = []; % Matrice vide
% emmaxTyr1 = [];
% k = 1;
% l = 1;
% disp(' ')
% for i = 1:size(eemTyr1,1) % Boucle parcourant chaque ?l?ment de eemTyr1
% for j = 1:size(eemTyr1,2)
% if eemTyr1(i,j) == maxTyr1 % Si un ?l?ment de eemTyr1 = max(eemTyr1), alors il le place dans une autre matrice
% emmaxTyr1(k) = i; % Cette matrice-l?
% k=k+1;
% exmaxTyr1(l) = j;
% j=j+1;
% end
% end
% end
% maxposTyr1 = [240+exmaxTyr1(end).*10 279+emmaxTyr1(end) max(max(eemTyr1))];
% 
% %Extrait la matrice des intensit? de fluorescence du Tyrosine-Like 2
% flTyr2 = eem_cor(37:67,2:4);
% eemTyr2 = [];
% eemTyr2(1:31,1:3) = flTyr2;
% %Extrait l'excitation, l'emission et l'intensit? fluorescente du pic max du
% %Tyr-Like 2
% maxposTyr2 = [];
% maxTyr2 = max(max(eemTyr2)); % Valeur maximale de eemTyr2: intensit? maximale de fluorescence.
% exmaxTyr2 = []; % Matrice vide
% emmaxTyr2 = [];
% k = 1;
% l = 1;
% disp(' ')
% for i = 1:size(eemTyr2,1) % Boucle parcourant chaque ?l?ment de eemTyr2
% for j = 1:size(eemTyr2,2)
% if eemTyr2(i,j) == maxTyr2 % Si un ?l?ment de eemTyr2 = max(eemTyr2), alors il le place dans une autre matrice
% emmaxTyr2(k) = i; % Cette matrice-l?
% k=k+1;
% exmaxTyr2(l) = j;
% j=j+1;
% end
% end
% end
% maxposTyr2 = [210+exmaxTyr2(end).*10 284+emmaxTyr2(end) max(max(eemTyr2))];
% 
% maxpos = [maxposH1 0 maxposH2 0 maxposP1 0 maxposTrp1 0 maxposTrp2 0 maxposTyr1 0 maxposTyr2 0];

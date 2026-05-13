function T2 = savgolay(T,L,forder,dorder,endprotect)
% T2 = savgolay(T,L,forder,dorder,endprotect);
%  
% Polynomial filtering method of Savitsky and Golay 
% T = matrix containing vectors of signals to be filtered
%     *** the derivative is calculated for each ROW  ** 
% L = filter length
% forder = filter order (2 = quadratic filter, 4= quartic)
% dorder = derivative order (0 = smoothing, 1 = first derivative, etc.)
% endprotect = 2-element array specifying number of columns to protect
%     on the beginning and end of each row, resp.
%
%posted on comp.soft-sys.matlab by Daniel Buckton (dbucton@ollamh.ucd.ie)
%
%modified by Wade Sheldon on 2/11/99 to support matrices of signal vectors
%     and variable endpoint protection

if nargin > 0  %check for required input matrix/vector
   
   %apply default values for any missing parameters
   if exist('L') ~= 1
      L = min(5,size(T,2));  %default to 5-element filter length
   end
   
   if exist('forder') ~= 1
      forder = 3;  %default = cubic
   end
   
   if exist('dorder') ~= 1
      dorder = 0;  %default to smoothing
   end
   
   if exist('endprotect') ~= 1
      endprotect = [0 0];  %default to no endpoint protection
   elseif length(endprotect) ~= 2  %test for proper # of elements
      endprotect = [endprotect(1) endprotect(1)];   
   end
   
   T2 = T;  %initialize output variable
   [rows,cols] = size(T);
   dorder = dorder + 1;
   
   % *** check inputs ***
   if  rem(L,2)-1 ~= 0
      error('filter length is not an odd integer')
   elseif (forder) < (dorder)
      error('the derivative order is too large')  
   end 
   
   % *** calculate filter coefficients ***
   Lc = (L-1)/2;                    % index
   X = [-Lc:Lc]'*ones(1,forder+1);  
   p = ones(L,1)*[0:forder];        % polynomial terms
   X = X.^p;                        % polynomial coefficients
   F = pinv(X);                     % invert
   
   % *** filter via convolution and take care of the end points ***
   for n = 1:rows  
      temp = conv(T(n,:),F(dorder,:));
      T2(n,:) = temp(Lc+1:length(temp)-Lc);
   end
   
   % *** apply endpoint replacements ***
   
   if endprotect(1) > 0
      T2(:,1:endprotect(1)) = T(:,1:endprotect(1));
   end
   
   if endprotect(2) > 0
      T2(:,cols-endprotect(2):cols) = T(:,cols-endprotect(2):cols);
   end
   
else  %no input arguments
   
   disp(' '); disp('Function requires an input matrix of signals!'); disp(' ')
   
end
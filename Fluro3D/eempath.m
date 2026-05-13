function eempath
%changes the working directory to the EEM Tools home directory

global EEMTOOLSPATH

if ~isempty(EEMTOOLSPATH)
   cd(EEMTOOLSPATH)
end

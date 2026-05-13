Installation Notes --

To install the toolbox, unzip the archived files to any new or existing directory accessible to
MATLAB.

To open the Fluorescence Toolbox startup window (i.e. program launcher), start MATLAB, change to
the installation directory, and type 'startup'.  To create a Windows shortcut that starts MATLAB
and runs the toolbox automatically, you can do the following:

1) right-click on the Windows desktop, highlight the 'New' sub-menu, select 'Shortcut', click on
the 'Browse' button, and locate 'matlab.exe' in the \bin sub-directory where MATLAB is installed

2) click the 'Next' button, assign a name for the shortcut (e.g. 'Fluorescence Toolbox'), and
click 'Finish' to create the shortcut

3) right-click on the new shortcut and select 'Properties' to open it for editing

4) click on the 'Shortcut' tab, and change the 'Start in' directory to the directory where you
installed the toolbox (this will instruct MATLAB to run the file 'startup.m' automatically, which
will add the toolbox to the search path and run the startup program)

5) you can also instruct MATLAB to start with the command window minimized by adding ' nosplash
minimize' after 'matlab.exe' on the 'Target' line for the shortcut

6) move or copy the shortcut to the Start menu or wherever else you like


Restrictions and Limitations -

This toolbox is under development and cannot be distributed without the author's express
permission.  For reasons of speed and copy protection, some functions may only be provided in
pre-compiled (p-code) form and are therefore not editable.  Full documentation of the data and
calibration file formats and correction and calculation algorithms will be provided in a future
release or upon request.

Note that no GUI tools are provided for creating or editing fluorometer calibration files.
Updated calibration file sets will periodically be provided as they are produced.  The
calibration and data importing schemes used by the toolbox programs are optimized for ISA Spex
Fluorolog instruments running DataMax software.  Calibration programs and instructions for
adapting the toolbox to work with other instruments or calibration techniques may also be
provided in a future release.


Release Notes --

The fluorescence toolbox is a set of MATLAB functions designed for comprehensive analysis and
   display of fluorescence excitation-emission matrix scan data (EEMs).  Standard Windows graphical
   user interfaces (GUI) provide access to the underlying functions, therefore no MATLAB experience
   is required to use this toolbox.  The major GUI tools are listed below as they appear on Toolbox
   Window buttons, with their associated MATLAB file names in parentheses:

Toolbox Window (fltoolbox.m):  Opens the toolbox window (i.e. program launcher) that provides
   convenient access to the individual toolbox programs.  This window is designed to stay open in
   the upper-left corner of the screen, and can be used to close all open toolbox-related windows
   and dialogs when you are ready to quit.  Typing 'fltoolbox' in the MATLAB command window will
   reopen the toolbox window if it is accidentally closed during a session.

Import DataMax File (importscan.m):  Imports single or multiple (i.e. split) fluorescence
   emission scans generated using ISA's Datamax software and exported in ASCII format.  Optionally
   corrects the fluorescence intensity data for instrument and scatter artifacts (PMT response,
   water Rayleigh and Raman peaks) and applies quinine sulfate calibration factors.  For diluted
   samples, the dilution factor and diluent EEM can also be specified, so that a dilution-corrected
   EEM can be generated.  This program generates '.eem' files, which are proprietary MATLAB data
   files containing raw and corrected data and information describing the data and calibrations
   applied.

Edit EEM Data File (edit_eem.m):  Opens an EEM data file ('*.eem') for editing and reapplying
   correction or calibration parameters, reducing the wavelength range, or modifying the description
   text.  Note that for calculated EEM files only the description and wavelength ranges can be
   modified (other fields will be disabled).

Use EEM Calculator (eemulator.m):  Loads scans from one or more EEM data files into a variables
   list, then computes calculated or emulated EEM scans using standard algebraic formulae and MATLAB
   commands.  Definition of intermediate terms is also supported, allowing very complex
   computations.  Equations can be documented and saved to a templates list, and all data and
   equations can be saved together as a workspace file ('*.ews') for convenient reloading.  MATLAB
   syntax parsing and EEM wavelength range- and density-matching are performed automatically.
   Calculated EEMs can be saved as EEM data files and plotted.  Templates for many common
   calculations are provided.

New Surface Plot (eemplot.m):  Opens an EEM data file ('*.eem') and plots the fluorescence data
   as a 3D surface.  If multiple types of data are present in the file (e.g. raw data and calibrated
   data) a list will be displayed for selection of the data to plot.  The appearance of the plot can
   be customized extensively (e.g. 3D viewpoint, surface appearance, color map, contour lines, peak
   labels), and the final plot can be printed or exported in various graphics formats for use in
   other programs.  The surface data can also be exported in ASCII format, 'probed' with the mouse
   to view fluorescence at specific excitation and emission wavelengths, and selectively integrated
   by defining regions of excitation and emission wavelengths as rectangular, circular or free-form
   polygons.

New 2D Line Plot (exem_plot.m):  Opens an EEM data file ('*.eem') and plots the fluorescence data
   as a series of individual line plots.  If multiple types of data are present in the file (e.g.
   raw data and calibrated data) a list will be displayed for selection of the data to plot.  The
   plot can be toggled between emission and excitation scan views, and the user can type in a
   wavelength selection or scroll through valid wavelengths to generate all possible excitation or
   emission plots.  Multiple line plots can be overlain for comparison.  The data can also be
   'probed' with the mouse to view fluorescence intensity at a specific excitation or emission
   wavelength, and selectively integrated by defining starting and ending wavelengths.

Open EEM Plot File (loadscan.m):  Displays an EEM surface plot previously saved to disk by the
   'eemplot' program (i.e. as '*.plt').  All of the appearance options and settings will be restored
   to entirely recreate the saved plot; in contrast, using 'New Surface Plot' to open a '*.plt' file
   will restore default appearance settings.


Contact Information -

If you have questions, comments, or bug reports, you can contact me as follows:

Wade M. Sheldon
Dept. of Marine Sciences
University of Georgia
Athens, Georgia  30602-3636
email:  sheldon@uga.edu


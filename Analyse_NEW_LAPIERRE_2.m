clear all
close all

%Define the excitation/emission output files and blanks
% CANNOT have non-numeric values in any cell; trim so low-range is 280nm
% and leave those above. Ensure all values are formatted in Scientific, and
% use comma delineator not decimal or semicolon between cells 
% Convert .csv to .xls (2003 Office)


%% Configure the settings

directorDEEM= 'C:\Users\admin\Documents\MATLAB\Fluoro3D'; % Base directory
directorOutputs='outputs'; % name for output base folder
directorInputs='treated data'; % name for input base folder


currentFolder='Kubota8_Fl07Jul'; % Place the name of the folder containing csv or xls file
currentBlank='28_2024-07-07 Blank 08'; % Place name of blank corresponding to the sample
currentSample='30_K8-05S-04'; % place name of the sample

blankLocation=append(directorDEEM,'\',directorInputs,'\',currentFolder,'\',currentBlank,'.CSV');
sampleLocation=append(directorDEEM,'\',directorInputs,'\',currentFolder,'\',currentSample,'.CSV');
outputLocation=append(directorDEEM,'\',directorOutputs,'\',currentFolder,'\',currentSample,'.txt');


%% Main Script
blanc=xlsread(blankLocation); %Name of the Blank
eem=xlsread(sampleLocation);%Name of the Sample


parms=xlsread('parms.xls');
correct=xlsread('correct.xls');


[eem_blanc,eem_cor,correct,eem_filter] = cleanscanlez_NEW_LAPIERRE_2(eem,blanc,correct,parms,0);


figure()
image(eem_cor)

%Create A Matrix File with eem_cor, save it as .txt for further processing
fid=fopen(outputLocation,'w'); % Name of the output file (desired)

for u=1:size(eem_cor,1)
    for uu=1:size(eem_cor,2)
    fprintf(fid,'%d ',eem_cor(u,uu));
    end
    fprintf(fid,'\n');
end
fclose(fid);




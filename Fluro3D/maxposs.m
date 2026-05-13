%Extrait la matrice des intensité de fluorescence de H1
flH1 = untitled(172:212,12:16);
eemH1 = [];
eemH1(1:41,1:5) = flH1;
%Extrait l'excitation, l'emission et l'intensité fluorescente du pic max de
%la MODH1
maxposH1 = [];
maxH1 = max(max(eemH1)); % Valeur maximale de eemH1: intensité maximale de fluorescence.
exmaxH1 = []; % Matrice vide
emmaxH1 = [];
k = 1;
l = 1;
disp(' ')
for i = 1:size(eemH1,1) % Boucle parcourant chaque élément de eemH1
for j = 1:size(eemH1,2)
if eemH1(i,j) == maxH1 % Si un élément de eemH1 = max(eemH1), alors il le place dans une autre matrice
emmaxH1(k) = i; % Cette matrice-là
k=k+1;
exmaxH1(l) = j;
j=j+1;
end
end
end
maxposH1 = [310+exmaxH1(end).*10 419+emmaxH1(end) max(max(eemH1))];

%Extrait la matrice des intensité de fluorescence de H2
flH2 = untitled(172:212,2:5);
eemH2 = [];
eemH2(1:41,1:4) = flH2;
%Extrait l'excitation, l'emission et l'intensité fluorescente du pic max de
%la MODH2
maxposH2 = [];
maxH2 = max(max(eemH2)); % Valeur maximale de eemH1: intensité maximale de fluorescence.
exmaxH2 = []; % Matrice vide
emmaxH2 = [];
k = 1;
l = 1;
disp(' ')
for i = 1:size(eemH2,1) % Boucle parcourant chaque élément de eemH2
for j = 1:size(eemH2,2)
if eemH2(i,j) == maxH2 % Si un élément de eemH1 = max(eemH1), alors il le place dans une autre matrice
emmaxH2(k) = i; % Cette matrice-là
k=k+1;
exmaxH2(l) = j;
j=j+1;
end
end
end
maxposH2 = [210+exmaxH2(end).*10 419+emmaxH2(end) max(max(eemH2))];

%Extrait la matrice des intensité de fluorescence de P1
flP1 = untitled(92:142,2:5);
eemP1 = [];
eemP1(1:51,1:4) = flP1;
%Extrait l'excitation, l'emission et l'intensité fluorescente du pic max de
%la MODP1
maxposP1 = [];
maxP1 = max(max(eemP1)); % Valeur maximale de eemH1: intensité maximale de fluorescence.
exmaxP1 = []; % Matrice vide
emmaxP1 = [];
k = 1;
l = 1;
disp(' ')
for i = 1:size(eemP1,1) % Boucle parcourant chaque élément de eemP1
for j = 1:size(eemP1,2)
if eemP1(i,j) == maxP1 % Si un élément de eemH1 = max(eemH1), alors il le place dans une autre matrice
emmaxP1(k) = i; % Cette matrice-là
k=k+1;
exmaxP1(l) = j;
j=j+1;
end
end
end
maxposP1 = [210+exmaxP1(end).*10 339+emmaxP1(end) max(max(eemP1))];
maxpos = [maxposH1 maxposH2 maxposP1]
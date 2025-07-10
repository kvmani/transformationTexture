%% Import Script for PoleFigure Data
%
% This script was automatically created by the import wizard. You should
% run the whole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = crystalSymmetry('mmm', [1 1 1]);

% specimen symmetry
SS = specimenSymmetry('1');

% plotting convention
how2plot = plottingConvention(zvector,xvector);
setMTEXpref('xyzPlotting',how2plot);

%% Specify File Names

% path to files
pname = 'Z:\backUps\currentProjects\colloborations\shibayan_iitKgp\HT XRT\850 degC Texture\Beta';

% which files to be imported
fname = {...
  [pname '\PF-1 beta _850.1°C_850.xrdml'],...
  [pname '\PF-2 beta _850.1°C_850.xrdml'],...
  [pname '\PF-3 beta_850.1°C_850.xrdml'],...
  };

%% Specify Miller Indices

h = { ...
  Miller(1,1,0,CS),...
  Miller(2,0,0,CS),...
  Miller(2,1,1,CS),...
  };

%% Import the Data

% create a Pole Figure variable containing the data
pf = PoleFigure.load(fname,h,CS,SS,'interface','xrdml');
plot(pf)

%%
odf = calcODF(pf)
fnameOdf = fullfile(pname, 'odf.txt');
%plotPDF(odf,pf.allH,'antipodal','silent','superposition')
plot(odf,'sections',6,'silent')
export(odf,fnameOdf,'Bunge')



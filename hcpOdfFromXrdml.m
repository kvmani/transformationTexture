%% Import Script for PoleFigure Data
%
% This script was automatically created by the import wizard. You should
% run the whoole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = crystalSymmetry('6/mmm', [1 1 1.6], 'X||a*', 'Y||b', 'Z||c');

% specimen symmetry
SS = specimenSymmetry('1');

% plotting convention
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','outOfPlane');

%% Specify File Names

% path to files
pname = 'Z:\backUps\currentProjects\colloborations\shibayan_iitKgp\HT XRT\850 degC Texture\Alpha';

% which files to be imported
fname = {...
  [pname '\PF-1 alpha _850.2°C_850.xrdml'],...
  [pname '\PF-2 alpha _850.2°C_850.xrdml'],...
  [pname '\PF-3 alpha _850.1°C_850.xrdml'],...
  [pname '\PF-5 alpha _850.1°C_850.xrdml'],...
  };

%% Specify Miller Indice

h = { ...
  Miller(1, 0,-1, 0,CS),...
  Miller(0,0,0,2,CS),...
  Miller(1, 0,-1, 1,CS),...
  Miller(1, 0,-1, 2,CS),...
  };

%% Import the Data

% create a Pole Figure variable containing the data
pf = PoleFigure.load(fname,h,CS,SS,'interface','xrdml');
odf = calcODF(pf);
odfPath = [pname '\odf.txt']
    export(odf, odfPath,'Bunge');
%     odfR = ODF.load(odfPath, ...
%                'interface','generic', ...
%                'CS',CS,'SS',SS, ...
%                'Bunge', ...
%                'ColumnNames',{'phi1','Phi','phi2','weights'}, ...
%                'Delimiter',' ', ...
%                'Header',4 ...
%                );
    %odfR = ODF.load(odfPath,'CS',CS,'SS',SS,'Bunge','ZXZ','Degree','Active Rotation');

   
   

    %% 4 Plot RAW pole figures
    figure('Name','PDF – all reflections','Color','w');
    plotPDF(odf, h, ...           % ← note: whole list, once
            'contourf', ...           % filled contours
            'levels', 10, ...         % 10 equally spaced levels
            'antipodal');             % show both hemispheres
    mtexColorbar;
    title(sprintf('PF %d – from xrdml '),'Interpreter','none');
    set(gcf,'Renderer','painters')
      
    


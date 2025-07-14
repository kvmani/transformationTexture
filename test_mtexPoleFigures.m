%% test_plotPDF_unimodal.m  —  minimal MTEX sanity check
% ------------------------------------------------------
checkEnvironment();
% 1.  Quick “is MTEX on the path?” test
try
    mtexRoot = fileparts(which('quaternion'));
    fprintf('MTEX detected in: %s\n', mtexRoot);
catch
    error('MTEX is not on the MATLAB path — add it before running this script.');
end

%% 2.  Crystal & specimen symmetries
CS = crystalSymmetry('m-3m', [1 1 1]);   % cubic Fe / Ni cell
SS = specimenSymmetry('1');              % triclinic sample
outPath = 'Z:\backUps\currentProjects\colloborations\shibayan_iitKgp\HT XRT\simulatedBeta'

%% 3.  Build a unimodal ODF (15° half-width around id-orientation)
g0  = orientation('Euler', 0*degree, 0*degree, 0*degree, CS, SS);
odf = unimodalODF(g0, 15*degree);
g2  = orientation('Euler', 0*degree, 0*degree, 0*degree, CS, SS);
odf2 = unimodalODF(g2, 15*degree);

odf = odf+odf2

outODF = fullfile(outPath, 'simulated_beta.odf');
export(odf,outODF,'Bunge');


%% 4.  Miller indices for {111}, {110}, {001}
h = [ ...
    Miller(1,1,1,CS), ...
    Miller(1,1,0,CS), ...
    Miller(0,0,1,CS)  ...
    ];
setMTEXpref('defaultColorMap','jet');          % <-- key line
levels = linspace(0, max(odf), 10);  

%% 5.  Plot contour pole figures
figure('Name','MTEX plotPDF unimodal test','Color','w');
plotPDF(odf, h, ...
        'contourf',        ...    % filled contours
        'antipodal',       ...    % both hemispheres
        'resolution', 5*degree);  % reasonably fine grid
caxis([0 1.1*max(odf)]);
mtexColorbar;
%title('Unimodal ODF | cubic crystal, triclinic specimen');
set(gcf,'Renderer','painters')


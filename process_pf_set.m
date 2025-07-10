function process_pf_set(fNames,hList,CS,SS,odfPath,plt)

    %% 1 Load & optional smoothing
    pf = PoleFigure.load(fNames,hList,CS,SS,'interface','xrdml');
    if plt.smoothPF
        pf = smooth(pf,5*degree);   % gentle 5° kernel
    end

    %% 2 Compute + export + reload ODF
    odf = calcODF(pf);
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

    %% 3 Common colour scale
    clim = plt.intensityScale;
    cticks = linspace(clim(1),clim(2),7);

    %% 4 Plot RAW pole figures
    figure('Name','PDF – all reflections','Color','w');
    plotPDF(odf, hList, ...           % ← note: whole list, once
            'contourf', ...           % filled contours
            'levels', 10, ...         % 10 equally spaced levels
            'antipodal');             % show both hemispheres
    mtexColorbar;
    title(sprintf('PF %d – from xrdml '),'Interpreter','none');
    set(gcf,'Renderer','painters')
      
    
   

%     %% 5 Back-calculated PFs from ORIGINAL ODF
%     figure('Name','PDF – all reflections','Color','w');
%     plotPDF(odfR, hList, ...           % ← note: whole list, once
%             'contourf', ...           % filled contours
%             'levels', 10, ...         % 10 equally spaced levels
%             'antipodal');             % show both hemispheres
%     mtexColorbar;
%     title(sprintf('recalcaulted PF %d – '),'Interpreter','none');
%     set(gcf,'Renderer','painters')
    

end

function run_texture_analysis(cfgFile)
% RUN_TEXTURE_ANALYSIS_JSON  – JSON-driven PF  ⇄  ODF round-trip check.
%
%   run_texture_analysis_json('texture_cfg.json')

    if nargin == 0, cfgFile = 'texture_cfg.json'; end
    cfg = jsondecode(fileread(cfgFile));

    CS = crystalSymmetry(cfg.crystalSymmetry.laue , cfg.crystalSymmetry.lattice);
    SS = specimenSymmetry(cfg.specimenSymmetry);

    setMTEXpref('defaultColorMap', cfg.plotting.colormap);

    for k = 1:numel(cfg.datasets)
        ds = cfg.datasets(k);
        fprintf('\n=== Data-set %d/%d ===\n',k,numel(cfg.datasets));

        fNames = fullfile(ds.root, ds.files);
        hList  = num2cell(ds.millers,2);
        hList  = cellfun(@(hkl) Miller(hkl(1),hkl(2),hkl(3),CS), ...
                         hList,'UniformOutput',false);

        process_pf_set( ...
            fNames, hList, CS, SS, fullfile(ds.root, ds.odfExport), ...
            cfg.plotting);
    end
end

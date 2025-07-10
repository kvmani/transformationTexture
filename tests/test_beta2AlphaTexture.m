function tests = test_beta2AlphaTexture
    tests = functiontests(localfunctions);
end

function testRunMinimal(testCase)
    tempRoot = tempname;
    betaDir = fullfile(tempRoot,'case1','beta');
    mkdir(betaDir);
    dlmwrite(fullfile(betaDir,'odf.txt'),[0 0 0 1],'delimiter',' ');
    rootDir = tempRoot;
    selList = 0.1;
    manualJsonText = ['[{"folder":"case1/beta","data_set_name":"case1_beta","pre_transformed_alpha_present":false}]'];
    run('beta2AlphaTexture.m');
    outFile = fullfile(betaDir,'alpha_texture_sel_0.10_Alpha_Frac_0.00.odf');
    verifyTrue(testCase,isfile(outFile));
end

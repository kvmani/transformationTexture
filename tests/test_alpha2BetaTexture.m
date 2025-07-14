function tests = test_alpha2BetaTexture
    tests = functiontests(localfunctions);
end

function testRunMinimal(testCase)
    tempRoot = tempname;
    alphaDir = fullfile(tempRoot,'case1','alpha');
    mkdir(alphaDir);
    dlmwrite(fullfile(alphaDir,'odf.txt'),[0 0 0 1],'delimiter',' ');
    rootDir = tempRoot;
    selList = 0.1;
    manualJsonText = ['[{"folder":"case1/alpha","data_set_name":"case1_alpha","pre_transformed_beta_present":false}]'];
    run('alpha2BetaTexture.m');
    outFile = fullfile(alphaDir,'beta_texture_sel_0.10_Beta_Frac_0.00.odf');
    verifyTrue(testCase,isfile(outFile));
end

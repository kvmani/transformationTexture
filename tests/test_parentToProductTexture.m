function tests = test_parentToProductTexture
    tests = functiontests(localfunctions);
end

function testAlphaToBetaNoPre(testCase)
    tempRoot = tempname;
    alphaDir = fullfile(tempRoot,'alpha');
    mkdir(alphaDir);
    dlmwrite(fullfile(alphaDir,'odf.txt'),[0 0 0 1],'delimiter',' ');
    [odf,rep] = parentToProductTexture(fullfile(alphaDir,'odf.txt'), 'alpha','beta', ...
        'Sel',0.2,'OutputDir',alphaDir,'DataSetName','case');
    outFile = fullfile(alphaDir,'beta_texture_sel_0.20_beta_Frac_0.00.odf');
    verifyTrue(testCase,isfile(outFile));
    verifyEqual(testCase,rep.productPhase,'beta');
end

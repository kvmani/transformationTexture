function tests = test_alpha2betaVariants
    tests = functiontests(localfunctions);
end

function testHalfSelection(testCase)
    [gB,wB] = alpha2betaVariants([0 0 0],1,0.5,false);
    verifyEqual(testCase,numel(gB),round(0.5*6));
    verifyEqual(testCase,sum(wB),1,'AbsTol',1e-6);
end

function testZeroSelection(testCase)
    [gB,~] = alpha2betaVariants([0 0 0],1,0,false);
    verifyEqual(testCase,numel(gB),1);
end

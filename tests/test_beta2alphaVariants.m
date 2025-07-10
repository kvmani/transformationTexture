function tests = test_beta2alphaVariants
    tests = functiontests(localfunctions);
end

function testHalfSelection(testCase)
    [gA,wA] = beta2alphaVariants([0 0 0],1,0.5,false);
    verifyEqual(testCase,numel(gA),round(0.5*12));
    verifyEqual(testCase,sum(wA),1,'AbsTol',1e-6);
end

function testZeroSelection(testCase)
    [gA,~] = beta2alphaVariants([0 0 0],1,0,false);
    verifyEqual(testCase,numel(gA),1);
end

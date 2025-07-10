function tests = test_betaVariantsFromAlpha
    tests = functiontests(localfunctions);
end

function testVariantNumber(testCase)
    V = buildBetaVariantsFromAlpha();
    gAlpha = orientation('Euler',0,0,0,V(1).CS,specimenSymmetry('1'));
    gBeta = betaVariantsFromAlpha(gAlpha,V);
    verifyEqual(testCase,numel(gBeta),numel(V));
end

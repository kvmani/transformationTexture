function tests = test_alphaVariantsFromBeta
    tests = functiontests(localfunctions);
end

function testVariantNumber(testCase)
    V = buildBurgersVariantOperators();
    gBeta = orientation('Euler',0,0,0,V(1).CS,specimenSymmetry('1'));
    gAlpha = alphaVariantsFromBeta(gBeta,V);
    verifyEqual(testCase,numel(gAlpha),numel(V));
end

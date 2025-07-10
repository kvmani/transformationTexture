function tests = test_buildBetaVariantsFromAlpha
    tests = functiontests(localfunctions);
end

function testCount(testCase)
    V = buildBetaVariantsFromAlpha();
    verifyEqual(testCase, numel(V), 6);
end

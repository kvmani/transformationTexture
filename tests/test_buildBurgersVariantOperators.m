function tests = test_buildBurgersVariantOperators
    tests = functiontests(localfunctions);
end

function testCount(testCase)
    V = buildBurgersVariantOperators();
    verifyEqual(testCase, numel(V), 12);
end

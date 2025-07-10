function gAlpha = alphaVariantsFromBeta(gBeta, V)
% alphaVariantsFromBeta  Generate 12 alpha variants from a beta orientation.
%
% Inputs:
%   gBeta - orientation object (beta-Ti)
%   V     - 1x12 orientation array (Burgers variant operators)
%
% Output:
%   gAlpha - 1x12 array of alpha orientations
%
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
ss=specimenSymmetry('1');
nVar = size(V);                  % should be 12
gAlpha(1,nVar) =orientation('Euler',0,0,0,V(1).CS,ss);     % pre-allocate row array

    for k = 1:nVar
        gAlpha_raw =  quaternion(gBeta)*quaternion(V(k));
        gAlpha(k) = orientation( quaternion(gAlpha_raw), V(1).CS, ss );     % explicit multiplication, no scalar test
    end
end

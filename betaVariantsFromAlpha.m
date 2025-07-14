function gBeta = betaVariantsFromAlpha(gAlpha, V)
% betaVariantsFromAlpha
% ----------------------
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
% Compute the 6 β-phase variant orientations from a given α-phase orientation.
% Applies reverse Burgers OR operators (V) to the α orientation.
%
% Input:
%   gAlpha : (1,1) orientation object (α-Ti)
%   V      : (1,6) orientation array (β variant operators)
%
% Output:
%   gBeta  : (1,6) array of β orientation variants (in specimen coords)

% Ensure specimen symmetry
ss = specimenSymmetry('1');

% Number of variants (should be 6)
nVar = size(V,1);

% Preallocate β orientations
gBeta(1,nVar) = orientation('Euler', 0, 0, 0, V(1).CS, ss);

% Apply each variant operator
for k = 1:nVar
    gBeta_raw = quaternion(gAlpha) * quaternion(V(k));   % apply operator
    gBeta(k) = orientation(quaternion(gBeta_raw), V(1).CS, ss);
end

end

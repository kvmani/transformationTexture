function gAlpha = alphaVariantsFromBeta(gBeta, V)
% gBeta  – orientation of the β parent grain   (orientation object)
% V      – 1×12 array from buildBurgersVariantOperators
% gAlpha – 1×12 array of α-orientations in specimen coords
% 
% arguments
%     gBeta (1,1) orientation            % single β grain
%     V     (1,12) orientation           % 12 variant operators
% end

% gAlpha_raw =  gBeta.*V;                   % apply operator to parent grain
% gAlpha     = orientation( quaternion(gAlpha_raw), V(1).CS, specimenSymmetry('1') );
% end
ss=specimenSymmetry('1');
nVar = size(V);                  % should be 12
gAlpha(1,nVar) =orientation('Euler',0,0,0,V(1).CS,ss);     % pre-allocate row array

    for k = 1:nVar
        gAlpha_raw =  quaternion(gBeta)*quaternion(V(k));
        gAlpha(k) = orientation( quaternion(gAlpha_raw), V(1).CS, ss );     % explicit multiplication, no scalar test
    end
end
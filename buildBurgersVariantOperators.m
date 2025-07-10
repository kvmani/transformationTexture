function V = buildBurgersVariantOperators()
% Returns a 1×12 array of orientation objects that map a β grain to each
% Author: Dr K V Mani Krishna
% Date  : 2025-05-01
% Build 12 Burgers variant operators for beta to alpha transformation.
% α variant according to the predfined Euler angles from my python code.

% ---- crystal symmetries -------------------------------------------------
csAlpha = crystalSymmetry('6/mmm',[2.951 2.951 4.684],'mineral','α-Ti');
ss      = specimenSymmetry('1');

% ---- Euler triplets from your list --------------------------------------
eul = [ ...
   135   90 144.7 ; 225  90 144.7 ; 315  90 144.7 ;  45  90 144.7 ; ...
   180   45 234.7 ;   0  45  54.7 ;   0 135  54.7 ; 180 135 234.7 ; ...
    90   45  54.7 ;  90 135  54.7 ; 270 135 234.7 ; 270  45 234.7 ];

% ---- convert to orientation objects ------------------------------------
V(12,1) = orientation('Euler',0,0,0,csAlpha,ss);      % pre-allocate orientation array
for k = 1:12
    V(k) = orientation('Euler', eul(k,1)*degree, ...
                                 eul(k,2)*degree, ...
                                 eul(k,3)*degree, ...
                                 csAlpha, ss);
end

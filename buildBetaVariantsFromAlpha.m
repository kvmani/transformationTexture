function V = buildBetaVariantsFromAlpha()
% buildBetaVariantsFromAlpha - Constructs 6 orientation variants mapping
% an α-phase grain to its possible β-phase variants using predefined Euler angles.
%
% This function implements the reverse of the Burgers Orientation Relationship,
% estimating possible β orientations that could have transformed into a given α orientation.
%
% Output:
%   V : 6×1 orientation array (MTEX) of β variants in crystal frame of β-Ti
%
% Crystallographic context:
%   α-Ti: HCP phase (6/mmm)
%   β-Ti: BCC phase (m-3m)
%
% Euler angles used are from a known reverse transformation (α → β).

% ---- crystal symmetry for β-phase (target) ------------------------------
csBeta = crystalSymmetry('m-3m', [3.32 3.32 3.32], 'mineral', 'β-Ti');

% ---- specimen symmetry --------------------------------------------------
ss = specimenSymmetry('1');

% ---- Euler angles for α → β variants ------------------------------------
eul = [ ...
   35.3   90.0   45.0 ; ...
   95.3   90.0   45.0 ; ...
  155.3   90.0   45.0 ; ...
   84.7   90.0  225.0 ; ...
   24.7   90.0  225.0 ; ...
  324.7   90.0  225.0 ];

% ---- convert Euler angles to MTEX orientation objects -------------------
V(6,1) = orientation('Euler', 0, 0, 0, csBeta, ss);  % preallocate
for k = 1:6
    V(k) = orientation('Euler', eul(k,1)*degree, ...
                                 eul(k,2)*degree, ...
                                 eul(k,3)*degree, ...
                                 csBeta, ss);
end

end

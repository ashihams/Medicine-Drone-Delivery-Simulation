p = 14/2; % pole pairs
Ls = 0.33*1e-3/2/sqrt(3); % mH
Rs = 0.03/2/sqrt(3); % Ohm
Tsc = 10e-4;
Ts = 1e-4;
Jm = 0.000120878; % Rotor inertia
TuneFactor = 5e-2;
Kii = 0.8*1e-1;
Kpi = 0.01*1e-1;
Kpw = 5.38*TuneFactor;
Kiw = 20*TuneFactor;
kV = 920;
psim = kV/(1000)/(2*pi*60);
Vdc = 14.8;

% 
% rho_nylon = 1.41;             % g/cm^3 
% rho_glass = 2.56;              % g/cm^3 glass fibre
% rho_pla = 1.25;                 % g/cm^3 
% rho_cfrp = 6.32/3;               % g/cm^3
% rho_al = 2.66;                  % g/cm^3, alluminium alloy 5086
% Opacity = 0;
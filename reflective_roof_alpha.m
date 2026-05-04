clc; clear; close all;

%% -------------------------------
% 1. INPUT PARAMETERS
%% -------------------------------

% Indoor temperature
T_in = 24; % °C

% Outdoor temperatures (UHI case)
T_UHI = 32; % °C

% Wall properties
U_wall = 0.5;   % W/m2K
A_wall = 200;   % m2

% Roof properties
U_roof = 0.3;   % W/m2K
A_roof = 150;   % m2

% Solar radiation
G = 800; % W/m2

% Window properties
A_window = 50;  % m2
SHGC = 0.7;

% Time
hours = 10 * 365; % annual cooling hours

%% -------------------------------
% 2. BASE HEAT GAINS (UHI CASE)
%% -------------------------------

% Wall & roof conduction
Q_wall_UHI = U_wall * A_wall * (T_UHI - T_in);
Q_roof_UHI = U_roof * A_roof * (T_UHI - T_in);

% Window heat gain
Q_window = SHGC * G * A_window;

%% -------------------------------
% 3. PARAMETRIC STUDY (COOL ROOF)
%% -------------------------------

% Different roof absorptivity values
alpha_values = [0.7 0.6 0.5 0.4 0.3 0.2];

E_results = zeros(size(alpha_values));

for i = 1:length(alpha_values)
    
    alpha = alpha_values(i);
    
    % Solar heat gain through roof
    Q_solar = alpha * G * A_roof;
    
    % Total cooling load
    Q_cool = Q_wall_UHI + Q_roof_UHI + Q_solar + Q_window;
    
    % Annual cooling energy (kWh)
    E_results(i) = (Q_cool * hours) / 1000;
    
end

%% -------------------------------
% 4. REFERENCE UHI ENERGY (α = 0.6)
%% -------------------------------

alpha_ref = 0.6;

Q_solar_ref = alpha_ref * G * A_roof;

Q_cool_ref = Q_wall_UHI + Q_roof_UHI + Q_solar_ref + Q_window;

E_UHI = (Q_cool_ref * hours) / 1000;

%% -------------------------------
% 5. PERCENTAGE REDUCTION
%% -------------------------------

reduction = ((E_UHI - E_results) / E_UHI) * 100;

%% -------------------------------
% 6. DISPLAY RESULTS
%% -------------------------------

disp('Alpha     Energy (kWh/year)     Reduction (%)')
disp([alpha_values' E_results' reduction'])

%% -------------------------------
% 7. PLOTS
%% -------------------------------

% Energy vs alpha
figure
plot(alpha_values, E_results, '-o', 'LineWidth', 2)
xlabel('Roof Absorptivity (\alpha)')
ylabel('Cooling Energy (kWh/year)')
title('Effect of Roof Reflectivity on Cooling Energy')
grid on

% Reduction vs alpha
figure
plot(alpha_values, reduction, '-o', 'LineWidth', 2)
xlabel('Roof Absorptivity (\alpha)')
ylabel('Energy Reduction (%)')
title('Cooling Energy Reduction due to Cool Roof')
grid on
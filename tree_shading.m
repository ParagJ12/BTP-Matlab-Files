clc; clear; close all;

%% Time (24 hours)
t = 0:23;

%% Solar Radiation (W/m^2) - sinusoidal model
G = max(0, 800 * sin(pi * (t - 6) / 12));

%% Building Parameters
A_wall = 960;   % m^2
A_roof = 400;   % m^2
A_window = 50;  % m^2

U_wall = 1.7;   % W/m^2K
U_roof = 2.5;   % W/m^2K

T_in = 25;      % Indoor temp
T_out = 32;     % UHI temp (~ baseline + 3°C)

alpha = 0.7;    % roof absorptivity
SHGC = 0.7;     % window property

%% Shading factors (beta)
beta_values = [1.0 0.8 0.6 0.4];

figure; hold on;

for i = 1:length(beta_values)
    
    beta = beta_values(i);
    
    % Apply shading
    G_eff = beta * G;
    
    % Heat gains
    Q_wall = U_wall * A_wall * (T_out - T_in);
    Q_roof = U_roof * A_roof * (T_out - T_in);
    Q_solar = alpha .* G_eff .* A_roof;
    Q_window = SHGC .* G_eff .* A_window;
    
    % Total cooling load
    Q_total = Q_wall + Q_roof + Q_solar + Q_window;
    
    % Plot
    plot(t, Q_total, 'LineWidth', 1.8);
end

xlabel('Hour of Day');
ylabel('Cooling Load (W)');
title('Effect of Shading on Cooling Load (UHI Conditions)');
legend('No Shading (β=1.0)','Light (0.8)','Moderate (0.6)','Heavy (0.4)');
grid on;
peak_load = zeros(size(beta_values));

for i = 1:length(beta_values)
    
    beta = beta_values(i);
    G_eff = beta * G;
    
    Q_wall = U_wall * A_wall * (T_out - T_in);
    Q_roof = U_roof * A_roof * (T_out - T_in);
    Q_solar = alpha .* G_eff .* A_roof;
    Q_window = SHGC .* G_eff .* A_window;
    
    Q_total = Q_wall + Q_roof + Q_solar + Q_window;
    
    peak_load(i) = max(Q_total);
end

figure;
plot(beta_values, peak_load, '-o','LineWidth',2);
xlabel('Shading Factor (β)');
ylabel('Peak Cooling Load (W)');
title('Peak Load Reduction with Shading');
grid on;
baseline_peak = peak_load(1); % β = 1

reduction = ((baseline_peak - peak_load) / baseline_peak) * 100;

figure;
plot(beta_values, reduction, '-s','LineWidth',2);
xlabel('Shading Factor (β)');
ylabel('Peak Load Reduction (%)');
title('Percentage Reduction in Peak Load');
grid on;
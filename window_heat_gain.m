clc; clear;

%% Constants
SHGC = 0.7;

% Time (hours in a day)
t = 0:23;

% Simulated solar radiation curve (W/m^2)
G = max(0, 800 * sin(pi * (t - 6) / 12));
% peaks at noon, zero at night

%% Window areas to test
A_window_values = [20 40 50 90 105];


E_window = zeros(size(A_window_values));

%% Loop for each window area

for i = 1:length(A_window_values)
    
    A = A_window_values(i);
    
    % Hourly heat gain
    Q_hourly = SHGC * G * A;  % vector
    
    % Total daily energy (Wh)
    E_window(i) = sum(Q_hourly);
    
end

%% Plot

figure
plot(A_window_values, E_window, '-o')
xlabel('Window Area (m^2)')
ylabel('Daily Window Heat Gain (Wh)')
title('Effect of Window Area (with Solar Variation)')
grid on
T_in = 24;
A_roof = 400;
A_wall = 960;
U_wall = 1.7;
U_roof = 2.5;
G = weather.GlobalHorizRad;
alpha = 0.7;
Q_wall_base = U_wall * A_wall .* (T_baseline - T_in);
Q_wall_UHI = U_wall * A_wall .* (T_UHI - T_in);
Q_roof_base = U_roof * A_roof .* (T_baseline - T_in);
Q_roof_UHI = U_roof * A_roof .* (T_UHI - T_in);
Q_solar = alpha * G * A_roof;

%total cooling energy
Q_cool_base = Q_wall_base + Q_roof_base + Q_solar;
Q_cool_UHI = Q_wall_UHI + Q_roof_UHI + Q_solar;

plot(Q_cool_base)
hold on
plot(Q_cool_UHI)
legend('Baseline Cooling Load','UHI Cooling Load')
xlabel('Hour of Year')
ylabel('Cooling Load (W)')
title('Cooling Load Comparison')

%energy increase
Energy_base = sum(Q_cool_base);
Energy_UHI = sum(Q_cool_UHI);
percent_increase = (Energy_UHI - Energy_base)/Energy_base * 100


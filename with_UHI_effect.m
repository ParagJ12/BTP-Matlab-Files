T_baseline = weather.DryBulb
delta_UHI = 2.8;
T_UHI = T_baseline + delta_UHI;
plot(T_baseline)
hold on
plot(T_UHI)
legend('Baseline Temperature','UHI Temperature')
xlabel('Hour of Year')
ylabel('Temperature (°C)')
title('Baseline vs UHI Temperature Profile')





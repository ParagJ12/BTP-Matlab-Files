data = readmatrix('C:\Users\Lenovo\Documents\MATLAB\IND_TN_Chennai.Intl.AP.432790_TMYx.2009-2023.epw','FileType','text');
openvar('data')
size(data)
columnNames = {
'Year','Month','Day','Hour','Minute','DataFlag',...
'DryBulb','DewPoint','RelHumidity','Pressure',...
'ExtraHorizRad','ExtraDirectRad',...
'GlobalHorizRad','DirectNormalRad','DiffuseHorizRad',...
'GlobalHorizIllum','DirectNormalIllum','DiffuseHorizIllum',...
'ZenithLuminance','WindDirection','WindSpeed',...
'TotalSkyCover','OpaqueSkyCover','Visibility','CeilingHeight',...
'PresentWeatherObservation','PresentWeatherCodes',...
'PrecipitableWater','AerosolOpticalDepth',...
'SnowDepth','DaysSinceLastSnow','Albedo',...
'LiquidPrecipitationDepth','LiquidPrecipitationQuantity',...
'Unused'};
weather = array2table(data,'VariableNames',columnNames);
min(weather.DryBulb)
max(weather.DryBulb)

%monthly avg temp month wise 
monthlyMean = groupsummary(weather,'Month','mean','DryBulb');

plot(monthlyMean.Month, monthlyMean.mean_DryBulb,'-o')
xlabel('Month')
ylabel('Average Temperature (°C)')
title('Monthly Average Temperature - Chennai')
xticks(1:12)

T = weather.DryBulb;

mean_T = mean(T);
median_T = median(T);
std_T = std(T);
max_T = max(T);
min_T = min(T);

mean_T
median_T
std_T
max_T
min_T
%temp frequency distribution
histogram(T,30)
xlabel('Temperature (°C)')
ylabel('Frequency')
title('Temperature Distribution - Chennai')

monthlyStats = groupsummary(weather,'Month',{'mean','max','min','std'},'DryBulb');
monthlyStats

weather.DayOfYear = day(datetime(weather.Year,weather.Month,weather.Day),'dayofyear');

dailyStats = groupsummary(weather,'DayOfYear',{'max','min'},'DryBulb');
dailyRange = dailyStats.max_DryBulb - dailyStats.min_DryBulb;

plot(dailyRange)
xlabel('Day of Year')
ylabel('Daily Temperature Range (°C)')
title('Daily Temperature Swing')

hourlyMean = groupsummary(weather,'Hour','mean','DryBulb');

plot(hourlyMean.Hour, hourlyMean.mean_DryBulb,'-o')
xlabel('Hour of Day')
ylabel('Average Temperature (°C)')
title('Average Daily Temperature Profile')

% Hangzhou
year = 2024;
month = 2;
day = 27;
hour = 4;
minute = 00;
second = 00;
latitude = 30.3075380; % 杭州的纬度
longitude = 120.0758134; % 杭州的经度

[solarAltitude, solarAzimuth] = calculateSolarPosition(year, month, day, hour, minute, second, latitude, longitude);
fprintf('Solar Altitude: %.2f degrees\n', solarAltitude);
fprintf('Solar Azimuth: %.2f degrees\n', solarAzimuth);
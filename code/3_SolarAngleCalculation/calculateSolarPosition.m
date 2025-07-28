function [solarAltitude, solarAzimuth] = calculateSolarPosition(year, month, day, hour, minute, second, latitude, longitude)
    % Convert local time to UTC time
    % China Standard Time (CST) is UTC+8
    hourUTC = hour - 8;
    if hourUTC < 0
        hourUTC = hourUTC + 24;
        day = day - 1;
    end

    % Calculate the Julian date
    JD = juliandate(datetime(year, month, day, hourUTC, minute, second));

    % Calculate the number of days since J2000.0
    n = JD - 2451545.0;

    % Calculate the mean longitude of the Sun (in degrees)
    L = mod(280.46 + 0.9856474 * n, 360);

    % Calculate the mean anomaly of the Sun (in degrees)
    g = mod(357.528 + 0.9856003 * n, 360);

    % Calculate the ecliptic longitude of the Sun (in degrees)
    lambda = L + 1.915 * sind(g) + 0.020 * sind(2 * g);

    % Calculate the obliquity of the ecliptic (in degrees)
    epsilon = 23.439 - 0.0000004 * n;

    % Calculate the right ascension (in degrees) and declination (in degrees) of the Sun
    alpha = atan2d(cosd(epsilon) * sind(lambda), cosd(lambda));
    delta = asind(sind(epsilon) * sind(lambda));

    % Calculate the Greenwich Mean Sidereal Time (in degrees)
    GMST = mod(280.46061837 + 360.98564736629 * n, 360);

    % Calculate the Local Sidereal Time (in degrees)
    LST = mod(GMST + longitude, 360);

    % Calculate the hour angle (in degrees)
    H = mod(LST - alpha, 360);

    % Convert hour angle to range [-180, 180]
    if H > 180
        H = H - 360;
    end

    % Calculate the solar altitude (in degrees)
    solarAltitude = asind(sind(latitude) * sind(delta) + cosd(latitude) * cosd(delta) * cosd(H));

    % Calculate the solar azimuth (in degrees)
    solarAzimuth = atan2d(-sind(H), cosd(latitude) * tand(delta) - sind(latitude) * cosd(H));
    
    % Convert solar azimuth to range [0, 360] and adjust the reference direction
    if solarAzimuth < 0
        solarAzimuth = solarAzimuth + 360;
    end
    solarAzimuth = mod(solarAzimuth, 360); % Adjust so that 0° is South, 90° is West, etc.

end
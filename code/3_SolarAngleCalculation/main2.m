clear
clc

% Hangzhou
latitude = 30.3075380; % 杭州的纬度
longitude = 120.0758134; % 杭州的经度

% 提示用户输入日期
    dateInput = input('请输入日期（格式：YYYY-MM-DD）：', 's');
    dateParts = strsplit(dateInput, '-');
    year = str2double(dateParts{1});
    month = str2double(dateParts{2});
    day = str2double(dateParts{3});

    % 读取CSV文件
    filename = 'Z:\Projects\Drone_radiometric_correction\全天建模实验\20240704全天动态监测\20240704_太阳高度角_SYT.csv';
    data = readtable(filename);

    % 检查时间列的类型并进行相应处理
    if iscell(data{1, 1})
        timeColumn = data{:, 1}; % 读取时间列（元胞数组）
    else
        timeColumn = cellstr(data{:, 1}); % 读取时间列并转换为元胞数组
    end

    % 初始化第6列和第7列
    data.SolarAzimuth = zeros(height(data), 1);
    data.SolarAltitude = zeros(height(data), 1);

    % 逐行读取时间数据，计算太阳方位角和高度角并填入表中
    for i = 2:height(data)
        timeStr = timeColumn{i}; % 获取时间字符串
        timeParts = strsplit(timeStr, ':');
        hour = str2double(timeParts{1});
        minute = str2double(timeParts{2});
        second = str2double(timeParts{3});

        % 调用calculateSolarPosition函数计算太阳方位角和高度角
        [solarAltitude, solarAzimuth] = calculateSolarPosition(year, month, day, hour, minute, second, latitude, longitude);

        % 将结果填入表中
        data.SolarAzimuth(i) = solarAzimuth;
        data.SolarAltitude(i) = solarAltitude;
    end

    % 将更新后的表写回CSV文件
    writetable(data, filename);
    fprintf('已成功计算并更新CSV文件中的太阳方位角和高度角。\n');
clear
clc

%% 设置图片文件夹路径和Excel文件路径
imageFolderPath = 'Z:\Projects\Drone_radiometric_correction\阴阳图\多光谱\解压后-重做暗角\架次2-copy'; % 更改为您的图片文件夹路径
excelFilePath = 'Z:\Projects\Drone_radiometric_correction\阴阳图\多光谱\解压后\架次2\output2-part4.xlsx'; % 更改为您的Excel文件路径

%% 视频开始时间(!!!!!!!每次需要更改）
videoStartTimeString = '12:22:04';
videoStartTime = datetime(videoStartTimeString, 'Format', 'HH:mm:ss');

%% 图像更改名字
% 读取文件夹中的所有.tif图像文件
imageFiles = dir(fullfile(imageFolderPath, '*.tif')); % '*.tif'匹配所有.tif文件

% 读取Excel文件
excelData = readtable(excelFilePath);

% 遍历Excel表格的每一行
for i = 1:height(excelData)
    % 获取当前行的图像序号
    imageNumber = excelData{i, 1}; % 第一列为图像序号
    
    % 获取当前行的新的文件名
    newFileNameFull = excelData{i, 2}{1}; % 第二列为新的文件名，{1}用于从cell中提取字符串
    
    % 使用正则表达式从newFileNameFull中提取秒数
    tokens = regexp(newFileNameFull, 'keyframe_(\d+)_\d+\.png', 'tokens');

    % 获取当前行的图像对应的秒数（newFileName）
    imageSeconds = str2double(tokens{1}{1}); % 第二列为秒数字符串，转换为数值

    % 计算图像对应的具体时间
    imageTime = videoStartTime + seconds(imageSeconds);

    % 构建原始文件的完整路径
    originalFileName = sprintf('corrected_4444_%d.tif', imageNumber);
    originalFilePath = fullfile(imageFolderPath, originalFileName);
    
    % 检查原始文件是否存在
    if exist(originalFilePath, 'file')
        % 构建具体时间字符串，例如 '154159_072.tif'
        timeString = datestr(imageTime, 'HH-MM-SS');
        newFileName = [timeString '_' sprintf('%04d', imageSeconds) '_' sprintf('%d', excelData{i,1}) '.tif']; % 使用三位数字格式化秒数
        
        % 构建新的文件路径
        newFilePath = fullfile(imageFolderPath, newFileName);
        
        % 重命名图像文件
        movefile(originalFilePath, newFilePath);
    else
        fprintf('File %s does not exist.\n', originalFileName);
    end
end

% 操作完成后输出提示信息
disp('All files have been renamed with their corresponding times.');
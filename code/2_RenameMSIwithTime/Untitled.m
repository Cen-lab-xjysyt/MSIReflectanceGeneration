% 指定要扫描的文件夹路径
folderPath = 'I:\耐寒性实验\0129\4_多光谱图像-归一化曝光时间'; % 请替换为实际文件夹路径

% 获取文件夹内所有文件的数据
files = dir(folderPath);

% 遍历文件夹内的每个文件
for k = 1:length(files)
    % 获取文件的名字
    fileName = files(k).name;
    
    % 跳过文件夹和隐藏文件
    if files(k).isdir || startsWith(fileName, '.')
        continue;
    end
    
    % 匹配“130306_101”格式的文件名，包括文件扩展名
    pattern = '^\d{6}_\d{3}';
    match = regexp(fileName, pattern, 'match');
    
    % 如果找到匹配项
    if ~isempty(match)
        % 生成新的文件名
        newFileName = [match{1}(1:2), '-', match{1}(3:4), '-', match{1}(5:6), '_', fileName(strfind(fileName, '_') + 1:end)];
        
        % 完整的老文件名和新文件名路径
        oldFilePath = fullfile(folderPath, fileName);
        newFilePath = fullfile(folderPath, newFileName);
        
        % 重命名文件
        movefile(oldFilePath, newFilePath);
        fprintf('Renamed "%s" to "%s"\n', fileName, newFileName);
    end
end
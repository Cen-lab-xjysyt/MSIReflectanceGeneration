clear
clc

%% 指定输入和输出文件夹路径
input_folder = 'H:\辐射校正\7_暗角校正文件\4_现有的暗角校正文件结果\';
output_folder = 'H:\辐射校正\7_暗角校正文件\2_生成文件\';

%% 检查输出文件夹是否存在，如果不存在则创建
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% 获取输入文件夹中的所有 .tif 文件
tif_files = dir(fullfile(input_folder, '*.tif'));
num_files = length(tif_files);

%% 检查是否有tif文件
if num_files == 0
    error('没有找到.tif文件，请检查输入文件夹。');
end

%% 设置暗电流
dark = [19,19,17,16,21,18,14,15,18,19,17,17,18,18,20,22,19,22,21,21,17,18,17,15,21];
% dark =  zeros(25,1);

%% 读取第一个图像以初始化累加器
file_name = tif_files(1).name;
file_path = fullfile(tif_files(1).folder, file_name);
img = imread(file_path);

% 初始化累加器矩阵
accumulator = zeros(size(img), 'double');

%% 遍历所有 .tif 文件
for i = 1:num_files
    file_name = tif_files(i).name;
    file_path = fullfile(tif_files(i).folder, file_name);
    img = double(imread(file_path)); % 转换为double进行计算
    
    % 遍历每个通道, 去除暗电流
    for j = 1:size(img, 3)
        img(:, :, j) = img(:, :, j) - dark(j);
        
        % 确保没有负数
        img(img(:, :, j) < 0, j) = 0;
    end
    
    % 累加处理后的图像
    accumulator = accumulator + img;
end

% 计算平均图像
averageImage = accumulator / num_files;

% 计算得到vignetteSmoothed文件
for k = 1:size(img,3)
    max_k = max(max(averageImage(:,:,k)));
    averageImage(:, :, k) = averageImage(:, :, k) ./ max_k;
end

% figure,imshow(averageImage(:,:,[5 10 13]))

% 保存平均图像到输出文件夹
output_file_name = 'vignetteSmoothed.tif';
output_file_path = fullfile(output_folder, output_file_name);
singletiffwrite(averageImage, output_file_path);

%% 输出完成信息
disp(['处理完成，平均图像已保存到：' output_file_path]);
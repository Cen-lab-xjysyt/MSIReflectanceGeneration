
clear
clc
%% Description
% perform *.raw dataDecompression
% perform vignetteCalib
% [optional] perform camResponseCalib 
% [optional] perform camFOVCalib 
%% 
% clc, clear all, close all, warning off
warning off
addpath('.\XIMEA_common');
% addpath('..\common');
%% Settings
% path settings
input_root = 'Z:\Projects\Drone_radiometric_correction\阴阳图\多光谱\原始文件\架次2\'
output_root = 'Z:\Projects\Drone_radiometric_correction\阴阳图\多光谱\解压后\架次2';
calibData_root = [pwd, '\XIMEA_Calib_Data\'];
% vis_path = [input_root, 'a6000\0929-1\'];
ms_path = input_root;

% outputImgs settings 
% dataDecompression output settings (input to extractCube.m)
options.patternImgOut  = 0;  % size = 2045*1080*1; format = *.tif(float); bit depth = 10 
options.ImgCubeOut     = 1;  % size = 409*216*25;  format = *.tif(float); bit depth = 10 [output original ImgCube]
options.ImgCubeBandOut = 0;  % size = 409*216*1;   format = *.tif(float); bit depth = 10 
% only output the Band10 img
options.jpgBandOut     = 0;  % size = 409*216*1;   format = *.jpg(uint8); bit depth = 8; Normalization = (Img ./ 1024) * 255

% dataCalibration output settings 
% isOutputImg [camResponseCalibCube vignetteCalibCube camFOVundistortCube]
% STEP1 options.CalibCubeOut(1) = 0:'linear'- no camResponseCalib, 1:load the ./responseCalibOutput
% STEP2 options.CalibCubeOut(2) = 0: no vignetteEffect,            1: load the ./vignetteCalibOutput
% STEP3 options.CalibCubeOut(3) = 0: no FOV correction,            1: load the 'cameraParams.mat'
options.CalibCubeOut   = [0 1 1];    % size = 409*216*25;  format = *.tif(float) /*.ENVI(float) 
writeFormat = 0;                     % 0:TIFF, 1:ENVI

patternImg_width = 2045; patternImg_height = 1080; 
blksize = 5; bands = 25; bitDepth = 10;
[InvG, vignetteSmoothedCube, cameraParams, options] = loadCalibFile(calibData_root, patternImg_width, patternImg_height, blksize, bitDepth, options);
dark = [19,19,17,16,21,18,14,15,18,19,17,17,18,18,20,22,19,22,21,21,17,18,17,15,21];

%% Pre-processing         
input_dir_file_path = fullfile(ms_path, '*.raw' );  
dat = dir(input_dir_file_path);               
for j = 1:length(dat)
    datapath = fullfile(ms_path, dat(j).name);
    [rawImage, nframes, exposureTime, ~] = readXimeaRaw(datapath, patternImg_width, patternImg_height);        % Multi-spectral .raw data decompression
    tempOutMarker = [options.patternImgOut options.ImgCubeOut options.ImgCubeBandOut options.jpgBandOut];
    
    counter = 0; % 每10张输出一次进度
    for m = 1:nframes 
        if m == 1
            if (isempty(find(options.CalibCubeOut) == 1) & isempty(find(tempOutMarker) == 1))
                options.ImgCubeOut = 1;
            end
        end
        [ori_dataCube, ~] = extractCube(rawImage, patternImg_width, patternImg_height, m, nframes, ...         % dataCube extraction
                                        output_root, dat(j).name(1:end-4), options); 

        if (isempty(find(options.CalibCubeOut) == 1))
            if m == nframes disp ('only XIMEA imgCbue is extracted!!!'); end                                   % No data calibration
            continue
        end

        [h, w, b] = size(ori_dataCube);        
        camResponseCalibCube = zeros(h, w, b);  
        vignetteCalibCube    = zeros(h, w, b);
        camFOVundistortCube  = zeros(h, w, b);  
        
        for bands = 1:b        
            temp = reshape(ori_dataCube(:,:,bands), [w*h 1]);                                                  % camResponseCalib and darkCalib
            for wh = 1:w*h
                if temp(wh) < 0 
                   temp(wh) = 0;
                elseif temp(wh) >= 1023
                    temp(wh) = 1023;
%                     disp([dat(j).name '过曝'])
                else
                    temp(wh) = InvG(bands,temp(wh)+1) - dark(bands);  
                end
            end
            camResponseCalibCube(:,:,bands) = reshape(temp, [h w]);
            
            vigCalibCube = camResponseCalibCube(:,:,bands) ./ (vignetteSmoothedCube(:,:,bands)*exposureTime);  % vignettingCalib and ExposureNormalization
            vignetteCalibCube(:,:,bands) = vigCalibCube;     
            
            if cameraParams ~= 0                                                                               % camFOVundistortCube
                camFOVundistortCube(:,:,bands) = undistortImage(vignetteCalibCube(:,:,bands), cameraParams);
            else
                camFOVundistortCube(:,:,bands) = vignetteCalibCube(:,:,bands);
            end
        end     
        
       % write imgCube
        dataName = {'camResponseCalibCube';'vignetteCalibCube'};
        loc = find(options.CalibCubeOut);
        
        for w = 1:length(loc) - 1
%             filePath = fullfile(output_root, dataName{loc(w)});
%             if ~exist(filePath,'dir') mkdir(filePath); end
            filePath = output_root;
            filename = [filePath, '\' , dat(j).name(1:end-4), '_', num2str(m)]; 
            wCube = single(eval(dataName{loc(w)}));                  
            switch writeFormat
              case 0     % TIFF write      
                    filename = [filename '.tif'];
                    writeTIFF(wCube, filename);         
                case 1     % ENVI write
                    enviwriteXimea(permute(wCube, [2 1 3]), waveRange, filename); 
            end
%             if m == nframes disp([dataName{loc(w)} 32 'extraction completion!!!']); end
        end
        counter = counter + 1;
        if counter == 10
            percent = char(num2str(round(m / nframes * 100)));
            disp(['The progress is ' percent '%']);
            counter = 0;
        end
    end
%     disp(['The progress is done!']);
end

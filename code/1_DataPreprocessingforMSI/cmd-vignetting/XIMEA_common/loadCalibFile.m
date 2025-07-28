function [InvG, vignetteSmoothedCube, cameraParams, options] = loadCalibFile(calibData_root, patternImg_width, patternImg_height, ...
                                                                          blksize, bitDepth, options)
                                                                      
    bands = blksize^2;
    % load camResponseCalib file
     if options.CalibCubeOut(1) == 0
         InvG = repmat((0:1:2^bitDepth-1), bands, 1);
     else
         for i = 1:bands
             invG_path = [calibData_root 'responseCalibOutput\Band'  num2str(i)  '\pcalib.txt'];
             InvG(i,:) = load(invG_path);
         end
         if ~exist('InvG')
            disp('Cannot load camResponseCalib file! (Not found \pcalib.txt)'); 
            InvG = repmat((0:1:2^bitDepth-1), bands, 1);
            options.CalibCubeOut(1) = 0;
         end
     end

    % load vignetteCalib file
    if options.CalibCubeOut(2) == 0
        vignetteSmoothedCube = ones(patternImg_height/blksize, patternImg_width/blksize ,bands);
    else
        if exist([calibData_root 'vignetteSmoothed.tif'],'file')
            vignetteSmoothedCube = imread([calibData_root 'vignetteSmoothed.tif']);
        else       
             for i = 1:bands             
                 vig_path = [calibData_root 'vignetteCalibOutput\MS_band'  num2str(i) '\vignetteSmoothed.png'];
                 if ~exist(vig_path,'file')
                     continue
                 end
                 vigImg = double(imread(vig_path));
                 vmin = min(vigImg(:)); vmax = max(vigImg(:));
                 vigImg = (vigImg - vmin) ./ (vmax - vmin);
%                  k=(1-0.5)/(vmax-vmin);
%                  vigImg = 0.5 + k*(vigImg - vmin);
                 vignetteSmoothedCube(:,:,i) = vigImg;
             end
             if ~exist('vignetteSmoothedCube')
                disp('Cannot load vignetteCalib file! (Not found \vignetteSmoothed.tif)'); 
                vignetteSmoothedCube = ones(patternImg_height/blksize, patternImg_width/blksize ,bands);
                options.CalibCubeOut(2) = 0;
             else
                 writeTIFF(single(vignetteSmoothedCube), [calibData_root 'vignetteSmoothed.tif']); 
             end
        end
    end

    % load cameraParams.mat
    if options.CalibCubeOut(3) == 0
        cameraParams = 0;
    else
        load([calibData_root 'cameraParams.mat']);
        if ~exist('cameraParams') 
            disp('Cannot load cameraParams.mat!'); 
            cameraParams = 0;
            options.CalibCubeOut(3) = 0;
        end
    end

end


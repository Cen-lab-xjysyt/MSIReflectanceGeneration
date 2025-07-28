function cameraParams = lensDistCorrect(path, refer_band)

    squareSize = 25;  % in units of 'mm'
    
    % Load the imageFileNames
    input_path = [path 'singleBands\MS_band' num2str(refer_band) '\tif'];    
    input_dir  = dir(input_path);
        input_dir_file_path = fullfile(input_path,  '*.tif' );
        dat = dir(input_dir_file_path);               
    for i = 1: size(dat, 1)
        imageFileNames{i} = fullfile(input_path, dat(i).name);
    end

    % Detect checkerboards in images
    [imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames);
    imageFileNames = imageFileNames(imagesUsed);

    % Read the first image to obtain image size
    originalImage = imread(imageFileNames{1});
    [mrows, ncols, ~] = size(originalImage);

    % Generate world coordinates of the corners of the squares
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);

    % Calibrate the camera
    [cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
        'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
        'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'mm', ...
        'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
        'ImageSize', [mrows, ncols]);

    % View reprojection errors
%     h1=figure; showReprojectionErrors(cameraParams);

    % Visualize pattern locations
%     h2=figure; showExtrinsics(cameraParams, 'CameraCentric');

    % Display parameter estimation errors
%     displayErrors(estimationErrors, cameraParams);
end


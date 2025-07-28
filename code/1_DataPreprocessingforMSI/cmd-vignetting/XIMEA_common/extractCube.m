function [dataCube, patternimg] = extractCube(img, width, height, m, nframes, input_path, fname, options)
    
    blksize = 5;
    nCols = width/blksize;
    nRows = height/blksize;
    nBands = blksize^2;

   %% 2D spatial data decompression
    temp = reshape(img(:,m), nCols*nBands, nRows); 
    temp = temp';
    for i = 1: blksize
        patternimg(i:blksize:height, 1:width) = temp(:,1 + width *(i-1):width * i);  % Pattern image
    end

    if options.patternImgOut == 1                                                    % write PatternImg to .tif
        out_path = [input_path 'patternImg\'];
        if ~exist(out_path,'dir')
            mkdir(out_path);
        end
        filename = ['MS_' fname, '_', num2str(m), '-', num2str(nframes) '.tif'];
        writeTIFF(single(patternimg), [out_path filename]);      
    end

   %% Demosaicing and reconstructed HIS data cube
    dataCube = zeros(nRows, nCols, nBands);
    for i = 1:blksize       % blkrow
        for j = 1:blksize   % blkcol
            dataCube(:,:,(i-1)*blksize+j) = patternimg(i:blksize:end,j:blksize:end); % reconstructed HIS cube

            if options.jpgBandOut == 1                                                %%% write normalized single band image to .jpg
                if (i==2)&(j==5)                                                      % output the Band10 img(.jpg)
                tmp = dataCube(:,:,(i-1)*blksize+j);
%                     minVal = min(tmp(:)); maxVal = max(tmp(:));                     % normalization
%                     tmp = ((tmp - minVal) ./ (maxVal - minVal))*255;
                tmp = (tmp ./ 1024) * 255;
                out_path = [input_path 'singleBands\MS_band' num2str((i-1)* blksize+j) '\rgb\'];
                if ~exist(out_path,'dir')
                    mkdir(out_path);
                end                
                
                filename = ['MS_b' num2str((i-1)*blksize+j) '_' fname '_' num2str(m) '-' num2str(nframes) '.jpg'];
                imwrite(uint8(tmp), [out_path filename]);  
                end
            end

            if options.ImgCubeBandOut == 1                                            %%% write single band image(non-normalization) to .tif
                out_path = [input_path 'singleBands\MS_band' num2str((i-1)* blksize+j) '\tif\'];
                if ~exist(out_path,'dir')
                    mkdir(out_path);
                end
                filename = ['MS_b' num2str((i-1)*blksize+j) '_' fname '_' num2str(m) '-' num2str(nframes) '.tif'];
                writeTIFF(single(dataCube(:,:,(i-1)*blksize+j)), [out_path filename]); 
            end
        end
    end

%     if options.ImgCubeOut == 1                                                         %%% write data cube to .tif
%         out_path = [input_path 'oriImgCube\'];
%         if ~exist(out_path,'dir')
%             mkdir(out_path);
%         end
%         filename = [fname, '_', num2str(m), '-', num2str(nframes) '.tif'];
%         writeTIFF(single(dataCube), [out_path filename]);
%     end
    
end

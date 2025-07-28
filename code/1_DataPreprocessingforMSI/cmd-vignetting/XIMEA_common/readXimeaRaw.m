function [rawImage, frames, exposureTime, hdr_fname] = readXimeaRaw(fname, patternImg_width, patternImg_height)

    % Open the .hdr file
    pos = find('.'== fname);
    hdr_fname = fname(1:pos(end)-1);
    hdrfid = fopen(strcat(hdr_fname,'.hdr'),'r');

    % Check if the header file is correctely open
    if hdrfid == -1
        error('Input header file does not exist');
    end

    % Obtain the frames info
    times = 1;
    while 1
        tline = fgetl(hdrfid);
        if ~ischar(tline), break, end
        if findstr(tline,'Exposure(ms)')
            if times < 2
               [~, second]=strtok(tline,'=');
               [~, etime]=strtok(second);
               exposureTime = str2num(etime);                 % exposure time
               times = 2;
            end
        end
        if findstr(tline,'Frames')
           [~, second]=strtok(tline,'=');
           [~, frames]=strtok(second);
           frames = str2num(frames);                      % frame info
        end
    end
    fid=fopen(fname);
    
    % .raw data decompression
    rawImage=fread(fid,[patternImg_width*patternImg_height frames], 'uint16'); % the real bit depth is 10
end


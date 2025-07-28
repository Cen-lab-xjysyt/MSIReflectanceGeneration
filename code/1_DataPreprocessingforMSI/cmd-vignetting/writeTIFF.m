function writeTIFF(data, filename)
% writeTIFF(data, filename)
% writes data as a multi-channel TIFF with single prec. float pixels
   t = Tiff(filename, 'w');
   tagstruct.ImageLength         = size(data, 1);
   tagstruct.ImageWidth          = size(data, 2);
   tagstruct.Compression         = Tiff.Compression.None;
   %tagstruct.Compression        = Tiff.Compression.LZW;            % compressed
   tagstruct.SampleFormat        = Tiff.SampleFormat.IEEEFP;        % 表示对数据类型的解释
   tagstruct.Photometric         = Tiff.Photometric.MinIsBlack;     % 颜色空间解释方式
   tagstruct.BitsPerSample       = 32;                              % float data
   tagstruct.SamplesPerPixel     = size(data,3);                    % band number
   tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
   t.setTag(tagstruct);                                             % 设置Tiff对象的tag
   t.write(data);                                                   % 已准备好头文件，开始写数据
   t.close();                                                       % 关闭影像

   

  
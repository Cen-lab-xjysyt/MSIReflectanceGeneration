function writeTIFF(data, filename)
% writeTIFF(data, filename)
% writes data as a multi-channel TIFF with single prec. float pixels
   t = Tiff(filename, 'w');
   tagstruct.ImageLength         = size(data, 1);
   tagstruct.ImageWidth          = size(data, 2);
   tagstruct.Compression         = Tiff.Compression.None;
   %tagstruct.Compression        = Tiff.Compression.LZW;            % compressed
   tagstruct.SampleFormat        = Tiff.SampleFormat.IEEEFP;        % ��ʾ���������͵Ľ���
   tagstruct.Photometric         = Tiff.Photometric.MinIsBlack;     % ��ɫ�ռ���ͷ�ʽ
   tagstruct.BitsPerSample       = 32;                              % float data
   tagstruct.SamplesPerPixel     = size(data,3);                    % band number
   tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
   t.setTag(tagstruct);                                             % ����Tiff�����tag
   t.write(data);                                                   % ��׼����ͷ�ļ�����ʼд����
   t.close();                                                       % �ر�Ӱ��

   

  
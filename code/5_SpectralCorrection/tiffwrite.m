% function tiffwrite(c,filepath)
%     t = Tiff(filepath,'w');
%     tagstruct.ImageLength = size(c,1); % 影像的长度
%     tagstruct.ImageWidth = size(c,2);  % 影像的宽度
%     tagstruct.Photometric = 1;
%     tagstruct.BitsPerSample = 32;
%     %如果 BitPerSample 为 16，则输入图像数据类型必须为 int16 或 uint16，而不是 double。
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.SamplesPerPixel =1;
%     tagstruct.RowsPerStrip = 16;
%     tagstruct.SampleFormat=3;  
%     t.setTag(tagstruct);
%     t.write(c);
%     t.close;
% end

%% double 类型图片用下面的程序
function tiffwrite(c,filepath)
    t = Tiff(filepath,'w');
    tagstruct.ImageLength = size(c,1); % 影像的长度
    tagstruct.ImageWidth = size(c,2);  % 影像的宽度
    tagstruct.Photometric = 1;
    tagstruct.BitsPerSample = 64;
    %如果 BitPerSample 为 16，则输入图像数据类型必须为 int16 或 uint16，而不是 double。
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.SamplesPerPixel =25;
    tagstruct.RowsPerStrip = 16;
    tagstruct.SampleFormat=3;  
    t.setTag(tagstruct);
    t.write(c);
    t.close;
end
%% single 类型图片用下面的程序
% function tiffwrite(c,filepath)
%     t = Tiff(filepath,'w');
%     tagstruct.ImageLength = size(c,1); % 影像的长度
%     tagstruct.ImageWidth = size(c,2);  % 影像的宽度
%     tagstruct.Photometric = 1;
%     tagstruct.BitsPerSample = 32;
%     %如果 BitPerSample 为 16，则输入图像数据类型必须为 int16 或 uint16，而不是 double。
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.SamplesPerPixel =25;
%     tagstruct.RowsPerStrip = 16;
%     tagstruct.SampleFormat=3;  
%     t.setTag(tagstruct);
%     t.write(c);
%     t.close;
% end

%%
%uint16类型的 用下面的程序
% function tiffwrite(c,filepath)
%     t = Tiff(filepath,'w');
%     tagstruct.ImageLength = size(c,1); % 影像的长度
%     tagstruct.ImageWidth = size(c,2);  % 影像的宽度
%     tagstruct.Photometric = 1;
%     tagstruct.BitsPerSample = 16;
%     %如果 BitPerSample 为 16，则输入图像数据类型必须为 int16 或 uint16，而不是 double。
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.SamplesPerPixel =25;
%     tagstruct.RowsPerStrip = 16;
%     %%%tagstruct.SampleFormat=3;  
%     t.setTag(tagstruct);
%     t.write(c);
%     t.close;
% end

%%
%单波段
% function tiffwrite(c,filepath)
%     t = Tiff(filepath,'w');
%     tagstruct.ImageLength = size(c,1); % 影像的长度
%     tagstruct.ImageWidth = size(c,2);  % 影像的宽度
%     tagstruct.Photometric = 1;
%     tagstruct.BitsPerSample = 32;
%     %如果 BitPerSample 为 16，则输入图像数据类型必须为 int16 或 uint16，而不是 double。
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.SamplesPerPixel =1;
%     tagstruct.RowsPerStrip = 16;
%     tagstruct.SampleFormat=3;  
%     t.setTag(tagstruct);
%     t.write(c);
%     t.close;
% end
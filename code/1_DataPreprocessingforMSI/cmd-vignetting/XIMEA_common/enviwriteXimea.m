function i=enviwriteXimea(image, waveRange, fname);

% enviwrite          	- write ENVI image from MATLAB array (V. Guissard, Apr 29 2004)
%
% 				Write a MATLAB array to a file in ENVI standard format
%				from a [col x line x band] array
%
% SYNTAX
%
% image=freadenvi(fname)
% [image,p]=freadenvi(fname)
% [image,p,t]=freadenvi(fname)
%
% INPUT :
%
%
% image	c by l by b	name of the MATLAB variable containing the array to export
%				to an ENVI image, with c = cols, l the lines and b the bands
% fname	string	full pathname of the ENVI image to write.
%
% OUTPUT :
%
% i		integer	i = -1 if process fail
%
% NOTE : 			
%
%%%%%%%%%%%%%

% Parameters initialization
    im_size=size(image);
    im_size(3)=size(image,3);
    elements={'samples =' 'lines   =' 'bands   =' 'data type =' 'exposure(ms) ='};
    d=[4 1 2 3 12 13];
    % Check user input
    if ~ischar(fname)
        error('fname should be a char string');
    end

    cl1=class(image);
    if cl1 == 'double'
        img=single(image);
    else
        img=image;
    end
    cl=class(img);
    switch cl
        case 'single'
            t = d(1);
        case 'int8'
            t = d(2);
        case 'int16'
            t = d(3);
        case 'int32'
            t = d(4);
        case 'uint16'
            t = d(6);
        case 'uint32'
            t = d(7);
        otherwise
            error('Data type not recognized');
    end
    wfid = fopen(fname,'w');
    if wfid == -1
        i=-1;
    end
    % disp([('Writing ENVI image ...')]);
    fwrite(wfid,img,cl);
    fclose(wfid);

    % Write header file
    fid = fopen(strcat(fname,'.hdr'),'w');
    if fid == -1
        i=-1;
    end

    fprintf(fid,'%s \n','ENVI');
    fprintf(fid,'%s \n','description = {');
    fprintf(fid,'%s \n','XIMEA xiSpec MQ022HG-IM-SM5X5-NIR (Exported from MATLAB)}');
    fprintf(fid,'%s %i \n',elements{1,1},im_size(1));
    fprintf(fid,'%s %i \n',elements{1,2},im_size(2));
    fprintf(fid,'%s %i \n',elements{1,3},im_size(3));
    fprintf(fid,'%s \n', 'header offset = 0');
    fprintf(fid,'%s \n', 'file type = ENVI Standard');
    fprintf(fid,'%s \n', 'sensor type = IMEC SSM5X5-600_1000');
    fprintf(fid,'%s %i \n',elements{1,4},t);
    fprintf(fid,'%s \n','interleave = bsq');
    fprintf(fid,'%s \n', 'default bands = { 13, 9, 6}');
    fprintf(fid,'%s \n', 'byte order = 0');
    fprintf(fid,'%s \n', 'x start = 0');
    fprintf(fid,'%s \n', 'y start = 0');

    fprintf(fid,'%s \n', 'wavelength units = Nanometers'); 
    fprintf(fid,'%s \n', 'wavelength = {');

    switch waveRange
        case 1 %'600-875'
            fprintf(fid,'%s \n', '603.3264153152667, 611.3075377197143, 624.2774593447067, 632.9144436317162, 641.3878862441062,');
            fprintf(fid,'%s \n', '649.6667556036475, 657.9542185030838, 666.5834232793961, 675.0040482293647, 679.0762013802932,');
            fprintf(fid,'%s \n', '693.1149338670836, 718.5766942495792, 732.0792800498073, 745.0352421932715, 758.504343555141,');
            fprintf(fid,'%s \n', '771.2944801715386, 784.3974711149768, 796.3178828283492, 808.1665219121527, 827.1555928179926,');
            fprintf(fid,'%s \n', '838.6535871662674, 849.0918017090138, 859.7260620410086, 869.4975340381731, 872.5388429752823}');

        case 2 %'675-975'
            fprintf(fid,'%s \n', '679.232515926512, 693.1566649667295, 718.5406386057117, 732.0534749757006, 745.0150593745192,');
            fprintf(fid,'%s \n', '758.4635660942944, 771.1623267246463, 784.3040492347801, 796.3640497926863, 808.2299777206982,');
            fprintf(fid,'%s \n', '827.3814667636491, 838.5948577597437, 849.1149267764746, 859.7661248647974, 869.8509132999335,');
            fprintf(fid,'%s \n', '879.9579085012728, 889.3914216490684, 898.0417421175591, 913.173814266214, 921.6516934981742,');
            fprintf(fid,'%s \n', '930.1857546616029, 936.676033057941, 944.7572347343183, 951.6198020258158, 956.6981649476446}');
        otherwise
    end

fclose(fid);

%  '600-875'
%         fprintf(fid,'%s \n', 'fwhm = {');
%         fprintf(fid,'%s \n', '4.359504132231405, 6.03305785123967, 4.731404958677686, 4.359504132231405, 4.359504132231405,');
%         fprintf(fid,'%s \n', '3.615702479338843, 3.243801652892563, 2.871900826446281, 3.615702479338843, 4.359504132231405,');
%         fprintf(fid,'%s \n', '3.987603305785124, 4.731404958677686, 4.359504132231405, 6.776859504132233, 6.404958677685952,');
%         fprintf(fid,'%s \n', '6.776859504132233, 7.148760330578514, 6.03305785123967, 6.404958677685952, 8.450413223140496,');
%         fprintf(fid,'%s \n', '6.776859504132233, 6.776859504132233, 7.706611570247934, 8.450413223140496, 8.450413223140496}');

% '675-975'
%         fprintf(fid,'%s \n', 'fwhm = {');
%         fprintf(fid,'%s \n', '3.987603305785124, 3.987603305785124, 4.731404958677686, 4.359504132231405, 6.776859504132233,');
%         fprintf(fid,'%s \n', '6.404958677685952, 6.776859504132233, 7.148760330578514, 5.661157024793389, 6.404958677685952,');
%         fprintf(fid,'%s \n', '8.450413223140496, 6.776859504132233, 6.404958677685952, 8.078512396694215, 10.12396694214876,');
%         fprintf(fid,'%s \n', '11.2396694214876, 11.2396694214876, 12.1694214876033, 12.54132231404958, 16.2603305785124,');
%         fprintf(fid,'%s \n', '19.97933884297521, 17.93388429752066, 24.99999999999999, 14.95867768595041, 14.21487603305785}');
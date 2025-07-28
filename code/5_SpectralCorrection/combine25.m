clear;
clc;

file_path = 'Z:\Projects\Drone_radiometric_correction\阴阳图\多光谱\解压后-重做暗角\架次2重做重做暗角20240830_output\';% 图像文件夹路径
img_path_list_tif = dir(strcat(file_path,'*.tif'));%获取该文件夹中所有tif格式的图像 
img_num = length(img_path_list_tif); %该文件夹中图像数量
output_path = 'Z:\Projects\Drone_radiometric_correction\阴阳图\多光谱\解压后-重做暗角\架次2重做重做暗角20240830_光谱校正后\';
mkdir(output_path);

load('CorrectionMatrix25-600-875.mat')
% 确保并行计算中的变量透明
correction_local = correction;


for p = 1:img_num
    image_name_tif = img_path_list_tif(p).name% 图像名 
    image_path=strcat(file_path,image_name_tif);
    D=imread(image_path);

    Flag=1;
    % data = xlsread ('D:\1_2021-2022诸暨油菜实验\4_20220216抽薹期早期\2_多光谱\0216-1\T0216.xlsx','0216');
    % DN=data(1:25,1:4);
    % RT1= xlsread ('D:\1_2021-2022诸暨油菜实验\4_20220216抽薹期早期\2_多光谱\0216-1\T0216.xlsx','R');
    % RT2=RT1(:,1:4);
    % RT=RT2;    
    

    img1=D;

    img2=img1(:,:,1:25);
    % for i=1:25
    %    bb=polyfit(DN(i,:),RT(i,:),1);
    %    k(i)=bb(1);
    %    l(i)=bb(2);
    % end
     [x,y,z]=size(img2);
     img=double(img2);
    % for a=1:z
    %      for b=1:x
    %          for c=1:y
    % %             temp=img(b,c,:);
    %             img(b,c,a)=k(a)*double(img2(b,c,a))+l(a);
    %         end
    %     end
    % end
    result=img;
    if Flag == 0
        result2=img;
    else
    result(:,:,21)=img(:,:,1);
    result(:,:,10)=img(:,:,2);
    result(:,:,15)=img(:,:,3);
    result(:,:,14)=img(:,:,4);
    result(:,:,13)=img(:,:,5);
    result(:,:,11)=img(:,:,6);
    result(:,:,12)=img(:,:,7);
    result(:,:,9)=img(:,:,8);
    result(:,:,8)=img(:,:,9);
    result(:,:,6)=img(:,:,10);
    result(:,:,7)=img(:,:,11);
    result(:,:,24)=img(:,:,12);
    result(:,:,23)=img(:,:,13);
    result(:,:,22)=img(:,:,14);
    result(:,:,4)=img(:,:,15);
    result(:,:,3)=img(:,:,16);
    result(:,:,1)=img(:,:,17);
    result(:,:,2)=img(:,:,18);
    result(:,:,19)=img(:,:,19);
    result(:,:,18)=img(:,:,20);
    result(:,:,16)=img(:,:,21);
    result(:,:,17)=img(:,:,22);
    result(:,:,25)=img(:,:,23);
    result(:,:,20)=img(:,:,24);
    result(:,:,5)=img(:,:,25);
    end

    img2=double(result);
     [x,y,z]=size(img2);
    for a=1:z
        a
        for b=1:x
            for c=1:y
                temp=img2(b,c,:);
                result2(b,c,a)=sum(correction_local(a,:).*temp(1,:));
            end
        end
    end
    img_path2=strcat(output_path,image_name_tif);
    
    result2 = result2(:,:,:);
    img_path2 = 'Z:\Projects\Drone_radiometric_correction\阴阳图\多光谱\解压后-重做暗角\架次2重做重做暗角20240830_光谱校正后\chunk4光谱校正后-r.tif';
    tiffwrite(result2(1:3000,:,:),img_path2);
end
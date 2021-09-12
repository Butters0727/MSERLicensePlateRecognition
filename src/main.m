colorImage = imread('test1.jpg');
figure,imshow(colorImage),title('original');
lp_color = lp_detect(colorImage);
figure,imshow(lp_color),title('license plate');
lp_color = lp_titlt(lp_color);
figure,imshow(lp_color),title('titlted correction license plate');
%lp_gray = rgb2gray(lp_color);
lp_bw = im2bw(lp_color);
lp_bw = bwareaopen(lp_bw, 10);
lp_bw = imclearborder(lp_bw,4);
figure,imshow(lp_bw),title('binary');

mserRegions= detectMSER(lp_bw);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));

mserMask = false(size(lp_bw));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
figure;imshow(mserMask),title('coarse filter');

[p_image,cwidth,img_color] =conComp_analysis(mserMask,lp_color,lp_bw);

if length(img_color)>7
    figure;imshow(mserMask),title('fine filter');
    wi= median(cwidth(:))/2;
    se1=strel('line',wi,0);
    p_image_dilate= imclose(p_image,se1);

    [rec_word,img_color,img_bw]=f_conComp_analysis(p_image_dilate,lp_color,lp_bw);
end

for i = 1:7
    img_bw{i}=imresize(img_bw{i},[32,16],'nearest');
end


figure,
subplot(1,7,1),imshow(img_bw{1});
subplot(1,7,2),imshow(img_bw{2});
subplot(1,7,3),imshow(img_bw{3});
subplot(1,7,4),imshow(img_bw{4});
subplot(1,7,5),imshow(img_bw{5});
subplot(1,7,6),imshow(img_bw{6});
subplot(1,7,7),imshow(img_bw{7});


characters = LicPlateRec(img_bw);
disp(characters);





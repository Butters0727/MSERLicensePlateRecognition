function [p_image,cwidth,seg_img_color,seg_img_bw] =conComp_analysis(bwimg,colorImg,p_img)
[x,y]=size(bwimg);
j=1;
cwidth=[];
whole=x*y;
connComp = bwconncomp(bwimg); % Find connected components
threefeature = regionprops(connComp,'Area','BoundingBox','Centroid'  );
broder=[threefeature.BoundingBox];%[x y width height]字符的区域
area=[threefeature.Area];%区域面积
centre=[threefeature.Centroid];
%area
for i=1:connComp.NumObjects
    leftx=broder((i-1)*4+1);
    lefty=broder((i-1)*4+2);
    width=broder((i-1)*4+3);
    height=broder((i-1)*4+4);
    cenx=floor(centre((i-1)*2+1));
    ceny=floor(centre((i-1)*2+2));
   
    if area(i)<10||area(i)>0.3*whole
        %display(area(i));
        bwimg(connComp.PixelIdxList{i})=0;
    elseif width/height<0.1||width/height>2
        %display(width),display(height);
        bwimg(connComp.PixelIdxList{i})=0;
    else
        cwidth=[cwidth,width];
        rectangle('Position',[leftx,lefty,width,height], 'EdgeColor','g','LineWidth',1);
        seg_img_color{j}=colorImg(lefty+1:lefty+height,leftx+1:leftx+width,:); % +1 避免索引为0
        seg_img_bw{j}=p_img(lefty+1:lefty+height,leftx+1:leftx+width);
        j=j+1;
    end
end

% for i=1:connComp.NumObjects
%     leftx=broder((i-1)*4+1);
%     lefty=broder((i-1)*4+2);
%     width=broder((i-1)*4+3);
%     height=broder((i-1)*4+4);
%     leftx1=broder(i*4+1);
%     lefty1=broder(i*4+2);
%     width1=broder(i*4+3);
%     height1=broder(i*4+4);
%     if abs(leftx-leftx1)<20 && abs(lefty-lefty1)<10
%         rectangle('Position',[min(leftx,leftx1),min(lefty,lefty1),max(width,width1),height+height1], 'EdgeColor','g');
%         
%     end
% end
p_image=bwimg;
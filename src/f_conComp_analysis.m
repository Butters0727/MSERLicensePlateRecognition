function [rec,seg_img_color,seg_img_bw] =f_conComp_analysis(P_image,colorImg,p_img)
[x,y]=size(P_image);
whole=x*y;
j=1;
rec=[];
connComp = bwconncomp(P_image); % Find connected components
threefeature = regionprops(connComp,'Area','BoundingBox');

broder=[threefeature.BoundingBox];
area=[threefeature.Area];
for i=1:connComp.NumObjects
    leftx=floor(broder((i-1)*4+1));
    lefty=floor(broder((i-1)*4+2));
    width=broder((i-1)*4+3);
    height=broder((i-1)*4+4);
    %    data=grayimg_reserve(lefty:lefty+height-1,leftx:leftx+width-1);
    %    stda(i,:)=statxture(data);
    if area(i)<300||area(i)>whole*0.4
        P_image(connComp.PixelIdxList{i})=0;
%     elseif width/height>2
%         P_image(connComp.PixelIdxList{i})=0;
    else
        rect=[leftx,lefty,width,height];
        rec=[rec;rect];
        rectangle('Position',[leftx,lefty,width,height], 'EdgeColor','g','LineWidth',1);
        seg_img_color{j}=colorImg(lefty+1:lefty+height,leftx+1:leftx+width,:); 
        seg_img_bw{j}=p_img(lefty+1:lefty+height,leftx+1:leftx+width);
        j=j+1;
    end
end
% for i=1:(connComp.NumObjects-1)
%     leftx=floor(broder((i-1)*4+1));
%     lefty=floor(broder((i-1)*4+2));
%     width=broder((i-1)*4+3);
%     height=broder((i-1)*4+4);
%     leftx1=floor(broder(i*4+1));
%     lefty1=floor(broder(i*4+2));
%     width1=broder(i*4+3);
%     height1=broder(i*4+4);
%     if abs(leftx-leftx1)<30 && abs(lefty-lefty1)<30
%         rectangle('Position',[leftx,min(lefty,lefty1),max(width,width1),height+height1], 'EdgeColor','g');
%         
%     end
% end
pp_image=P_image;
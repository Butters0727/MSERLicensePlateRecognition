function mserRegions = detectMSER(I)
mserRegions=detectMSERFeatures(I, ... 
    'RegionAreaRange',[50 8000],'ThresholdDelta',4);

figure
imshow(I)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('MSER regions')
hold off



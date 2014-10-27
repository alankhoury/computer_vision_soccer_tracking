clc 
clear all
close all

ImageDir='imdemos/';%directory containing the images

Irgb = imread([ImageDir 'figures.jpg']);
if ndims(Irgb) == 3;
    I = rgb2gray(Irgb);
elseif ndims(Irgb) == 2;
    I = Irgb;
end

figure, set(gca,'FontSize',30,'fontWeight','bold'),
subplot(2,3,1), imshow(I)
set(gcf,'color','w');
title('original image')
%% wweewew

[x,y]=size(I);
X=1:x;
Y=1:y;
[xx,yy]=meshgrid(Y,X);



%% Harris corner detection
filtCoeff = fspecial('gaussian',[9 1],1);
sensFactor = 0.05;
R = cornermetric(I,'Harris','FilterCoefficients', filtCoeff ,'SensitivityFactor',sensFactor);
i=im2double(R);
subplot(2,3,2),mesh(xx,yy,i);colormap(jet)
title('3D plot of R values at pixel location')

R1 = R;
R2 = R;
R3 = R;

maxR = max(max(R(:,:)))
minR = min(min(R(:,:)))


blurred = imfilter(I,filtCoeff);
subplot(2,3,3), imshow(blurred)
title('Image after Gaussian Blur')



threshold = 0.001
idx = find(R1 < threshold);
R1(idx) = 0;
corner_peaks = imregionalmax(R1);
[cornerY,cornerX]  = find(corner_peaks == true);
subplot(2,3,4), imshow(I), hold on
plot(cornerX, cornerY, 'r*');
title('Detected corners with thresholding at 0.001')



threshold = 0.001
idx = find(R2 < threshold);
R2(idx) = 0;
corner_peaks = imregionalmax(R2);
[cornerY,cornerX]  = find(corner_peaks == true);
subplot(2,3,5), imshow(I), hold on
plot(cornerX, cornerY, 'r*');
title('Detected corners with thresholding at 0.001')



threshold = 0.0001
idx = find(R3 < threshold);
R3(idx) = 0;
corner_peaks = imregionalmax(R3);
[cornerY,cornerX]  = find(corner_peaks == true);
subplot(2,3,6), imshow(I), hold on
plot(cornerX, cornerY, 'r*');
title('Detected corners with thresholding at 0.0001')





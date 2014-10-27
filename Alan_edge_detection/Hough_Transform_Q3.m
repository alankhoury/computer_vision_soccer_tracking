clc 
clear all
close all

% ImageDir='imdemos/';%directory containing the images

I = imread('../test_images/test2.png');
I = imadjust(I,[0.4 0.7],[0 0.8]);
I = rgb2gray(I);
subplot(2,2,1), imshow(I)
title('original image')

%% canny edge detection

canny_thresh = [0.1 0.25];
canny_sigma = 1;
BW = edge(I,'canny', canny_thresh, canny_sigma);
subplot(2,2,2), imshow(BW)
title('output from the canny edge detector')


%% hough transform

[H,theta,rho] = hough(BW);

subplot(2,2,3), imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
         'InitialMagnification','fit');
xlabel('\theta (degrees)'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(hot)
title('output from the hough transform');


maxPeaks = 31;
peakSepar = [55 23];
peakThresh = 100;
P = houghpeaks(H, maxPeaks, 'Threshold', peakThresh, 'NhoodSize', peakSepar);

x = theta(P(:,2));
y = rho(P(:,1));
plot(x,y,'s','color','blue');

lineGap = 20;
lineMinL = 3;
lines = houghlines(I,theta,rho,P,'FillGap',lineGap,'MinLength',lineMinL);

subplot(2,2,4), imshow(I), hold on


for k = 1:length(lines)
xy = [lines(k).point1; lines(k).point2];
plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
end
title('orginal image with the detected edges')
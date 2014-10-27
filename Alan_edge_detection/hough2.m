%% AMME4710 Tutorial 4 - Image Features - Q3 - Hough Transform
% Coded 29/08/2014

%% Clear workspace
close all
clear
clc

%% Read in images and convert to grayscale
chessImg = rgb2gray(imread('../test_images/test2.png'));


imshow(chessImg);

% Apply Canny Edge Detector
% canny_thresh = [0.1 0.2];
canny_thresh = [0.1 0.25];
canny_sigma = 2;
BW = edge(chessImg,'canny', canny_thresh, canny_sigma);
figure, imshow(BW)

% Extract Hough-space information

[H,theta,rho] = hough(BW);
figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,'InitialMagnification','fit');
xlabel('\theta (degrees)'), ylabel('\rho');
axis on, axis normal, hold on;
% colormap(hot);

% Nominate peak parameters and isolate best candidates
maxPeaks = 21;
peakSep = [55 23];

peakThresh = 100;
P = houghpeaks(H, maxPeaks, 'Threshold', peakThresh, 'NhoodSize', peakSep);
x = theta(P(:,2));
y = rho(P(:,1));
plot(x,y,'s','color','blue');

% Translate peak candidates back into pixel-space
lineGap = 20;
lineMinL = 7;
lines = houghlines(chessImg,theta,rho,P,'FillGap',lineGap,'MinLength',lineMinL);
figure, imshow(chessImg), hold on
for k = 1:length(lines)
xy = [lines(k).point1; lines(k).point2];
plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
end

clc;
clear;
close all
dbstop if error

figure

a = imread('justField1.png');
imshow(a);
[M, N, O] = size(a);

% roi = roipoly(a);
% roiR = immultiply(roi,a(:,:,1));
% roiG = immultiply(roi,a(:,:,2));
% roiB = immultiply(roi,a(:,:,3));
% section = cat(3, roiR, roiG, roiB);
load('section.mat');


[P, Q, R] = size(section);
I = reshape(section,P*Q,[]); %rearranges the color pizels in g as rows of I
% idx = find(roi); % find the row incidices of the color pixels that are not black
load('idx.mat')
I = double(I(idx,1:3));
[C,m] = covmatrix(I);


% C = [31.8771079434449,29.1197552793659,37.4568138061232;29.1197552793659,...
%     29.4459769306286,35.3514333479497;37.4568138061232,35.3514333479497,51.2454664633277];
% m = [91.6153789820579;129.080007323325;51.3335042109118];

d = diag(C);
sd = sqrt(d);

Length = size(I,1);

%compute an estimate of m
mean = sum(I,1)/Length;
I = I - mean(ones(Length,1),:); % Subtract the mean from each row of X
Covariance = (I'*I)/(Length-1);
sigma = sqrt(diag(Covariance));
sd = ceil(sigma(3,1));

figure
imshow(a)
title('Original Image')


figure,
S = colorseg('euclidean',a,6*sd,mean,m);
S = im2bw(S);
imshow(S)
title('black and white image of players using color seg')

% S = S(:,:,1);
% 
% 
% canny_thresh = [0.1 0.25];
% canny_sigma = 2;
% BW = edge(S,'canny', canny_thresh, canny_sigma);
% figure, imshow(BW)
% title('output from the canny edge detector')
% 
% 
% %% hough transform
% 
% [H,theta,rho] = hough(BW);
% 
% figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
%          'InitialMagnification','fit');
% xlabel('\theta (degrees)'), ylabel('\rho');
% axis on, axis normal, hold on;
% colormap(hot)
% title('output from the hough transform');
% 
% 
% maxPeaks = 2;
% peakSepar = [55 23];
% peakThresh = 100;
% P = houghpeaks(H, maxPeaks, 'Threshold', peakThresh, 'NhoodSize', peakSepar);
% 
% x = theta(P(:,2));
% y = rho(P(:,1));
% plot(x,y,'s','color','blue');
% 
% lineGap = 60;
% lineMinL = 50;
% lines = houghlines(BW,theta,rho,P,'FillGap',lineGap,'MinLength',lineMinL);
% 
% figure, imshow(BW), hold on
% 
% 
% for k = 1:length(lines)
% xy = [lines(k).point1; lines(k).point2];
% plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
% end
% title('orginal image with the detected edges')

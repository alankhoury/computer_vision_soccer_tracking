clc 
clear all
close all

%ImageDir='imdemos/';%directory containing the images

I = imread('../test_images/test2.png');
sharpended = imsharpen(I);
I = rgb2gray(I);
%figure, imshow(I)
title('original image')

%% canny edge detection

canny_thresh = [0.1 0.25];
canny_sigma = 2;
BW = edge(I,'canny', canny_thresh, canny_sigma);
figure, imshow(BW)
title('output from the canny edge detector')

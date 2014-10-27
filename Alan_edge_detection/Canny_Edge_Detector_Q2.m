%% clear all
close all


Irgb = imread('../test_images/test2.png');

Irgb = imsharpen(Irgb);
if ndims(Irgb) == 3;
    I = rgb2gray(Irgb);
elseif ndims(Irgb) == 2;
    I = Irgb;
end
subplot(2,1,1), imshow(I)
title('original image')

%%
canny_thresh = [0.1 0.2];
canny_sigma = 1;
BW = edge(I,'canny', canny_thresh, canny_sigma);
%BW = edge(I, 'canny', 0.2 , canny_sigma);

subplot(2,1,2), imshow(BW)
title('binary image mask created by the canny edge detector')


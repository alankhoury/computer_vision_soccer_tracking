addpath('Alan_Segmentation');
obj = VideoReader('goal3.mp4');
I = read(obj, 1);
I = im2double(I);
a = posterize(I,32);
imshow(a);
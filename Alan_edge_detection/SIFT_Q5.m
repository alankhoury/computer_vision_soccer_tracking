
clc 
clear all
close all

ImageDir='imdemos/';%directory containing the images

image = [ImageDir 'randomobjects.jpg'];
image = rgb2gray(image);

[image, descrips, locs] = sift(image);
showkeys(image, locs);


figure
match1([ImageDir 'randomobjects.jpg'],[ImageDir 'object.jpg']);
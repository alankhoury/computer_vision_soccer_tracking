addpath('Alan_Segmentation');
obj = VideoReader('goal3.mp4');

nframes = get(obj, 'NumberOfFrames');
I = read(obj, 1);
VideoStruct = zeros([(size(I,1)) (size(I,2)) 3 nframes], class(I));

alan = read(obj,200);
imOut = removeAudience(alan,1);
% figure, imshow(imOut);
imOut = im2uint8(imOut);


bw = bwPlayers(imOut);
imwrite(bw,'bwPlayers1.png');

figure;
imshow(bw);
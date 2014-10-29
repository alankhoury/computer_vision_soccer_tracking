addpath('Alan_Segmentation');
obj = VideoReader('goal3.mp4');

nframes = get(obj, 'NumberOfFrames');
I = read(obj, 1);
VideoStruct = zeros([(size(I,1)) (size(I,2)) 3 nframes], class(I));

% alan = read(obj,300);
% imOut = removeAudience(alan,1);
% % figure, imshow(imOut);
% imOut = im2uint8(imOut);
% 
% 
% bw = bwPlayers(imOut);
% imwrite(bw,'bwPlayers1.png');
% 
% figure;
% imshow(bw);

% grayIm = rgb2gray(bw);
% imshow(grayIm);
% % imwrite(grayIm,'Gray1.png')

% [pixelCount grayLevels] = imhist(bw);
% figure;
% bar(pixelCount); title('Histogram of original image');
% xlim([0 grayLevels(end)]); % Scale x axis manually.


%%%%%% color segmentation using kmeans and graph cut to be done on rgb
%%%%%% image
% color_seg_graph_cut(bw);


for k = 1:3:nframes
    currentFrame = read(obj, k);
    imOut = removeAudience(currentFrame,1);
%     figure, subplot (1,5,k), imshow(imOut);
    imOut = im2uint8(imOut);
    bw = bwPlayers(imOut);
imshow(bw);
  
    VideoStruct(:,:,:,k) = imOut;
    
    
    color_seg_graph_cut(imOut);
    
end

frameRate = get(obj,'FrameRate');
implay(VideoStruct,frameRate);
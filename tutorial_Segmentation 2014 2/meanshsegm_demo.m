% MEANSHSEGM_DEMO Demo showing the usage of meanshsegm 
% 
% adapted from CMP Vision algorithms http://visionbook.felk.cvut.cz
%
% Example
%
% Mean shift segmentation is applied to an RGB color image (264x
% 512 pixels) which takes several minutes.  It is possible to use
% a different color space or a grayscale image. Small regions can be
% eliminated by post-processing.  

ImageDir='images/';%directory containing the images

img=imread([ImageDir '101087.jpg']);

img=imresize(img,0.5) ; %resize or convert to grayscale if needed

figure, imagesc(img); axis image ; axis off ; 

display('Mean shift segmentation')
display('this procedure may take several minutes...')

l=meanshsegm(img,20,20) ;

figure, imagesc(label2rgb(l-1,'jet','w','shuffle')) ; 
axis image ; axis off ; 

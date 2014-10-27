%% Tutorial PANORAMA

ImageDir='images/';%directory containing the images

im1 = imread([ImageDir 'demo1.png']);
im2 = imread([ImageDir 'demo2.png']); 

%plot figure for affine warping
fshowA=figure;
subA1=subplot(2,2,1); imshow(im1);
subA2=subplot(2,2,2); imshow(im2);
movegui(fshowA, 'northwest');

%plot figure for homography warping
fshowH=figure;
subH1=subplot(2,2,1); imshow(im1);
subH2=subplot(2,2,2); imshow(im2);
movegui(fshowH, 'northeast');

%% sift features
[pts1 pts2] = SIFTmatch( im1, im2, 0, true );


%% ransac homography
if length(pts1) < 4 % at least 4 points needed
    disp('too few points matched.. stitching not possible.');
end
    
[im2_TH, best_ptsH] = ransac( pts2, pts1, 'proj_svd', 5 );
showbestpts(subH2, subH1, best_ptsH);
figure(fshowH);

%% stitch homography
[im_stitchedH, stitched_maskH, im1TH, im2TH] = stitch(im1, im2, im2_TH);
figure(fshowH);
subplot(2,2,3); imshow(im1TH);
subplot(2,2,4); imshow(im2TH);

fH=figure;
axis off;
movegui(fH, 'southeast');
imshow(im_stitchedH);

%% ransac affine
if length(pts1) < 3 % at least 3 points needed
    disp('too few points matched.. stitching not possible.');
end
[im2_TA, best_ptsA] = ransac( pts2, pts1, 'aff_lsq', 3 );
showbestpts(subA2, subA1, best_ptsA);
figure(fshowA);

%% stitch affine
[im_stitchedA, stitched_maskA, im1TA, im2TA] = stitch(im1, im2, im2_TA);
figure(fshowA);
subplot(2,2,3); imshow(im1TA);
subplot(2,2,4); imshow(im2TA);

fA=figure;
axis off;
movegui(fA, 'southwest');
imshow(im_stitchedA);

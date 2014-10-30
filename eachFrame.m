function eachFrame(I)
fieldOnly = removeAudience(I,1);
%  figure, imshow(fieldOnly);
fieldOnly = im2uint8(fieldOnly); 
figure, subplot(2,2,1),imshow(fieldOnly);
% bw = bwPlayers(imOut);
% imshow(bw);
yellow = detectYellowPlayers(fieldOnly);
subplot(2,2,2),imshow(yellow);

% yellowGray = mat2gray(yellow);
% g  = fspecial( 'gauss', [9 9], 2 );
% dy = fspecial( 'sobel' );
% vf = conv2( g, dy, 'valid' );
% 
% yellowFiltered = imfilter(yellowGray(:,:,1), vf , 'symmetric');

filled = imfill(yellow,'holes');
subplot(2,2,3), imshow(filled);

BW2 = bwareaopen(filled, 100);
labeledImage = bwlabel(BW2, 8);
coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
subplot(2,2,4),imagesc(coloredLabels);
end
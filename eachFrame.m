function eachFrame(I)
fieldOnly = removeAudience(I,1);
%  figure, imshow(fieldOnly);
fieldOnly = im2uint8(fieldOnly); 
figure(2), subplot(3,2,1),imshow(I);
% bw = bwPlayers(imOut);
% imshow(bw);

H = fspecial('gaussian',5,9);
fieldOnly = imfilter(fieldOnly,H,'replicate');
figure(2), subplot(3,2,2), imshow(fieldOnly);
yellow = detectYellowPlayers(fieldOnly);
subplot(3,2,3),imshow(yellow);


filled = imfill(yellow,'holes');
subplot(3,2,4), imshow(filled);

BW2 = bwareaopen(filled, 180);
labeledImage = bwlabel(BW2, 8);
coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
subplot(3,2,5),imagesc(coloredLabels);
end
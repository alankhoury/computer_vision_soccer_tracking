function blobDetectionAlan(binaryImage)
binaryImage = im2bw(binaryImage);
binaryImage = imfill(binaryImage, 'holes');
imshow(binaryImage);
% Label each blob so we can make measurements of it
labeledImage = bwlabel(binaryImage, 8);    

end
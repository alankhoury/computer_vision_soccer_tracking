clear; clc; close all;

frame = imread('GerBrazStart.jpg');
figure; imshow(frame);

[fR, fG, fB] = readRGB(frame);
fR = double(fR);
fG = double(fG);
fB = double(fB);
[nRows, nCols] = size(fR);
percMap = zeros(nRows, nCols);
percMap = double(percMap);
for r = 1:nRows
   for c = 1:nCols
       total = (fR(r,c)/255 + fG(r,c)/255 + fB(r,c)/255);
       if fG(r,c)/255 > 0.44*total
           percMap(r,c) = 1;
       else
           percMap(r,c) = 0;
       end
        
   end
end
figure; imagesc(percMap);
G = fspecial('gaussian',[20 20],2);
percMap = imfilter(percMap,G,'same');

for r = 2:nRows
    for c = 1:nCols
        if percMap(r,c) == 1 && percMap(r-1,c) == 0
            percMap(r,c) = 0.5;
        end
    end
end
figure; imagesc(percMap);
% for r = 1:nRows
%    for c = 1:nCols
%         if fG(r,c)>(fR(r,c)) && fG(r,c)>(fB(r,c)) && fG(r,c)>50
%             fG(r,c) = 255;
%         else
%             fG(r,c) = 0;
%         end
%    end
% end
% figure; imshow(fG);

ImageDir='images/';%directory containing the images

I = imread([ImageDir 'chess2.jpg']);
% I = rgb2gray(Irgb);

imshow(I)

%% Harris corner detection
filtCoeff = fspecial('gaussian',[9 1],3);
sensFactor = 0.05;
R = cornermetric(I,'Harris','FilterCoefficients', filtCoeff ,'SensitivityFactor',sensFactor);
figure,imshow(imadjust(R)), colormap(jet)

corner_peaks = imregionalmax(R);
[cornerY,cornerX]  = find(corner_peaks == true);
figure, imshow(I), hold on
plot(cornerX, cornerY, 'r*');


%% canny edge detection

canny_thresh = [0.1 0.2];
canny_sigma = 2;
BW = edge(I,'canny', canny_thresh, canny_sigma);
figure, imshow(BW)

%% hough transform

[H,theta,rho] = hough(BW);

figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
         'InitialMagnification','fit');
xlabel('\theta (degrees)'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(hot)

maxPeaks = 30;
peakSep = [27 11];
peakThresh = 0;
P = houghpeaks(H, maxPeaks, 'Threshold', peakThresh, 'NhoodSize', peakSep);

x = theta(P(:,2));
y = rho(P(:,1));
plot(x,y,'s','color','blue');

lineGap = 5;
lineMinL = 7;
lines = houghlines(BW,theta,rho,P,'FillGap',lineGap,'MinLength',lineMinL);

figure, imshow(I), hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
end

%%
[image, descrips, locs] = sift([ImageDir 'eiffel_tower.jpg']);
showkeys(image, locs);

match([ImageDir 'randomobjects.jpg'],[ImageDir 'object.jpg']);

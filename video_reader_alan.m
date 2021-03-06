function AlanSickVision()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter Initialisation

updateDT = 1;
predictDT = 1;
scaleF = 0.25;
X = [0 0 0 0 0 0];
alpha = 0.4;
beta = 0.01;
gamma = 0.00015;
if (beta > 4 - 2*alpha)
    disp('INVALID RANGE OF BETA');
end
if (gamma > 4*alpha*beta/(2-alpha))
    disp('INVALID RANGE OF GAMMA');
end
shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));


addpath('Alan_Segmentation');
obj = VideoReader('goal3.mp4');
I = read(obj, 1);
fullFrame = I;
figure(1);
imshow(fullFrame);
X(1:2) = ginput(1);

I = imresize(I,scaleF);
yellow = zeros([size(I,1), size(I,1)], 'uint8');

nframes = 200;%get(obj, 'NumberOfFrames');

VideoStruct = zeros([(size(fullFrame,1)) (size(fullFrame,2)) 3 nframes], class(fullFrame));
% I = posterize(im2double(I),32);
%figure(2); imshow(I);


X(1:2) = X(1:2)*scaleF;
for (frameNo = 2:1:nframes)
    I = read(obj, frameNo);  
    fullFrame = I;
    I = imresize(I,scaleF);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove audience using graphcut 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fieldOnly = I;

   % fieldOnly = removeAudience(I,1);
    %  figure, imshow(fieldOnly);
    %fieldOnly = im2uint8(fieldOnly); 
    % bw = bwPlayers(imOut);
    % imshow(bw);

    X = predict(X, predictDT);
    % at this point X is the projected value aat the next frame (time t+1)

    
    if (mod(frameNo, updateDT) == 0)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Blob detection
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        H = fspecial('gaussian',5,9);
        fieldOnly = imfilter(fieldOnly,H,'replicate');
        yellow = detectYellowPlayers(fieldOnly);

%        filled = imfill(yellow,'holes');
%        subplot(3,2,4), imshow(filled);

        BW2 = bwareaopen(yellow, 1);
        labeledImage = bwlabel(BW2, 8);
        coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Blob localisation using regionprops
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        props = regionprops(labeledImage,'centroid');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % blob selection using closest blob
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        if length(props) > 0
            % [blob x, blob y, blob dist from current estimate]
            blobPositions = zeros(length(props),3);
            for (i = 1:length(props))
                blobPositions(i,1:2) = props(i).Centroid;
                blobPositions(i,3) = rssq(props(i).Centroid - X(1:2));
            end
            % disp(blobPositions);
            [~,closestBlobIndex] = min(blobPositions(:,3));

            observedPlayerPos = blobPositions(closestBlobIndex, 1:2);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % State Estimation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            X = update(X, observedPlayerPos, alpha, beta, gamma, updateDT);
            % at this point X is the x updated value at the next frame (time t+1)
        end

        disp(X);
    end
    
    %%% overlay red dot at X[1,2] on original frame image
    
    playersCoords = int32([X(1) X(2) 15]);
    overlayedImage = step(shapeInserter, fullFrame, playersCoords/scaleF);
    
    yellowOverlay = label2rgb(yellow);
    yellowOverlay = step(shapeInserter, yellowOverlay, playersCoords);

    VideoStruct(:,:,:,frameNo) = overlayedImage;
%    plotDisplay(overlayedImage);
     plotDebug(yellowOverlay);

end

frameRate = get(obj,'FrameRate');
implay(VideoStruct,frameRate);



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


% for k = 1:2:10
%      currentFrame = read(obj, k);
%     imOut = removeAudience(currentFrame,1);
% %     figure, subplot (1,5,k), imshow(imOut);
%     imOut = im2uint8(imOut);
%     bw = bwPlayers(imOut);
% % imshow(bw);
%   
%     VideoStruct(:,:,:,k) = imOut;
%     
%     
%     color_seg_graph_cut(imOut);
% 
%  eachFrame(currentFrame);
%     
% end
% 
% frameRate = get(obj,'FrameRate');
% implay(VideoStruct,frameRate);
end

function X = predict(X, dt)
    X(1:2) = X(1:2) + X(3:4)*dt + X(5:6)*dt*dt/2;
    X(3:4) = X(3:4) + X(4:5)*dt;
end

function X = update(X, y, alpha, beta, gamma, dt)
    r = y - X(1:2); % position residual

    X(1:2) = X(1:2) + alpha * r ;
    X(3:4) = X(3:4) + beta * r/dt;
    X(5:6) = X(5:6) + gamma * r/(2*dt^2);
end

function plotDebug(blobFrame)
    figure(1);
%    subplot(2,1,1);
    imshow(blobFrame);
%    subplot(2,1,2);
%    imshow(finalFrame);    
end

function plotDisplay(fullFrame)
    imshow(fullFrame);
end



function AlanSickVision()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter Initialisation
addpath('matlab_utilities');
updateDT = 10;
predictDT = 1;
scaleF = 0.25;
x = [0; 0; 0; 0; 0; 0];
P = eye(6)*eps; % note: for stability, P should never be quite zero
% Specify uncertainties
SigmaP = 3;       % position (px)
SigmaV = 5;  % velocity (px/frame)
SigmaA = 0.5;  % acceleration (px/frame^2)
Q = diag([SigmaP SigmaP SigmaV SigmaV SigmaA SigmaA].^2);    % prediction uncertainty    
SigmaR = 2;       % range (px)
R = diag([SigmaR SigmaR].^2);   % observation uncertainty


u=[];

shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));

addpath('Alan_Segmentation');
obj = VideoReader('goal3.mp4');
I = read(obj, 1);
fullFrame = I;
figure(1);
imshow(fullFrame);
x(1:2) = ginput(1);

I = imresize(I,scaleF);
yellow = zeros([size(I,1), size(I,1)], 'uint8');

nframes = get(obj, 'NumberOfFrames');

VideoStruct = zeros([(size(fullFrame,1)) (size(fullFrame,2)) 3 nframes], class(fullFrame));
% I = posterize(im2double(I),32);
%figure(2); imshow(I);


x(1:2) = x(1:2)*scaleF;
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

    % predict
    [x,P] = predict(x, P, u, Q, predictDT);
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
                blobPositions(i,3) = rssq(props(i).Centroid - x(1:2).');
            end
            % disp(blobPositions);
            [~,closestBlobIndex] = min(blobPositions(:,3));

            observedPlayerPos = blobPositions(closestBlobIndex, 1:2);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % State Estimation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update
            [x,P] = update(x, P, observedPlayerPos.', R, 3); % the end parameter specifies which KF function to use.
            % at this point X is the x updated value at the next frame (time t+1)
        end

        disp(x);
    end
    
    %%% overlay red dot at X[1,2] on original frame image
    
    playersCoords = int32([x(1) x(2) 15]);
    overlayedImage = step(shapeInserter, fullFrame, playersCoords/scaleF);
    
    yellowOverlay = label2rgb(yellow);
    yellowOverlay = step(shapeInserter, yellowOverlay, playersCoords);

    VideoStruct(:,:,:,frameNo) = overlayedImage;
%    plotDisplay(overlayedImage);
     plotDebug(yellowOverlay);

end

frameRate = get(obj,'FrameRate');
implay(VideoStruct,frameRate);

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

function x = predict_model(x, u, dt)
% Constant accel model

    x = [x(1) + x(3)*dt + 0.5*x(5)*dt*dt; 
         x(2) + x(4)*dt + 0.5*x(6)*dt*dt;
         x(3) + x(5)*dt;
         x(4) + x(6)*dt;
         x(5);
         x(6)]; 
end

function z = observe_model(x)
% We have a position measurement of the player in the pixel space.
    z = [x(1);
         x(2)];
end

function v = observe_residual(v)
% Given nominal residual, compute normalised residual.
    %v(2) = pi_to_pi(v(2)); % normalise angle to +/- pi
    v = v;
end

function [x,P] = predict(x, P, u, Q, dt)
% We use the numerical_Jacobian function to compute an approximate Jacobian of the non-linear
% predict model. Thus, we can avoid deriving explicit analytical Jacobians.
    x = predict_model(x, u, dt);
    F = numerical_jacobian_i(@predict_model, [], 1, [], x, u, dt);
    if (0 && ~isempty(u))
        G = numerical_jacobian_i(@predict_model, [], 2, [], x, u, dt);
        P = F*P*F' + G*Q*G';
    else
        P = F*P*F' + Q;
    end
end

function [x,P] = update(x, P, z, R, type)
% This update demonstrates a variety of KF update implementations. For most purposes, the 
% KF_cholesky_update is best.

    zpred = observe_model(x);
    v = observe_residual(z - zpred);
    H = numerical_jacobian_i(@observe_model, @observe_residual, 1, [], x);

    switch type
    case 1
        [x,P] = kf_update_simple(x,P,v,R,H);
    case 2
        [x,P] = kf_update_joseph(x,P,v,R,H);
    case 3
        [x,P] = kf_update_cholesky(x,P,v,R,H);
    case 4
        [x,P] = kf_update_iekf(x,P, z,R, @iekf_observe_model, @iekf_jacobian_model, 10);
    otherwise
        error('Invalid choice of KF update')
    end
end


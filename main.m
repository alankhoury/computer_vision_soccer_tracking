%% Main Script
% Last Edited 16/09/2014 by Michael Holmes

function main()
% Clear workspace
close all
clear
clc
debugFlag = 1;

% File definitions for video source
vidDir = 'test_videos\';
vidFilename = 'goal1.mp4';

% Load in raw video
rawVidObj = loadVideo([vidDir, vidFilename]);




% Prompt user for target region time stamps in <hh:mm:ss>
[startFrame, endFrame] = getVidBounds(rawVidObj);

% Segment Target Video Region Into Scenes
sceneStep = 5;
sceneWindow = 7;
meanThresh = 0.75;

% sceneIndex = detectScenes(rawVidObj, startFrame, endFrame, sceneWindow, sceneStep, meanThresh, debugFlag);

sceneIndex = load('rawSceneSplit.mat');
sceneIndex = sceneIndex.sceneOut;

% Refine scenes by rejecting short durations and linking scenes
minTime = 5;                % Time in seconds
refinedVid = refineScenes(rawVidObj,sceneIndex, minTime,debugFlag);

end

%% Reader Script
% Last Edited 16/09/2014 by Michael Holmes

function vidObj = loadVideo(filename)
% Load raw file
disp('Loading in raw video from filespace, this may take a couple of minutes.');
vidObj = VideoReader(filename);

% Perform error checking
if vidObj.BitsPerPixel < 24
    error('System cannot operate on monochrome video.');
end
disp('Video loaded to filespace.');
disp('--------------------------');
fprintf('Title: %s\nHeight: %d\nWidth: %d\nFrame Rate: %f\nFrame Count: %d\nDuration: %.1f seconds\n',vidObj.Name,vidObj.Height,vidObj.Width,vidObj.FrameRate,vidObj.NumberOfFrames,vidObj.Duration);
disp('--------------------------');
return;
end

function [startFrame, endFrame] = getVidBounds(vidObj)
startFrame = 0;
endFrame = 0;

% DEBUG CODE %
% startFrame = 1;
% % startFrame = 500;
% endFrame = 2758;
% 
% return;
% ---------- %
while startFrame == 0
    % Start = 1s
    startTime = input('Please enter starting timestamp (integers) for analysis <hh:mm:ss>: ','s');
    startFrame = decodeTime(startTime,vidObj);
end
while endFrame == 0
    % End = 1min 50s
    endTime = input('Please enter finishing timestamp (integers) for analysis <hh:mm:ss>: ','s');
    endFrame = decodeTime(endTime,vidObj);
    if endFrame ~= 0 && endFrame < startFrame
        disp('Finishing timestamp cannot be less than the starting timestamp, please re-enter.');
        endFrame = 0;
    end
end
disp('--------------------------');
return;
end

function frame = decodeTime(timeString,vidObj)

% Extract individual hours, minutes, seconds to individual variables
time = sscanf(timeString,'%d:%d:%d',[1,3]);

% Isolate varibles from video object
frameCount = vidObj.NumberOfFrames;
fps = vidObj.FrameRate;

% Error check input for negatives, min & sec > 60
if numel(time) ~= 3 || ~isempty(find(sign(time)<0)) || time(2) > 60 || time(3) > 60
    frame = 0;
    disp('Incorrect format or bounding on input, please re-enter.');
    return;
end

timeSec = time(1)*60*60 + time(2)*60 + time(3);

frame = floor(fps*timeSec);
if frame == 0
    frame = 1;
end
if frame > frameCount || frame < 1
    frame = 0;
    disp('Given timestamp out of given video time bounds, please re-enter.');
    return;
end
return;
end

%% Frame Analysis Script
% Last edited 17/09/2014 by Michael Holmes

% ----------------------------------------------------------------------- %
% The detectScenes function segments the target video region into different
% scenes (defined as changing of camera) by using SURF.
%
% Inputs:   vidObj - Video Object Output from VideoReader function
%           start  - Starting frame of the target region (1x1)
%           finish - Final frame of the target region (1x1)
%           window - Odd number of frames to compare frames over
%           step   - Amount to increment frames by, have less than window
%                    overlapping frames.
%
% Outputs:  sceneOut - (nx2) Array for each frame in the target region,
%                       with its associated scene in the second column.
% ----------------------------------------------------------------------- %
function sceneOut = detectScenes(vidObj, start, finish, window, step, meanThresh,debugFlag)
disp('Commencing raw scene detection.');
fprintf('--------------------------------');
if mod(window,2) == 0
    error('Scene detection window must be odd numbered.');
end
halfWin = floor(window/2);
sceneOut = (start:1:finish)';
sceneOut(:,2) = NaN;

sceneCount = 1;

% For a sliding window sample , check for scene change from
% current reference frame, if timed out, grab new reference.
histCurr = imhist(rgb2gray(read(vidObj,start)));
histCurr = histCurr/max(histCurr);
histMat = zeros(256,window);
meanCurr = NaN;

for frameCount = (start+halfWin):step:(finish-halfWin)
    % Extract histograms for comparison
    for i = -halfWin:halfWin
        histMat(:,i+halfWin+1) = imhist(rgb2gray(read(vidObj,frameCount+i)));
    end
    histMax = repmat(max(histMat),256,1);
    histMat = histMat./histMax;
    matches = zeros(1,window);
    for i = 1:window
       matches(i) = pdist2(histCurr',histMat(:,i)'); 
    end
    
    % Histogram Testing
    if debugFlag
        figure(1);
        clf;
        for i = -halfWin:halfWin
            im = rgb2gray(read(vidObj,frameCount+i));
            subplot(window,1,halfWin+i+1);
            imshow(im);
        end
        disp(matches);
    else
        percDone = floor((frameCount-start)*100/(finish-start));
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
        fprintf('Scene detection completion: %03d%%',percDone);
    end
    % Compare prevous frame mean to each new candidate frame set (<window> frames) and average metrics
    newMean = mean(matches);
    if ~isnan(meanCurr) && ((newMean <= meanCurr - meanThresh) || (newMean >= meanCurr + meanThresh))
        % If different scene, find which frame was the cuplrit (first one
        % to change)
        targFrame = 0;
        for i = 1:window
            if (matches(i) <= meanCurr - meanThresh) || (matches(i) >= meanCurr + meanThresh)
                targFrame = i;
                %Update new frames to new scene
                sceneOut((frameCount-start-halfWin+targFrame):(frameCount-start+halfWin+1),2) = (sceneCount+1)*ones(window+1-i,1);
                %Set frames before target to previous scene
                if targFrame ~= 1
                    sceneOut((frameCount-start-halfWin+1):(frameCount-start-halfWin-1+targFrame),2) = sceneCount*ones(-1+i,1);
                end
                % Update new reference histogram/mean to new scene frames
                histCurr = histMat(:,window);
                meanCurr = 0.5;
                break;
            end
        end
        sceneCount = sceneCount + 1; 
        continue;
    end 
    sceneOut((frameCount-start-halfWin+1):(frameCount-start+halfWin+1),2) = sceneCount*ones(window,1);
    meanCurr = newMean;
    histCurr = histMat(:,halfWin);
    
end
sceneOut(frameCount-start+halfWin+1:finish-start+1,2) = sceneCount;
if debugFlag
    save('rawSceneSplit.mat','sceneOut');
end
fprintf('\nFound %d potential scenes.\n',sceneCount);
disp('--------------------------');
return;
end

function sceneOut = refineScenes(vidObj,rawScenes,timeThresh,debugFlag)
    disp('Commencing scene refinement.');
    % Determine threshold in frames
    thresh = round(timeThresh*vidObj.FrameRate);
    % Set function parameters
    sceneSampleCoef = 0.1;
    sceneSampleThresh = 0.75;
    imSampleCoef = 0.25;
    imSampleThresh = 0.5;
    greenThresh = [0.21,0.28];
    % Segment raw array into individual scenes, if scene is above
    % time threshold, allow through first pass.
    endScene = rawScenes(end,2);
    sceneCount = 1;
    disp('Rejecting scene fragments.');
    for i = 1:endScene
        currIdx = find(rawScenes(:,2) == i);
        if (numel(currIdx) >= thresh)
            sceneFilt1(sceneCount,:) = [sceneCount,rawScenes(currIdx(1),1),rawScenes(currIdx(end),1)];
            sceneCount = sceneCount + 1;
        end
    end
    fprintf('%d scenes rejected.\n',endScene-sceneCount+1);
    % Uniformly sample a portion of the scene, check for adequate
    % 'greenness'
    disp('Rejecting scenes with inadequate amount of green.');
    endScene = sceneFilt1(end,1);
    sceneCount = 1;
    for i = 1:endScene
        fprintf('Scene %d/%d:     ',i,endScene);
        sceneSize = sceneFilt1(i,3)-sceneFilt1(i,2);
        sceneSampleSize = round(sceneSampleCoef*sceneSize);
        sceneSamples = linspace(sceneFilt1(i,2),sceneFilt1(i,3),sceneSampleSize);
        % For each sample, randomly sample the image for pixels, convert to 
        % HSV and check the percentage that are close to green.
        scenePass = 0;
        for j = 1:length(sceneSamples)
            scenePerc = round(j/length(sceneSamples)*100);
            fprintf('\b\b\b\b');
            fprintf('%3d%%',scenePerc);
            image = read(vidObj,sceneSamples(j));
            %Convert to HSV and reshape for sampling
            image = rgb2hsv(image);
            image = reshape(image,[vidObj.Height*vidObj.Width,3]);
            % Generate random sample
            imageSamples = randi(vidObj.Height*vidObj.Width,[1,imSampleCoef*vidObj.Height*vidObj.Width]);
            image = image(imageSamples,:);
            % Isolate Hue
            image = image(:,1);
            goodIdx = find(image >= greenThresh(1) & image <= greenThresh(2));
            if (length(goodIdx)/length(imageSamples) >= imSampleThresh)
                scenePass = scenePass + 1;
            end
        end
        if (scenePass/sceneSampleSize >= sceneSampleThresh)
            sceneOut(sceneCount,:) = [sceneCount, sceneFilt1(i,2),sceneFilt1(i,3)];
            sceneCount = sceneCount+1;
        end
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
    end
    fprintf('%d scenes rejected.\n',endScene-sceneCount+1);
    % Debug to show output
    if debugFlag
        figure();
        for i = 1:sceneOut(end,1)
            frame = sceneOut(i,2);
            while (frame ~= sceneOut(i,3))
                imshow(read(vidObj,frame));
                frame = frame + 1;
            end
        end
    end
    test = 1;
return;
end
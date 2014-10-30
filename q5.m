%% AMME4710 Tutorial 2 Q5 - Basic Image Segmentation in RGB Vector Space
% Coded 18/08/2014

function output = q5()
    % Clear Workspace

    
    % Script Parameters
    method = 'mahalanobis';
    D0 = 0.3;
    
    % Read in image
     rgbInputImage = imread('justField1.png');
    R = rgbInputImage(:,:,1);
    G = rgbInputImage(:,:,2);
    B = rgbInputImage(:,:,3);
    
    % Generate interactive target region mask
    mask = roipoly(rgbInputImage);
    targetR = immultiply(mask,R);
    targetG = immultiply(mask,G);
    targetB = immultiply(mask,B);
    figure(2);
    target = cat(3,targetR,targetG,targetB);
    imshow(target);
    title('Mask');
    
    maskR = 255*im2double(R(mask));
    maskG = 255*im2double(G(mask));
    maskB = 255*im2double(B(mask));
    n = numel(maskR);
    
    avgRGB = [mean(maskR);mean(maskG);mean(maskB)];
    reshapedRGB = [reshape(maskR,1,n);reshape(maskG,1,n);reshape(maskB,1,n)]';
    covMatrix = cov(reshapedRGB);
    
    if strcmp(method,'euclidean')
        S = colourseg(method,rgbInputImage,D0,avgRGB);
    end
    if strcmp(method,'mahalanobis')
        S = colourseg(method,rgbInputImage,D0,avgRGB,covMatrix);
        S = imfill(S,'holes');
    end
%     figure(1);
%     subplot(2,1,1);
%     imshow(image1);
%     subplot(2,1,2);
%     imshow(S);
output = S;
end

function S = colourseg(varargin)
    
%% Input Validation
% Method
if ~strcmp(varargin(1),'euclidean') && ~strcmp(varargin(1),'mahalanobis');
    error('Bad method.');
end
% Minimum Arguments
if nargin < 4
    error('Not enough input arguments.');
end
% Image test for 3 layers
foo = 0;
foo = size(varargin{2},3);
if foo ~= 3
    error('Not an RGB image.');
end
% Check DO for number
if ~isnumeric(varargin{3})
    error('Distance threshold is not a number.');
end
% Check 2 parameters for Mahalanobis
if strcmp(varargin(1),'mahalanobis') && (nargin ~= 5 || numel(varargin{5}) ~= 9)
    error('Incorrect parameter input for mahalanobis method.');                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
end
% Check a for format
if numel(varargin{4}) ~= 3 || size(varargin{4},1) ~= 3
    error('Average column ''a'' not proper format.');
end
%% Segment Image Depending on Method
rgb = 255*im2double(varargin{2});
a = varargin{4};
if nargin == 5
   c = varargin{5}; 
end
D0 = varargin{3};
n = numel(rgb(:,:,1));
[height,width] = size(rgb(:,:,1));
distance = zeros(height,width);

% For each pixel
if strcmp(varargin(1),'euclidean');
    for i = 1:height
        for j = 1:width
            z = [rgb(i,j,1);rgb(i,j,2);rgb(i,j,3)];
            distance(i,j) = ((z - a)'*(z - a)).^(0.5);
        end
    end
    [ind] = find(distance <= D0);
else % Mahalanobis
    variances = diag(c);
    stdDev = sqrt(variances(1));
    for i = 1:height
        for j = 1:width
            z = [rgb(i,j,1);rgb(i,j,2);rgb(i,j,3)];
            distance(i,j) = ((z - a)'*inv(c)*(z - a)).^(0.5);
        end
    end
    [ind] = find(distance <= D0*stdDev);
end

S = zeros(size(rgb(:,:,1)));
S(ind) = 1;
S = im2bw(S);
% imwrite(S,'yoyoyo.png');
return;
end
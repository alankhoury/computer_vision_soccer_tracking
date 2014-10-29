function I = colorseg ( varargin )
%COLORSEG Performs segmentation of a color image.
% s = COLORSEG( 'EUCLIDEAN' , F, T, M) performs segmentation of color
% image F using a Euclidean measure of similarity. M is a 1-by-3
% vector representing the average color used for segmentation (this
% is the center of the sphere in Fig. 6.26 of DIPUM). T is the
% threshold against which the distances are compared. %
% s = COLORSEG( 'MAHALANOBIS' , F, T, M, C) performs segmentation of
% color image F using the Mahalanobis distance as a measure of
% similarity. c is the 3-by-3 covariance matrix of the sample color
% vectors of the class of interest. See function covmatrix for the
% computation of C and M . %
% S is the segmented image (a binary matrix) in which Os denote the
% background .
% Preliminaries.
% Recall that varargin is a cell array.


f = varargin{2};
if (ndims(f) ~= 3) || (size(f, 3) ~= 3)
error('Input image must be RGB.');
end

M = size(f,1);
N = size(f,2);

%Convert f to vector format using function imstack2vectors.

f = imstack2vectors(f);
f = double(f);

% Initialize I as a column vector. It will be reshaped later into an image.

I = zeroes(M*N, 1);
T = varargin{3};
m = varargin{4};
m = m(:);

if length(varargin) == 4
    method = 'euclidean';
elseif length(varargin) == 5
    method = 'mahalanobis'
else
    error('Wrong number of inputs');
    
end


switch method
    case 'euclidean'
        p = length(f);
        D = sqrt(sum(abs(f - repmat(m, p, 1)).^2,2));
    case 'mahalanobis'
        C = varargin{5} ;
        D = mahalanobis(f, C, m) ;
end


J = find(D <= T);

I(J) = 1;

I = reshape(I,M,N);



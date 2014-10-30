function S = detectYellowPlayers(a)
% TODO check that image is an RGB color image
[M, N, O] = size(a);
load('section.mat');
[P, Q, R] = size(section);

I = reshape(section,P*Q,[]); %rearranges the color pixels in g as rows of I
load('idx.mat');
I = double(I(idx,1:3));


[C,m] = covmatrix(I);
d = diag(C);
sd = sqrt(d);
Length = size(I,1);

%compute an estimate of m
mean = sum(I,1)/Length;
I = I - mean(ones(Length,1),:); % Subtract the mean from each row of X
Covariance = (I'*I)/(Length-1);
sigma = sqrt(diag(Covariance));
sd = ceil(sigma(3,1));


S = colorseg('euclidean',a,6*sd,mean,m);
S = im2bw(S);
% imshow(S);
% title('black and white image of players using color seg')
end
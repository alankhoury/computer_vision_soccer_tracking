%%% this function inputs an image and a cluster number and outputs an image
%%% with players extracted from the grass
function [segmented_im] = color_seg_graph_cut(image_a, k)

img = im2double(image_a);
%figure, imagesc(img) ; axis image ;  axis off ; title('original frame');

[ny,nx,nc] = size(img);
imgc = applycform( img, makecform('srgb2lab') );
%figure, imshow(imgc(:,:,1:3));
imgd = reshape( imgc(:,:,2:3), ny*nx, 2 ); 
 imgd(:,1) = imgd(:,1)/max(imgd(:,1));   
 imgd(:,2) = imgd(:,2)/max(imgd(:,2));


% We ask the k-means algorithm for k clusters
% to capture the variability of the background. 

[cluster_idx,cluster_center] = kmeans(imgd,k);

kmlabels = reshape( cluster_idx, ny, nx );
%figure, imagesc(kmlabels) ; axis image ;  axis off; title('imagesc(kmlabels)')

      

if exist('GraphCut')~=2 || exist('GraphCutMex')~=3 || ...
      exist('GraphCutConstr')~=3 ,
  disp('ERROR: It appears that the GraphCut Matlab wrapper is not installed.');
  disp('Please install it from ') ;
  disp('         http://www.wisdom.weizmann.ac.il/~bagon/matlab.html') ;
  disp('to directory ../matlab_code/graphcut.') ;
  error([ 'GraphCut wrapper not installed.'])
end ;

% For each class, the data term Dc measures the distance of
% each pixel value to the class prototype. For simplicity, standard
% Euclidean distance is used. Mahalanobis distance (weighted by class
% covariances) might improve the results in some cases.  Note that the
% image intensity values are in the [0,1] interval, which provides
% normalization.  

Dc = zeros( ny, nx, k );
for i = 1:k
  dif = imgd - repmat( cluster_center(i,:), ny*nx, 1 );
  Dc(:,:,i) = reshape( sum(dif.^2,2), ny, nx ); %squared Euclidean distance
end

% The smoothness term Sc(i,j) is a matrix of costs associated
% with neighboring pixels having values i, j. We define the cost to
% be zero if i=j and a constant (2) otherwise. Increasing this
% constant strengthens the neighborhood constraints more and makes the
% segments larger (and vice versa).  
% example: Sc = 2 * ( ones(k)-eye(k) );

Sc = 2 *(ones(k) - eye(k));

% The graph cut problem is initialized by calling
% GraphCut('open',...) which returns a handle.
% GraphCut('expand',handle) performs the actual optimization and
% returns the labeling l (note that the class labels start with
% 0, unlike for kmeans). The optimization takes only a few
% seconds, depending on the parameter setting and image size. Finally,
% GraphCut('close') takes care of releasing the memory.  The
% segmentation results can be seen in
% Figure ??c,d. Note that while the segmentation
% result is not perfect, it is very good for a completely unsupervised
% algorithm. The algorithm successfully fills in the artifacts present
% in the k-means segmentation.  

gch=GraphCut( 'open', Dc, Sc ); % ,exp(-5*Vc),exp(-5*Hc));
[gch gclabels]= GraphCut('expand',gch);
gch = GraphCut('close', gch);

%figure, imagesc(gclabels) ; axis image ; axis off ;  title('2 cluster image of field and not field');
%figure, imshow(gclabels) ; title('gclabels')

yoyo = mat2bw(gclabels);

%figure,imshow(yoyo) ; title('yoyo')

% Draw a boundary separating the main class from the rest
label=gclabels(200,100) ; %look for the label coordinate corresponding to the main class (e.g. the rhino)
lb=(gclabels==label);
lb=imdilate(lb,strel('disk',1))-lb ; 

%figure, image(img) ; axis image ; axis off ; hold on ;
%contour(lb,[1 1],'r','LineWidth',2) ; hold off ; %


%
% The data and smoothness terms by themselves provide a good
% segmentation (Figure ??b,e). However, the
% results can be further improved if edge information is also taken
% into account, to encourage pixel label changes across edges and
% discourage them otherwise. We obtain the edge information (separately
% for horizontal and vertical directions) by applying a smoothed Sobel
% filter. We take a maximum over all three color channels and apply an
% exponential transformation on the result. The horizontal and vertical
% costs are then passed to GraphCut('open') as additional
% parameters.

g  = fspecial( 'gauss', [29 29], 2 );
dy = fspecial( 'sobel' );
vf = conv2( g, dy, 'valid' );

Vc = zeros( ny, nx );
Hc = Vc;

for b = 1:nc
  Vc = max( Vc, abs(imfilter(img(:,:,b), vf , 'symmetric')) );
  Hc = max( Hc, abs(imfilter(img(:,:,b), vf', 'symmetric')) );
end

gch = GraphCut( 'open', Dc, 5*Sc,exp(-10*Vc), exp(-10*Hc) );
[gch gclabels] = GraphCut( 'expand', gch );
gch = GraphCut( 'close', gch );

%figure, imagesc(gclabels) ; axis image ; axis off

lb=(gclabels==label) ;
lb=imdilate(lb,strel('disk',1))-lb ; 

figure, image(img) ; axis image ; axis off ; hold on ;
contour(lb,[1 1],'r','LineWidth',2) ; hold off ; 


% Results are shown in Figure ??. Note that the
% edge information  improves the segmentation of the horn and of the
% legs of the animal slightly.
% 
% Graph cut segmentation is a very versatile and powerful segmentation
% tool. Its main advantage is the global optimality of the results
% together with a reasonable speed. However, some experimentation with
% cost terms appropriate for a particular task is usually required.

% FOR each pixel
    % if equal to 1 leave alone
    % if equal to false change to black 
        %
%         
%     for each pixel in original image
%         if pixel value in boolean array is 1 change pixel value in original image to zero
        
% [nny, nnx, nc] = size(gclabels);
% original = img;
% 
% if (ny == nny && nnx == nx)
%     for i = 1:1:ny
%         for j = 1:1:nx
%             if yoyo(i,j)== 1
%                 original(i,j,1) = 0;
%                 original(i,j,2) = 0;
%                 original(i,j,3) = 0;
%             end
%         end
%     end
% end
% 
% figure, imshow(original); title('audience removed');
% 
% 



end
function S = colorseg(method, f, D0, a, C)
%%% parameters = a if method = euclidean, a is the "average" colour to
%%% segement
%%% parameters = C if method = mahalanobis, C is co variance matrix
%%% output S is a binary image where 1s in the location that passed the
%%% test, 0s where the test fails
%%% f is the image to be segmented 
%%% D0 is the threshold distance

[M, N, O] = size(f);
f = double(f);

S = zeros(M,N,O);

a1 = ones(M,N)*a(1,1);
a2 = ones(M,N)*a(1,2);
a3 = ones(M,N)*a(1,3);
amat = cat(3,a1,a2,a3);
%amat = im2uint8(amat);
mulM = imsubtract(f,amat);


if strcmp(method,'euclidean')
   for x = 1:M
       for y = 1:N
              result = (mulM(x,y,1))^2;
              result = (mulM(x,y,2)^2)+result;
              result = sqrt((mulM(x,y,3)^2)+result);
              if result <= D0
                  S(x,y,:) = 1;
              end
                          
       end
   end
   
elseif strcmp(method,'mahalanobis')
    
    
end
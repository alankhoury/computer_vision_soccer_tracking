        A = 10*ones(100,100);
        A(2:4,2:4) = 22;    % maxima 12 higher than surrounding pixels
        A(30:40,30:40) = 33;    % maxima 23 higher than surrounding pixels
        A(50:60,50:60) = -22;

        regmax = imregionalmax(A);
        figure; imshow(regmax);
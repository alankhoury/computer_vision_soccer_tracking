function output = rgb2hsi2(image)

image = double(image);
fR = image(:,:,1);
fG = image(:,:,2);
fB = image(:,:,3);

[M N O] = size(image);

%%
%%
%for x = 1:M
    %for y = 1:N
        %top = (1/2)*((fR(x,y) - fB(x,y))+(fR(x,y)-fB(x,y)));
        %bottom = ((fR(x,y)-1*fG(x,y))^2+(fR(x,y)-fB(x,y))*(fG(x,y)-fB(x,y)))^(0.5);
        %theta = acos(top./(bottom + eps));
        
        %if(fR(x,y) <= fG(x,y))
            %hue(x,y) = theta;
        %else
            %hue(x,y) = 2*pi - theta;
        %end
        
        %hue(x,y) = hue(x,y)/(2*pi);
        
        %top1 = min(fR(x,y),min(fG(x,y),fB(x,y)));
        %bottom1 = fR(x,y) + fG(x,y) + fB(x,y);
        %sat(x,y) = 1 - 3*(top1/(bottom1+eps));
        
        %int(x,y) = (1/3)*bottom1;
    %end
%end 
%%

top = 0.5.*((fR - fG)+(fR - fB));
bottom = sqrt((fR - fG).^2 + (fR - fB).*(fG - fB));
theta = acos(top./(bottom + eps));

for x = 1:M
    for y = 1:N
        if(fB(x,y) <= fG(x,y))
            hue(x,y) = theta(x,y);
        else
            hue(x,y) = 2*pi - theta(x,y);
        end
        
        hue(x,y) = hue(x,y)/(2*pi);
        
        top1 = min(fR(x,y),min(fG(x,y),fB(x,y)));
        bottom1 = fR(x,y) + fG(x,y) + fB(x,y);
        
        if hue(x,y) == 0
            sat(x,y) = 0;
        else        
        sat(x,y) = 1 - 3*(top1/(bottom1+eps));
        end
        
        int(x,y) = (1/3)*bottom1;
        
        
        
    end
end



output = cat(3,hue,sat,int);

output = uint8(output);

function [ Error ] = errormetrics( M, type, removezeros )
%ERRORMETRICS Computes a variety of error metrics for image stack. 
%   [ Error ] = errormetrics( M, type, removezeros ) M is the
%   image stack, 'type' specifies which type of error you wish to compute.
%   Error is an array of size [size(M,3)-1]. Error(i) returns the error
%   between images i and i+1 in stack. removezeros indicates if
%   you want to remove the zeros before calculating error.
%
%   Options: 
%   'psnr': Signal-to-Noise Ratio (PSNR)
%   'mse': Mean-Squared Error (MSE)
%   'sse': Sum-Squared Error (SSE)
%   'pxdiff': Pixel intensity difference

zerotable = NaN(size(M));
zerotable(:,:,1) = M(:,:,1) == 0;
Error = NaN(size(M,3)-1,1);
switch lower(type)
    case 'psnr'
        for i=1:size(M,3)-1
            if removezeros
                zerotable(:,:,i+1) = M(:,:,i+1) == 0;
                zeroelements = zerotable(:,:,i) | zerotable(:,:,i+1);
                i1 = M(:,:,i);
                i2 = M(:,:,i+1);
                i1(zeroelements) = 0;
                i2(zeroelements) = 0;
                Error(i) = psnr(i1, i2);
            else
                Error(i) = psnr(M(:,:,i), M(:,:,i+1));
            end
        end
    case 'mse'
        for i=1:size(M,3)-1
            if removezeros
                zerotable(:,:,i+1) = M(:,:,i+1) == 0;
                zeroelements = zerotable(:,:,i) | zerotable(:,:,i+1);
                i1 = M(:,:,i);
                i2 = M(:,:,i+1);
                i1(zeroelements) = 0;
                i2(zeroelements) = 0;
                Error(i) = mean(mean((i1 - i2).^2));
            else
                Error(i) = mean(mean((M(:,:,i) - M(:,:,i+1)).^2));
            end
        end
    case 'sse'
        for i=1:size(M,3)-1
            if removezeros
                zerotable(:,:,i+1) = M(:,:,i+1) == 0;
                zeroelements = zerotable(:,:,i) | zerotable(:,:,i+1);
                i1 = M(:,:,i);
                i2 = M(:,:,i+1);
                i1(zeroelements) = 0;
                i2(zeroelements) = 0;
                Error(i) = sum(sum((i1 - i2).^2));
            else
                Error(i) = sum(sum((M(:,:,i) - M(:,:,i+1)).^2));
            end
        end
    case 'pxdiff'
        for i=1:size(M,3)-1
            if removezeros
                zerotable(:,:,i+1) = M(:,:,i+1) == 0;
                zeroelements = zerotable(:,:,i) | zerotable(:,:,i+1);
                i1 = M(:,:,i);
                i2 = M(:,:,i+1);
                i1(zeroelements) = 0;
                i2(zeroelements) = 0;
                Error(i) = sum(sum(abs(i1 - i2)));
            else
                Error(i) = sum(sum(abs(M(:,:,i) - M(:,:,i+1))));
            end
        end
end

end

% zerotable = NaN(size(M));
% zerotable(:,:,1) = M(:,:,1) == 0;
%     case 'psnr'
%         for i=1:size(M,3)-1
%             zerotable(:,:,i+1) = M(:,:,i+1) == 0;
%             zeroelements = zerotable(:,:,i) | zerotable(:,:,i+1);
%             i1 = M(:,:,i);
%             i2 = M(:,:,i+1);
%             i1(zeroelements) = 0;
%             i2(zeroelements) = 0;
%             Error(i) = psnr(i1, i2);
%         end
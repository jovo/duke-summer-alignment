function [ Error ] = errormetrics( M, type )
%ERRORMETRICS Computes a variety of error metrics for image stack. 
%   [ Error ] = errormetrics( M, type ) M is the
%   image stack, 'type' specifies which type of error you wish to compute.
%   Error is an array of size [size(M,3)-1]. Error(i) returns the error
%   between images i and i+1 in stack.
%   Options: 
%   'psnr': Signal-to-Noise Ratio (PSNR)
%   'mse': Mean-Squared Error (MSE)
%   'sse': Sum-Squared Error (SSE)
%   'pxdiff': Pixel intensity difference

M = double(M);
Error = NaN(size(M,3)-1,1);
switch lower(type)
    case 'psnr'
        for i=1:size(M,3)-1
            i1 = M(:,:,i);
            i2 = M(:,:,i+1);
            imgOR = i1 ~= 0 & i2 ~= 0;
            zeroE =  i1 == 0 | i2 == 0;
            if sum(sum(~zeroE)) < imgOR/2;
                warning('majority of elements are zeros');
            end
            i1(zeroE) = 0;
            i2(zeroE) = 0;
            Error(i) = psnr(i1, i2);
        end
    case 'mse'
        for i=1:size(M,3)-1
            i1 = M(:,:,i);
            i2 = M(:,:,i+1);
            imgOR = i1 ~= 0 & i2 ~= 0;
            zeroE =  i1 == 0 | i2 == 0;
            if sum(sum(~zeroE)) < imgOR/2;
                warning('majority of elements are zeros');
            end
            i1(zeroE) = 0;
            i2(zeroE) = 0;
            Error(i) = mean(mean((i1 - i2).^2));
        end
    case 'sse'
        for i=1:size(M,3)-1
            i1 = M(:,:,i);
            i2 = M(:,:,i+1);
            imgOR = i1 ~= 0 & i2 ~= 0;
            zeroE =  i1 == 0 | i2 == 0;
            if sum(sum(~zeroE)) < imgOR/2;
                warning('majority of elements are zeros');
            end
            i1(zeroE) = 0;
            i2(zeroE) = 0;
            Error(i) = sum(sum((i1 - i2).^2));
        end
    case 'pxdiff'
        for i=1:size(M,3)-1
            i1 = M(:,:,i);
            i2 = M(:,:,i+1);
            imgOR = i1 ~= 0 & i2 ~= 0;
            zeroE =  i1 == 0 | i2 == 0;
            if sum(sum(~zeroE)) < imgOR/2;
                warning('majority of elements are zeros');
            end
            i1(zeroE) = 0;
            i2(zeroE) = 0;
            Error(i) = mean(mean(abs(i1 - i2)));
        end
end

end

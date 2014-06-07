function [ Error, flag ] = errormetrics( M, type, varargin )
%ERRORMETRICS Computes a variety of error metrics for image stack. 
%   [ Error ] = errormetrics( M, type )
%   [ Error ] = errormetrics( M, type, minimum )
%   [ Error ] = errormetrics( M, type, minimum, warn, maxval ) M is the
%   image stack, 'type' specifies which type of error you wish to compute.
%   Error is an array of size [size(M,3)-1]. Error(i) returns the error
%   between images i and i+1 in stack. minimum is the smallest percentage
%   of nonzero space allowed. default is 0. If set to 0, then that
%   essentially disables this check because it allows for the union of two
%   images to be nil. if less than minimum, a flag and warning is set. if
%   the maxval parameter is entered, then the error will be set to maxval.
%   Otherwise, the error will be calculated normally.
%   Options: 
%   'psnr': Signal-to-Noise Ratio (PSNR)
%   'mse': Mean-Squared Error (MSE)
%   'sse': Sum-Squared Error (SSE)
%   'pxdiff': Pixel intensity difference

narginchk(2,5);
minimum = 0;
maxval = NaN;
warn = 0;
if nargin > 2
	minimum = varargin{1};
end
if nargin > 3
    warn = strcmpi('warn', varargin{2});
end
if nargin > 4
    maxval = varargin{3};
end

M = double(M);
Error = NaN(size(M,3)-1,1);
switch lower(type)
    case 'psnr'
        flag = zeros(1,size(M,3)-1);
        for i=1:size(M,3)-1
            i1 = M(:,:,i);
            i2 = M(:,:,i+1);
            imgOR = i1 ~= 0 | i2 ~= 0;
            zeroE =  i1 == 0 | i2 == 0;
            if sum(sum(~zeroE))/sum(sum(imgOR)) < minimum;
                flag(1,i) = 1;
                if warn
                    warning('majority of elements are zeros');
                end
            end
            if ~isnan(maxval) && flag(1,i)
                Error(i) = maxval;
            else
                i1(zeroE) = 0;
                i2(zeroE) = 0;
                Error(i) = psnr(i1, i2);
            end
        end
    case 'mse'
        flag = zeros(1,size(M,3)-1);
        for i=1:size(M,3)-1
            i1 = M(:,:,i);
            i2 = M(:,:,i+1);
            imgOR = i1 ~= 0 | i2 ~= 0;
            zeroE =  i1 == 0 | i2 == 0;
            if sum(sum(~zeroE))/sum(sum(imgOR)) < minimum;
                flag(1,i) = 1;
                if warn
                    warning('majority of elements are zeros');
                end
            end
            if ~isnan(maxval) && flag(1,i)
                Error(i) = maxval;
            else
                i1(zeroE) = 0;
                i2(zeroE) = 0;
                Error(i) = mean(mean((i1 - i2).^2));
            end
        end
    case 'sse'
        flag = zeros(1,size(M,3)-1);
        for i=1:size(M,3)-1
            i1 = M(:,:,i);
            i2 = M(:,:,i+1);
            imgOR = i1 ~= 0 | i2 ~= 0;
            zeroE =  i1 == 0 | i2 == 0;
            if sum(sum(~zeroE))/sum(sum(imgOR)) < minimum;
                flag(1,i) = 1;
                if warn
                    warning('majority of elements are zeros');
                end
            end
            if ~isnan(maxval) && flag(1,i)
                Error(i) = maxval;
            else
                i1(zeroE) = 0;
                i2(zeroE) = 0;
                Error(i) = sum(sum((i1 - i2).^2));
            end
        end
    case 'pxdiff'
        flag = zeros(1,size(M,3)-1);
        for i=1:size(M,3)-1
            i1 = M(:,:,i);
            i2 = M(:,:,i+1);
            imgOR = i1 ~= 0 | i2 ~= 0;
            zeroE =  i1 == 0 | i2 == 0;
            if sum(sum(~zeroE))/sum(sum(imgOR)) < minimum;
                flag(1,i) = 1;
                if warn
                    warning('majority of elements are zeros');
                end
            end
            if ~isnan(maxval) && flag(1,i)
                Error(i) = maxval;
            else
                i1(zeroE) = 0;
                i2(zeroE) = 0;
                Error(i) = mean(mean(abs(i1 - i2)));
            end
        end
end

end

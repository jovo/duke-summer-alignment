function [ Error, flag, nonzeropercent ] = errormetrics( config, M, maxval )
%ERRORMETRICS Computes a variety of error metrics for image stack. 
%   [ Error, flag, nonzeropercent ] = errormetrics( config, M )
%   [ Error, flag, nonzeropercent ] = errormetrics( config, M, maxval )
%   M is the image stack, config is the struct from configapivars. maxval
%   is the value assigned if there is a problem. One can override maxval by
%   assigning maxval to -1, in which case the error will be computed as
%   usual. Error is the error value, flag is set to true (1) if
%   minnonzeropercent is less than the proportion of nonzero overlap.
%   nonzeropercent is the actual proportion of nonzero overlap.
%   Options: 
%   'psnr': Signal-to-Noise Ratio (PSNR)
%   'mse': Mean-Squared Error (MSE)
%   'pxdiff': Mean Pixel intensity difference

% validate inputs
narginchk(2,3);
if nargin == 2
    maxval = NaN;
end
suppress = config.suppressmessages;
minimum = config.minnonzeropercent;
type = config.errormeasure;

% compute error vector
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
            nonzeropercent = sum(sum(~zeroE))/sum(sum(imgOR));
            if nonzeropercent < minimum;
                flag(1,i) = 1;
                if ~suppress
                    warning('majority of elements are zeros');
                end
            end
            if ~isnan(maxval) && flag(1,i)
                Error(i) = maxval;
            else
                i1(zeroE) = [];
                i2(zeroE) = [];
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
            nonzeropercent = sum(sum(~zeroE))/sum(sum(imgOR));
            if nonzeropercent < minimum;
                flag(1,i) = 1;
                if ~suppress
                    warning('majority of elements are zeros');
                end
            end
            if ~isnan(maxval) && flag(1,i)
                Error(i) = maxval;
            else
                i1(zeroE) = [];
                i2(zeroE) = [];
                Error(i) = mean(mean((i1 - i2).^2));
            end
        end
    case 'pxdiff'
        flag = zeros(1,size(M,3)-1);
        for i=1:size(M,3)-1
            i1 = M(:,:,i);
            i2 = M(:,:,i+1);
            imgOR = i1 ~= 0 | i2 ~= 0;
            zeroE =  i1 == 0 | i2 == 0;
            nonzeropercent = sum(sum(~zeroE))/sum(sum(imgOR));
            if nonzeropercent < minimum;
                flag(1,i) = 1;
                if ~suppress
                    warning('majority of elements are zeros');
                end
            end
            if ~isnan(maxval) && flag(1,i)
                Error(i) = maxval;
            else
                i1(zeroE) = [];
                i2(zeroE) = [];
                Error(i) = mean(mean(abs(i1 - i2)));
            end
        end
end

end

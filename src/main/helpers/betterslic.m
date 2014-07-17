% To run this you need this code on your path: 
% Fast Bilateral Filtering:  http://www.mathworks.com/matlabcentral/fileexchange/36657-fast-bilateral-filter
% VLFeat:  http://www.vlfeat.org/
% Some sort of RAMONVolume, e.g. AC4, called im
% W. Gray Roncal
function [ L, imSeg ] = betterslic( im )
%% Supervoxels require preprocessing
imSeg = zeros(size(im));
imSliceVis = im;
%%
for i = 1:1%size(im,3)
    
    imSlice = im(:,:,i);
    
    %% Bilateral Filtering
    % filter parameters
    sigma1 = 20;
    sigma2 = 20;
    tol    = 0.01;
    
    % make odd
    if (mod(sigma1,2) == 0)
        w  = sigma1 + 1;
    else
        w  = sigma1;
    end
    
    [outImg, param] =  shiftableBF(double(imSlice), sigma1, sigma2, w, tol);
    
    outImg = single(outImg)/255;
    outImg(:,:,2) = outImg(:,:,1);
    outImg(:,:,3) = outImg(:,:,1);
    
    %Ready for SLIC
    temp = vl_slic(outImg, 50, 1);
    
    imSeg(:,:,i) = temp;
    
    temp = imSlice;
    
    [sx,sy]=vl_grad(double(imSeg(:,:,i)), 'type', 'forward');
    s = find(sx | sy);
    temp(s) = 0;
    imSliceVis(:,:,i) = temp;
    
end
 
L = imSliceVis;
count = 0; %Start here to ensure non-zero voxels
for i = 1:size(imSeg,3)
    imSeg(:,:,i) = imSeg(:,:,i) + count+ 1;  %TODO
    count = max(max(imSeg(:,:,i)));
    
end
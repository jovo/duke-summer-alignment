function [ ISAligned, Transforms ] = constructalignment( IStack, Transforms, inverse )
%CONSTRUCTALIGNMENT Transforms image stack as instructed
%   [ IStackAligned ] = constructalignment( IStack, Transforms ) Takes in
%   stack of images, IStack, and a list of Transforms. Performs alignment
%   on all images in IStack.

% validate inputs
narginchk(2,3)

if nargin == 3 && inverse
    
else
    globalT = zeros(size(IStack, 3), 3);
    for i=1:size(IStack, 3)-1
        val = values(Transforms.pairwise, {localindices2key(i, i+1)});
        matrix = val{1};
        params = matrix2params(matrix);
        globalT(i+1,:) = globalT(i,:);
        globalT(i+1,3) = globalT(i+1,3) + params(3);

        prevrotmatrix = params2matrix([0, 0, globalT(i,3)]);
        transmatrix = params2matrix([params(1:2), 0]);
        transparams = matrix2params(prevrotmatrix*transmatrix);
        if transparams(1) > 0
            globalT(i+1,1) = globalT(i+1,1) + transparams(1);
        elseif transparams(1) < 0
            globalT(1:i,1) = globalT(1:i,1) + abs(transparams(1));
        end
        if transparams(2) > 0
            globalT(i+1,2) = globalT(i+1,2) + transparams(2);
        elseif transparams(2) < 0
            globalT(1:i,2) = globalT(1:i,2) + abs(transparams(2));
        end
    end
    globalTransforms = containers.Map;
    globalImages = cell(size(IStack, 3), 1);
    globalImageRef = cell(size(IStack, 3), 1);
    imgsizey = 0;
    imgsizex = 0;
    for i=1:size(globalT, 1)
        curimg = IStack(:,:,i);
        curimgref = imref2d(size(curimg));
        params = globalT(i,:);
        globalTransforms(num2str(i)) = params2matrix(params);
        [img, imref] = imtranslate(curimg, curimgref, -round(size(curimg)/2), 'OutputView', 'full');
        rotmatrix = params2matrix([0, 0, -params(3)]);
        tmatrix = params2matrix([params(1:2), 0]);
        [globalImages{i}, globalImageRef{i}] = imwarp(img, imref, affine2d(rotmatrix*tmatrix));
        if size(globalImages{i},1) > imgsizey
            imgsizey = size(globalImages{i},1);
        end
        if size(globalImages{i},2) > imgsizex
            imgsizex = size(globalImages{i},2);
        end
    end

    ISAligned = NaN(imgsizey*2, imgsizex*2, size(globalT, 1));
    for i=1:size(globalT, 1)
        globalImages{i} = imwarp(globalImages{i}, globalImageRef{i}, ...
            affine2d(eye(3)), 'OutputView', imref2d([imgsizey, imgsizex], ...
            [0.5-imgsizey/2, 0.5+imgsizey], [0.5-imgsizex/2, 0.5+imgsizex]));
        ISAligned(1:size(globalImages{i},1), 1:size(globalImages{i},2), i) = globalImages{i};
    end
    ISAligned(:,isnan(ISAligned(1,:,1)),:) = [];
    ISAligned(isnan(ISAligned(:,1,1)),:,:) = [];

    Transforms.global = globalTransforms;

end

end

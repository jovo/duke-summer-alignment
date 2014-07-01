function [ ISAligned, Transforms ] = constructalignment( IStack, Transforms, inverse )
%CONSTRUCTALIGNMENT Transforms image stack as instructed
%   [ ISAligned, Transforms ] = constructalignment( IStack, Transforms, inverse )
%   Takes in stack of images, IStack, and a list of Transforms. If inverse
%   is false (0), then performs alignment on all images in IStack.
%   Otherwise, unaligns an already aligned stack. Transforms is a structure
%   with important information. The Transforms output has another term
%   (Transforms.global) if used to align image stack.

% validate inputs
narginchk(2,3)

% unaligning image stack. Assumed for Transforms to contain global and size keys
if nargin == 3 && inverse
    imgsize = Transforms.size;
    ISAligned = zeros(imgsize);
    for i=1:size(IStack, 3)
        val = values(Transforms.global, {num2str(i)});
        tform = val{1};
        tparam = matrix2params(tform);
        center = round( [imgsize(1)/2, imgsize(2)/2] );
        newcenter = center + round(tparam(1:2));
        halfsizey = min(size(IStack(:,:,i),1)-newcenter(1), newcenter(1)-1);
        halfsizex = min(size(IStack(:,:,i),2)-newcenter(2), newcenter(2)-1);
        imcropped = IStack(newcenter(1)-halfsizey:newcenter(1)+halfsizey, newcenter(2)-halfsizex:newcenter(2)+halfsizex, i);
        newcenter = [halfsizey, halfsizex]+1;
        imrotated = imrotate(imcropped,-tparam(3));
        sizediff = round((size(imrotated)-size(imcropped))/2);
        newcenter = newcenter + sizediff;
        aligned = imrotated(1+newcenter(1)-ceil(imgsize(1)/2):newcenter(1)+ceil(imgsize(1)/2)-1, 1+newcenter(2)-ceil(imgsize(2)/2):newcenter(2)+ceil(imgsize(2)/2)-1);
        ISAligned(1:size(aligned,1), 1:size(aligned,2), i) = aligned;
    end
% aligns image stack
else
    % if Transforms.global doesn't exist, then computes it. Otherwise,
    % automatically aligns using that information.
    try
        Transforms.global;
    catch
        Transforms.global = [];
    end
    % Transforms.global doesn't exist
    if isempty(Transforms.global)
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
        % saves the global transforms to Transforms.global
        Transforms.global = containers.Map;
        for i=1:size(IStack, 3)
            Transforms.global(num2str(i)) = params2matrix(globalT(i,:));
        end
    end

    % align image stack using Transforms.global
    ISAligned = zeros(size(IStack,1)*2, size(IStack,2)*2, size(IStack, 3));
    for i=1:size(IStack, 3)
        val = values(Transforms.global, {num2str(i)});
        aligned = affinetransform(IStack(:,:,i), zeros(size(IStack(:,:,i))), val{1});
        ISAligned(1:size(aligned,1), 1:size(aligned,2), i) = aligned(:,:,1);
    end

    % save the original image stack size
    Transforms.size = size(IStack);

end

end

function [ IStackAligned ] = constructalignment( IStack, Transforms )
%CONSTRUCTALIGNMENT Transforms image stack as instructed
%   [ IStackAligned ] = constructalignment( IStack, Transforms ) Takes in
%   stack of images, IStack, and a list of Transforms. Performs alignment
%   on all images in IStack.

Ids = 1:size(IStack, 3);

IStackAligned = RLHelper(Ids, IStack);


    % recursive helper that does the work.
    function [ istacknew ] = RLHelper( ids, istack )
    switch size(istack, 3)
        case 0
        case 1
            istacknew = istack;
        otherwise
            med = floor(size(istack,3)/2);
            key = {[int2str(ids(med)), ' ', int2str(ids(med+1))]};
            vals = values(Transforms, key);
            aligned = affinetransform(istack(:,:,1:med),istack(:,:,med+1:end),vals{1});
            a1n = RLHelper(ids(1:med), aligned(:,:,1:med));
            a2n = RLHelper(ids(med+1:end), aligned(:,:,med+1:end));
            ymax = max(size(a1n,1), size(a2n,1));
            xmax = max(size(a1n,2), size(a2n,2));
            a1n = padarray(a1n, [ymax-size(a1n,1), xmax-size(a1n,2), 0], 0, 'post');
            a2n = padarray(a2n, [ymax-size(a2n,1), xmax-size(a2n,2), 0], 0, 'post');
            istacknew = cat(3, a1n, a2n);
    end
    size(istacknew)
    end


% depth = size(IStack,3);
% queue = Queue(depth);
% % initially add each image to Q
% for i=1:depth
%   queue.push({i, IStack(:,:,i), [0,0,1,0]});
% end
% clear IStack;
% while queue.count() > 1
%     queuesize = queue.count();
%     for i=1:2:queuesize
%         N1 = queue.pop();
%         if queuesize == i
%             queue.push(N1);
%         else
%             N2 = queue.pop();
%             keys1 = N1{1};
%             images1 = N1{2};
%             keys2 = N2{1};
%             images2 = N2{2};
%             prevt1 = N1{3};
%             key = {[int2str(keys1(size(images1,3))), ' ', int2str(keys2(1))]};
%             vals = values(Transforms, key);
%             vals = vals{1};
%             % update transforms
%             transforms = zeros(1,4);
%             transforms(1:3) = vals(1:3)-prevt1(1:3);
%             transforms(4) = vals(4)*prevt1(4);
%             % perform transformed images
%             merged = affinetransform(images1, images2, transforms);
%             queue.push({[keys1, keys2], merged, transforms});
%             clear merged;
%         end
%     end
% end
% N = queue.pop();
% IStackAligned = N{2};


end


function [ IStackAligned ] = constructalignment( IStack, Transforms )
%CONSTRUCTALIGNMENT Transforms image stack as instructed
%   [ IStackAligned ] = constructalignment( IStack, Transforms ) Takes in
%   stack of images, IStack, and a list of Transforms. Performs alignment
%   on all images in IStack.

% O(n) time, space complexity.
depth = size(IStack,3);
queue = Queue(depth);
% initially add each image to Q
for i=1:depth
  queue.push(IStack(:,:,i));
end
while queue.count() > 1
    queuesize = queue.count();
    for i=1:2:queuesize
        N1 = queue.pop();
        if queuesize == i
            queue.push(N1);
        else
            N2 = queue.pop();
            if isKey(Transforms, {[int2str(i),' ',int2str(i+1)]})
                vals = values(Transforms, {[int2str(i),' ',int2str(i+1)]});
            else
                vals = values(Transforms, {[int2str(i+1),' ',int2str(i)]});
            end
            vals = vals{1};
            merged = affinetransform(N1, N2, vals);
            queue.push(merged);
        end
    end
end
IStackAligned = queue.pop();
    
%   % recursive implementation... too much memory overhead probably unless 
%   % split into small chunks.
%     function [ N_new ] = roughalignhelper( N )
%         
%     switch size(N, 3)
%         case 0
%         case 1
%             N_new = N;
%         otherwise
%             N1 = roughalignhelper(N(:, :, 1:floor(size(N,3)/2)));
%             N2 = roughalignhelper(N(:, :, ceil(size(N,3)/2):size(N,3)));
%             [~, N_new] = xcorr2imgs(N1(:,:,size(N1,3)), N2(:,:,1), N1, N2); 
%     end
%     
%     end

end


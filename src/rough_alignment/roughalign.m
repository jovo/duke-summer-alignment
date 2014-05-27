function [ M_new ] = roughalign( M )
%ROUGHALIGN Aligns a stack of images.
%   

M_new = roughalignhelper(M);

    % helper method that performs the image alignment with a queue
    % structure. O(n) time, space complexity.
    function [ N_new ] = roughalignhelper( N )
        depth = size(N,3);
        queue = Queue(depth);
        % initially add each image to Q
        for i=1:depth
          queue.push(N(:,:,i));
        end
        while queue.count() > 1
            queuesize = queue.count();
            for i=1:2:queuesize
                N1 = queue.pop();
                if queuesize == i
                    queue.push(N1);
                else
                    N2 = queue.pop();
                    [~, N_merged] = xcorr2imgs(N1(:,:,size(N1,3)), N2(:,:,1), N1, N2); 
                    size(N_merged)
                    queue.push(N_merged);
                end
            end   
        end
        N_new = queue.pop();
    end
        
        
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



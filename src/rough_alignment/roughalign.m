function [ M_new ] = roughalign( M )
%ROUGHALIGN Aligns a stack of images.
%   

M_new = roughalignhelper(M);




    % helper, not recursive
    function [ N_new ] = roughalignhelper( N )
        stack = java.util.Stack;
        
    end
        
        
    % recursive helper
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


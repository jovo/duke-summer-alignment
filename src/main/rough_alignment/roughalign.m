function [ FinalTransforms, M_new ] = roughalign( config, M, align )
%ROUGHALIGN Aligns a stack of images
%   [ FinalTransforms, M_new ] = roughalign( config, M )
%   [ FinalTransforms, M_new ] = roughalign( config, M, align )
%   M is the image stack. If align variable is 'align', M_new returns 
%   the aligned image stack; otherwise M_new is nil. scale indicates 
%   how much the image should be resized during the alignment process. 
%   Primarily used for large images that may take up too much memory. 
%   0.5 < scale < 1 is an appropriate range. 

% validate inputs
narginchk(2,3);
if size(M, 3) < 2
    error('Size of stack must be at least 2');
end
% parse inputs
if nargin == 3 && strcmpi(align, 'align')
    align = 1;
else
    align = 0;
end
scale = config.downsample;

% remove images that are all one color
removed = false(size(M, 3),1);
for i=1:size(M, 3)
    curimage = M(:,:,i);
    if std(double(curimage(:))) == 0
        removed(i) = 1;
    end
end
Mremoved = M(:,:,~removed);

% initialize output variables
M_new = [];
FinalTransforms = struct;
FinalTransforms.pairwise = containers.Map;
FinalTransforms.global = containers.Map;

% if # of valid images (after invalid img removal) < 2, then return
if size(Mremoved, 3) < 2
    return;
end

% resize
Mtemp = imresize(Mremoved, scale);

% compute pairwise transforms
tformstemp  = constructtransforms(config, Mtemp);
pairwiseTransforms = tformstemp;

% undo the initial resizing
if scale ~= 1
	keySet = keys(tformstemp);
	for i=1:length(keySet)
        val = values(tformstemp, keySet(i));
        params = matrix2params(val{1});
        params(1:2) = params(1:2)/scale;
        newmatrix = params2matrix(params);
        pairwiseTransforms(keySet{i}) = newmatrix;
	end
end

% assigns pairwise transforms to FinalTranforms
FinalTransforms.pairwise = pairwiseTransforms;

% aligns the image based on the transforms if required
if align
    % global alignment using piecewise transformation parameters
    [ M_new, FinalTransforms ] = constructalignment(Mremoved, FinalTransforms);
    origIndices = 1:size(M_new,3);
    % add back removed image slices
    if removed(1)
        M_new = cat(3, zeros(size(M_new(:,:,1)), 'uint8'), M_new);
        origIndices = origIndices + 1;
    end
    for i=2:size(M,3)
        if removed(i)
            M_new = cat(3, M_new(:,:,1:i-1), zeros(size(M_new(:,:,i)), 'uint8'), M_new(:,:,i:end));
            origIndices(i:end) = origIndices(i:end)+1;
        end
    end

    % update transform map keys after adding back image slices
    for i=1:length(origIndices)-1
        curLKey = localindices2key(i, i+1);
        curLVal = values(FinalTransforms.pairwise, {curLKey});
        remove(FinalTransforms.pairwise, curLKey);
        FinalTransforms.pairwise(localindices2key(origIndices(i), origIndices(i+1))) = curLVal{1};
    end
    for i=1:length(origIndices)
        curGKey = localindices2key(i, i);
        curGVal = values(FinalTransforms.global, {curGKey});
        remove(FinalTransforms.global, curGKey);
        FinalTransforms.global(localindices2key(origIndices(i), origIndices(i))) = curGVal{1};
    end

     % output error report for both original and aligned stacks if messages
     % are not suppressed.
    if ~config.suppressmessages
        format short g;
        [origE, orig] = errorreport(config, M, 'Original');
        [alignedE, aligned] = errorreport(config, M_new, 'Aligned');
        disp('Error improvement:');
        disp([sprintf('\tIndex\tImprovement\t'), '% Improvement']);
        disp( [(1:size(origE,1))', origE-alignedE, (origE-alignedE)./origE] );
        disp(orig);
        disp(aligned);
    end
end

end

function [ IStackNew, indices ] = folddetection( IStack, rangethres )
%FOLDDETECTION Splits an image into two if there is a fold.
%   Detailed explanation goes here

IStackNew = zeros(size(IStack(:,:,1)));
indices = 0;
StackBinary = im2bw(IStack, 0.5);
d = 10;
for i=1:size(IStack,3)
    [Y,X] = find(StackBinary(:,:,i)==0);
    Indices = [Y,X];
    [m, b, inrangeprop] = ransac(Indices, d);
    if inrangeprop >= rangethres
        M_new = splitimage(IStack(:,:,i), m, b, d);
        IStackNew = cat(3, IStackNew, M_new);
        curindex = size(IStackNew, 3);
        indices = [indices, curindex-2, curindex-1];
    end
end
indices = indices(2:size(indices,2));
IStackNew = IStackNew(:,:,2:size(IStackNew,3));

end

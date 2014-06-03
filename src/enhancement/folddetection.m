function [ IStackNew ] = folddetection( IStack, rangethres )
%FOLDDETECTION Splits an image into two if there is a fold.
%   Detailed explanation goes here

IStackNew = zeros(size(IStack(:,:,1)));
StackBinary = im2bw(IStack, 0.5);
for i=1:size(IStack,3)
    [Y,X] = find(StackBinary(:,:,i)==0);
    Indices = [Y,X];
    [m, b, inrangeprop] = ransac(Indices, 10);
    if inrangeprop >= rangethres
        M_new = splitimage(IStack(:,:,i), m, b);
        IStackNew = cat(3, IStackNew, M_new);
    end
end
IStackNew = IStackNew(:,:,2:size(IStackNew,3));

end


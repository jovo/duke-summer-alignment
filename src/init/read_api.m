function [ cutout ] = read_api
%READ_API Read the API and output the stack of images as a n*n*x matrix.
%   Detailed explanation goes here

xoff = 40000;
yoff = 40000;
zoff = 10;

% Create OCP Interface and set tokens
oo = OCP();
oo.setImageToken('lee14');
% oo.setAnnoToken('bock11_examples');
oo.imageInfo.DATASET.IMAGE_SIZE(1)
oo.setDefaultResolution(1);
q = OCPQuery(eOCPQueryType.imageDense);
% [pf, msg] = q.validate()
q.setCutoutArgs([100 1124]+xoff,...
                [100 1124]+yoff,...
                [100 500]+zoff,...
                1);
% [pf, msg] = q.validate()
cutout = oo.query(q);

end

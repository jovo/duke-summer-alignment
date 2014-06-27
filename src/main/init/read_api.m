function [ cutout ] = read_api(oo, xoff, yoff, zoff, xsize, ysize, zsize, res)
%READ_API Read the API and output the stack of images
%   [ cutout ] = read_api(oo, xoff, yoff, zoff, xsize, ysize, zsize, res)
%   Retrieves data from the API.
% configure settings
oo.setDefaultResolution(res);
q = OCPQuery(eOCPQueryType.imageDense);
% [pf, msg] = q.validate();

% set cutout location
q.setCutoutArgs([0, xsize] + xoff,...
                [0, ysize] + yoff,...
                [0, zsize] + zoff,...
                res);
% [pf, msg] = q.validate();

% query API
cutout = oo.query(q);

end

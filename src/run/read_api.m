function [ cutout ] = read_api(oo, xsize, ysize, zsize, xoff, yoff, zoff, res)
%READ_API Read the API and output the stack of images
%   [ cutout ] = read_api(oo, xsize, ysize, zsize, xoff, yoff, zoff, res)
%   Retrieves data from the API.

% configure settings
oo.setDefaultResolution(res);
q = OCPQuery(eOCPQueryType.imageDense);

% set cutout location
q.setCutoutArgs([0, xsize] + xoff,...
                [0, ysize] + yoff,...
                [0, zsize] + zoff,...
                res);

% query API if passed validation
[ pf, msg ] = q.validate();
if  pf
    cutout = oo.query(q);
else
    disp(msg);
    error('API validation failed');
end

end

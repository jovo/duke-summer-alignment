function [ Transforms ] = alignimagecube ( imgtoken, xsize, ysize, res )
%PROCESSIMAGECUBE Process an entire image stack from API

% initialize global variables. See setup.m for more info.
setup();

% connect to API
oo = OCP();
oo.setImageToken(imgtoken);

% retrieve sizes
imgsizemap = oo.imageInfo.DATASET.IMAGE_SIZE;
imgdepth = oo.imageInfo.DATASET.ZSCALE;

% initialize map to store transforms
Transforms = containers.Map();

% iterate over all possible image cubes
for i=1:length(imgsizemap)

    % size of specific image cube
    curimgsize = imgsizemap(i-1);
    xcount = floor(curimgsize(1)/xsize);
    ycount = floor(curimgsize(2)/ysize);

    % initialize index locations for query
    [xindex, yindex] = meshgrid(1:xcount, 1:ycount);
    xindex = xindex(:)*xsize - xsize;
    yindex = yindex(:)*ysize - ysize;

    % use total depth for each sub-cube
    zsize = imgdepth;
    zoff = 0;

    % iterate over all image sub-cubes
    for j=1:length(xindex)

        % set offsets and sizes
        if xindex(j) == xcount * (xsize-1)  % end slice
            xs = curimgsize(1) - xindex(j);
        else
            xs = xsize;
        end
        if yindex(j) == ycount * (ysize-1)
            ys = curimgsize(2) - yindex(j);
        else
            ys = ysize;
        end
        xoff = xindex(j);
        yoff = yindex(j);

        % query API
        cutout = read_api(oo, xoff, yoff, zoff, xs, ys, zsize, res);

        % calculate transformations for affine global alignment
        [tforms, ~] = roughalign(cutout.data, '', 0.5);

        % update keys to global coordinates
        % format: 'res_xoff_yoff_zoff_xsize_ysize_zsize'
        tformkeys = keys(tforms);
        for k=1:length(tformkeys)
            curkey = tformkeys{k};
            curval = values(tforms, curkey);
            remove(tforms, curkey);
            id = [num2str(res), '_', num2str(xoff), '_', num2str(yoff), '_', ...
                num2str(zoff), '_', num2str(xs), '_', num2str(ys), '_', curkey];
            tforms(id) = curval;
        end

        % update Transforms with latest transform values
        Transforms = [Transforms; tforms];

    end

end

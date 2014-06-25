function [ data ] = constructimgcubealignment( ...
                                                    Transforms, ...
                                                    xtotalsize, ...
                                                    ytotalsize, ...
                                                    ztotalsize, ...
                                                    xoffset, ...
                                                    yoffset, ...
                                                    zoffset ...
                                                )

% connect to API
oo = OCP();
oo.setImageToken(Transforms.imgtoken);

% retrieve sizes from API
image_size = oo.imageInfo.DATASET.IMAGE_SIZE(Transforms.resolution);
slicerange = oo.imageInfo.DATASET.SLICERANGE(2);

xsubsize = Transforms.xsubsize;
ysubsize = Transforms.ysubsize;
xcubeimgsize = min(image_size(1)-xoffset, ceil(xtotalsize/xsubsize)*xsubsize);
ycubeimgsize = min(image_size(2)-yoffset, ceil(ytotalsize/ysubsize)*ysubsize);
zcubeimgsize = min(slicerange-zoffset, ztotalsize);
xoffsetmark = floor(xoffset/xsubsize)*xsubsize;
yoffsetmark = floor(yoffset/ysubsize)*ysubsize;
zoffsetmark = zoffset;

% retrieve data from API
cutout = read_api(  oo, ...
                    double(xoffsetmark), ...
                    double(yoffsetmark), ...
                    double(zoffsetmark), ...
                    double(xcubeimgsize), ...
                    double(ycubeimgsize), ...
                    double(zcubeimgsize), ...
                    double(Transforms.resolution) ...
                );
data = cutout.data;

% define start indices
xItCount = ceil(xcubeimgsize/xsubsize);
yItCount = ceil(ycubeimgsize/ysubsize);
[xstartindex, ystartindex] = meshgrid(1:xItCount, 1:yItCount);
xstartindex = (xstartindex(:)*xsubsize - xsubsize) + xoffsetmark;
ystartindex = (ystartindex(:)*ysubsize - ysubsize) + yoffsetmark;

% iterate over each sub-cube defined when computing transformations
itLength = size(xstartindex, 1);
zsliceLength = zcubeimgsize;
for i=1:itLength
    
    % set offsets and sizes
    if xstartindex(i) == xsubsize * (xItCount-1) + xoffsetmark
        xs = xcubeimgsize - xstartindex(i);
    else
        xs = xsubsize;
    end
    if ystartindex(i) == ysubsize * (yItCount-1) + yoffsetmark
        ys = ycubeimgsize - ystartindex(i);
    else
        ys = ysubsize;
    end
    xoff = xstartindex(i);
    yoff = ystartindex(i);

    % retrieve sub-cube of interest from entire data set
    dataseg = data(1+yoff:ys+yoff, 1+xoff:xs+xoff, :);
    tforms = containers.Map;

    % iterate over each slice, retrieve local transformations
    for j=1:zsliceLength
        globalkey = globalindices2key(struct( ...
                            'imgtoken', Transforms.imgtoken, ...
                            'resolution', Transforms.resolution, ...
                            'xoffset', xoff, ...
                            'yoffset', yoff, ...
                            'xsubsize', xs, ...
                            'ysubsize', ys, ...
                            'zslice1', j+zoffset, ...
                            'zslice2', j+1+zoffset ...
                           ));
        try
            val = values(Transforms.transforms, globalkey);
        catch
            val = {eye(3)};
        end
        localkey = indices2key(j, j+1);
        tforms(localkey) = val{1};
    end

    % apply transformations to sub-cube
    alignedseg = constructalignment(dataseg, tforms);

    % find a model image from aligned and unaligned sub-cubes for comparison
    cmpindex = 1;
    while cmpindex <= size(alignedseg, 3) && std2(alignedseg(:,:,cmpindex)) == 0
        cmpindex = cmpindex+1;
    end

    % find the transformations necessary to match the model images
    if cmpindex <= size(alignedseg, 3)

        % remove zero padding from aligned 
        [rmaligned, yshiftmin, xshiftmin] = rmzeropadding(alignedseg(:,:,cmpindex));
        if size(rmaligned, 1) > 0 && size(rmaligned, 2) > 0

            % use cross-correlation to find translation params
            c = normxcorr2(rmaligned, dataseg(:,:,cmpindex));
            [ypeak, xpeak] = find(c==max(c(:)));
            translatey = ypeak - size(rmaligned, 1) - yshiftmin;
            translatex = xpeak - size(rmaligned, 2) - xshiftmin;
            ystart = yoff + translatey + 1;
            xstart = xoff + translatex + 1;
            yend = min(yoff + size(alignedseg, 1), size(data, 1));
            xend = min(xoff + size(alignedseg, 2), size(data, 2));

            % get image cube to apply transformations
            replaced = data(ystart:yend, xstart:xend, :);
            
            % replace image cube with aligned data only w/ non-zero entries
            alignedseg = alignedseg(1:min(size(replaced,1), end), 1:min(size(replaced,2), end), :);
            notzero = alignedseg~=0;
            replaced(notzero) = alignedseg(notzero);
            data(ystart:yend, xstart:xend, :) = replaced;

        end
    end
end

data = data(1+yoffset-yoffsetmark:end, 1+xoffset-xoffsetmark:end, :);

end

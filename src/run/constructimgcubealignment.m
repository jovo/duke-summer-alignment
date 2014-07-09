function [ RAMONVol ] = constructimgcubealignment( ...
                                                    TransformData, ...
                                                    xtotalsize, ...
                                                    ytotalsize, ...
                                                    ztotalsize, ...
                                                    xoffset, ...
                                                    yoffset, ...
                                                    zoffset ...
                                                )
%CONSTRUCTIMGCUBEALIGNMENT Aligns subset of image dataset using entire
%image dataset transformations.
%   function [ data ] = constructimgcubealignment( ...
%                                                     TransformData, ...
%                                                     xtotalsize, ...
%                                                     ytotalsize, ...
%                                                     ztotalsize, ...
%                                                     xoffset, ...
%                                                     yoffset, ...
%                                                     zoffset ...
%                                                 )
%   TransformData is a struct with information on the transformations for
%   the entire data set. totalsize is the size of the image cube, offset is
%   the offset in relation to the entire image dataset.

tic

% connect to API
oo = OCP();
oo.setImageToken(TransformData.imgtoken);

% retrieve sizes from API
image_size = oo.imageInfo.DATASET.IMAGE_SIZE(TransformData.resolution);
slicerange = oo.imageInfo.DATASET.SLICERANGE(2);
% sub-cube size
xsubsize = TransformData.xsubsize;
ysubsize = TransformData.ysubsize;
% round offset to nearest subcube
xoffsetdiff = xoffset-TransformData.xoffset;
yoffsetdiff = yoffset-TransformData.yoffset;
xoffsetmark = TransformData.xoffset + floor(xoffsetdiff/xsubsize)*xsubsize;
yoffsetmark = TransformData.yoffset + floor(yoffsetdiff/ysubsize)*ysubsize;
zoffsetmark = zoffset;
% compute modified total size
xtotalsize = min(image_size(1)-xoffsetmark, xtotalsize+xoffset-xoffsetmark);
ytotalsize = min(image_size(2)-yoffsetmark, ytotalsize+yoffset-yoffsetmark);
ztotalsize = min(slicerange-zoffset, ztotalsize);

% retrieve data from API
cutout = read_api(  oo, ...
                    double(xtotalsize), ...
                    double(ytotalsize), ...
                    double(ztotalsize), ...
                    double(xoffsetmark), ...
                    double(yoffsetmark), ...
                    double(zoffsetmark), ...
                    double(TransformData.resolution) ...
                );
data = cutout.data;

% define start indices
xItCount = ceil(xtotalsize/xsubsize);
yItCount = ceil(ytotalsize/ysubsize);
[xstartindex, ystartindex] = meshgrid(1:xItCount, 1:yItCount);
xstartindex = (xstartindex(:)*xsubsize - xsubsize);
ystartindex = (ystartindex(:)*ysubsize - ysubsize);

% iterate over each sub-cube defined when computing transformations
itLength = size(xstartindex, 1);
zsliceLength = ztotalsize;
for i=1:itLength

    % set offsets and sizes
    if xstartindex(i) == xsubsize * (xItCount-1)
        xs = xtotalsize - xstartindex(i);
    else
        xs = xsubsize;
    end
    if ystartindex(i) == ysubsize * (yItCount-1)
        ys = ytotalsize - ystartindex(i);
    else
        ys = ysubsize;
    end
    xoff = xstartindex(i);
    yoff = ystartindex(i);
    zoff = 0;

    % retrieve sub-cube of interest from entire data set
    dataseg = data(1+yoff:ys+yoff, 1+xoff:xs+xoff, :);
    tforms = containers.Map;

    % iterate over each slice, retrieve local transformations
    for j=1:zsliceLength
        globalkey = globalindices2key(struct( ...
                            'resolution', TransformData.resolution, ...
                            'xoffset', xoffsetmark + xoff, ...
                            'yoffset', yoffsetmark + yoff, ...
                            'zoffset', zoffsetmark + zoff, ...
                            'xsubsize', xs, ...
                            'ysubsize', ys, ...
                            'zslice1', zoffset + j-1, ...
                            'zslice2', zoffset + j ...
                           ));
        try
            val = values(TransformData.transforms, {globalkey});
        catch
            val = {eye(3)};
        end
        localkey = localindices2key(j, j+1);
        tforms(localkey) = val{1};
    end

    % apply transformations to sub-cube
    transforms = struct;
    transforms.pairwise = tforms;
    alignedseg = constructalignment(dataseg, transforms);

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
            ystart = max(yoff + 1 + translatey, 1);
            xstart = max(xoff + 1 + translatex, 1);
            yend = min(yoff + size(alignedseg, 1) + translatey, size(data, 1));
            xend = min(xoff + size(alignedseg, 2) + translatex, size(data, 2));

            % get image cube to apply transformations
            replaced = data(ystart:yend, xstart:xend, :);

            % replace image cube with aligned data only w/ non-zero entries
            if ystart + translatey < 1
                aliystart = 1 - translatey;
            else
                aliystart = 1;
            end
            if xstart + translatex < 1
                alixstart = 1 - translatex;
            else
                alixstart = 1;
            end
            yendtemp = ystart + translatey + size(alignedseg, 1);
            if yendtemp > size(data, 1)
                aliyend = size(alignedseg, 1) - (yendtemp - size(data, 1)) + 1;
            else
                aliyend = size(alignedseg, 1);
            end
            xendtemp = xstart + translatex + size(alignedseg, 2);
            if xendtemp > size(data, 2)
                alixend = size(alignedseg, 2) - (xendtemp - size(data, 2)) + 1;
            else
                alixend = size(alignedseg, 2);
            end

            alignedseg = alignedseg(aliystart:aliyend, alixstart:alixend, :);

            notzero = alignedseg~=0;
            replaced(notzero) = alignedseg(notzero);
            data(ystart:yend, xstart:xend, :) = replaced;

        end
    end
end

data = data(1+yoffset-yoffsetmark:end, 1+xoffset-xoffsetmark:end, :);
RAMONVol = RAMONVolume;
RAMONVol.setXyzOffset([xoffset, yoffset, zoffset]);
RAMONVol.setResolution(TransformData.resolution);
RAMONVol.setCutout(data);

toc

end

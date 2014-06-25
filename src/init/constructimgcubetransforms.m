function [ Transforms ] = constructimgcubetransforms( ...
                                                        imgtoken, ...
                                                        resolution, ...
                                                        xtotalsize, ...
                                                        ytotalsize, ...
                                                        ztotalsize, ...
                                                        xsubsize, ...
                                                        ysubsize, ...
                                                        zsubsize, ...
                                                        xoffset, ...
                                                        yoffset, ...
                                                        zoffset, ...
                                                        workersize ...
                                                    )
%COMPUTEIMGCUBETRANSFORMS Compute transforms for an entire image stack.

tic

% setup config variables
config = setupconfigvars();

% connect to API
oo = OCP();
oo.setImageToken(imgtoken);

% retrieve sizes from API
image_size = oo.imageInfo.DATASET.IMAGE_SIZE(resolution);
slicerange = oo.imageInfo.DATASET.SLICERANGE(2);

% size of specific image cube
xcubeimgsize = min(image_size(1)-xoffset, xtotalsize);
ycubeimgsize = min(image_size(2)-yoffset, ytotalsize);
zcubeimgsize = min(slicerange-zoffset, ztotalsize);
xItCount = ceil(xcubeimgsize/xsubsize);
yItCount = ceil(ycubeimgsize/ysubsize);
zItCount = ceil((zcubeimgsize-1)/(zsubsize-1));

% initialize index locations for query
[xstartindex, ystartindex, zstartindex] = meshgrid(1:xItCount, 1:yItCount, 1:zItCount);
xstartindex = xstartindex(:)*xsubsize - xsubsize + xoffset;
ystartindex = ystartindex(:)*ysubsize - ysubsize + yoffset;
zstartindex = zstartindex(:)*(zsubsize-1) - 1 + zoffset;

% specify number of sub-cubes and iterations
numCubes = length(xstartindex);
partitionSize = workersize;
numIterations = ceil(numCubes/partitionSize);

% data structure for transforms and associated keys
KeyCells = cell(numIterations, (zsubsize-1)*partitionSize);
ValCells = cell(numIterations, (zsubsize-1)*partitionSize);

% set pool of workers
pObj = parpool('local', workersize);

% save all sub-cubes as memmapfiles
c = 1;  % counter
for i=1:numIterations   % iterate over partitions

    % starting index and size of current iteration
    curIndex = c;
    curItCount = min(numCubes-curIndex+1,partitionSize);

    % data structure for memmapfile keys and ids in current iteration
    MemKeys = cell(1, curItCount);
    BaseIDs = cell(1, curItCount);

    for j=1:curItCount % iterate over each partition

        % set offsets and sizes
        if xstartindex(c) == xsubsize * (xItCount-1) + xoffset
            xs = xoffset + xcubeimgsize - xstartindex(c);
        else
            xs = xsubsize;
        end
        if ystartindex(c) == ysubsize * (yItCount-1) + yoffset
            ys = yoffset + ycubeimgsize - ystartindex(c);
        else
            ys = ysubsize;
        end
        if zstartindex(c) == zsubsize * (zItCount-1) + zoffset
            zs = zoffset + zcubeimgsize - zstartindex(c);
        else
            zs = zsubsize;
        end
        xoff = xstartindex(c);
        yoff = ystartindex(c);
        zoff = zstartindex(c);

        % query API
        cutout = read_api(  oo, ...
                            double(xoff), ...
                            double(yoff), ...
                            double(zoff), ...
                            double(xs), ...
                            double(ys), ...
                            double(zs), ...
                            resolution ...
                        );

        % save as memmapfile
        filename = [ 'data/aligntemp_', num2str(j), '.dat' ];
        fileID = fopen(filename, 'w');
        fwrite(fileID, cutout.data, 'uint8');
        fclose(fileID);
        m = memmapfile(filename, 'Format', {'uint8', size(cutout.data), 'data'});

        % store sub-cube and its base ids
        MemKeys(j) = {m};
        BaseIDs(j) = {struct( ...
                            'imgtoken', imgtoken, ...
                            'resolution', resolution, ...
                            'xoffset', xoff, ...
                            'yoffset', yoff, ...
                            'zoffset', zoff, ...
                            'xsubsize', xs, ...
                            'ysubsize', ys ...
                           )};

        % update status for next procedure
        if c >= numCubes
            break;
        else
            c = c + 1;
        end

    end

    % helper to compute transforms in parallel
    [curKeyCells, curValCells] = alignhelper(MemKeys, BaseIDs);

    % update data structure with computed transforms
    KeyCells(i, 1:size(curKeyCells,1)) = curKeyCells';
    ValCells(i, 1:size(curValCells,1)) = curValCells';

end

% format output by removing empty cells
nancells = cellfun('isempty', KeyCells);
KeyCells = KeyCells(~nancells);
ValCells = ValCells(~nancells);

% save transforms
Transforms = struct;
Transforms.imgtoken = imgtoken;
Transforms.resolution = resolution;
Transforms.xtotalsize = xtotalsize;
Transforms.ytotalsize = ytotalsize;
Transforms.ztotalsize = ztotalsize;
Transforms.xsubsize = xsubsize;
Transforms.ysubsize = ysubsize;
Transforms.xoffset = xoffset;
Transforms.yoffset = yoffset;
Transforms.zoffset = zoffset;
Transforms.transforms = containers.Map(KeyCells(:), ValCells(:));
                                                
% delete parpool and temp files
delete(pObj);
delete('data/aligntemp_*.dat');

%% Helper function

    % computes tranforms in parallel for sub-cubes specified in inputs
    function [ keycells, valcells ] = alignhelper( memkeys, baseids )

        % specify sizes and initialize data structures
        numParIterations = length(memkeys);
        numZSlices = size(memkeys{1}.Data.data, 3) - 1;
        valcells = cell(numParIterations, numZSlices);
        keycells = cell(numParIterations, numZSlices);

        % iterate over each sub-cube
        parfor u=1:numParIterations

            % calculate transformations for affine global alignment
            [tforms, ~] = roughalign(memkeys{u}.Data.data, '', 0.5, config);
            tformkeys = keys(tforms);
            valrow = cell(1, numZSlices);
            keyrow = cell(1, numZSlices);

            % iterate over each transformation for one sub-cube
            for v=1:length(tformkeys)

                % change keys to reflect global coordinates
                curkey = tformkeys{v};
                curval = values(tforms, {curkey});
                index = baseids{u};
                [index.zslice1, index.zslice2] = key2indices(curkey);
                index.zslice1 = index.zslice1 + index.zoffset;
                index.zslice2 = index.zslice2 + index.zoffset;
                valrow(v) = curval;
                keyrow(v) = {globalindices2key(index)};

            end

            valcells(u,:) = valrow;
            keycells(u,:) = keyrow;

        end

        valcells = valcells(:);
        keycells = keycells(:);

    end

toc

end

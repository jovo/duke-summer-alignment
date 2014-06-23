function [ Transforms ] = computeimgcubetransforms ( imgtoken, xsubsize, ysubsize, res, workersize )
%COMPUTEIMGCUBETRANSFORMS Compute transforms for an entire image stack.

% setup config variables
config = setupconfigvars();

% connect to API
oo = OCP();
oo.setImageToken(imgtoken);

% retrieve sizes
imgsizemap = oo.imageInfo.DATASET.IMAGE_SIZE(res);
imgdepth = oo.imageInfo.DATASET.SLICERANGE(2);

% size of specific image cube
xcurimgsize = imgsizemap(1);
ycurimgsize = imgsizemap(2);
xcount = ceil(xcurimgsize/xsubsize);
ycount = ceil(ycurimgsize/ysubsize);

% initialize index locations for query
[xindex, yindex] = meshgrid(1:xcount, 1:ycount);
xindex = xindex(:)*xsubsize - xsubsize;
yindex = yindex(:)*ysubsize - ysubsize;

% use total depth for z direction
zsize = imgdepth;
zoff = 0;

% specify number of sub-cubes and iterations
numCubes = length(xindex);
partitionsize = workersize;
numIterations = ceil(numCubes/partitionsize);

% data structure for transforms and associated keys
KeyCells = cell(numIterations, (zsize-1)*partitionsize);
ValCells = cell(numIterations, (zsize-1)*partitionsize);

% set pool of workers
pObj = parpool('local', workersize);

% save all sub-cubes as memmapfiles
c = 1;  % counter
for i=1:numIterations   % iterate over partitions

    % starting index and size of current iteration
    curIndex = c;
    curItCount = min(numCubes-curIndex+1,partitionsize);

    % data structure for memmapfile keys and ids in current iteration
    MemKeys = cell(1, curItCount);
    BaseIDs = cell(1, curItCount);

    for j=1: curItCount % iterate over each partition

        % set offsets and sizes
        if xindex(c) == xsubsize * (xcount-1)
            xs = xcurimgsize - xindex(c);
        else
            xs = xsubsize;
        end
        if yindex(c) == ysubsize * (ycount-1)
            ys = ycurimgsize - yindex(c);
        else
            ys = ysubsize;
        end
        xoff = xindex(c);
        yoff = yindex(c);

        % query API
        cutout = read_api(oo, xoff, yoff, zoff, xs, ys, zsize, res);

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
                            'resolution', res, ...
                            'xoffset', xoff, ...
                            'yoffset', yoff, ...
                            'zoffset', zoff, ...
                            'xsize', xs, ...
                            'ysize', ys ...
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
Transforms.resolution = res;
Transforms.xsubsize = xsubsize;
Transforms.ysubsize = ysubsize;
Transforms.transforms = containers.Map(KeyCells(:), ValCells(:));

% delete parpool and temp files
delete(pObj);
delete('data/aligntemp_*.dat');

%% Helper function

    % computes tranforms in parallel for sub-cubes specified in inputs
    function [ keycells, valcells ] = alignhelper( memkeys, baseids )

        % specify sizes and initialize data structures
        cellsizey = length(memkeys);
        cellsizex = size(memkeys{1}.Data.data, 3) - 1;
        valcells = cell(cellsizey, cellsizex);
        keycells = cell(cellsizey, cellsizex);

        % iterate over each sub-cube
        parfor u=1:cellsizey

            % calculate transformations for affine global alignment
            [tforms, ~] = roughalign(memkeys{u}.Data.data, '', 0.5, config);
            tformkeys = keys(tforms);
            valrow = cell(1, cellsizex);
            keyrow = cell(1, cellsizex);

            % iterate over each transformation for one sub-cube
            for v=1:length(tformkeys)

                % change keys to reflect global coordinates
                curkey = tformkeys{v};
                curval = values(tforms, {curkey});
                index = baseids{u};
                [index.zslice1, index.zslice2] = key2indices(curkey);
                valrow(v) = curval;
                keyrow(v) = {globalindices2key(index)};

            end

            valcells(u,:) = valrow;
            keycells(u,:) = keyrow;

        end

        valcells = valcells(:);
        keycells = keycells(:);

    end

end

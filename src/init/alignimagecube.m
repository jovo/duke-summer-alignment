function [ Transforms ] = alignimagecube ( imgtoken, xsize, ysize, res, workersize )
%PROCESSIMAGECUBE Process an entire image stack from API

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
xcount = floor(xcurimgsize/xsize);
ycount = floor(ycurimgsize/ysize);

% initialize index locations for query
[xindex, yindex] = meshgrid(1:xcount+1, 1:ycount+1);
xindex = xindex(:)*xsize - xsize;
yindex = yindex(:)*ysize - ysize;

% use total depth for z direction
zsize = imgdepth;
zoff = 0;

% specify number of sub-cubes and iterations
numCubes = length(xindex);
partitionsize = workersize;
numIterations = ceil(numCubes/partitionsize);

% data structure for transforms and associated keys
KeyCells = cell(numCubes, zsize-1);
ValCells = cell(numCubes, zsize-1);

% set pool of workers
pObj = parpool('local', workersize);

% save all sub-cubes as memmapfiles
c = 1;  % counter
for i=1:numIterations   % iterate over partitions
    
    % data structure for memmapfile keys and ids in current iteration
    MemKeys = cell(1, partitionsize);
    BaseIDs = cell(1, partitionsize);
    
    % starting index for current iteration
    curIndex = c;
    
    for j=1:partitionsize   % iterate over each partition

        % set offsets and sizes
        if xindex(c) == xsize * xcount
            xs = xcurimgsize - xindex(c);
        else
            xs = xsize;
        end
        if yindex(c) == ysize * ycount
            ys = ycurimgsize - yindex(c);
        else
            ys = ysize;
        end
        xoff = xindex(c);
        yoff = yindex(c);

        % query API
        cutout = read_api(oo, xoff, yoff, zoff, xs, ys, zsize, res);

        size(cutout.data)
        
        % save as memmapfile
        filename = [ 'data/aligntemp_', num2str(j), '.dat' ];
        fileID = fopen(filename, 'w');
        fwrite(fileID, cutout.data, 'uint8');
        fclose(fileID);
        m = memmapfile(filename, 'Format', {'uint8', size(cutout.data), 'data'});

        % store sub-cube and its base ids
        MemKeys(j) = {m};
        BaseIDs(j) = {[imgtoken, '_', num2str(res), '_', num2str(xoff), '_', ...
            num2str(yoff), '_', num2str(zoff), '_', num2str(xs), '_', num2str(ys)]};

        % update status for next procedure
        if c >= numCubes
            break;
        else
            c = c + 1;
        end
        
    end

    [curKeyCells, curValCells] = alignhelper(MemKeys, BaseIDs);

    KeyCells(curIndex, 1:size(curKeyCells,1)) = curKeyCells;
    ValCells(curIndex, 1:size(curValCells,1)) = curValCells;

end

% save transforms as map
Transforms = containers.Map(KeyCells(:), ValCells(:));

% delete parpool and temp files
delete(pObj);
delete('data/aligntemp_*.dat');

%% Helper function

    % given a few sub-cubes, will align then and output transformations.
    function [ keycells, valcells ] = alignhelper( memkeys, baseids )

        % specify sizes and initialize data structures
        celly = length(memkeys);
        cellx = size(memkeys{1}.Data.data,3)-1;
        valcells = cell(celly, cellx);
        keycells = cell(celly, cellx);

        % iterate over each sub-cube
        parfor u=1:length(memkeys)
            
            % calculate transformations for affine global alignment
            [tforms, ~] = roughalign(memkeys{u}.Data.data, '', 0.5, config);
            tformkeys = keys(tforms);
            valrow = cell(1, cellx);
            keyrow = cell(1, cellx);
            
            % iterate over each transformation for one sub-cube
            for v=1:length(tformkeys)
                
                % change keys to reflect global coordinates
                curkey = tformkeys{v};
                curval = values(tforms, {curkey});
                ids = [ baseids{u}, '_[', curkey, ']' ];
                valrow(v) = {curval};
                keyrow(v) = {ids};
                
            end
            valcells(u,:) = valrow;
            keycells(u,:) = keyrow;
        end
        
        emptycells = cellfun('isempty', keycells);
        valcells = valcells(~emptycells);
        keycells = keycells(~emptycells);
        valcells = valcells(:);
        keycells = keycells(:);

    end

end

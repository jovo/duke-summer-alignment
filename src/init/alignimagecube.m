function [ Transforms ] = alignimagecube ( imgtoken, xsize, ysize, res )
%PROCESSIMAGECUBE Process an entire image stack from API

% setup config variables
config = setup();

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

% use total depth for each sub-cube
zsize = imgdepth;
zoff = 0;

MemKeys = cell(1, length(xindex));
BaseIDs = cell(1, length(xindex));

% save all sub-cubes as memmapfiles
for i=1:length(xindex)

    % set offsets and sizes
    if xindex(i) == xsize * xcount
        xs = xcurimgsize - xindex(i);
    else
        xs = xsize;
    end
    if yindex(i) == ysize * ycount
        ys = ycurimgsize - yindex(i);
    else
        ys = ysize;
    end
    xoff = xindex(i);
    yoff = yindex(i);

    % query API
    cutout = read_api(oo, xoff, yoff, zoff, xs, ys, zsize, res);

    % save as memmapfile
    filename = [ 'data/aligntemp_', num2str(i), '.dat' ];
    fileID = fopen(filename, 'w');
    fwrite(fileID, cutout.data, 'uint8');
    fclose(fileID);
    m = memmapfile(filename, 'Format', {'uint8', size(cutout.data), 'data'});

    % store sub-cube and its base ids
    MemKeys(i) = {m};
    BaseIDs(i) = {[num2str(res), '_', num2str(xoff), '_', num2str(yoff), '_', ...
                  num2str(zoff), '_', num2str(xs), '_', num2str(ys)]};

end

pObj = parpool('local', 9);
[ValCells, KeyCells] = alignhelper(MemKeys, BaseIDs);
Transforms = containers.Map(KeyCells, ValCells);

delete(pObj);
delete('data/aligntemp_*.dat');

%% Helper function

    function [ valcells, keycells ] = alignhelper( memkeys, baseids )

        celly = length(memkeys);
        cellx = size(memkeys{1}.Data.data,3)-1;
        valcells = cell(celly, cellx);
        keycells = cell(celly, cellx);

        parfor j=1:length(memkeys)
            % calculate transformations for affine global alignment
            [tforms, ~] = roughalign(memkeys{j}.Data.data, '', 0.5, config);
            tformkeys = keys(tforms);
            valrow = cell(1, cellx);
            keyrow = cell(1, cellx);
            for k=1:length(tformkeys)
                curkey = tformkeys{k};
                curval = values(tforms, {curkey});
                ids = [ baseids{j}, '_[', curkey, ']' ];
                valrow(k) = {curval};
                keyrow(k) = {ids};
            end
            valcells(j,:) = valrow;
            keycells(j,:) = keyrow;
        end
        emptycells = cellfun('isempty', keycells);
        valcells = valcells(~emptycells);
        keycells = keycells(~emptycells);
        valcells = valcells(:);
        keycells = keycells(:);

    end

end

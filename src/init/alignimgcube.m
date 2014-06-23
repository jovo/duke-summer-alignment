function [ Aligned ] = alignimgcube( Transforms, xsize, ysize, xoff, yoff )

xsubsize = Transforms.xsubsize;
ysubsize = Transforms.ysubsize;

xoffmark = floor(xoff/1024)*1024;
yoffmark = floor(yoff/1024)*1024;
xsizemark = ceil(xsize/1024)*1024;
ysizemark = ceil(ysize/1024)*1024;

cutout = read_api(oo, xoff, yoff, zoff, xs, ys, zsize, res);

end
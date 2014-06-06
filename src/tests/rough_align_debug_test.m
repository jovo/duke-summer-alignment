data = zeros(512, 512, 5);
for i=1:30
    r1 = round(rand*100);
    r2 = round(rand*100);
    rot = round(rand*180);
    im = imageAC4(r1:r1+511, r2:r2+511, 1);
    data(:,:,i) = imrotate(im, rot, 'nearest', 'crop');
end

[transforms, merged] = roughalign(data, 'align');

align_gui
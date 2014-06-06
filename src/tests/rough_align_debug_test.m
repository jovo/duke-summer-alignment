% have r1, r2, rot

data = zeros(512, 512, 5);
for i=1:30
    im = imageAC4(r1(i):r1(i)+511, r2(i):r2(i)+511, 1);
    data(:,:,i) = imrotate(im, rot(i), 'nearest', 'crop');
end

[transforms, merged] = roughalign(data, 'align');

align_gui
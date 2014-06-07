% various tests.

% test identical image with large rotations, moderate shifts
load('/Users/rogerzou/Projects/openconnectome/alignment/data/AC4_matrices.mat')
n1 = 30;
data1 = zeros(512, 512, n1);
for i=1:n1
    r1 = ceil(rand*200);
    r2 = ceil(rand*200);
    rot1 = floor(rand*180);
    im = imageAC4(r1:r1+511, r2:r2+511, 10);
    data1(:,:,i) = imrotate(im, rot1, 'nearest', 'crop');
end
[transforms1, merged1] = roughalign(data1, 'align');


% test more realistic EM section data. Artifically add large rotations
% prior to alignment.
cutout = read_api;
data2 = cutout.data;
for i=1:size(data2,3)
    data2(:,:,i) = imrotate(data2(:,:,i), rand*180, 'nearest', 'crop');
end
[transforms2, merged2] = roughalign(data2, 'align', 0.5);

% various tests.

clear all
close all
load('/Users/rogerzou/Projects/openconnectome/alignment/data/svm/svm1.mat');
setup;
% test identical image with large rotations, moderate shifts
load('/Users/rogerzou/Projects/openconnectome/alignment/data/AC4_matrices.mat')

rng; % control random number generator
n1 = 30;
data1 = zeros(512, 512, n1, 'uint8');
r1 = ceil(rand(1,n1)*200);
r2 = ceil(rand(1,n1)*200);
rot1 = floor(rand(1,n1)*180);
for i=1:n1
    im = imageAC4(r1(i):r1(i)+511, r2(i):r2(i)+511, 10);
    data1(:,:,i) = imrotate(im, rot1(i), 'nearest', 'crop');
end
[transforms1, merged1] = roughalign(data1, 'align');


% test more realistic EM section data. Artifically add large rotations
% prior to alignment.
cutout = read_api;
data2 = cutout.data;
n2 = size(data,3);
rot2 = floor(rand(1,n1)*180);
for i=1:n2
    data2(:,:,i) = imrotate(data2(:,:,i), rot2(i), 'nearest', 'crop');
end
[transforms2, merged2] = roughalign(data2, 'align', 0.5);

% various tests.
clear all
close all

setup();

% test identical image with large rotations, moderate shifts
ac4 = load('/Users/rogerzou/Projects/openconnectome/alignment/data/bock11_example1.mat');
rng(5); % control random number generator
n1 = 10;
r1 = ceil(rand(1,n1)*200);
r2 = ceil(rand(1,n1)*200);
rot1 = floor(rand(1,n1)*360);
start = floor(200/sqrt(2));
finish = ceil(800-200/sqrt(2));
data2 = zeros(finish-start+1, finish-start+1, n1, 'uint8');

for i=1:n1
    im = ac4.data(r1(i):r1(i)+799, r2(i):r2(i)+799, i+10);
    d = imrotate(im, rot1(i), 'nearest', 'crop');
    data2(:,:,i) = d(start:finish, start:finish);
end
[transforms1, merged1] = roughalign(data2, 'align');


% test more realistic EM section data. Artifically add large rotations
% prior to alignment.
lee14 = load('/Users/rogerzou/Projects/openconnectome/alignment/data/lee14_example1.mat');
n2 = size(lee14.data,3);
rot2 = floor(rand(1,n2)*360);
start = floor(256/sqrt(2));
finish = ceil(1024-256/sqrt(2));
data2 = zeros(finish-start+1, finish-start+1, n2, 'uint8');

for i=1:n2
	d = imrotate(lee14.data(:,:,i), rot2(i), 'nearest', 'crop');
	data2(:,:,i) = d(start:finish, start:finish);
end
[transforms2, merged2] = roughalign(data2, 'align', 0.5);

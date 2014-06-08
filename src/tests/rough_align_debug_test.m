% various tests.

% test identical image with large rotations, moderate shifts
load('/Users/rogerzou/Projects/openconnectome/alignment/data/AC4_matrices.mat')
n1 = 30;
data1 = zeros(512, 512, n1);
r1 = [183,127,20,56,110,192,193,32,195,192,98,161,29,85,184,159,192,132,8,170,187,136,152,149,79,132,35,142,7,56];
r2 = [10,20,165,139,64,191,7,88,77,154,160,38,98,90,130,142,151,56,136,132,33,24,100,192,69,118,45,151,52,102];
rot1 = [125,160,172,98,24,26,46,151,45,146,43,167,62,35,45,110,85,63,149,105,98,165,51,136,135,68,102,13,9,95];
% r1 = ceil(rand(1,n1)*200);
% r2 = ceil(rand(1,n1)*200);
% rot1 = floor(rand(1,n1)*180);
for i=1:n1
    im = imageAC4(r1(i):r1(i)+511, r2(i):r2(i)+511, 10);
    data1(:,:,i) = imrotate(im, rot1(i), 'nearest', 'crop');
end
[transforms1, merged1] = roughalign(data1, 'align');


% % test more realistic EM section data. Artifically add large rotations
% % prior to alignment.
% cutout = read_api;
% data2 = cutout.data;
% for i=1:size(data2,3)
%     data2(:,:,i) = imrotate(data2(:,:,i), rand*180, 'nearest', 'crop');
% end
% [transforms2, merged2] = roughalign(data2, 'align', 0.5);

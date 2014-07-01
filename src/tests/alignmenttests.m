%ALIGNMENT TESTS

close all

config = configalignvars();

% test identical image with large rotations, moderate shifts
ac4 = load('/Users/rogerzou/Projects/openconnectome/alignment/data/examples/bock11_example1.mat');
rng(5); % control random number generator
n1 = 10;
r1 = ceil(rand(1,n1)*200);
r2 = ceil(rand(1,n1)*200);
rot1 = floor(rand(1,n1)*360);
start = floor(200/sqrt(2));
finish = ceil(800-200/sqrt(2));
data1 = zeros(finish-start+1, finish-start+1, n1, 'uint8');

for i=1:n1
    im = ac4.data(r1(i):r1(i)+799, r2(i):r2(i)+799, 1);
    d = imrotate(im, rot1(i), 'nearest', 'crop');
    data1(:,:,i) = d(start:finish, start:finish);
end
[transforms1, merged1] = roughalign(data1, 'align', config);

% inverse alignment
original1 = constructalignment(merged1, transforms1, 1);

% output error report for both original and aligned stacks.
format short g;
[origE, orig] = errorreport(data1, 'Data1', 'mse');
[alignedE, aligned] = errorreport(original1, 'Original1', 'mse');
disp('Error improvement:');
disp([sprintf('\tIndex\tImprovement\t'), '% Improvement']);
disp( [(1:size(origE,1))', origE-alignedE, (origE-alignedE)./origE] );
disp(orig);
disp(aligned);
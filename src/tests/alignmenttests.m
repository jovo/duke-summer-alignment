%ALIGNMENT TESTS

%% prepare API retrieval
close all
configalign = configalignvars();
oo = OCP();
oo.setImageToken('kasthuri11cc');

%% LARGE ROTATION/TRANSLATION TEST ON IDENTICAL IMAGE

RAMONOrig = read_api(oo, 1024, 1024, 5, 3000, 5000, 400, 1);

disp('LARGE ROTATION/TRANSLATION TEST ON IDENTICAL IMAGE');
% test identical image with large rotations, moderate shifts
rng(5); % control random number generator
n1 = 10;
r1 = ceil(rand(1,n1)*200);
r2 = ceil(rand(1,n1)*200);
rot1 = floor(rand(1,n1)*360);
start = floor(200/sqrt(2));
finish = ceil(800-200/sqrt(2));
data1 = zeros(finish-start+1, finish-start+1, n1, 'uint8');

for i=1:n1
    im = RAMONOrig.data(r1(i):r1(i)+799, r2(i):r2(i)+799, 1);
    d = imrotate(im, rot1(i), 'nearest', 'crop');
    data1(:,:,i) = d(start:finish, start:finish);
end
[transforms1, merged1] = roughalign(configalign, data1, 'align');

% inverse alignment
original1 = constructalignment(merged1, transforms1, 1);

% output error report for both original and aligned stacks.
format short g;
[origE, orig] = errorreport(configalign, data1, 'Data1');
[alignedE, aligned] = errorreport(configalign, original1, 'Original1');
disp('Error improvement:');
disp([sprintf('\tIndex\tImprovement\t'), '% Improvement']);
disp( [(1:size(origE,1))', origE-alignedE, (origE-alignedE)./origE] );
disp(orig);
disp(aligned);
disp('If correct, the above error reports should be close to identical.');

%% TESTING ALIGNRAMONVOL

disp('TESTING ALIGNRAMONVOL');
newRAMON = RAMONOrig.clone();
newRAMON.setCutout(data1);
[RAMONAligned, TransformsNew] = alignRAMONVol(newRAMON);

% RAMONAligned is the aligned version of newRAMON. 
%% TESTING UNALIGNRAMONVOL

disp('TESTNG UNALIGNRAMONVOL');
[newRAMONOrig] = unalignRAMONVol(RAMONAligned, TransformsNew);
disp('newRAMONOrig is the unaligned version of RAMONAligned. It should look identical to newRAMON.');

%% TESTING CONSTRUCTIMGCUBETRANSFORMS

disp('TESTING CONSTRUCTIMGCUBETRANSFORMS');
apivarstest = configapivars_test();
TransformsData = constructimgcubetransforms(apivarstest);

%% TESTING CONSTRUCTIMGCUBEALIGNMENT

disp('TESTING CONSTRUCTIMGCUBEALIGNMENT');
constructimgcubealignmenttest = constructimgcubealignment(TransformsData, intmax, intmax, 3, 0, 0, 1);

%% TESTING ALIGNRAMONVOL WITH CONSTRUCTIMGCUBETRANSFORMS

disp('TESTING ALIGNRAMONVOL WITH CONSTRUCTIMGCUBETRANSFORMS');
resolution = 4;
imgsize = oo.imageInfo.DATASET.IMAGE_SIZE(resolution);
cutout = read_api(oo, imgsize(1), imgsize(2), 3, 0, 0, 1, resolution);
constructimgcubetransformsalignramonvol = alignRAMONVol(cutout, TransformsData);

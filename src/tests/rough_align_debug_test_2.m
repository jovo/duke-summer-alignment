A = imageAC4(:,:,1);
T = imageAC4(:,:,2);
c = normxcorr2(T,A);
[ypeak, xpeak] = find(c==max(c(:)));
cbw = im2bw(c, max(max(c))*0.5);
figure; imshowpair(c, cbw,'montage');
hold on
plot(xpeak, ypeak,'ro');
A1 = A(1:512,1:512);
T1 = T(1:512,1:512);
c1 = normxcorr2(T1,A1);
[ypeak1, xpeak1] = find(c1==max(c1(:)));
c1bw = im2bw(c1, max(max(c1))*0.5);
figure; imshowpair(c1, c1bw,'montage');
hold on
plot(xpeak1, ypeak1,'ro');
A2 = A(1:256, 1:256);
T2 = T(1:256, 1:256);
c2 = normxcorr2(T2,A2);
[ypeak2, xpeak2] = find(c2==max(c2(:)));
c2bw = im2bw(c2, max(max(c2))*0.5);
cc2 = bwconncomp(c2bw);
figure; imshowpair(c2, c2bw,'montage');
hold on
plot(xpeak2, ypeak2,'ro');

feat = getpeakfeatures(c, ypeak, xpeak);
feat1 = getpeakfeatures(c1, ypeak1, xpeak1);
feat2 = getpeakfeatures(c2, ypeak2, xpeak2);


A3 = A;
T3 = imrotate(T,23, 'nearest','crop');
c3 = normxcorr2(T3,A3);
[ypeak3, xpeak3] = find(c3==max(c3(:)));
c3bw = im2bw(c3, max(max(c3))*0.5);
cc3 = bwconncomp(c3bw);
figure; imshowpair(c3, c3bw,'montage');

feat3 = getpeakfeatures(c3, ypeak3, xpeak3);
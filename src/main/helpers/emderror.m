function [ Error ] = emderror( P, Q )

% resize and superpixelize
% P = imresize(P, 0.25);
% Q = imresize(Q, 0.25);
[IP, LP] = betterslic(P);
[IQ, LQ] = betterslic(Q);
% figure; imshowpair(IP, IQ, 'montage');
LP(Q==0) = 0;
LP(P==0) = 0;
LQ(Q==0) = 0;
LQ(P==0) = 0;

Prange = unique(LP(:))';
Qrange = unique(LQ(:))';
Prange(Prange==0) = [];
Qrange(Qrange==0) = [];
% get [X centroid, Y centroid, Weight] of each cluster, where Weight is the
% Area*(meanIntensity)/255.
Psig = NaN(size(Prange, 2), 3);
for i=1:size(Prange, 2)
    Pbw = LP==Prange(i);
    Pvalues = NaN(size(P));
    Pvalues(Pbw) = P(Pbw);
    Pvalues(~Pbw) = [];
    Pvalues = Pvalues(:);
    Prp = regionprops(Pbw, 'Centroid', 'Area');
    parea = [Prp.Area];
    pindex = find(parea==max(parea), 1);
    Psig(i,:) = [ Prp(pindex).Centroid, Prp(pindex).Area*mean(Pvalues)/255 ];
end
Qsig = NaN(size(Qrange, 2), 3);
for i=1:size(Qrange, 2)
    Qbw = LQ==Qrange(i);
    Qvalues = NaN(size(Q));
    Qvalues(Qbw) = Q(Qbw);
    Qvalues(~Qbw) = [];
    Qvalues = Qvalues(:);
    Qrp = regionprops(Qbw, 'Centroid', 'Area');
    qarea = [Qrp.Area];
    qindex = find(qarea==max(qarea), 1);
    Qsig(i,:) = [ Qrp(qindex).Centroid, Qrp(qindex).Area*mean(Qvalues)/255 ];
end

Pcent = Psig(:,1:2);
Qcent = Qsig(:,1:2);
D = pdist2(Pcent, Qcent);
m = size(D, 1);
n = size(D, 2);
% MIN WORK(P,Q,F) = sum_i sum_j d_{ij} f_{ij}
% subject to constraints:
% f{ij} \ge 0 forall i, j
% sum_j f_{ij} \le w_{pi} forall i
% sum_i f_{ij} \le w_{qj} forall j
% sum_i sum_j f_{ij} = min(sum_i w_{pi}, sum_j w_{qj})
d = D(:);
A = zeros(m+n, m*n);
b = zeros(m+n, 1);
for i=1:m
    Iindices = zeros(size(D));
    Iindices(i,:) = 1;
    A(i,:) = Iindices(:);
end
b(1:m) = Psig(:,3);
for j=1:n
    Jindices = zeros(size(D));
    Jindices(:,j) = 1;
    A(m+j,:) = Jindices(:);
end
b(m+1:m+n) = Qsig(:,3);
Aeq = ones(1, m*n);
beq = min(sum(Psig(:,3)), sum(Qsig(:,3)));
lb = zeros(m*n, 1);
ub = [];
options = optimset('Display','none');
f = linprog(d, A, b, Aeq, beq, lb, ub, 0, options);
F = reshape(f, m, n);
% figure; imshow(D, [min(D(:)), max(D(:))]);
% figure; imshow(F, [min(F(:)), max(F(:))]);
Error = sum(sum(D.*F))/sum(sum(F));

end

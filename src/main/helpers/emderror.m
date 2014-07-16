function [ Error ] = emderror( P, Q )

k = 500;

% resize and superpixelize
P = imresize(P, 0.5);
Q = imresize(Q, 0.5);
[~, LP] = betterslic(P);
[~, LQ] = betterslic(Q);

% get [X centroid, Y centroid, Weight] of each cluster, where Weight is the
% Area*(meanIntensity)/255.
Psig = NaN(k, 3);
Qsig = NaN(k, 3);
for i=1:k
    Pbw = LP==i;
    Qbw = LQ==i;
    Pvalues = NaN(size(P));
    Qvalues = NaN(size(Q));
    Pvalues(Pbw) = P(Pbw);
    Qvalues(Qbw) = Q(Qbw);
    Pvalues(~Pbw) = [];
    Qvalues(~Qbw) = [];
    Pvalues = Pvalues(:);
    Qvalues = Qvalues(:);
    Prp = regionprops(Pbw, 'Centroid', 'Area');
    Qrp = regionprops(Qbw, 'Centroid', 'Area');
    parea = [Prp.Area];
    qarea = [Qrp.Area];
    pindex = parea==max(parea);
    qindex = qarea==max(qarea);
    if ~isempty(pindex)
        Psig(i,:) = [ Prp(pindex).Centroid, Prp(pindex).Area*mean(Pvalues)/255 ];
    end
    if ~isempty(qindex)
        Qsig(i,:) = [ Qrp(qindex).Centroid, Qrp(qindex).Area*mean(Qvalues)/255 ];
    end
end
Psig(isnan(Psig)) = [];
Qsig(isnan(Qsig)) = [];

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

Error = sum(sum(D.*F))/sum(sum(F));

end

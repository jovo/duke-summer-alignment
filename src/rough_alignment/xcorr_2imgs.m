function [ T_new, A_new, Merged, TranslateY, TranslateX ]= xcorr_2imgs( template, A )
%XCORR_2IMGS Rough alignment by 2D cross-correlation
%   Very basic right now. There are plenty of assumptions:
%   1) template should be smaller than A or same size. 
%   2) there can not be much zero padding.
%   3) only supports translations. Will add rotation/scaling support soon.

% 2d cross correlation
c = normxcorr2(template, A);
[ypeak, xpeak] = find(c==max(c(:)));

% determine how much to translate
TranslateY = ypeak-size(template, 1);
TranslateX = xpeak-size(template, 2);

Asizey = size(A, 1);
Asizex = size(A, 2);
Tsizey = size(template, 1);
Tsizex = size(template, 2);
new_y = max(Asizey, abs(TranslateY) + Tsizey);
new_x = max(Asizex, abs(TranslateX) + Tsizex);
A_new = zeros(new_y, new_x);
T_new = A_new;

% translate
if TranslateY > 0
    Ayrange = 1:Asizey;
	Tyrange = (1:Tsizey) + TranslateY;
    if TranslateX > 0
        Axrange = 1:Asizex;
        Txrange = (1:Tsizex) + TranslateX;
        A_new(Ayrange, Axrange) = A;
        T_new(Tyrange, Txrange) = template;
    else
        Axrange = (1:Asizex) + abs(TranslateX);
        Txrange = 1:Tsizex;
        A_new(Ayrange, Axrange) = A;
        T_new(Tyrange, Txrange) = template;
    end
else
    Ayrange = (1:Asizey) + abs(TranslateY);
    Tyrange = 1:Tsizey;
    if TranslateX > 0
        Axrange = 1:Asizex;
        Txrange = (1:Tsizex) + TranslateX;
        A_new(Ayrange, Axrange) = A;
        T_new(Tyrange, Txrange) = template;
    else
        Axrange = (1:Asizex) + abs(TranslateX);
        Txrange = 1:Tsizex;
        A_new(Ayrange, Axrange) = A;
        T_new(Tyrange, Txrange) = template;
    end
end

% remove padded zeros from final image.
Merged = A_new;
empty = find(T_new~=0);
Merged(empty) = T_new(empty);
[A_new, T_new, Merged] = removezeropadding(A_new, T_new, Merged);



% great debugging tool below.
% figure
% imshow(c, [min(c(:)), max(c(:))]);
% figure
% imshow(c, [0, 255]);
% ycoords = (1:size(A,1))+floor(size(template,1)/2)
% xcoords = (1:size(A,2))+floor(size(template,2)/2)
% c(ycoords, xcoords) = A;
% imshow(c, [0, 255]);
% 
% ytrans = (1:size(template,1))+ypeak-floor(size(template,1)/2);
% xtrans = (1:size(template,2))+xpeak-floor(size(template,2)/2);
% c(ytrans, xtrans) = template;
% imshow(c, [0, 255]);

end


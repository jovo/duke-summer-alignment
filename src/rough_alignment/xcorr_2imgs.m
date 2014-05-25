function [ T_new, A_new, Merged ]= xcorr_2imgs( template, A )
%XCORR_2IMGS Rough alignment by 2D cross-correlation
%   Very basic right now; can only support translations, no rotations :(

% add zero padding as necessary for same image size.
maxy = max(size(template, 1), size(A, 1));
maxx = max(size(template, 2), size(A, 2));
Amod = zeros(maxy, maxx);
Tmod = Amod;
Amod(1:size(A, 1), 1:size(A, 2)) = A;
Tmod(1:size(template, 1), 1:size(template, 2)) = template;
A = Amod;
template = Tmod;

% 2d cross correlation
c = normxcorr2(template, A);
[ypeak, xpeak] = find(c==max(c(:)));

TranslateY = ypeak-size(template,1);
TranslateX = xpeak-size(template,2);
Asizey = size(A, 1);
Asizex = size(A, 2);
Tsizey = size(template, 1);
Tsizex = size(template, 2);
new_y = max(Asizey, abs(TranslateY) + Tsizey);
new_x = max(Asizex, abs(TranslateX) + Tsizex);
A_new = zeros(new_y, new_x);
T_new = A_new;

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
empty = find(Merged==0);
Merged(empty) = T_new(empty);

[ycoord, xcoord] = find(Merged);
A_new = A_new(min(ycoord):max(ycoord), min(xcoord):max(xcoord));
T_new = T_new(min(ycoord):max(ycoord), min(xcoord):max(xcoord));
Merged = Merged(min(ycoord):max(ycoord), min(xcoord):max(xcoord));

end


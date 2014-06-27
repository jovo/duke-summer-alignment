function [ updatedtform ] = updatetransform( templateStack, curtform, prevtform )


% compute new transformation parameters
newtform = prevtform * curtform;

% compute the actual transformation to apply.
newtparam = matrix2params(newtform);
TranslateYunrounded = newtparam(1);
TranslateXunrounded = newtparam(2);
TranslateY = round(TranslateYunrounded);
TranslateX = round(TranslateXunrounded);
THETA = newtparam(3);

% rotate TStack, determine additional shifts caused by the rotation
TStack = imrotate(templateStack, THETA);
ysizediff = (size(TStack,1)-size(templateStack,1))/2;
xsizediff = (size(TStack,2)-size(templateStack,2))/2;
TranslateY = TranslateY - round(ysizediff);
TranslateX = TranslateX - round(xsizediff);

% save the actual transformation to updatedtform
updatedtparam = zeros(1, 3);
updatedtparam(1) = ysizediff;
updatedtparam(2) = xsizediff;
updatedtparam(3) = newtparam(3);
if TranslateY > 0
    updatedtparam(1) = max(TranslateYunrounded, ysizediff);
end
if TranslateX > 0
    updatedtparam(2) = max(TranslateXunrounded, xsizediff);
end
updatedtform = params2matrix(updatedtparam);

end
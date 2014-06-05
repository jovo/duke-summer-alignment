function [ Error, s ] = errorreport( M, name, type )
%ERRORREPORT String output of the error metrics for image stack.
%   [ Error, s ] = errorreport( M, name, type ) M is the image
%   stack, name is the name of the test run, type is the type of error.
%   s is the string output of the error report.

Error = errormetrics(M, type);

s = sprintf('ERROR REPORT:\n #############################################\n');
s = [s, [' Error for image stack ', name, ':'], sprintf('\n')];
s = [s, ['Error metric: ', upper(type), sprintf('\n')]];
s = [s, sprintf('Sum: %f\n', sum(Error))];
s = [s, sprintf('Mean: %f\n', mean(Error))];
s = [s, sprintf('Median: %f\n', median(Error))];
s = [s, sprintf('Max: %f\n', max(Error))];
s = [s, sprintf('Min: %f\n', min(Error))];

end

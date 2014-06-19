function [ Error, s ] = errorreport( M, name, type )
%ERRORREPORT String output of the error metrics for image stack.
%   [ Error, s ] = errorreport( M, name, type ) M is the image
%   stack, name is the name of the test run, type is the type of error.
%   s is the string output of the error report.

% retrieve global variable
global minnonzeropercent;
if isempty(minnonzeropercent)
    minnonzeropercent = 0.3;
end

% compute error metrics
Error = errormetrics(M, type, 'warn', -1, minnonzeropercent);

% remove NaNs from error display string
disperror = Error;
disperror(isnan(disperror)) = [];

% save error display to string
s = sprintf('ERROR REPORT:\n #############################################\n');
s = [s, [' Error for image stack ', name, ':'], sprintf('\n')];
s = [s, ['Error metric: ', upper(type), sprintf('\n')]];
s = [s, sprintf('Sum: %f\n', sum(disperror))];
s = [s, sprintf('Mean: %f\n', mean(disperror))];
s = [s, sprintf('Median: %f\n', median(disperror))];
s = [s, sprintf('Max: %f\n', max(disperror))];
s = [s, sprintf('Min: %f\n', min(disperror))];

end

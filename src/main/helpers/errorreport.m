function [ Error, s ] = errorreport(config, M, name )
%ERRORREPORT String output of the error metrics for image stack.
%   [ Error, s ] = errorreport(config, M, name ) M is the image
%   stack, name is the name of the test run, s is the string output of the
%   error report. config is the struct for alignment config parameters.

% compute error metrics
Error = errormetrics(config, M, -1);

% remove NaNs from error display string
disperror = Error;
disperror(isnan(disperror)) = [];

% save error display to string
s = sprintf('ERROR REPORT:\n #############################################\n');
s = [s, [' Error for image stack ', name, ':'], sprintf('\n')];
s = [s, ['Error metric: ', upper(config.errormeasure), sprintf('\n')]];
s = [s, sprintf('Sum: %f\n', sum(disperror))];
s = [s, sprintf('Mean: %f\n', mean(disperror))];
s = [s, sprintf('Median: %f\n', median(disperror))];
s = [s, sprintf('Max: %f\n', max(disperror))];
s = [s, sprintf('Min: %f\n', min(disperror))];

end

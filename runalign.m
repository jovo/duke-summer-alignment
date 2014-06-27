function [ Aligned, Transforms ] = runalign( Transforms )
%RUNALIGN Run runalign to align everything.

tic

% align images as specified in 
if nargin == 0
    alignvars = configalignvars();
    apivars = configapivars();
    Transforms = constructimgcubetransforms( alignvars, apivars );
end

Aligned = constructimgcubealignment( ...
                                        Transforms, ...     % transforms
                                        10000, ...         % xtotalsize
                                        10000, ...         % ytotalsize
                                        5, ...              % ztotalsize
                                        20000, ...              % xoffset
                                        20000, ...              % yoffset
                                        5 ...               % zoffset
                                  );

toc

%RUNALIGN Run runalign to align everything.

tic

% align all images from specific token
Transforms = constructimgcubetransforms( ...
                                            'lee14', ...    % token
                                            2, ...          % resolution
                                            5000, ...     % xtotalsize
                                            5000, ...     % ytotalsize
                                            5, ...          % ztotalsize
                                            1024, ...       % xsubsize
                                            1024, ...       % ysubsize
                                            2, ...          % zsubsize
                                            20000, ...          % xoffset
                                            20000, ...          % yoffset
                                            5, ...          % zoffset
                                            6 ...           % worker size
                                       );

Merged = constructimgcubealignment( ...
                                        Transforms, ...     % transforms
                                        5000, ...         % xtotalsize
                                        5000, ...         % ytotalsize
                                        5, ...              % ztotalsize
                                        20000, ...              % xoffset
                                        20000, ...              % yoffset
                                        5 ...               % zoffset
                                  );

toc

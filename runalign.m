%RUNALIGN Run runalign to align everything.

% align all images from specific token
Transforms = constructimgcubetransforms( ...
                                            'lee14', ...    % token
                                            4, ...          % resolution
                                            intmax, ...     % xtotalsize
                                            intmax, ...     % ytotalsize
                                            6, ...          % ztotalsize
                                            1024, ...       % xsubsize
                                            1024, ...       % ysubsize
                                            2, ...          % zsubsize
                                            0, ...          % xoffset
                                            0, ...          % yoffset
                                            0, ...          % zoffset
                                            6 ...           % worker size
                                       );

Merged = constructimgcubealignment( ...
                                        Transforms, ...     % transforms
                                        intmax, ...         % xtotalsize
                                        intmax, ...         % ytotalsize
                                        5, ...              % ztotalsize
                                        0, ...              % xoffset
                                        0, ...              % yoffset
                                        0 ...               % zoffset
                                  );

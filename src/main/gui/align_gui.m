function align_gui
% ALIGNGUI GUI for visualizing alignment data in depth.

    % Create GUI
    H.f = figure(...
                        'Visible', 'off',    ...
                        'MenuBar', 'none',   ...
                        'Toolbar', 'figure', ...
                        'Position', [0, 0, 500, 400]);

    % GUI variables
    imagename = 'Enter variable name here. Then click ''open''. -->';
    imagestack = membrane;
    
    % GUI components
    H.imagename = uicontrol('Style', 'edit', 'String', imagename, ...
            'Position', [10, 370, 380, 25]);
    H.zslider = uicontrol('Style', 'slider', 'Min', 0,'Max', 1, ...
            'Value', 1, 'SliderStep', [1, 10], ...
            'Position', [50, 10, 250, 20]);
    H.openvar = uicontrol('Style', 'pushbutton', 'String', 'Open', ...
            'Position', [400, 370, 70, 25]);
    H.imgindex = uicontrol('Style', 'text', 'String', 1, ...
            'Position', [10, 10, 30, 20]);
    H.a = axes('Units', 'Pixels', 'Position', [10, 40, 300, 300]);
    
    % Set callbacks
    set(H.zslider, 'Callback', {@slider_Callback, H});
    set(H.openvar, 'Callback', {@openvar_Callback, H});
    
    % Initialize GUI
    set([H.f, H.a, H.imagename, H.openvar, H.imgindex, H.zslider], 'Units', 'normalized');
    imshow(membrane);
    set(H.f, 'Name', 'Image Stack viewer')
    movegui(H.f, 'center')
    set(H.f, 'Visible', 'on');

    % GUI callbacks
    function openvar_Callback(varargin)
        handles = varargin{3};
        
        varname = get(handles.imagename, 'String');
        try
            imagestack = uint8(evalin('base', varname));
            depth = size(imagestack, 3);
            set(handles.imgindex, 'String', '1');
            set(handles.zslider, 'Max', depth);
            set(handles.zslider, 'SliderStep', [1, 10]./depth);
            dispimage = imagestack(:, :, 1);
            imshow(dispimage);
        catch
            disp(['variable ''', varname, ''' doesn''t exist in workspace']);
        end
    end

    function slider_Callback(varargin)
        hObj = varargin{1};
        handles = varargin{3};
        
        imgindex = floor(get(hObj, 'Value'));
        if ~imgindex
            imgindex = 1;
        end
        set(handles.imgindex, 'String', int2str(imgindex));
        dispimage = imagestack(:, :, imgindex);
        imshow(dispimage);
    end
end 

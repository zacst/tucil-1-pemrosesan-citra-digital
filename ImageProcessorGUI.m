function ImageProcessorGUI()
% ImageProcessorGUI A graphical user interface for basic image processing operations.
%
% To run, place this file in the root directory. The helper functions
% should be organized in the following subdirectories:
%   - ./CustomHistogram/customHistogram.m
%   - ./ImageTransformations/imageTransformations.m
%   - ./HistogramEqualization/histogramEqualization.m
%   - ./HistogramSpecification/histogramSpecification.m
%
% Then, execute 'ImageProcessorGUI' in the MATLAB Command Window.

    % --- Add subdirectories to the MATLAB path ---
    try
        current_folder = fileparts(mfilename('fullpath'));
        addpath(genpath(fullfile(current_folder, 'CustomHistogram')));
        addpath(genpath(fullfile(current_folder, 'ImageTransformations')));
        addpath(genpath(fullfile(current_folder, 'HistogramEqualization')));
        addpath(genpath(fullfile(current_folder, 'HistogramSpecification')));
    catch ME
        warning('Could not automatically add subdirectories to the path. Please ensure they are added manually. Error: %s', ME.message);
    end

    % --- Main Figure and Component Creation ---
    fig = figure('Name', 'Image Processor GUI', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1200, 700], 'MenuBar', 'none', 'ToolBar', 'none');

    % --- Initialize App State ---
    app.originalImage = [];
    app.targetImage = [];
    app.handles = struct();

    % --- Panels for Organization ---
    panel_controls = uipanel('Title', 'Controls', 'Position', [0.02, 0.5, 0.2, 0.45]);
    panel_params = uipanel('Title', 'Parameters', 'Position', [0.02, 0.05, 0.2, 0.44]);
    panel_images = uipanel('Title', 'Image Comparison', 'Position', [0.24, 0.05, 0.74, 0.9]);

    % --- Axes for Display ---
    app.handles.ax_original = subplot(2, 2, 1, 'Parent', panel_images);
    title(app.handles.ax_original, 'Original Image'); axis(app.handles.ax_original, 'off');
    
    app.handles.ax_processed = subplot(2, 2, 2, 'Parent', panel_images);
    title(app.handles.ax_processed, 'Processed Image'); axis(app.handles.ax_processed, 'off');

    app.handles.ax_hist_original = subplot(2, 2, 3, 'Parent', panel_images);
    title(app.handles.ax_hist_original, 'Original Histogram');
    
    app.handles.ax_hist_processed = subplot(2, 2, 4, 'Parent', panel_images);
    title(app.handles.ax_hist_processed, 'Processed Histogram');

    % --- Control Components ---
    app.handles.btn_load = uicontrol(panel_controls, 'Style', 'pushbutton', 'String', '1. Load Image', ...
        'Position', [10, 190, 200, 30], 'Callback', @loadImage);
    
    app.handles.popup_operation = uicontrol(panel_controls, 'Style', 'popupmenu', ...
        'String', {'Select Operation...', 'Brightening', 'Negative', 'Log Transform', ...
                   'Exponent Transform', 'Contrast Stretching', 'Histogram Equalization', 'Histogram Specification'}, ...
        'Position', [10, 150, 200, 30], 'Callback', @selectOperation, 'Enable', 'off');

    app.handles.btn_load_target = uicontrol(panel_controls, 'Style', 'pushbutton', 'String', '2. Load Target Image', ...
        'Position', [10, 110, 200, 30], 'Callback', @loadTarget, 'Visible', 'off');
        
    app.handles.btn_apply = uicontrol(panel_controls, 'Style', 'pushbutton', 'String', '3. Apply', ...
        'Position', [10, 50, 200, 40], 'Callback', @applyOperation, 'Enable', 'off', 'FontSize', 12);

    % --- Parameter Components (created invisible) ---
    app.handles.all_param_controls = {}; % Cell array to hold all param handles
    app = createParam(app, panel_params, 'A (scale):', 'edit_a', 1.2, 1);
    app = createParam(app, panel_params, 'B (offset):', 'edit_b', 30, 2);
    app = createParam(app, panel_params, 'C (const):', 'edit_c', 45, 3);
    app = createParam(app, panel_params, 'R (offset):', 'edit_r', 1, 4);
    app = createParam(app, panel_params, 'Y (gamma):', 'edit_y', 1.1, 5);
    
    % --- Store the app structure using guidata ---
    guidata(fig, app);
    
    % --- Callback Functions ---
    
    function loadImage(hObject, ~)
        app = guidata(hObject); % Retrieve app data
        [file, path] = uigetfile({'*.png'; '*.jpg'; '*.bmp'}, 'Select an Image');
        if isequal(file, 0); return; end
        
        app.originalImage = imread(fullfile(path, file));
        
        imshow(app.originalImage, 'Parent', app.handles.ax_original);
        title(app.handles.ax_original, 'Original Image');
        
        plotHistogram(app.handles.ax_hist_original, app.originalImage);
        
        cla(app.handles.ax_processed); cla(app.handles.ax_hist_processed);
        title(app.handles.ax_processed, 'Processed Image'); title(app.handles.ax_hist_processed, 'Processed Histogram');
        axis(app.handles.ax_processed, 'off');
        
        set(app.handles.popup_operation, 'Enable', 'on', 'Value', 1);
        set(app.handles.btn_apply, 'Enable', 'on');
        
        guidata(hObject, app); % Save updated app data
        selectOperation(app.handles.popup_operation, []); % Update param visibility
    end

    function loadTarget(hObject, ~)
        app = guidata(hObject); % Retrieve app data
        [file, path] = uigetfile({'*.png'; '*.jpg'; '*.bmp'}, 'Select a Target Image');
        if isequal(file, 0); return; end
        app.targetImage = imread(fullfile(path, file));
        msgbox('Target image loaded successfully!', 'Success');
        guidata(hObject, app); % Save updated app data
    end

    function selectOperation(hObject, ~)
        app = guidata(hObject); % Retrieve app data
        if isempty(app) || ~isfield(app, 'handles'), return; end % Guard clause
        
        idx = get(app.handles.popup_operation, 'Value');
        
        for i = 1:length(app.handles.all_param_controls)
            set(app.handles.all_param_controls{i}, 'Visible', 'off');
        end
        set(app.handles.btn_load_target, 'Visible', 'off');
        
        switch idx
            case 2 % Brightening
                set([app.handles.label_a, app.handles.edit_a, app.handles.label_b, app.handles.edit_b], 'Visible', 'on');
                % Debug: Check if handles exist and visibility is set
                fprintf('label_a visible: %s\n', get(app.handles.label_a, 'Visible'));
                fprintf('edit_a visible: %s\n', get(app.handles.edit_a, 'Visible'));
            case 4 % Log Transform
                set([app.handles.label_c, app.handles.edit_c, app.handles.label_r, app.handles.edit_r], 'Visible', 'on');
            case 5 % Exponent Transform
                set([app.handles.label_c, app.handles.edit_c, app.handles.label_y, app.handles.edit_y], 'Visible', 'on');
            case 8 % Histogram Specification
                set(app.handles.btn_load_target, 'Visible', 'on');
        end
        drawnow;
    end
    
    function applyOperation(hObject, ~)
        app = guidata(hObject); % Retrieve app data
        if isempty(app.originalImage); errordlg('Please load an image first.'); return; end
        
        idx = get(app.handles.popup_operation, 'Value');
        if idx == 1; errordlg('Please select an operation.'); return; end
        
        processedImage = [];
        
        try
            if idx >= 2 && idx <= 6
                params = struct();
                params.brighten.a = str2double(get(app.handles.edit_a, 'String'));
                params.brighten.b = str2double(get(app.handles.edit_b, 'String'));
                params.log.c = str2double(get(app.handles.edit_c, 'String'));
                params.log.r = str2double(get(app.handles.edit_r, 'String'));
                params.exponent.c = str2double(get(app.handles.edit_c, 'String'));
                params.exponent.y = str2double(get(app.handles.edit_y, 'String'));
                
                transformed_images = imageTransformations(app.originalImage, params);
                
                switch idx
                    case 2; processedImage = transformed_images.brighten;
                    case 3; processedImage = transformed_images.negative;
                    case 4; processedImage = transformed_images.log;
                    case 5; processedImage = transformed_images.exponent;
                    case 6; processedImage = transformed_images.contrast;
                end
            else
                switch idx
                    case 7
                        processedImage = histogramEqualization(app.originalImage);
                    case 8
                        if isempty(app.targetImage); errordlg('Please load a target image first.'); return; end
                        processedImage = histogramSpecification(app.originalImage, app.targetImage);
                end
            end

            if isempty(processedImage)
                errordlg('The selected operation did not produce a result.', 'Operation Failed');
                return;
            end

            imshow(processedImage, 'Parent', app.handles.ax_processed);
            title(app.handles.ax_processed, 'Processed Image');
            plotHistogram(app.handles.ax_hist_processed, processedImage);

        catch ME
            errordlg(['An error occurred: ' ME.message], 'Error');
        end
    end

    % --- Helper Functions ---

    function app_out = createParam(app_in, parent, labelText, editTag, defaultValue, position)
        app_out = app_in;
        
        % Calculate from bottom, with proper spacing
        y_pos = 280 - (position * 40);  % Start from a fixed high point and go down
        
        label_h = uicontrol(parent, 'Style', 'text', 'String', labelText, ...
            'Position', [10, y_pos, 80, 20], ...
            'HorizontalAlignment', 'right', ...
            'Visible', 'off', ...
            'BackgroundColor', get(parent, 'BackgroundColor'), ...
            'ForegroundColor', 'black');
        
        edit_h = uicontrol(parent, 'Style', 'edit', ...
            'String', num2str(defaultValue), ...
            'Position', [100, y_pos, 100, 20], ...
            'Visible', 'off', ...
            'BackgroundColor', 'white', ...
            'ForegroundColor', 'black');
        
        param_name = strrep(editTag, 'edit_', '');
        app_out.handles.(['label_' param_name]) = label_h;
        app_out.handles.(editTag) = edit_h;
        
        app_out.handles.all_param_controls{end+1} = label_h;
        app_out.handles.all_param_controls{end+1} = edit_h;
    end

    function plotHistogram(ax, img)
        if size(img, 3) == 3
            data = rgb2gray(img);
        else
            data = img;
        end
        [counts, centers] = customHistogram(data, 256);
        bar(ax, centers, counts, 'hist');
        xlim(ax, [0 255]);
        xlabel(ax, 'Pixel Value');
        ylabel(ax, 'Frequency');
        grid(ax, 'on');
    end
end


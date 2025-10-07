function ImageProcessorGUI()
% ImageProcessorGUI A modern graphical user interface for image processing.
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

    % --- UI Theme and Colors ---
    colors.background = [0.94, 0.94, 0.94]; % Light gray
    colors.panel = [0.98, 0.98, 0.98];      % Off-white for panels
    colors.text = [0.2, 0.2, 0.2];         % Dark gray for text
    colors.accent = [0.07, 0.62, 1.0];     % A nice, bright blue
    colors.accent_dark = [0.0, 0.45, 0.74];% A darker blue for accents
    colors.accent_text = [1, 1, 1];         % White text on accent colors
    
    font.name = 'Segoe UI';
    font.size = 10;
    font.title_size = 12;

    % --- Main Figure ---
    fig = figure('Name', 'Image Processing Studio', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1300, 750], 'MenuBar', 'none', 'ToolBar', 'none', ...
                 'Color', colors.background);

    % --- Initialize App State ---
    app.originalImage = [];
    app.targetImage = [];
    app.handles = struct();

    % --- Panels for Organization ---
    panel_props = {'BackgroundColor', colors.panel, 'ForegroundColor', colors.text, ...
                   'FontName', font.name, 'FontSize', font.title_size, 'FontWeight', 'bold'};
               
    panel_controls = uipanel('Title', 'Workflow', 'Position', [0.02, 0.05, 0.22, 0.9], panel_props{:});
    panel_images = uipanel('Title', 'Image Preview & Analysis', 'Position', [0.26, 0.05, 0.72, 0.9], panel_props{:});

    % --- Axes for Display ---
    app.handles.ax_original = subplot(2, 2, 1, 'Parent', panel_images);
    title(app.handles.ax_original, 'Original Image', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);
    axis(app.handles.ax_original, 'off');
    
    app.handles.ax_processed = subplot(2, 2, 2, 'Parent', panel_images);
    title(app.handles.ax_processed, 'Processed Image', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);
    axis(app.handles.ax_processed, 'off');

    app.handles.ax_hist_original = subplot(2, 2, 3, 'Parent', panel_images);
    title(app.handles.ax_hist_original, 'Original Histogram', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);
    
    app.handles.ax_hist_processed = subplot(2, 2, 4, 'Parent', panel_images);
    title(app.handles.ax_hist_processed, 'Processed Histogram', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);

    % --- Control Components ---
    control_props = {'FontName', font.name, 'FontSize', font.size, 'BackgroundColor', [1 1 1], 'ForegroundColor', colors.text};
    
    uicontrol(panel_controls, 'Style', 'text', 'String', 'Step 1: Load your base image', 'Position', [20, 620, 240, 25], 'HorizontalAlignment', 'left', 'FontSize', font.size+1, 'FontWeight', 'bold', 'BackgroundColor', colors.panel);
    app.handles.btn_load = uicontrol(panel_controls, 'Style', 'pushbutton', 'String', 'Select Image...', ...
        'Position', [20, 580, 240, 35], 'Callback', @loadImage, control_props{:});
    
    uicontrol(panel_controls, 'Style', 'text', 'String', 'Step 2: Choose an operation', 'Position', [20, 520, 240, 25], 'HorizontalAlignment', 'left', 'FontSize', font.size+1, 'FontWeight', 'bold', 'BackgroundColor', colors.panel);
    app.handles.popup_operation = uicontrol(panel_controls, 'Style', 'popupmenu', ...
        'String', {'Select Operation...', 'Brightening', 'Negative', 'Log Transform', ...
                   'Exponent Transform', 'Contrast Stretching', 'Histogram Equalization', 'Histogram Specification'}, ...
        'Position', [20, 480, 240, 35], 'Callback', @selectOperation, 'Enable', 'off', control_props{:});

    % --- Dynamic Parameter Panel within Controls ---
    panel_params = uipanel(panel_controls, 'Title', 'Step 2b: Adjust Parameters', 'Position', [0.05, 0.2, 0.9, 0.45], panel_props{:});
    
    app.handles.btn_load_target = uicontrol(panel_params, 'Style', 'pushbutton', 'String', 'Select Target Image...', ...
        'Position', [20, 200, 200, 35], 'Callback', @loadTarget, 'Visible', 'off', control_props{:});
        
    uicontrol(panel_controls, 'Style', 'text', 'String', 'Step 3: Apply changes', 'Position', [20, 80, 240, 25], 'HorizontalAlignment', 'left', 'FontSize', font.size+1, 'FontWeight', 'bold', 'BackgroundColor', colors.panel);
    app.handles.btn_apply = uicontrol(panel_controls, 'Style', 'pushbutton', 'String', 'Apply Transformation', ...
        'Position', [20, 40, 240, 40], 'Callback', @applyOperation, 'Enable', 'off', ...
        'FontSize', font.title_size, 'FontWeight', 'bold', 'BackgroundColor', colors.accent_dark, 'ForegroundColor', colors.accent_text);

    % --- Parameter Components (created invisible) ---
    app.handles.all_param_controls = {};
    app = createParam(app, panel_params, 'Scale (A):', 'edit_a', 1.2, 1);
    app = createParam(app, panel_params, 'Offset (B):', 'edit_b', 30, 2);
    app = createParam(app, panel_params, 'Constant (C):', 'edit_c', 45, 3);
    app = createParam(app, panel_params, 'Offset (R):', 'edit_r', 1, 4);
    app = createParam(app, panel_params, 'Gamma (Y):', 'edit_y', 1.1, 5);
    
    % --- Store the app structure using guidata ---
    guidata(fig, app);
    
    % --- Callback Functions ---
    
    function loadImage(hObject, ~)
        app = guidata(hObject);
        [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp', 'Image Files (*.png, *.jpg, *.bmp)'}, 'Select an Image');
        if isequal(file, 0); return; end
        
        app.originalImage = imread(fullfile(path, file));
        imshow(app.originalImage, 'Parent', app.handles.ax_original);
        title(app.handles.ax_original, 'Original Image');
        plotHistogram(app.handles.ax_hist_original, app.originalImage);
        
        cla(app.handles.ax_processed, 'reset'); cla(app.handles.ax_hist_processed, 'reset');
        title(app.handles.ax_processed, 'Processed Image'); title(app.handles.ax_hist_processed, 'Processed Histogram');
        axis(app.handles.ax_processed, 'off');
        
        set(app.handles.popup_operation, 'Enable', 'on', 'Value', 1);
        set(app.handles.btn_apply, 'Enable', 'on');
        
        guidata(hObject, app);
        selectOperation(app.handles.popup_operation, []);
    end

    function loadTarget(hObject, ~)
        app = guidata(hObject);
        [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp', 'Image Files'}, 'Select a Target Image');
        if isequal(file, 0); return; end
        app.targetImage = imread(fullfile(path, file));
        msgbox('Target image loaded successfully!', 'Success');
        guidata(hObject, app);
    end

    function selectOperation(hObject, ~)
        app = guidata(hObject);
        if isempty(app) || ~isfield(app, 'handles'), return; end
        idx = get(app.handles.popup_operation, 'Value');
        
        cellfun(@(x) set(x, 'Visible', 'off'), app.handles.all_param_controls);
        set(app.handles.btn_load_target, 'Visible', 'off');
        
        switch idx
            case 2 % Brightening
                set([app.handles.label_a, app.handles.edit_a, app.handles.label_b, app.handles.edit_b], 'Visible', 'on');
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
        app = guidata(hObject);
        if isempty(app.originalImage); errordlg('Please load an image first.'); return; end
        idx = get(app.handles.popup_operation, 'Value');
        if idx == 1; errordlg('Please select an operation.'); return; end
        
        processedImage = [];
        try
            params = struct();
            params.brighten.a = str2double(get(app.handles.edit_a, 'String'));
            params.brighten.b = str2double(get(app.handles.edit_b, 'String'));
            params.log.c = str2double(get(app.handles.edit_c, 'String'));
            params.log.r = str2double(get(app.handles.edit_r, 'String'));
            params.exponent.c = str2double(get(app.handles.edit_c, 'String'));
            params.exponent.y = str2double(get(app.handles.edit_y, 'String'));
            
            switch idx
                case {2, 3, 4, 5, 6}
                    transformed_images = imageTransformations(app.originalImage, params);
                    switch idx
                        case 2; processedImage = transformed_images.brighten;
                        case 3; processedImage = transformed_images.negative;
                        case 4; processedImage = transformed_images.log;
                        case 5; processedImage = transformed_images.exponent;
                        case 6; processedImage = transformed_images.contrast;
                    end
                case 7
                    processedImage = histogramEqualization(app.originalImage);
                case 8
                    if isempty(app.targetImage); errordlg('Please load a target image first.'); return; end
                    processedImage = histogramSpecification(app.originalImage, app.targetImage);
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
        y_pos = parent.Position(4) - 40 - (position * 40);
        
        label_h = uicontrol(parent, 'Style', 'text', 'String', labelText, 'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'right', 'Visible', 'off', 'BackgroundColor', colors.panel, 'ForegroundColor', colors.text, 'FontSize', font.size, 'FontName', font.name);
        edit_h = uicontrol(parent, 'Style', 'edit', 'String', num2str(defaultValue), 'Position', [110, y_pos, 110, 25], 'Visible', 'off', 'BackgroundColor', [1 1 1], 'ForegroundColor', colors.text, 'FontSize', font.size, 'FontName', font.name);
        
        param_name = strrep(editTag, 'edit_', '');
        app_out.handles.(['label_' param_name]) = label_h;
        app_out.handles.(editTag) = edit_h;
        
        app_out.handles.all_param_controls{end+1} = label_h;
        app_out.handles.all_param_controls{end+1} = edit_h;
    end

    function plotHistogram(ax, img)
        cla(ax, 'reset');
        if size(img, 3) == 3
            data = rgb2gray(img);
        else
            data = img;
        end
        [counts, centers] = customHistogram(data, 256);
        bar(ax, centers, counts, 'hist', 'FaceColor', colors.accent_dark, 'EdgeColor', 'none');
        xlim(ax, [0 255]);
        xlabel(ax, 'Pixel Value', 'Color', colors.text);
        ylabel(ax, 'Frequency', 'Color', colors.text);
        set(ax, 'Color', colors.panel, 'XColor', colors.text, 'YColor', colors.text);
        grid(ax, 'on');
        box(ax, 'on');
    end
end


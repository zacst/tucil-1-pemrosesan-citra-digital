function ImageProcessorGUI()
% ImageProcessorGUI A modern, responsive graphical user interface for image processing.
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
    colors.text = [0.2, 0.2, 0.2];          % Dark gray for text
    colors.accent = [0.07, 0.62, 1.0];      % Bright blue
    colors.accent_dark = [0.0, 0.45, 0.74]; % Darker blue
    colors.accent_text = [1, 1, 1];         % White text
    colors.custom_hist = [0.9, 0.2, 0.2];   % Red for custom histogram
    colors.library_hist = [0.2, 0.7, 0.3];  % Green for library histogram
    
    font.name = 'Segoe UI';
    font.size = 10;
    font.title_size = 12;

    % --- Main Figure ---
    fig = figure('Name', 'Image Processing Studio', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1300, 750], 'MenuBar', 'none', 'ToolBar', 'none', ...
                 'Color', colors.background, 'Resize', 'on');

    % --- Initialize App State ---
    app.originalImage = [];
    app.targetImage = [];
    app.handles = struct();
    app.useCustomHistogram = true; % Default to custom histogram
    app.colors = colors;
    app.font = font;

    % --- Panels for Organization ---
    panel_props = {'BackgroundColor', colors.panel, 'ForegroundColor', colors.text, ...
                   'FontName', font.name, 'FontSize', font.title_size, 'FontWeight', 'bold'};
               
    app.handles.panel_controls = uipanel('Title', 'Workflow', 'Position', [0.02, 0.05, 0.22, 0.9], ...
        'Units', 'normalized', panel_props{:});
    app.handles.panel_images = uipanel('Title', 'Image Preview & Analysis', 'Position', [0.26, 0.05, 0.72, 0.9], ...
        'Units', 'normalized', panel_props{:});

    % --- Axes for Display ---
    app.handles.ax_original = subplot(2, 2, 1, 'Parent', app.handles.panel_images);
    title(app.handles.ax_original, 'Original Image', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);
    axis(app.handles.ax_original, 'off');
    
    app.handles.ax_processed = subplot(2, 2, 2, 'Parent', app.handles.panel_images);
    title(app.handles.ax_processed, 'Processed Image', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);
    axis(app.handles.ax_processed, 'off');

    app.handles.ax_hist_original = subplot(2, 2, 3, 'Parent', app.handles.panel_images);
    title(app.handles.ax_hist_original, 'Original Histogram', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);
    
    app.handles.ax_hist_processed = subplot(2, 2, 4, 'Parent', app.handles.panel_images);
    title(app.handles.ax_hist_processed, 'Processed Histogram', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);

    % --- Control Components ---
    control_props = {'FontName', font.name, 'FontSize', font.size, 'BackgroundColor', [1 1 1], ...
                     'ForegroundColor', colors.text};
    
    uicontrol(app.handles.panel_controls, 'Style', 'text', 'String', 'Step 1: Load your base image', ...
        'Position', [20, 620, 240, 25], 'HorizontalAlignment', 'left', ...
        'FontSize', font.size+1, 'FontWeight', 'bold', 'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.text);
    
    app.handles.btn_load = uicontrol(app.handles.panel_controls, 'Style', 'pushbutton', ...
        'String', 'Select Image...', 'Position', [20, 580, 240, 35], ...
        'Callback', @loadImage, control_props{:});
    
    uicontrol(app.handles.panel_controls, 'Style', 'text', 'String', 'Step 2: Choose an operation', ...
        'Position', [20, 530, 240, 25], 'HorizontalAlignment', 'left', ...
        'FontSize', font.size+1, 'FontWeight', 'bold', 'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.text);
    
    app.handles.popup_operation = uicontrol(app.handles.panel_controls, 'Style', 'popupmenu', ...
        'String', {'Select Operation...', 'Brightening', 'Negative', 'Log Transform', ...
                   'Exponent Transform', 'Contrast Stretching', 'All Transformations', ...
                   'Histogram Equalization', 'Histogram Specification'}, ...
        'Position', [20, 490, 240, 35], 'Callback', @selectOperation, ...
        'Enable', 'off', control_props{:});

    % --- Histogram Method Selection ---
    uicontrol(app.handles.panel_controls, 'Style', 'text', 'String', 'Histogram Method:', ...
        'Position', [20, 450, 240, 20], 'HorizontalAlignment', 'left', ...
        'FontSize', font.size, 'FontWeight', 'bold', 'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.text);
    
    app.handles.radio_custom = uicontrol(app.handles.panel_controls, 'Style', 'radiobutton', ...
        'String', 'Custom Histogram', 'Position', [25, 425, 210, 20], ...
        'Value', 1, 'Callback', @selectHistogramMethod, ...
        'BackgroundColor', colors.panel, 'ForegroundColor', colors.text, ...
        'FontSize', font.size);
    
    app.handles.radio_library = uicontrol(app.handles.panel_controls, 'Style', 'radiobutton', ...
        'String', 'MATLAB Library (imhist)', 'Position', [25, 400, 210, 20], ...
        'Value', 0, 'Callback', @selectHistogramMethod, ...
        'BackgroundColor', colors.panel, 'ForegroundColor', colors.text, ...
        'FontSize', font.size);
    
    app.handles.checkbox_compare = uicontrol(app.handles.panel_controls, 'Style', 'checkbox', ...
        'String', 'Compare Both Methods', 'Position', [25, 375, 210, 20], ...
        'Value', 0, 'Callback', @updateHistograms, ...
        'BackgroundColor', colors.panel, 'ForegroundColor', colors.text, ...
        'FontSize', font.size);

    % --- Dynamic Parameter Panel within Controls ---
    app.handles.panel_params = uipanel(app.handles.panel_controls, 'Title', 'Step 2b: Adjust Parameters', ...
        'Units', 'pixels', 'Position', [15, 140, 250, 220], panel_props{:});
    
    app.handles.btn_load_target = uicontrol(app.handles.panel_params, 'Style', 'pushbutton', ...
        'String', 'Select Target Image...', 'Position', [20, 150, 210, 35], ...
        'Callback', @loadTarget, 'Visible', 'off', control_props{:});
        
    uicontrol(app.handles.panel_controls, 'Style', 'text', 'String', 'Step 3: Apply changes', ...
        'Position', [20, 90, 240, 25], 'HorizontalAlignment', 'left', ...
        'FontSize', font.size+1, 'FontWeight', 'bold', 'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.text);
    
    app.handles.btn_apply = uicontrol(app.handles.panel_controls, 'Style', 'pushbutton', ...
        'String', 'Apply Transformation', 'Position', [20, 40, 240, 40], ...
        'Callback', @applyOperation, 'Enable', 'off', 'FontSize', font.title_size, ...
        'FontWeight', 'bold', 'BackgroundColor', colors.accent_dark, ...
        'ForegroundColor', colors.accent_text);

    % --- Parameter Components (created invisible) ---
    app.handles.all_param_controls = {};
    app = createParam(app, app.handles.panel_params, 'Scale (A):', 'edit_a', 1.2, 1);
    app = createParam(app, app.handles.panel_params, 'Offset (B):', 'edit_b', 30, 2);
    app = createParam(app, app.handles.panel_params, 'Constant (C):', 'edit_c', 45, 3);
    app = createParam(app, app.handles.panel_params, 'Offset (R):', 'edit_r', 1, 4);
    app = createParam(app, app.handles.panel_params, 'Gamma (Y):', 'edit_y', 1.1, 5);
    
    % --- Store the app structure using guidata ---
    guidata(fig, app);
    
    % --- Set resize callback after app is initialized ---
    set(fig, 'SizeChangedFcn', @resizeCallback);
    
    % --- Callback Functions ---
    
    function resizeCallback(hObject, ~)
        % Handle responsive layout adjustments if needed
        app = guidata(hObject);
        if isempty(app) || ~isfield(app, 'originalImage')
            return;
        end
        if ~isempty(app.originalImage)
            updateHistograms(hObject, []);
        end
    end
    
    function selectHistogramMethod(hObject, ~)
        app = guidata(hObject);
        
        % Update radio button states
        if hObject == app.handles.radio_custom
            set(app.handles.radio_custom, 'Value', 1);
            set(app.handles.radio_library, 'Value', 0);
            app.useCustomHistogram = true;
        else
            set(app.handles.radio_custom, 'Value', 0);
            set(app.handles.radio_library, 'Value', 1);
            app.useCustomHistogram = false;
        end
        
        guidata(hObject, app);
        updateHistograms(hObject, []);
    end
    
    function updateHistograms(hObject, ~)
        app = guidata(hObject);
        if ~isempty(app.originalImage)
            plotHistogram(app.handles.ax_hist_original, app.originalImage, app);
        end
        if ~isempty(app.handles.ax_hist_processed.Children)
            % Get processed image from the axes
            img_children = findobj(app.handles.ax_processed, 'Type', 'image');
            if ~isempty(img_children)
                processedImage = img_children(1).CData;
                plotHistogram(app.handles.ax_hist_processed, processedImage, app);
            end
        end
    end
    
    function loadImage(hObject, ~)
        app = guidata(hObject);
        [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp', 'Image Files (*.png, *.jpg, *.bmp)'}, 'Select an Image');
        if isequal(file, 0); return; end
        
        app.originalImage = imread(fullfile(path, file));
        imshow(app.originalImage, 'Parent', app.handles.ax_original);
        title(app.handles.ax_original, 'Original Image', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);
        plotHistogram(app.handles.ax_hist_original, app.originalImage, app);
        
        cla(app.handles.ax_processed, 'reset'); 
        cla(app.handles.ax_hist_processed, 'reset');
        title(app.handles.ax_processed, 'Processed Image', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name); 
        title(app.handles.ax_hist_processed, 'Processed Histogram', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);
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
        
        % --- First, hide everything ---
        cellfun(@(x) set(x, 'Visible', 'off'), app.handles.all_param_controls);
        set(app.handles.btn_load_target, 'Visible', 'off');
        
        % --- Then, show only what's needed for the selected operation ---
        switch idx
            case 1 % Select Operation...
                % Nothing to show
                
            case 2 % Brightening
                set([app.handles.label_a, app.handles.edit_a, app.handles.label_b, app.handles.edit_b], 'Visible', 'on');
            
            case 3 % Negative
                % No parameters needed
                
            case 4 % Log Transform
                set([app.handles.label_c, app.handles.edit_c, app.handles.label_r, app.handles.edit_r], 'Visible', 'on');
            
            case 5 % Exponent Transform
                set([app.handles.label_c, app.handles.edit_c, app.handles.label_y, app.handles.edit_y], 'Visible', 'on');
            
            case 6 % Contrast Stretching
                % No parameters needed
                
            case 7 % All Transformations
                set([app.handles.label_a, app.handles.edit_a, app.handles.label_b, app.handles.edit_b, ...
                     app.handles.label_c, app.handles.edit_c, app.handles.label_r, app.handles.edit_r, ...
                     app.handles.label_y, app.handles.edit_y], 'Visible', 'on');
            
            case 8 % Histogram Equalization
                % No parameters needed
                
            case 9 % Histogram Specification
                set(app.handles.btn_load_target, 'Visible', 'on');
        end
        drawnow; % Ensure the UI updates immediately
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
                case 7 % All Transformations
                    showAllTransformations(app, params);
                    return; % Early return since we handle display differently
                case 8
                    processedImage = histogramEqualization(app.originalImage);
                case 9
                    if isempty(app.targetImage); errordlg('Please load a target image first.'); return; end
                    processedImage = histogramSpecification(app.originalImage, app.targetImage);
            end

            if isempty(processedImage)
                errordlg('The selected operation did not produce a result.', 'Operation Failed');
                return;
            end

            imshow(processedImage, 'Parent', app.handles.ax_processed);
            title(app.handles.ax_processed, 'Processed Image', 'Color', colors.text, 'FontSize', font.title_size, 'FontName', font.name);
            plotHistogram(app.handles.ax_hist_processed, processedImage, app);
        catch ME
            errordlg(['An error occurred: ' ME.message], 'Error');
        end
    end

    function showAllTransformations(app, params)
        % Create a new figure to show all transformations
        transformFig = figure('Name', 'All Image Transformations', 'NumberTitle', 'off', ...
                              'Position', [150, 150, 1400, 900], 'Color', colors.background);
        
        transformed_images = imageTransformations(app.originalImage, params);
        transformations = {'Original', 'Brightening', 'Negative', 'Log Transform', ...
                          'Exponent Transform', 'Contrast Stretching'};
        images = {app.originalImage, transformed_images.brighten, transformed_images.negative, ...
                  transformed_images.log, transformed_images.exponent, transformed_images.contrast};
        
        for i = 1:6
            % Image display
            subplot(3, 4, (i-1)*2 + 1);
            imshow(images{i});
            title(transformations{i}, 'FontSize', font.title_size, 'FontWeight', 'bold', 'Color', colors.text);
            
            % Histogram display
            ax_hist = subplot(3, 4, (i-1)*2 + 2);
            plotHistogram(ax_hist, images{i}, app);
            title([transformations{i} ' Histogram'], 'FontSize', font.size, 'Color', colors.text);
        end
        
        % Add a note
        annotation(transformFig, 'textbox', [0.35, 0.01, 0.3, 0.03], ...
                   'String', 'All transformations applied with current parameters', ...
                   'HorizontalAlignment', 'center', 'EdgeColor', 'none', ...
                   'FontSize', font.size, 'FontWeight', 'bold', 'Color', colors.text);
    end

    % --- Helper Functions ---
    
    function app_out = createParam(app_in, parent, labelText, editTag, defaultValue, position)
        app_out = app_in;
        y_pos = 180 - (position * 30);
        
        label_h = uicontrol(parent, 'Style', 'text', 'String', labelText, ...
            'Position', [20, y_pos, 80, 25], 'HorizontalAlignment', 'right', ...
            'Visible', 'off', 'BackgroundColor', colors.panel, 'ForegroundColor', colors.text, ...
            'FontSize', font.size, 'FontName', font.name);
        
        edit_h = uicontrol(parent, 'Style', 'edit', 'String', num2str(defaultValue), ...
            'Position', [110, y_pos, 110, 25], 'Visible', 'off', ...
            'BackgroundColor', [1 1 1], 'ForegroundColor', colors.text, ...
            'FontSize', font.size, 'FontName', font.name);
        
        param_name = strrep(editTag, 'edit_', '');
        app_out.handles.(['label_' param_name]) = label_h;
        app_out.handles.(editTag) = edit_h;
        
        app_out.handles.all_param_controls{end+1} = label_h;
        app_out.handles.all_param_controls{end+1} = edit_h;
    end

    function plotHistogram(ax, img, app)
        cla(ax, 'reset');
        if size(img, 3) == 3
            data = rgb2gray(img);
        else
            data = img;
        end
        
        compareMode = get(app.handles.checkbox_compare, 'Value');
        
        if compareMode
            % Show both histograms overlaid
            hold(ax, 'on');
            
            % Custom histogram
            [counts_custom, centers] = customHistogram(data, 256);
            bar(ax, centers, counts_custom, 'hist', 'FaceColor', app.colors.custom_hist, ...
                'EdgeColor', 'none', 'FaceAlpha', 0.6, 'DisplayName', 'Custom');
            
            % Library histogram
            [counts_lib, ~] = imhist(data);
            bar(ax, 0:255, counts_lib, 'hist', 'FaceColor', app.colors.library_hist, ...
                'EdgeColor', 'none', 'FaceAlpha', 0.6, 'DisplayName', 'Library');
            
            legend(ax, 'Location', 'best', 'TextColor', app.colors.text);
            hold(ax, 'off');
        else
            % Show selected histogram method
            if app.useCustomHistogram
                [counts, centers] = customHistogram(data, 256);
                bar(ax, centers, counts, 'hist', 'FaceColor', app.colors.custom_hist, 'EdgeColor', 'none');
            else
                [counts, ~] = imhist(data);
                bar(ax, 0:255, counts, 'hist', 'FaceColor', app.colors.library_hist, 'EdgeColor', 'none');
            end
        end
        
        xlim(ax, [0 255]);
        xlabel(ax, 'Pixel Value', 'Color', app.colors.text, 'FontSize', app.font.size, 'FontName', app.font.name);
        ylabel(ax, 'Frequency', 'Color', app.colors.text, 'FontSize', app.font.size, 'FontName', app.font.name);
        set(ax, 'Color', app.colors.panel, 'XColor', app.colors.text, 'YColor', app.colors.text);
        grid(ax, 'on');
        box(ax, 'on');
    end
end
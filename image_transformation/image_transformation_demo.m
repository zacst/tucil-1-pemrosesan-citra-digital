% Image Transformations Demo with side-by-side histogram comparisons
clc; 
clear; 
close all;

% --- 1. Setup Image Directory ---
image_folder = '.'; 
image_files = [
    dir(fullfile(image_folder, '*.bmp')); 
    dir(fullfile(image_folder, '*.png'));
    dir(fullfile(image_folder, '*.jpg'))
];

if isempty(image_files)
    error('No image files (.bmp, .png, .jpg) found in the current directory.');
end

% --- 2. Define Transformation Parameters ---
params.brighten.a = 1.2;
params.brighten.b = 30;
params.log.c = 45;
params.log.r = 1;
params.exponent.c = 1.05;
params.exponent.y = 1.1;

% --- Helper function for plotting histograms ---
function plotCustomHistogram(subplotHandle, image, plotTitle)
    axes(subplotHandle); % Activate the correct subplot
    if size(image, 3) == 3
        data = rgb2gray(image);
    else
        data = image;
    end
    [counts, centers] = customHistogram(data, 256);
    bar(centers, counts, 'hist');
    xlim([0 255]);
    xlabel('Pixel Value');
    ylabel('Frequency');
    title(plotTitle);
end

% --- 3. Loop Through Each Image ---
for k = 1:length(image_files)
    current_filename = image_files(k).name;
    full_filepath = fullfile(image_folder, current_filename);
    fprintf('Processing image: %s\n', current_filename);
    
    try
        img = imread(full_filepath);
    catch ME
        warning('Failed to read "%s". Skipping file. Error: %s', current_filename, ME.message);
        continue;
    end
    
    % Apply all transformations
    transformed = imageTransformations(img, params);
    
    % --- Create comparison plots for each transformation ---
    
    % Get all transformation names from the struct fields
    transform_names = fieldnames(transformed);
    
    for i = 1:length(transform_names)
        t_name = transform_names{i};
        img_transformed = transformed.(t_name); % Get transformed image using dynamic field name
        
        figure('Name', [current_filename ' - ' t_name], 'NumberTitle', 'off');
        
        % Original Image
        h1 = subplot(2, 2, 1);
        imshow(img);
        title('Original');
        
        % Original Histogram
        h2 = subplot(2, 2, 2);
        plotCustomHistogram(h2, img, 'Original Histogram');
        
        % Transformed Image
        h3 = subplot(2, 2, 3);
        imshow(img_transformed);
        title(['Transformed: ' t_name]);
        
        % Transformed Histogram
        h4 = subplot(2, 2, 4);
        plotCustomHistogram(h4, img_transformed, [t_name ' Histogram']);
    end
end

disp('Finished processing all images.');

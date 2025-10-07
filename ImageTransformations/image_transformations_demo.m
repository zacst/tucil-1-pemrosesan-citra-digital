% Image Transformations Demo with user-defined parameters and histogram comparisons
clc; 
clear; 
close all;

% --- 1. Setup Image Directory ---
image_folder = './test_case/';
image_files = [
    dir(fullfile(image_folder, '*.bmp')); 
    dir(fullfile(image_folder, '*.png'));
    dir(fullfile(image_folder, '*.jpg'))
];

if isempty(image_files)
    error('No image files (.bmp, .png, .jpg) found in the specified directory ("%s").', image_folder);
end

% --- 2. Get Transformation Parameters from User ---
disp('Please enter the parameters for the image transformations.');
params = struct(); % Initialize params struct

% Brightening parameters
disp('--- Brightening ---');
params.brighten.a = input('Enter scaling factor a (e.g., 1.2): ');
params.brighten.b = input('Enter offset b (e.g., 30): ');

% Log transform parameters
disp('--- Log Transformation ---');
params.log.c = input('Enter constant c (e.g., 45): ');
params.log.r = input('Enter offset r (e.g., 1): ');

% Exponent transform parameters
disp('--- Exponent Transformation ---');
params.exponent.c = input('Enter constant c (e.g., 1.05): ');
params.exponent.y = input('Enter power y (gamma) (e.g., 1.1): ');

fprintf('\nParameters set. Starting image processing...\n\n');

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
    
    % Apply all transformations using the user-defined parameters
    transformed = imageTransformations(img, params);
    
    % --- Create comparison plots for each transformation ---
    transform_names = fieldnames(transformed);
    
    for i = 1:length(transform_names)
        t_name = transform_names{i};
        img_transformed = transformed.(t_name);
        
        % Create a new figure for each transformation of each image
        figure('Name', sprintf('%s - %s', current_filename, t_name), 'NumberTitle', 'off', 'WindowState', 'maximized');
        
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
        title(sprintf('Transformed: %s', t_name));
        
        % Transformed Histogram
        h4 = subplot(2, 2, 4);
        plotCustomHistogram(h4, img_transformed, sprintf('%s Histogram', t_name));
    end
end

disp('Finished processing all images.');

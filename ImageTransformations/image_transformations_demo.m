% Image Transformations Demo with user-defined parameters and histogram comparisons
clc; 
clear; 
close all;

% --- 1. Setup Image Directory ---
image_folder = './test_case/'; % Make sure this folder exists
image_files = [
    dir(fullfile(image_folder, '*.bmp')); 
    dir(fullfile(image_folder, '*.png'));
    dir(fullfile(image_folder, '*.jpg'))
];

if isempty(image_files)
    error('No image files (.bmp, .png, .jpg) found in the specified directory ("%s").', image_folder);
end

% --- 2. Get Transformation Parameters from User ---
disp('Please enter the parameters for the sequential image transformations.');
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
    
    % --- Apply all transformations sequentially ---
    % Step 1: Brightening
    img_processed = uint8(double(img) .* params.brighten.a + params.brighten.b);
    
    % Step 2: Negative
    img_processed = 255 - img_processed;
    
    % Step 3: Log Transformation
    img_processed = uint8(params.log.c .* log(double(img_processed) + params.log.r));
    
    % Step 4: Exponent Transformation
    img_processed = uint8(params.exponent.c .* (double(img_processed) .^ params.exponent.y));
    
    % Step 5: Contrast Stretching
    r_min = double(min(img_processed(:)));
    r_max = double(max(img_processed(:)));
    % Handle case where the image is flat to avoid division by zero
    if r_min == r_max
        final_image = uint8(0 .* ones(size(img_processed)));
    else
        final_image = uint8(255 .* ((double(img_processed) - r_min) ./ (r_max - r_min)));
    end
    
    % --- Create a single comparison plot for the final result ---
    figure('Name', [current_filename ' - All Transformations'], 'NumberTitle', 'off', 'WindowState', 'maximized');
    
    % Original Image
    h1 = subplot(2, 2, 1);
    imshow(img);
    title('Original');
    
    % Original Histogram
    h2 = subplot(2, 2, 2);
    plotCustomHistogram(h2, img, 'Original Histogram');
    
    % Final Transformed Image
    h3 = subplot(2, 2, 3);
    imshow(final_image);
    title('Final Image (All Transformations)');
    
    % Final Transformed Histogram
    h4 = subplot(2, 2, 4);
    plotCustomHistogram(h4, final_image, 'Final Histogram');
end

disp('Finished processing all images.');
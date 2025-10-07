% Histogram Equalization Demo - Batch processing for multiple images
clc; 
clear; 
close all;

% --- 1. Setup Image Directory ---
image_folder = './test_case/'; % Use the current folder
image_files = [
    dir(fullfile(image_folder, '*.bmp'));
    dir(fullfile(image_folder, '*.png'));
    dir(fullfile(image_folder, '*.jpg'))
];

if isempty(image_files)
    error('No image files (.bmp, .png, .jpg) found in the current directory.');
end

% --- 2. Loop Through Each Image ---
for k = 1:length(image_files)
    current_filename = image_files(k).name;
    full_filepath = fullfile(image_folder, current_filename);
    
    fprintf('Processing image: %s\n', current_filename);
    
    % --- Read Image ---
    try
        img = imread(full_filepath);
    catch ME
        warning('Failed to read "%s". Skipping file. Error: %s', current_filename, ME.message);
        continue; % Skip to the next image
    end
    
    % --- Display Original Image ---
    figure('Name', [current_filename ' - Original'], 'NumberTitle', 'off');
    imshow(img);
    title(['Original: ' current_filename], 'Interpreter', 'none');

    % --- Apply Histogram Equalization ---
    img_eq = histogramEqualization(img);
    
    % --- Display Equalized Image ---
    figure('Name', [current_filename ' - Equalized'], 'NumberTitle', 'off');
    imshow(img_eq);
    title('Histogram Equalized', 'Interpreter', 'none');
    
    % --- Display Histograms for Comparison ---
    figure('Name', [current_filename ' - Histograms'], 'NumberTitle', 'off');
    
    % Subplot for original histogram using custom function
    subplot(1, 2, 1);
    if size(img, 3) == 3
        data_for_hist = rgb2gray(img); % Convert RGB to grayscale for intensity histogram
    else
        data_for_hist = img;
    end
    [counts, bin_centers] = customHistogram(data_for_hist, 256);
    bar(bin_centers, counts, 'hist');
    xlim([0 255]); % Set axis limits for consistency
    xlabel('Pixel Value');
    ylabel('Frequency');
    title('Original Histogram');
    
    % Subplot for equalized histogram using custom function
    subplot(1, 2, 2);
    if size(img_eq, 3) == 3
        data_for_hist_eq = rgb2gray(img_eq); % Convert RGB to grayscale
    else
        data_for_hist_eq = img_eq;
    end
    [counts_eq, bin_centers_eq] = customHistogram(data_for_hist_eq, 256);
    bar(bin_centers_eq, counts_eq, 'hist');
    xlim([0 255]); % Set axis limits for consistency
    xlabel('Pixel Value');
    ylabel('Frequency');
    title('Equalized Histogram');
end

disp('Finished processing all images.');


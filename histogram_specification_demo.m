% Histogram Specification Demo with side-by-side histogram comparisons
clc; 
clear; 
close all;

% --- 1. Setup Image Directory and Target Image ---
image_folder = '.'; 
image_files = [
    dir(fullfile(image_folder, '*.bmp')); 
    dir(fullfile(image_folder, '*.png'));
    dir(fullfile(image_folder, '*.jpg'))
];

% --- Define the target image ---
% IMPORTANT: You must have an image named 'target.png' (or change the name below)
% in the same directory for this demo to work.
target_filename = 'target.png';
if ~exist(target_filename, 'file')
    error('Target image "%s" not found. Please add it to the directory.', target_filename);
end
target_img = imread(target_filename);


if isempty(image_files)
    error('No image files (.bmp, .png, .jpg) found in the current directory.');
end

% --- Helper function for plotting histograms using your custom function ---
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

% --- 2. Loop Through Each Image ---
for k = 1:length(image_files)
    current_filename = image_files(k).name;
    
    % Skip the target image if it's found in the directory loop
    if strcmpi(current_filename, target_filename)
        continue;
    end
    
    full_filepath = fullfile(image_folder, current_filename);
    fprintf('Processing image: %s\n', current_filename);
    
    try
        img = imread(full_filepath);
    catch ME
        warning('Failed to read "%s". Skipping file. Error: %s', current_filename, ME.message);
        continue;
    end
    
    % --- Apply Histogram Specification ---
    img_specified = histogramSpecification(img, target_img);
    
    % --- 3. Create Comparison Plots ---
    
    % Figure 1: Shows the Input and Target images and their histograms
    figure('Name', [current_filename ' - Input vs Target'], 'NumberTitle', 'off');
    
    % Input Image
    h1 = subplot(2, 2, 1);
    imshow(img);
    title(['Input: ' current_filename], 'Interpreter', 'none');
    
    % Input Histogram
    h2 = subplot(2, 2, 2);
    plotCustomHistogram(h2, img, 'Input Histogram');
    
    % Target Image
    h3 = subplot(2, 2, 3);
    imshow(target_img);
    title(['Target: ' target_filename], 'Interpreter', 'none');
    
    % Target Histogram
    h4 = subplot(2, 2, 4);
    plotCustomHistogram(h4, target_img, 'Target Histogram');

    % Figure 2: Shows the final result after specification
    figure('Name', [current_filename ' - Specification Result'], 'NumberTitle', 'off');

    % Specified Image
    h5 = subplot(1, 2, 1);
    imshow(img_specified);
    title('Specified Image');

    % Specified Histogram
    h6 = subplot(1, 2, 2);
    plotCustomHistogram(h6, img_specified, 'Specified Histogram');
end

disp('Finished processing all images.');

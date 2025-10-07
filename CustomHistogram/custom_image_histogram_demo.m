% Image Processing Demo - Batch processing for multiple images (RGB or Grayscale)
clc; 
clear; 
close all;

% --- 1. Setup Image Directory ---
% Define the folder where your images are located. '.' means the current folder.
image_folder = './test_case/';
% Find all common image types in the specified folder.
image_files = [
    dir(fullfile(image_folder, '*.bmp'));
    dir(fullfile(image_folder, '*.png'));
    dir(fullfile(image_folder, '*.jpg'))
];

% Check if any images were found
if isempty(image_files)
    error('No image files (.bmp, .png, .jpg) found in the directory.');
end

% --- 2. Loop Through Each Image ---
for k = 1:length(image_files)
    % Get the full path for the current image
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
    
    % Display the original image
    figure('Name', [current_filename ' - Original'], 'NumberTitle', 'off');
    imshow(img);
    title(['Original Image: ' current_filename], 'Interpreter', 'none');

    % --- 3. Check Image Type (RGB vs. Grayscale) and Process ---
    num_bins = 256;
    num_channels = size(img, 3);
    
    if num_channels == 3 % This is an RGB image
        
        % --- Library Histogram (converts to grayscale) ---
        figure('Name', [current_filename ' - Library Hist'], 'NumberTitle', 'off');
        imhist(img);
        title({['Library Histogram for ' current_filename], '(Grayscale Version)'}, 'Interpreter', 'none');

        % --- Custom Histogram for All Channels Combined ---
        [counts_all, bins_all] = customHistogram(img, num_bins);
        figure('Name', [current_filename ' - Custom Hist (All)'], 'NumberTitle', 'off');
        bar(bins_all, counts_all, 'hist');
        xlabel('Pixel Value');
        ylabel('Frequency');
        title({['Custom Histogram for ' current_filename], 'All Channels Combined'}, 'Interpreter', 'none');
        xlim([0 num_bins-1]);

        % --- Custom Histogram (per channel) ---
        channel_names = {'Red', 'Green', 'Blue'};
        for c = 1:3
            channel_data = img(:,:,c);
            [counts_channel, bins_channel] = customHistogram(channel_data, num_bins);
            
            figure('Name', [current_filename ' - ' channel_names{c} ' Hist'], 'NumberTitle', 'off');
            bar(bins_channel, counts_channel, 'hist');
            xlabel('Pixel Value');
            ylabel('Frequency');
            title({['Custom Histogram for ' current_filename], [channel_names{c} ' Channel']}, 'Interpreter', 'none');
            xlim([0 num_bins-1]);
        end
        
    elseif num_channels == 1 % This is a Grayscale image
        
        % --- Library Histogram ---
        figure('Name', [current_filename ' - Library Hist'], 'NumberTitle', 'off');
        imhist(img);
        title(['Library Histogram for ' current_filename], 'Interpreter', 'none');
        
        % --- Custom Histogram ---
        [counts_gray, bins_gray] = customHistogram(img, num_bins);
        figure('Name', [current_filename ' - Custom Hist'], 'NumberTitle', 'off');
        bar(bins_gray, counts_gray, 'hist');
        xlabel('Pixel Value');
        ylabel('Frequency');
        title({['Custom Histogram for ' current_filename], '(Grayscale)'}, 'Interpreter', 'none');
        xlim([0 num_bins-1]);
        
    else
        warning('Image "%s" is not a standard RGB or grayscale image. Skipping.', current_filename);
    end
end

disp('Finished processing all images.');
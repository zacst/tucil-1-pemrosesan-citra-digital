% Image Processing Demo
clc; clear; close all;

% --- Input Image ---
img = imread('baboon24.bmp');
figure('Name', 'Original Image', 'NumberTitle', 'off');
imshow(img);

% --- Histogram Equalization ---
num_bins = 256;

if size(img, 3) == 1
    % ----------------------------
    % Case 1: Grayscale
    % ----------------------------
    counts = zeros(1, num_bins);
    for i = 0:num_bins-1
        counts(i+1) = sum(img(:) == i);
    end
    
    % Normalize
    num_pixels = numel(img);
    normalizedCounts = counts / num_pixels;

    % CDF
    s = cumsum(normalizedCounts);

    % Scale to [0, 255]
    s = round((num_bins-1) * s);

    % Map original intensities to equalized values
    img_eq = s(double(img)+1);

else
    % ----------------------------
    % Case 2: RGB
    % ----------------------------
    img_eq = img; % preallocate
    for channel = 1:3
        channel_data = img(:,:,channel);
        
        % Histogram
        counts = zeros(1, num_bins);
        for i = 0:num_bins-1
            counts(i+1) = sum(channel_data(:) == i);
        end
        
        % Normalize
        num_pixels = numel(channel_data);
        normalizedCounts = counts / num_pixels;

        % CDF
        s = cumsum(normalizedCounts);
        s = round((num_bins-1) * s);

        % Map intensities
        img_eq(:,:,channel) = s(double(channel_data)+1);
    end
end

% --- Show Result ---
figure('Name', 'Histogram Equalized', 'NumberTitle', 'off');
imshow(img_eq);
% Image Processing Demo
clc; clear; close all;

% --- Input Image ---
img = imread('baboon24.bmp');
imshow(img);
set(gcf, 'Name', 'Original Image', 'NumberTitle', 'off');

% --- Library Histogram ---
figure('Name', 'Library Histogram', 'NumberTitle', 'off');
imhist(img);
title('Library Histogram');

% Convert to double for processing
data = double(img(:));

% --- From Scratch Histogram ---

num_bins = 256;
edges = linspace(min(data), max(data), num_bins + 1);

counts = zeros(1, num_bins);
for i = 1:num_bins
    counts(i) = sum(data >= edges(i) & data < edges(i+1));
end

% Include max value in the last bin
counts(end) = counts(end) + sum(data == edges(end));

bin_centers = (edges(1:end-1) + edges(2:end))/2;
figure('Name', 'Custom Histogram', 'NumberTitle', 'off');
bar(bin_centers, counts, 'hist');
xlabel('Pixel Value');
ylabel('Frequency');
title('Histogram from Scratch');

% --- From Scratch Histogram (per channel) ---
num_bins = 256;
edges = linspace(0, 255, num_bins + 1);

channels = {'Red', 'Green', 'Blue'};
for c = 1:3
    channel_data = img(:,:,c);      % Extract one channel
    data = double(channel_data(:)); % Flatten to vector
    
    counts = zeros(1, num_bins);
    for i = 1:num_bins
        counts(i) = sum(data >= edges(i) & data < edges(i+1));
    end
    counts(end) = counts(end) + sum(data == edges(end));

    bin_centers = (edges(1:end-1) + edges(2:end))/2;
    figure('Name', ['Custom Histogram - ' channels{c}], 'NumberTitle', 'off');
    bar(bin_centers, counts, 'hist');
    xlabel('Pixel Value');
    ylabel('Frequency');
    title(['Histogram from Scratch - ' channels{c}]);
end
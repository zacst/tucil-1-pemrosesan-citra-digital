function [counts, bin_locations] = customHistogram(imageData, num_bins)
% customHistogram Computes the histogram of an image or a single channel.
%   [counts, bin_locations] = customHistogram(imageData, num_bins)
%   calculates the frequency distribution of pixel values in imageData.
%
%   Inputs:
%       imageData - A matrix of image data (can be grayscale, a color image, 
%                   or a single color channel). If a color image is provided,
%                   all pixel values from all channels are flattened and
%                   counted together.
%       num_bins  - The number of bins to use for the histogram (typically 
%                   256 for 8-bit images).
%
%   Outputs:
%       counts        - A 1xnum_bins vector of pixel counts for each bin.
%       bin_locations - A 1xnum_bins vector representing the pixel value 
%                       for each bin (e.g., 0, 1, ..., 255).

    % Convert input data to a flat vector of doubles for processing.
    data = double(imageData(:));

    % Define the bin edges. For an 8-bit image, values range from 0 to 255.
    % Create num_bins+1 edges from 0 to num_bins because it's a histogram (num_bins bar).
    edges = linspace(0, num_bins, num_bins + 1);

    % Initialize a vector to store the counts (frequency) for each bin.
    counts = zeros(1, num_bins);

    % Loop-based implementation to count the frequencies of each pixel.
    for i = 1:num_bins
        % Count all pixel values that are >= the left edge AND < the right edge.
        counts(i) = sum(data >= edges(i) & data < edges(i+1));
    end

    % The bin locations correspond to the integer pixel values (0, 1, 2, ...).
    bin_locations = 0:(num_bins-1);

end

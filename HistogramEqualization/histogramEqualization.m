function [img_eq] = histogramEqualization(inputImg)
% histogramEqualization Performs histogram equalization on an image.
%
%   img_eq = histogramEqualization(inputImg)
%
%   This function works for both grayscale and RGB images. For RGB, it
%   equalizes each color channel independently.
%
%   Inputs:
%       inputImg - The source image matrix (uint8).
%
%   Outputs:
%       img_eq   - The histogram-equalized image (uint8).

    num_bins = 256;
    % Convert to double once for indexing, which is faster than converting repeatedly.
    inputImg_double = double(inputImg); 

    if size(inputImg, 3) == 1
        % --- Case 1: Grayscale Image ---
        
        % Calculate the histogram (counts of each pixel intensity)
        counts = zeros(1, num_bins);
        for i = 0:(num_bins - 1)
            counts(i + 1) = sum(inputImg(:) == i);
        end
        
        % Calculate the PDF (Probability Density Function)
        pdf = counts / numel(inputImg);
        
        % Calculate the CDF (Cumulative Distribution Function)
        cdf = cumsum(pdf);
        
        % Create the mapping function by scaling the CDF to [0, 255]
        s = round((num_bins - 1) * cdf);
        
        % Map original intensities to equalized values. Add 1 for 1-based indexing.
        img_eq_double = s(inputImg_double + 1);
        
    elseif size(inputImg, 3) == 3
        % --- Case 2: RGB Image ---
        
        img_eq_double = zeros(size(inputImg_double)); % Pre-allocate
        
        % Process each color channel independently
        for channel = 1:3
            channel_data = inputImg(:,:,channel);
            
            counts = zeros(1, num_bins);
            for i = 0:(num_bins - 1)
                counts(i + 1) = sum(channel_data(:) == i);
            end
            
            pdf = counts / numel(channel_data);
            cdf = cumsum(pdf);
            s = round((num_bins - 1) * cdf);
            
            % Map intensities for the current channel
            img_eq_double(:,:,channel) = s(inputImg_double(:,:,channel) + 1);
        end
        
    else
        error('Input image must be either grayscale or RGB.');
    end
    
    % Convert the final result back to uint8 for image display
    img_eq = uint8(img_eq_double);
end

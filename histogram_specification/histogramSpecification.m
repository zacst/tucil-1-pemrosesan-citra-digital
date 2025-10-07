function [img_spec] = histogramSpecification(inputImg, targetImg)
% histogramSpecification Performs histogram specification (matching).
%
%   img_spec = histogramSpecification(inputImg, targetImg)
%
%   Transforms the inputImg so its histogram matches the histogram of targetImg.
%   This function handles both grayscale and RGB images.
%
%   Inputs:
%       inputImg  - The source image matrix to be transformed (uint8).
%       targetImg - The image whose histogram will be the target (uint8).
%
%   Outputs:
%       img_spec  - The transformed image (uint8).

    % --- Helper function to calculate the scaled Cumulative Distribution Function (CDF) ---
    % This is the core of histogram-based transformations.
    function scaled_cdf = calculate_scaled_cdf(image_channel)
        num_bins = 256;
        
        % Calculate histogram
        counts = zeros(1, num_bins);
        for i = 0:(num_bins - 1)
            counts(i + 1) = sum(image_channel(:) == i);
        end
        
        % Calculate PDF (Probability Density Function)
        pdf = counts / numel(image_channel);
        
        % Calculate CDF
        cdf = cumsum(pdf);
        
        % Scale CDF to the range [0, 255] for mapping
        scaled_cdf = round((num_bins - 1) * cdf);
    end

    % --- Main Logic: Handle Grayscale vs. RGB ---
    if size(inputImg, 3) == 1 % Case 1: Grayscale Image
        % Ensure target is also grayscale for a valid comparison
        if size(targetImg, 3) == 3
            targetImg = rgb2gray(targetImg);
        end
        
        % Step 1: Calculate scaled CDF for both input and target images
        s_in = calculate_scaled_cdf(inputImg);
        s_target = calculate_scaled_cdf(targetImg);
        
        % Step 2: Create the mapping from input intensity to target intensity
        mapping = zeros(1, 256);
        for g = 1:256
            % For each intensity `g` in the input, find the intensity `z` in the
            % target that has the closest CDF value.
            [~, z] = min(abs(s_in(g) - s_target));
            mapping(g) = z - 1; % Subtract 1 for 0-based intensity values
        end
        
        % Step 3: Apply the mapping to the input image
        img_spec = mapping(double(inputImg) + 1);

    else % Case 2: RGB Image
        img_spec = zeros(size(inputImg)); % Pre-allocate output
        
        % Ensure target is also RGB
        if size(targetImg, 3) == 1
            targetImg = repmat(targetImg, [1, 1, 3]); % Convert grayscale to RGB
        end

        % Process each color channel independently
        for channel = 1:3
            s_in = calculate_scaled_cdf(inputImg(:,:,channel));
            s_target = calculate_scaled_cdf(targetImg(:,:,channel));
            
            mapping = zeros(1, 256);
            for g = 1:256
                [~, z] = min(abs(s_in(g) - s_target));
                mapping(g) = z - 1;
            end
            
            img_spec(:,:,channel) = mapping(double(inputImg(:,:,channel)) + 1);
        end
    end
    
    % Convert the final result back to uint8 for image display
    img_spec = uint8(img_spec);
end

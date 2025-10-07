function [transformedImages] = imageTransformations(inputImg, params)
% imageTransformations Applies all available pixel-wise transformations to an image.
%
%   transformedImages = imageTransformations(inputImg, params)
%
%   Inputs:
%       inputImg  - The source image matrix (can be RGB or grayscale).
%       params    - A struct containing parameters for the operations.
%                   - params.brighten.a, params.brighten.b
%                   - params.log.c, params.log.r
%                   - params.exponent.c, params.exponent.y
%
%   Outputs:
%       transformedImages - A struct containing all the transformed images.
%                           - .brighten
%                           - .negative
%                           - .log
%                           - .exponent
%                           - .contrast

    % Initialize the output struct
    transformedImages = struct();
    
    % Convert image to double for mathematical operations
    vec = double(inputImg);
    
    % --- Helper function for clipping and type conversion ---
    % This avoids repeating the same lines of code for each operation.
    function out = clipAndConvert(inVec)
        inVec(inVec > 255) = 255; % Clip values above 255
        inVec(inVec < 0) = 0;   % Clip values below 0
        out = uint8(inVec);     % Convert back to uint8
    end

    % --- 1. Brighten ---
    if isfield(params, 'brighten') && isfield(params.brighten, 'a') && isfield(params.brighten, 'b')
        brightVec = vec .* params.brighten.a + params.brighten.b;
        transformedImages.brighten = clipAndConvert(brightVec);
    else
        warning('Brighten parameters not found. Skipping operation.');
        transformedImages.brighten = inputImg; % Return original if params are missing
    end

    % --- 2. Negative ---
    negVec = 255 - vec;
    transformedImages.negative = clipAndConvert(negVec);

    % --- 3. Log Transformation ---
    if isfield(params, 'log') && isfield(params.log, 'c') && isfield(params.log, 'r')
        logVec = params.log.c .* log(vec + params.log.r);
        transformedImages.log = clipAndConvert(logVec);
    else
        warning('Log transform parameters not found. Skipping operation.');
        transformedImages.log = inputImg;
    end

    % --- 4. Exponent Transformation ---
    if isfield(params, 'exponent') && isfield(params.exponent, 'c') && isfield(params.exponent, 'y')
        expVec = params.exponent.c .* (vec .^ params.exponent.y);
        transformedImages.exponent = clipAndConvert(expVec);
    else
        warning('Exponent transform parameters not found. Skipping operation.');
        transformedImages.exponent = inputImg;
    end
        
    % --- 5. Contrast Stretching ---
    r_min = double(min(vec(:)));
    r_max = double(max(vec(:)));
    
    % Avoid division by zero if the image is a solid color
    if r_min == r_max
        contrastVec = vec;
    else
        s_max = 255;
        contrastVec = s_max .* ((vec - r_min) ./ (r_max - r_min));
    end
    transformedImages.contrast = clipAndConvert(contrastVec);
            
end
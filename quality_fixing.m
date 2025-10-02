% Image Processing Demo
clc; clear; close all;

% --- Input Image ---
img = imread('baboon24.bmp');
figure('Name', 'Original Image', 'NumberTitle', 'off');
imshow(img);

% Convert image to double for processing
vec = double(img);

%% --- Image Brightening ---
disp('Image Brightening:');
a = input('Enter scaling factor a: ');
b = input('Enter offset b: ');

bright_img = uint8(vec .* a + b);

figure('Name', 'Image Brightening', 'NumberTitle', 'off');
imshow(bright_img);

%% --- Negative ---
disp('Negative:');
neg_img = 255 - bright_img;

figure('Name', 'Negative Image', 'NumberTitle', 'off');
imshow(neg_img);

%% --- Log Transformation ---
disp('Log Transformation:');
c = input('Enter constant c: ');
r = input('Enter offset r: ');

log_img = uint8(c .* log(double(neg_img) + r));

figure('Name', 'Log Transformation', 'NumberTitle', 'off');
imshow(log_img);

%% --- Exponent Transformation ---
disp('Exponent Transformation:');
c2 = input('Enter constant c2: ');
y = input('Enter power y: ');

exp_img = uint8(c2 .* (double(log_img) .^ y));

figure('Name', 'Exponent Transformation', 'NumberTitle', 'off');
imshow(exp_img);

%% --- Contrast Stretching ---
disp('Contrast Stretching:');
r_min = double(min(exp_img(:)));
r_max = double(max(exp_img(:)));
s_min = 0;
s_max = 255;

cs_img = uint8(s_max .* ((double(exp_img) - r_min) ./ (r_max - r_min)));

figure('Name', 'Contrast Stretching', 'NumberTitle', 'off');
imshow(cs_img);
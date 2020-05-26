function [CCI] = CCICalculation(image,tolerance)

% Function to calculate the contrast code image (CCI), first proposed in
% the work titled "A Contrast-Guided Approach for the Enhancement 
% of Low-Lighting Underwater Images" by Tunai P. Marques, Alexandra
% Branzan-Albu and Maia Hoeberechts
% By Tunai Porto Marques, 2020 (tunaimarques.com)
%
% Inputs:
% image - the RGB image whose the CCI is calculated upon
% tolerance - parameter that defines the priority that bigger patch sizes
% will have.
%
% Outputs: 
% CCI - a 1-D matrix with the same dimensions as "image" composed, in each
% location x, by the contrast code c that specifies the patch size that 
% generated the smallest local standard deviation considering 7 patch
% sizes.

% ========== Contrast code image (CCI) calculation ============== %

% turn image into double so its decimal points can be used in calculations
A = double(image);
[x y z] = size(A);

% create an image with padding big enough to allocate all the dynamic patch
% sizes when calculating dark channel and transmission maps
biggest_psize = 15;
prange_biggest = round(biggest_psize/2)-1;

% assign the different psizes to be tested. usual range is [15 13 ... 5 3]
psize2 = [15 13 11 9 7 5 3];

% determines the tolerance factor (weight decay)
tol = 1-(tolerance/100);

% creates a tolerance array that will use the tolerance factor to
% proportionally increase the priority of bigger patch sizes. Since 
% the lowest std.dev. will determine the patch size chosen, lowering 
% this value increases its relevance in latter stages of the algorithm. 
tolerance_array = [1*((tol)^6) 1*((tol)^5) 1*((tol)^4) 1*((tol)^3) 1*((tol)^2) 1*((tol)^1) 1];
% reshapes the array into a 7-dimensional array
tolerance_array = reshape(tolerance_array,1,1,7);
% clones the array so it can be multiplied with all the elements of the
% std.dev. results image
tolerance_matrix = repmat(tolerance_array,[x y 1]);

% Score Image creation. note that the number of dimensions is given by the
% number of std. deviation. scores that will be saved for each pixel,
% corresponding to different window sizes
score_temp = zeros(x,y,length(psize2));

% calculation of the grayscale version of the image:

% 1. uses ITU-R Recommendation BT.601-7 for luminance (E'y) caclualtion: 
% E'y = 0.299 * R + 0.587 * G + 0.114 * B. This formulation takes into
% consideration the perceived importance of each color channel to the human
% eye, therefore it is preferred.

gray = rgb2gray(image);
% 2. Alternativelly, use the simple mean between the three color channels
% gray = (A(:,:,1)+A(:,:,2)+A(:,:,3))/3;

% calculation of the std. dev for the seven different patch sizes:
% calculates the standard deviation for each patch size, centered in each
% pixel (stride 1) of the image and save all the results in the score_temp
% image. note that score_temp(x,y,1) refers to the std. dev. of patch size 
% 15x15, score_temp(x,y,7) to patch 3x3, and so on. 
for i = 1:length(psize2)
    patchsize=psize2(i);
    score_temp(:,:,i)=stdfilt(gray,true(patchsize));
end

% do an element-wise multiplication with the tolerance matrix so all the
% std. dev. for higher patch sizes are prioritized (i.e., their values are lowered).
% note that using tolerance=0 will assign the same priority to the 
% std. dev. results of all patch sizes. 
score_temp = score_temp.*tolerance_matrix; 

% the dimension with lowest value indicates the approapriate patch size (the one 
% that generated the lowest std. dev. result.  

disp("Contrast code image calculated.");
[~, CCI] = min(score_temp,[],3);
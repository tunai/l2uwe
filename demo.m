% Implementation of the work "L^2UWE: A Framework for the 
% Efficient Enhancement of Low-Light Underwater Images Using
% Local Contrast and Multi-Scale Fusion" by Tunai P. Marques and Alenxadra
% Branzan Albu
% 2020 CVPR Workshop - NTIRE: New Trends in Image Restoration and Enhancement
%  
% By Tunai Porto Marques, 2020 (tunaimarques.com)

if ~exist("./out", 'dir')
       mkdir("./out")
end

addpath("./third party/")
addpath("./utils/")

clc; close all; clear;

%% Collection of input parameters

% choose the input image
img_original = imread('./data/181.jpg');

% to standardize calculations, the image has to be 3-channel and type uint8
if ~(isa(img_original,'uint8'))
    img_original = uint8(img_original)
end
if size(img_original,3)<2
    img_original = repmat(img_original,1,1,3);
end

% path where the enhanced and partial images are saved
save_outputs = 1; % 1/0 = save/don't save outputs
outPath = '.\out\';

% dehazing-related parameters (refer to [1,2])
tol = 3; % tolerance used in the CCI calculation
filter = 1; % 1/0 = refine/don't refine the transmission map
multiplier = [5,30]; % defines the size of multiplier m for inputs 1 and 2
w = 0.9; % parameter from eq. (12) [2]
t0 = 0.02; % parameter from eq. (22) [2]

%fusion-related parameters
laplaciankernel = [-1,-1,-1;-1,8,-1;-1,-1,-1]/8; % laplacian kernel used on 
% the local contrast weight map
regTerm = 0.001; % a term that guarantees that each input contributes to 
% the multi-scale fusion output  
pyramidLevels = 5;
display_multiFusion = 1; % 1/0 = display/don't display the partial results 


%% Calculation of contrast-guided inputs (dehazed versions of the image)

inverted = imcomplement(img_original); 
CCI = CCICalculation(inverted,tol); 
input1 = luwe_input(inverted,CCI,w,t0,filter,multiplier(1),outPath,save_outputs); 
input2 = luwe_input(inverted,CCI,w,t0,filter,multiplier(2),outPath,save_outputs);

%% Blending of inputs via multi-scale fusion [3]

input1 = imcomplement(input1);
input2 = imcomplement(input2);
result = multiscalefusion(input1, input2, regTerm, pyramidLevels, ...
    laplaciankernel, display_multiFusion, outPath, save_outputs);

figure;subplot(2,2,1);imshow(img_original);title('Original image');
subplot(2,2,2);imshow(input1);title('Input 1');
subplot(2,2,3);imshow(input2);title('Input 2');
subplot(2,2,4);imshow(result);title('Final output');

if(save_outputs == 1)
    imwrite(result,string(outPath)+'result.png');
    imwrite(inverted,string(outPath)+'inverted.png');
    imwrite(img_original,string(outPath)+'original.png');
end 

license('inuse')


%% References
% [1] L^2UWE: A Framework for the Efficient Enhancement of Low-Light 
% Underwater Images Using Local Contrast and Multi-Scale Fusion. Tunai 
% Porto Marques, Alexandra Branzan Albu, 2020. 
% [2] Single Image Haze Removal Using Dark Channel Prior. Kaiming He, 
% Jian Sun, Xiaoou Tang, 2011.  
% [3] Single Image Dehazing by Multi-Scale Fusion. Codruta O. Ancuti and 
% Cosmin Ancuti, 2013
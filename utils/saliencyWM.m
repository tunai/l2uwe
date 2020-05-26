function [out] = saliencyWM(input)
% Function to calculate a saliency weight map. 
% By Tunai Porto Marques, 2020 (tunaimarques.com)
%
% Inputs:
% input - RGB image used to calculate the saliency map
% Outputs: 
% out - 1-D saliency weight map with the same dimensions of "input"

% create a 5x5 separable binomial kernel with high frequency cut-off of
% pi/2.75 (eq. (11) from [1]).
a = ([1 4 6 4 1])/16;
Gkernel = a'*a;

% the image has to be of type double
if ~(isa(input,'double'))   
    input = im2double(input);
end

% calculate a Gaussian-smoothed version of the image by applying
% the gaussian filter
oneC = rgb2gray(input);
meank = mean(oneC(:));
gaussianSmoothed = imfilter(oneC, Gkernel, 'symmetric');
out = abs(gaussianSmoothed - meank); %(eq. (11) from [1]) 

end

%%% References
% [1] Single Image Dehazing by Multi-Scale Fusion. Codruta O. Ancuti and 
% Cosmin Ancuti, 2013


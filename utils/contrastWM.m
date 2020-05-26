function [out] = contrastWM(input, laplacianKernel)
% Function to calculate a local constrast weight map. 
% By Tunai Porto Marques, 2020 (tunaimarques.com)
%
% Inputs:
% input - RGB image used to calculate the local contrast map
% laplacianKernel - laplacian kernel used in the calculation of the
% local contrast WM
% Outputs: 
% out - 1-D local contrast weight map with the same dimensions of "input"

% calculate the luminance (mean of the three color channels)
luminance = mean(input,3);

% apply a laplacian kernel to filter the image and highlight intensity
% changes.
out = abs(imfilter(luminance,laplacianKernel,'symmetric')); % Local 
% contrast WM eq. from section III-B of [1]


end

%%% References
% [1] Night-time dehazing by fusion. Ancuti et al., 2016



function [out] = luminanceWM(input)
% Function to calculate a luminance weight map. 
% By Tunai Porto Marques, 2020 (tunaimarques.com)
%
% Inputs:
% input - RGB image used to calculate the luminance map
% Outputs: 
% out - 1-D luminance weight map with the same dimensions of "input"

%calculate the luminance (mean of the three color channels)
luminance = mean(input,3);

% get R,G and B (minus luminance)
Rl = input(:, :, 1)-luminance;
Gl = input(:, :, 2)-luminance;
Bl = input(:, :, 3)-luminance;

sum = ((Rl.^2 + Gl.^2 + Bl.^2))/3; % eq. (9) from [1]
out = sqrt(sum);

end

%%% References
% [1] Single Image Dehazing by Multi-Scale Fusion. Codruta O. Ancuti and 
% Cosmin Ancuti, 2013

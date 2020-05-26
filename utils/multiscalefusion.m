function out = multiscalefusion(input1, input2, regTerm, pyramidLevels,laplacianKernel, display, outPath, save)

% Function to calculate the weight maps and perform multi-scale fusion [1,2]. 
% By Tunai Porto Marques, 2020 (tunaimarques.com)
%
% Inputs:
% input1 - image dehazed using the atm. lighting. model obtained with the first m parameter
% input2 - image dehazed using the atm. lighting. model obtained with the second m parameter
% regTerm - A term that guarantees that each input contributes to the output 
% pyramidLevels - number of levels (+1 for the original image) of the Gaussian and Laplacian pyramids
% laplacianKernel - kernel used in the calculation of the contrast weight map
% display - defines if the partial results are shown (1 or 0)
% outPath - path of the output folder
% save - defines if partial results are saved on outPath
%
% Outputs: 
% out - result of the multi-scale fusion

    % #1 - Saliency weight map calculated using the Achantay method (eq. (11) on [2])
    saliencyWM1 = saliencyWM(input1);
    saliencyWM2 = saliencyWM(input2);

    % #2 -  Luminance WM (eq. (7) on [1])
    luminanceWM1 = luminanceWM(input1);
    luminanceWM2 = luminanceWM(input2);

    % #3 -  Contrast WM = absolute value of a laplacian filtering on the
    % luminance (which is the mean of R,G,B). Eq. in sub-section IV.b. of [1]
    contrastWM1 = contrastWM(input1,laplacianKernel);
    contrastWM2 = contrastWM(input2,laplacianKernel);

    % aggregate and normalize the WMs using a regularization term
    % (detailed in sub-section IV.b. of [1]). The reg. term. chosen in [2]
    % is 0.1 and it guarantees that each input contributes to the output
    aggregatedWM1 = (saliencyWM1 + luminanceWM1 + contrastWM1)+regTerm;  
    aggregatedWM2 = (saliencyWM2 + luminanceWM2 + contrastWM2)+regTerm;  
   
    sum = (aggregatedWM1 + aggregatedWM2) + (2*regTerm);

    normalizedWM1 = aggregatedWM1./sum;
    normalizedWM2 = aggregatedWM2./sum;
    
    if(save==1)        
        imwrite(contrastWM1,string(outPath)+'ContrastWM1.png');
        imwrite(contrastWM2,string(outPath)+'ContrastWM2.png');
        imwrite(saliencyWM1,string(outPath)+'SaliencyWM1.png');
        imwrite(saliencyWM2,string(outPath)+'SaliencyWM2.png');
        imwrite(luminanceWM1,string(outPath)+'LuminanceWM1.png');
        imwrite(luminanceWM2,string(outPath)+'LuminanceWM2.png');
        imwrite(input1,string(outPath)+'input1.png');
        imwrite(input2,string(outPath)+'input2.png');
        imwrite(normalizedWM1,string(outPath)+'NormalizedWM1.png');
        imwrite(normalizedWM2,string(outPath)+'NormalizedWM2.png');
    end
    
    %calculate a gaussian pyramid with the normalized WMs (N levels + original
    %image)
    gaussPyramid1 = multiresolutionPyramid(normalizedWM1,pyramidLevels);
    gaussPyramid2 = multiresolutionPyramid(normalizedWM2,pyramidLevels);

    %calculate a laplacian pyramid of the derived inputs (N levels+original
    %image)
    mrp1 = multiresolutionPyramid(input1,pyramidLevels);
    mrp2 = multiresolutionPyramid(input2,pyramidLevels);
    lapp1 = laplacianPyramid(mrp1);
    lapp2 = laplacianPyramid(mrp2);

    % calculate the fused pyramids. note that the gaussian pyramid from the 
    % normalized WMs is one-channel, while the laplacian pyramid of the derived
    % inputs has three channels. therefore, each value in the gauss. pyr. is
    % multiplied by the three values in a given location of the lap. pyr. 

    for i=1:pyramidLevels
        if ~(isequal(size(gaussPyramid1{i},1:2),size(lapp1{i},1:2)))
            disp(sprintf('Different sizes in level %d of the pyramid. Check its constructuion',i));
        end

        %Eq. (13) from [1]
        fusedPyramid{i} = gaussPyramid1{i} .* lapp1{i} + gaussPyramid2{i} .* lapp2{i};

    end

    result = reconstructFromLaplacianPyramid(fusedPyramid);
    
    if (display)
        figure;subplot(2,3,1);imshow(saliencyWM1,[]);title('Saliency WM1');
        subplot(2,3,4);imshow(saliencyWM2,[]);title('Saliency WM2');
        subplot(2,3,2);imshow(luminanceWM1,[]);title('Luminance WM1');  
        subplot(2,3,5);imshow(luminanceWM2,[]);title('Luminance WM2');
        subplot(2,3,3);imshow(contrastWM1,[]);title('Contrast WM1');
        subplot(2,3,6);imshow(contrastWM2,[]);title('Contrast WM2');
    end
    
    out = result; 

end

% supporting functions

function mrp = multiresolutionPyramid(A,num_levels)
%multiresolutionPyramid(A,numlevels)
%   mrp = multiresolutionPyramid(A,numlevels) returns a multiresolution
%   pyramd from the input image, A. The output, mrp, is a 1-by-numlevels
%   cell array. The first element of mrp, mrp{1}, is the input image.
%
%   If numlevels is not specified, then it is automatically computed to
%   keep the smallest level in the pyramid at least 32-by-32.

%   Steve Eddins
%   MathWorks

A = im2double(A);

M = size(A,1);
N = size(A,2);

if nargin < 2
    lower_limit = 32;
    num_levels = min(floor(log2([M N]) - log2(lower_limit))) + 1;
else
    num_levels = min(num_levels, min(floor(log2([M N]))) + 2);
end

mrp = cell(1,num_levels);

smallest_size = [M N] / 2^(num_levels - 1);
smallest_size = ceil(smallest_size);
padded_size = smallest_size * 2^(num_levels - 1);

Ap = padarray(A,padded_size - [M N],'replicate','post');

mrp{1} = Ap;
for k = 2:num_levels
    mrp{k} = imresize(mrp{k-1},0.5,'lanczos3');
end

mrp{1} = A;
end

function lapp = laplacianPyramid(mrp)

% Steve Eddins
% MathWorks

lapp = cell(size(mrp));
num_levels = numel(mrp);
lapp{num_levels} = mrp{num_levels};
for k = 1:(num_levels - 1)
   A = mrp{k};
   B = imresize(mrp{k+1},2,'lanczos3');
   [M,N,~] = size(A);
   lapp{k} = A - B(1:M,1:N,:);
end
lapp{end} = mrp{end};
end

function out = reconstructFromLaplacianPyramid(lapp)

% Steve Eddins
% MathWorks

num_levels = numel(lapp);
out = lapp{end};
for k = (num_levels - 1) : -1 : 1
   out = imresize(out,2,'lanczos3');
   g = lapp{k};
   [M,N,~] = size(g);
   out = out(1:M,1:N,:) + g;
end
end

%%% References
% [1] Color Balance and Fusion for Underwater Image Enhancement. Ancuti 
% et al., 2018
% [2] Single Image Dehazing by Multi-Scale Fusion. Codruta O. Ancuti and 
% Cosmin Ancuti, 2013
function [dynamic] = luwe_input(image,CCI,w,t0,filter, atmLightPatchMul, name, save)

% Function to calculate the inputs of the multi-scale fusion process by 
% dehazing the original image using two atmospheric lighting models
% By Tunai Porto Marques, 2020 (tunaimarques.com)
%
% Inputs:
% image - RGB image to be used in the dehazing process
% CCI - contrast code image calculated using the CCICalculation function
% w - parameter that preserves some of the particles (haze) in the image 
% for more realistic results (aerial perspective)
% t0 - to avoid the noise cause by small J(x)t(x) (in the radiance recovery
% phase), this term is added as a lower boundary
% filter - defines if the transmission map and atm. lighting are refined or not
% atmLightPatchMul - multiplying factor m (with respect to constrast code
% c) to be used in the atm. lighting model calculation
% name - path of the  output images
% save - defines if partial results are saved as images or not
%
% Outputs: 
% dynamic - result (RGB image) of the contrast-based, local 
% atm. lighting-led dehazing process 

disp(sprintf('Creating input with atm. lighting using m=%d',atmLightPatchMul));

if ~exist(name, 'dir')
   mkdir(name)
end
    
% The functions used to calculate the dark channel and transmission maps 
% with different patch sizes were included in this function for clarity. 

% ========== Calculating the dark channel ============== %

% turn image into double so its decimal points can be used in calculations
A = double(image); 
A(A<10)=0;

[x y z] = size(A);

% create an image with padding big enough to allocate all the dynamic patch
% sizes when calculating dark channel and transmission maps
biggest_psize = 15;
prange_biggest = round(biggest_psize/2)-1;
extended = padarray(A,[prange_biggest prange_biggest],'symmetric','both');

dcs = zeros(x,y,3);

%loop throught the image constructing the dark channel
for i = 1:x
        for j = 1:y
            
            % compensate for the extended indices (padding)
            cpx = i+prange_biggest; %current pixel x
            cpy = j+prange_biggest; %current pixel y
            
            % select the ideal patch size for this particular pixel (based
            % on the CCI previously calculated)
            prange = CCI(i,j);
            prange = 8-prange;
            
            % determine the current patch to be considered
            patch = extended(cpx-prange:cpx+prange,cpy-prange:cpy+prange,:);
            
            dcs(i,j,1) = min(min(patch(:,:,1)));
            dcs(i,j,2) = min(min(patch(:,:,2)));
            dcs(i,j,3) = min(min(patch(:,:,3)));
                                    
       end
end

% ========== Calculating the atmospheric light ============== %

atmLightImage = zeros(x,y,3);

% calculate the atm. lighting model for each of the color channels based 
% on local contrast, as specified by eq. (9) from [1]
atmLightImage(:,:,1) = contrastGuidedAL(dcs(:,:,1),CCI,atmLightPatchMul);
atmLightImage(:,:,2) = contrastGuidedAL(dcs(:,:,2),CCI,atmLightPatchMul);
atmLightImage(:,:,3) = contrastGuidedAL(dcs(:,:,3),CCI,atmLightPatchMul);

if (filter == 1)
    atmLightImageFilt = imgaussfilt(atmLightImage,10);
else
    atmLightImageFilt = atmLightImage;
end

% ========== Calculating the transmission map ============== %

transmm = zeros(x,y);

% normalize the image using the previously calculated atmospheric lighting 
% model in each color channel

normalized(:,:,1) = A(:,:,1)./atmLightImageFilt(:,:,1);
normalized(:,:,2) = A(:,:,2)./atmLightImageFilt(:,:,2);
normalized(:,:,3) = A(:,:,3)./atmLightImageFilt(:,:,3);
normalized(isnan(normalized))=0;

%values of normalized vary between 0-1 (variable of type double)

% pad the normalized image so patches of different sizes can be used to
% calculate the transmission map
normalized = padarray(normalized,[prange_biggest prange_biggest],'symmetric','both');

for i = 1:x
        for j = 1:y
            
            % for each pixel, compensate the coordinates with the 
            % padding applied
            
            cpx=i+prange_biggest; %current pixel x
            cpy=j+prange_biggest; %current pixel y
            
            %choose the best psize
            prange=CCI(i,j);
            prange = 8-prange;
             
            % select the patch on the normalized image
            patch = normalized(cpx-prange:cpx+prange,cpy-prange:cpy+prange,:);
            
            % eq. (12) from [2]
            transmm(i,j) = 1 - ( w * min(patch(:)) );
                    
       end
end

tmr = transmm;

% most of the single-image dehazing algorithms add a filtering step after
% the tmap calculation. Common filtering options are the Gaussian,
% bi-lateral and fast guided filter. Based on [3], we use the fast guided 
% filter. 

% applies the fast-guided filter if prompted by the user. 
if (filter == 1)
        p = double(transmm);
        r = 16; % radius of the window w
        s = 4; %subsampling ratio s 
        eps = 0.45; %regularization parameter controlling the degree of smoothness
        transmm = fastguidedfilter(p,p,r,eps,s);
end

tmd = transmm;

% ========== Recovering the radiance (haze-less version of the image) === %

J=zeros(size(A));

% for the current implementation of this formula, the values of the 
% pixels should range from [0 1].

% rescale the intensities of each pixel in the three channels of the 
% original image
a_r = im2single(uint8(A(:,:,1)));
a_g = im2single(uint8(A(:,:,2)));
a_b = im2single(uint8(A(:,:,3)));

% rescale the atm. lighting.
atm_lighting = atmLightImageFilt;
atm_lighting = atm_lighting/255;

% loop throught the image to recover its radiance (haze-less version)
for i = 1:x
        for j = 1:y
            
            % from eq. (22) in [2]: 
            % 1 - subtract the original pixel value by the atm. light
            % 2 - divide the result by the max of (tmap(x,y0 , t0))
            % 3 - sum the result with the atm. light
            
            diff = (double(a_r(i,j))-atm_lighting(i,j,1));
            J(i,j,1)=diff/max(transmm(i,j),t0);
            J(i,j,1)=J(i,j,1)+atm_lighting(i,j,1);
            
            diff = (double(a_g(i,j))-atm_lighting(i,j,2));
            J(i,j,2)=diff/max(transmm(i,j),t0);
            J(i,j,2)=J(i,j,2)+atm_lighting(i,j,2);
                        
            diff = (double(a_b(i,j))-atm_lighting(i,j,3));
            J(i,j,3)=diff/max(transmm(i,j),t0);
            J(i,j,3)=J(i,j,3)+atm_lighting(i,j,3);
                   
        end
end

% save images if prompted
if(save==1)
    imwrite(tmd,string(name)+string(atmLightPatchMul)+'tmap_filtered.png');
    imwrite(tmr,string(name)+string(atmLightPatchMul)+'tmap_raw.png');
    imwrite(rescale(atmLightImageFilt),string(name)+string(atmLightPatchMul)+'atml_filtered.png');
    imwrite(rescale(atmLightImage),string(name)+string(atmLightPatchMul)+'atml_raw.png');
    imwrite(rgb2gray(rescale(dcs)),string(name)+'dc.png');    
end

% return the final, contrast-based dehazed image 
dynamic = J;

%%% References
% [1] L^2UWE: A Framework for the Efficient Enhancement of Low-Light 
% Underwater Images Using Local Contrast and Multi-Scale Fusion. Tunai 
% Porto Marques, Alexandra Branzan Albu, 2020. 
% [2] Single Image Haze Removal Using Dark Channel Prior. Kaiming He, 
% Jian Sun, Xiaoou Tang, 2011.
% [3] Enhancement of Low-Lighting Underwater Images Using Dark Channel 
% Prior and Fast Guided Filters. Tunai Porto Marques, Alexandra 
% Brazan-Albu, Maia Hoeberechts, 2018 




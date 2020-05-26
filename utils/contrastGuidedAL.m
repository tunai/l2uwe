function result = contrastGuidedAL(dc,CCI,mult)

% Function to calculate the local, constrast-guided atmospheric lighting 
% model used by L^2WE
% By Tunai Porto Marques, 2020 (tunaimarques.com)
%
% Inputs:
% dc - 1-D dark channel matrix
% CCI - contrast code image calculated using the CCICalculation function
% mult - multiplying factor m (with respect to constrast code
%
% Outputs: 
% result - 1-D atmospheric lighting model of one color channel  

prange_biggest = round(15/2)-1;

%mult_factor = 3;
extended = padarray(dc,[prange_biggest*mult prange_biggest*mult],'symmetric','both');
[x y z] = size(dc);
result = zeros(x,y);

m = mult; 
upsilon = [3*m-((m/3)*(1-1))...
    3*m-((m/3)*(2-1))...
    3*m-((m/3)*(3-1))...
    3*m-((m/3)*(4-1))...
    3*m-((m/3)*(5-1))...
    3*m-((m/3)*(6-1))...
    3*m-((m/3)*(7-1))];

upsilon = floor(upsilon/2);

for i = 1:x
        for j = 1:y
            
            %compensate for the extended indices (padding)
            cpx=i+(prange_biggest*mult); %current pixel x
            cpy=j+(prange_biggest*mult); %current pixel y
            
            %prange=CCI(i,j);
            %prange = 8-prange;
            %prange = prange*mult_factor(CCI(i,j));
            c = CCI(i,j);
            %disp(sprintf('CCI=%d, upsilon = %d',c,upsilon(8-c)));
            prange = upsilon(8-c);
              
            %determine the patch to be considered
            patch = extended(cpx-prange:cpx+prange,cpy-prange:cpy+prange);
            
            %calculate the max of the DC in that color channel inside the patch
            result(i,j) = max(patch(:));
                                   
       end
end






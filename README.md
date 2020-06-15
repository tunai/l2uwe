<img height="343px" width="300px" align="right" src="https://i.imgur.com/fFuKV6O.png">  

### L^2UWE: Low-light underwater image enhancement

This repo contains the implementation of our work: [**L^2UWE: A Framework for the Efficient Enhancement of Low-Light Underwater Images Using Local Contrast and Multi-Scale Fusion**](https://arxiv.org/abs/2005.13736), by Tunai Porto Marques and Alexandra Branzan Albu (presented at the 2020 CVPR Workshop NTIRE: New Trends in Image Restoration and Enhancement held in Seattle, June 15th).

L^2UWE uses a single image, local contrast information and a multi-scale fusion process to highlight visual features from the input that might have been originally hidden because of low-light settings.

If L^2UWE proves to be useful to your work, we ask that you cite its related publications:



#### BibTeX

>    @inProceedings{Marques_2020_CVPR_Workshops,    
>      title={L2UWE: A Framework for the Efficient Enhancement of Low-Light Underwater Images Using Local Contrast and Multi-Scale Fusion},    
>      author={Porto Marques, Tunai and Branzan Albu, Alexandra},    
>      booktitle={The IEEE/CVF Conference on Computer Vision and Pattern Recognition (CVPR) Workshops},   
>      month = {June},   
>      year={2020}}
>
>    @article{porto2019contrast,    
>      title={A Contrast-Guided Approach for the Enhancement of Low-Lighting Underwater Images},    
>      author={Porto Marques, Tunai and Branzan Albu, Alexandra and Hoeberechts, Maia},    
>      journal={Journal of Imaging},      
>      volume={5},  
>      number={10},  
>      pages={79},  
>      year={2019},  
>      publisher={Multidisciplinary Digital Publishing Institute} }

### System requirements

1. MATLAB 
2. Image Processing Toolbox 

The framework was tested on MATLAB versions R2019b and R2020a.

### Demo script

Open the *"demo.m"* script and point to your input image in the *"imread"* command. Some sample low-lighting underwater and aerial images are already provided in the *"./data/"* folder. 

Once processed, the partial and final results are saved on the *"./out/"* folder.

### Dataset

The dataset used in the article, OceanDark, can be accessed at [OceanDark](https://sites.google.com/view/oceandark/home).

### Repo author

Tunai Porto Marques (tunaip@uvic.ca), [website](https://www.tunaimarques.com) 




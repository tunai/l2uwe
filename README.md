<img height="343px" width="300px" align="right" src="https://i.imgur.com/fFuKV6O.png">  

### L^2UWE: Low-light underwater image enhancement

This repo implements our work: **L^2UWE: A Framework for the Efficient Enhancement of Low-Light Underwater Images Using Local Contrast and Multi-Scale Fusion**, by Tunai Porto Marques and Alexandra Branzan Albu (presented at the 2020 CVPR Workshop NTIRE: New Trends in Image Restoration and Enhancement).

If L^2UWE proves to be useful to your work, we ask that you cite its related publications:



#### BibTeX

>    @inproceedings{porto2020contrast,    
>      title={L^2UWE: A Framework for the Efficient Enhancement of Low-Light Underwater Images Using Local Contrast and Multi-Scale Fusion},    
>      author={Porto Marques, Tunai and Branzan Albu, Alexandra},    
>      booktitle={The IEEE Conference on Computer Vision and Pattern Recognition (CVPR) Workshops},    
>      year={2020},
>      publisher={Computer Vision Foundation Open Access} }
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

The framework was tested on MATLAB version R2019b.

### Demo script

Open the "demo.m" script and point to your input image in the "imread" command. Some sample low-lighting underwater and aerial images are already provided in the *"./data"* folder. 

Once processed, the partial and final results are saved on the *"./out"* folder.

### Repo author

Tunai Porto Marques (tunaip@uvic.ca), www.tunaimarques.com 




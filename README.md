# pansharpening-cnn-matlab-version
[Target-adaptive CNN-based pansharpening](https://ieeexplore.ieee.org/document/8334206) is an advanced version of pansharpening method [PNN](http://www.mdpi.com/2072-4292/8/7/594) with residual learning, different loss and a target-adaptive phase. 

This the matlab version of the code, [Go to Python version](https://github.com/sergiovitale/pansharpening-cnn-python-version) for Python.

# Team members
 Giuseppe Scarpa  (giscarpa@.unina.it);
 Sergio Vitale    (contact person, sergio.vitale@uniparthenope.it);
 Davide Cozzolino (davide.cozzolino@unina.it).
 

 
# License
Copyright (c) 2018 Image Processing Research Group of University Federico II of Naples ('GRIP-UNINA').

All rights reserved. This work should only be used for nonprofit purposes.

By downloading and/or using any of these files, you implicitly agree to all the
terms of the license, as specified in the document LICENSE.txt
(included in this directory)

# System requirements:
        Matlab2018b or higher versions, with deep learning toolboxes.
        The running on previous Matlab versions is not guaranteed.
        

# MATLAB packages for :
    a) PNN  [Masi et al. (2016)] 
    b) PNN+ [Scarpa et al. (2018)]

    References
        [Masi2016]      G. Masi, D. Cozzolino, L. Verdoliva and G. Scarpa 
                        “Pansharpening by Convolutional Neural Networks” 
                        Remote Sensing, 
                        vol. , no. , pp. , July 2016.

        [Scarpa2018]    G. Scarpa, S. Vitale and D. Cozzolino, 
                        "Target-Adaptive CNN-Based Pansharpening" 
                        IEEE Transactions on Geoscience and Remote Sensing, 
                        vol. 56, no. 9, pp. 5443-5457, Sept. 2018.

   

# Usage:
  Main functions to call:
  
        `PNN` and `PNNplus`

  Add folder path to your Matlab environment and go:
  
          addpath('<folder location on your pc>/PNNplus_Matlab_code/');
  
  Execution Environment:
   
        The code runs on GPU when available or on CPU, otherwise.
        
        WARNING:    
        
                In the CPU case execution slows down. It is recommended to 
                limit to a few iterations (TF_epochs<10) or skip 
                (FT_epochs=0) the fine-tuning for PNN+ in this case.
   
   To test the code move to the companion folder 'TestPNNplus', that 
   includes three sample images (Ikonos, GeoEye1 and WV2). 
	 Uncomment one row in “testPNNplus.m” to select the sample and run it.
	 The following alternative pansharpened images will be provided and saved (.mat):

	    a) PNN+ with fine tuning (50 iterations): 	“img<sample>_PNNplus.mat”
	    b) PNN+ without fintuning: 			“img<sample>_PNNplus_noFT.mat”
	    c) PNN with additional input bands: 	“img<sample>_PNN.mat”
	    c) PNN without additional input bands: 	“img<sample>_PNN_noIDX.mat”

In "DIARETDB1" and "E_OPTHTA" folders you can find the images used for the experiments detailed in the article "Evaluation of Fractal Dimension effectiveness for damage 
detection in retinal background". In these folders the output images of the preprocessed stage as well as the FOV, disk and vessels masks are available.

In the "code" folder the source code to compute locally the fractal dimension in RGB images is available. In addition, the algorithm used to extract the texture
features by means of the LBPV local histogram is included. Of course, the code in which the SVM classification process using the bagging technique is implemented is also 
available (LIBSVM library is required and available in https://www.csie.ntu.edu.tw/~cjlin/libsvm/). 

If you need the original images of the public databases you have to download them from:

************************************************************************
* E_OPTHTA: *
* http://www.adcis.net/es/Descargar-Software-Base-De-Datos-Terceros/E-Ophtha.html *
* DIARETDB1: *
* http://www.it.lut.fi/project/imageret/diaretdb1/ *
* ***********************************************************************

If you make use of this source code for research pourposes always refer to the following article in any publication or document:
A.Colomer, V.Naranjo, T.Janvier and J.M. Mossi, "Evaluation of Fractal Dimension effectiveness for damage detection in retinal background"
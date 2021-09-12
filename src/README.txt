For users, run 'main.m' or 'LPRec_exported.m' (with GUI) directly in MATLAB, 'test1.jpg' is used for demonstration.
-----------------------------------------------------------------------------------------------------------------------
m files description:
*main.m                                Main function
*LPRex_exported.m               Integrated file with methods and GUI
lp_detect.m                           License plate region detection
lp_titlt.m                                License plate image titlt correction
detectMSER.m                      MSER detection
conComp_analysis.m            MSERs coarse filtering
f_conComp_analysis.m         MSERs fine filtering
LicPlateRec.m                        Characters recgonition
recognise.m                           Load parameters for characters recgonition
sigmoid.m                             sigmoid function

other files description:
test1.jpg                                Test image
theta1.mat                             Non-chinese characters neural network patameter 1
theta2.mat                             Non-chinese characters neural network patameter 2
hanzi_theta1.mat                   Chinese characters neural network patameter 1
hanzi_theta2.mat                   Chinese characters neural network patameter 2
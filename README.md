Livescripts in folder:
1. CorrelationLive.mlx
2. GetAveragesLive.mlx
3. GetAverages_Gabriel.mlx

Scripts in folder:
1. BatchSynchronization.m
2. BatchGetAverages.m
3. BatchGetAverages_Gabriel.m

Description:
This whole directory contains the verification scripts used to analyze the Instron test data for the stepped loading test obtained for AT2- Stepped Loading Test of the Verification document. The stepped loading test was done as we needed to find a calibration factor for high loads (up to 150kg). Once the calibration was found through our MATLAB scripts, we would program the calibration factor through our firmware. Refer to Appendix N of the Design document for the AT2 setup process with Instron  

The Instron folder contains the datasets of the excel sheets that were exported via Instron and stored in folders.

The MCU folder was the test data obtained from the uncalibrated load cell readings generated from our prototype unit (load cell registered force readings applied by Instron and send the data to the MCU unit). Refer to design document (7. Calibration process) for more information.  

Our breadboard prototype was connected through a USB_TTL cable to another laptop. We uploaded the (InstronTestfirmware/src/main.cpp) via VSCODE first, and ran a python script (InstronTestfirmware/datalogging/logRawLoadCellData.py) to read our live uncalibrated force data automatically via serial connection through VSCODE. The python code automatically generates the datasets and exports it as a .csv file, which is what was found in MCU folder. The commands are "python logRawLoadCellData.py exportedfilename.csv". Again, refer to Appendix N of the Design document for the AT2 setup process with Instron. 

The MATLAB scripts were used to first correlate and resample the MCU datasets and Instron datasets since there were time synchronization issues. After that, we would analyze the average slopes of the adjacent step loads to find an average calibration factor value, which was used to program into our firmware via the .set_scale() command.

The MATLAB livescripts (.mlx) are just standalone script use to analyze each test case of the steploads. It is just used an easier visualization of the MATLAB scripts(.m), since the MATLAB scripts analyzes all the datasets automatically.

Run the "BatchSynchronization.m" to correlate and resample the datasets, and a "SyncOutputFiles" folder will appear with the resampled datasets as .csv files. After that, run the "BatchGetAverages.m", which takes the datasets from "SyncOutputFiles" and generates the average calibration data values by automatically exporting the calibration datasets as .csv files to an automatically generated folder called "Average_GradientOutputFiles". The calibration factors for each step load can be found in the second column of the .csv files of the Average_GradientOutputFiles for each step.
**You can re-run the scripts and the folders would be overwritten, if you analyzing new datasets. No need to delete the folders if you want to re-run the scripts.**


How to use:
1. Make sure that the two folders "MCU" and "Instron" are in the same directory as the scripts. These folders contain the experimental data acquired using prototype 2 and the instron setup.
2. Run "BatchSynchronization.m". This creates and populates the folder "SyncOutputFiles". The first column of the files contains time in seconds, the second column contains either raw readings (MCU) or readings in N (Instron). Supporting plots generated as well.
3. (Optional) Open and run "CorrelationLive.mlx" for explanatory graphs on the process that BatchSynchronization performs
4. (alternative to 5.)Run "BatchGetAverages.m". This creates and populates the folder "Average_GradientOutputFiles". The first column of the files contains averaged raw readings at the steps defined by the protocol. The second column contains the gradients calculated for the intervals between each of the steps defined in the protocol. Supporting plots generated as well.
5. (alternative to 4.)Run "BatchGetAverages_Gabriel.m". This creates and populates the folder "Average_GradientOutputFiles_Gabriel"
6. (Optional) Open and run "GetAveragesLive.mlx" for explanatory graphs on the process that BatchGetAverages performs
7. (Optional) Open and run "GetAverages_Gabriel.mlx" for explanatory graphs on the process that BatchGetAverages_Gabriel performs

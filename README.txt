Livescripts in folder:
1. CorrelationLive.mlx
2. GetAveragesLive.mlx
3. GetAverages_Gabriel.mlx

Scripts in folder:
1. BatchSynchronization.m
2. BatchGetAverages.m
3. BatchGetAverages_Gabriel.m

How to use:
1. Make sure that the two folders "MCU" and "Instron" are in the same directory as the scripts. These folders contain the experimental data acquired using prototype 2 and the instron setup.
2. Run "BatchSynchronization.m". This creates and populates the folder "SyncOutputFiles". The first column of the files contains time in seconds, the second column contains either raw readings (MCU) or readings in N (Instron). Supporting plots generated as well.
3. (Optional) Open and run "CorrelationLive.mlx" for explanatory graphs on the process that BatchSynchronization performs
4. (alternative to 5.)Run "BatchGetAverages.m". This creates and populates the folder "Average_GradientOutputFiles". The first column of the files contains averaged raw readings at the steps defined by the protocol. The second column contains the gradients calculated for the intervals between each of the steps defined in the protocol. Supporting plots generated as well.
5. (alternative to 4.)Run "BatchGetAverages_Gabriel.m". This creates and populates the folder "Average_GradientOutputFiles_Gabriel"
6. (Optional) Open and run "GetAveragesLive.mlx" for explanatory graphs on the process that BatchGetAverages performs
7. (Optional) Open and run "GetAverages_Gabriel.mlx" for explanatory graphs on the process that BatchGetAverages_Gabriel performs
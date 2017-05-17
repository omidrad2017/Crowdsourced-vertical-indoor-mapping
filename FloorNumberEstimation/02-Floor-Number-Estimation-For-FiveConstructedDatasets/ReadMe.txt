Floor number estimator for 5 new constructed datasets in the paper.

To evaluate results in paper, you should first open main_Floor_Number_Estimator.mat and 
run it. 

This matlab code calls a function which creates 5 new datasets from aggregation of floor altitude datasets
 which are extracted from 5 different datasets we collected in 5 different days.

finally it runs elbow method on each new dataset and findes the number of floors as K1, K2,..K5.
for the new 5 datasets.

You can evaluate the clustering result of each aggregated dataset based on cluster numbers which are stored in IDX1,..IDX5

The charts in the paper are created based on clustering result of elbow method.




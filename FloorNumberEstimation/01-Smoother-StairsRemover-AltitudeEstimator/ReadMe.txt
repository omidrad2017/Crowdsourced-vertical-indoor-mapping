Current folder contains 4 ddirectory, each related to one building.

In each directory we have 4 to 5 pressure sensor datasets from different days and times.

In each directory, there are two mat files, one of them is best_kmeans and the other is the main script.

The best_kmeans.mat is a function which implements elbow method for determination of number of floors for all pressure datasets and 
alts.m for determination for smoothing pressure signal, removal of stairs data and finally clustering the dataset to altitude datasets.


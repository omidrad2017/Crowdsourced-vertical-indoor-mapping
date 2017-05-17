% Assume that we have five raw pressure datasets from TUM Main Campus
% buildig.
% After smoothing and removal of stairs from these datasets, we convert remained 
% pressure values into altitude values using barometric formula  

% This script calls a set of altitude datasets which are extracted from five
% mentioned altitude datasets at different dates and temperatures 

% Then it runs elbow method to determine number of floors (clusters) in an unsupervised
% way for each dataset to determine number of clusters in each of them
% The important variables:
%   K1,K2,..K5 tell us about number of estimated floors in each constructed
%   dataset
%   C1,C2,..,C5 tells us the final altitude of each floor
%   IDX1,..IDX5 are the corresponding indexes of each cluster

% This function constructs 5 new datasets from TUM Main Campus
% building datasets
 create_five_new_datasets();
 
 % These are for determination of number of floors at each new constructed
 % datasets which were mentioned in a table in the paper
 
[IDX1,C1,SUMD1,K1]= best_kmeans(new_1);
[IDX2,C2,SUMD2,K2]= best_kmeans(new_2);
[IDX3,C3,SUMD3,K3]= best_kmeans(new_3);
[IDX4,C4,SUMD4,K4]= best_kmeans(new_4);
[IDX5,C5,SUMD5,K5]= best_kmeans(new_1);




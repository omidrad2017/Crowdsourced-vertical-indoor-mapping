% TUM Main Campus building has 6 floors (ground floor to 5th floor). 
%--------------------------------------------------------------------------
%
% Assume that we have five raw pressure datasets from TUM Main Campus
% buildig from different days,temperatures and humidities.
% 
% We construct manually 5 new datasets from these five original datasets
% based on the teble in the proposed paper
%
% After smoothing and removal of stairs from these datasets, we convert
% remained pressure values into altitude values using barometric formula  

% This script calls a set of altitude datasets which are already extracted
% from five original altitude datasets 

% Then it runs elbow method to determine number of floors(clusters) in an
% unsupervised way for each constructed dataset 
%
% The important variables:
%
%   K1,K2,..K5: number of estimated floors in each constructed dataset
%   C1,C2,..,C5: final altitude of each floor for each constructed dataset
%   IDX1,..IDX5 are the corresponding indexes of each cluster sets
%   create_five_new_datasets(): constructs 5 new datasets from TUM Main 
%                               Campus building datasets
%
%%
 [new_1,new_2,new_3,new_4,new_5 ]=create_five_new_datasets();
 
 % These are for determination of number of floors at each new constructed
 % datasets which were mentioned in a table in the paper
 
[IDX1,C1,SUMD1,K1]= best_kmeans(new_1');

figure
plot(find(IDX1==1),new_1(IDX1==1),'*')
hold on
plot(find(IDX1==2),new_1(IDX1==2),'*')
plot(find(IDX1==3),new_1(IDX1==3),'*')
plot(find(IDX1==4),new_1(IDX1==4),'*')
plot(find(IDX1==5),new_1(IDX1==5),'*')
plot(find(IDX1==6),new_1(IDX1==6),'*')
plot(new_1)

[IDX2,C2,SUMD2,K2]= best_kmeans(new_2');

figure
plot(find(IDX2==1),new_2(IDX2==1),'*')
hold on
plot(find(IDX2==2),new_2(IDX2==2),'*')
plot(find(IDX2==3),new_2(IDX2==3),'*')
plot(find(IDX2==4),new_2(IDX2==4),'*')
plot(find(IDX2==5),new_2(IDX2==5),'*')
plot(find(IDX2==6),new_2(IDX2==6),'*')
plot(new_2)

[IDX3,C3,SUMD3,K3]= best_kmeans(new_3');

figure
plot(find(IDX3==1),new_3(IDX3==1),'*')
hold on
plot(find(IDX3==2),new_3(IDX3==2),'*')
plot(find(IDX3==3),new_3(IDX3==3),'*')
plot(find(IDX3==4),new_3(IDX3==4),'*')
plot(find(IDX3==5),new_3(IDX3==5),'*')
plot(find(IDX3==6),new_3(IDX3==6),'*')
plot(new_3)

[IDX4,C4,SUMD4,K4]= best_kmeans(new_4');

figure
plot(find(IDX4==1),new_4(IDX4==1),'*')
hold on
plot(find(IDX4==2),new_4(IDX4==2),'*')
plot(find(IDX4==3),new_4(IDX4==3),'*')
plot(find(IDX4==4),new_4(IDX4==4),'*')
plot(find(IDX4==5),new_4(IDX4==5),'*')
plot(find(IDX4==6),new_4(IDX4==6),'*')
plot(new_4)

[IDX5,C5,SUMD5,K5]= best_kmeans(new_5');

figure
plot(find(IDX5==1),new_5(IDX5==1),'*')
hold on
plot(find(IDX5==2),new_5(IDX5==2),'*')
plot(find(IDX5==3),new_5(IDX5==3),'*')
plot(find(IDX5==4),new_5(IDX5==4),'*')
plot(find(IDX5==5),new_5(IDX5==5),'*')
plot(find(IDX5==6),new_5(IDX5==6),'*')
plot(new_5)

% 



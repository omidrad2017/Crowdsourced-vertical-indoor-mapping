% Floor numbers and corresponding altitudes determinator for building
% Adelheid13_A.
%
%
% The true number of floors in this building is 7. We want to run the
% algorithm on aggregated datasets and see how elbow method works for
% Determining number of floors and floors altitude in unsupervised manner
%
%
% Current directory contains pressure datasets and we want to estimate
% floor numbers using elbow method and corresponding altitudes by k-means 
% clustering method and barometric formula
% 
% Variables and functions:
%
%    K2: The final estimated number of floors of this building from aggregated altitude datasets
%    C2: cluster centers of aggregated altitude datasets, they tell us
%         about overall altitude of each floor
%    cluster_1,...,cluster_7: are for evaluation of altitude clusters of aggregated
%                             altitudes(evaluate floor altitudes)
%
%    temps: temperatures of datasets
%
%    best_kmeans: implements the elbow method. At the last line of this function,
%                  there is the k-means function which uses the output of
%                  elbow method for clustering  
% 
% OMID REZA MOSLEHI RAD, 2017

%% read data files from current directory

file_names = dir('*.csv');
nummber_of_files = length(file_names);
Raw_datasets = cell(1,length(file_names));
my_data_smoothed = cell(1,length(file_names));
all_altitudes =NaN;

%% File temperature list
count =1;
% Corresponding temperatures for the 4 pressure datasets 
temps = [8,10,9,11];

%% movingSTD threshold for removing stairs
STD_threshold = 0.022;
sliding_win_size_movstd = 28.5;

%% Main for-loop
% This is a loop to call each dataset and determines the number of floors
% and clustering it

for a=1:length(file_names)
  
  % Loading datasets   
  fname = file_names(a).name;
  Raw_pressure = xlsread(file_names(a).name);
  
  % Smooth each raw pressure signal using median filter
  smoothed = medfilt1(Raw_pressure(1:end,2), 101);
  
  % Altitude of smoothed pressure:
  
  
  % First is determination of reference pressure from overall ground floor pressure
  % values
  % To do so, we temporarily run movstd algorithm to remove all stair pressure
  % values, then run best_kmeans on the pressure signal to find pressure
  % values of each floor
 
  % Moving STD: run movstd algorithm which moves a sliding window size of 28.5 seen at top of script 
  moved = movstd(smoothed,sliding_win_size_movstd ,1); 
  
  % Take those values from smoothed signal where SDT at that point is less
  % than threshold. Those with STD higher than threshold are considered as
  % stair data, while the residuals are for the floors data
  
  Datasets_STDs{a}=moved;
  smoothed_without_stairs=NaN;
  for b = 1:length(smoothed)
      if moved(b)< STD_threshold
          smoothed_without_stairs(b)=smoothed(b);
      else
          smoothed_without_stairs(b)=NaN; 
      end
  end
  
  figure
   subplot(2,1,1)
  plot(Raw_pressure(1:end,2),'LineWidth',2)
  hold on
  plot(smoothed,'LineWidth',1.5)
  title('Raw and Smoothed pressure')
  legend('Raw','Smoothed')
   subplot(2,1,2)
  plot(smoothed_without_stairs,'LineWidth',2)
  hold on
  yyaxis('right')
  plot(moved,'LineWidth',1.5)
  title('Smoothed pressure without stairs')
  legend('Smoothed without stairs','movstd of smoothed')
  
  
smoothed_without_stairs(isnan(smoothed_without_stairs))=[];
 
  % Determination of reference pressure from ground floor pressure values
  % We cluster entire smoothed pressure signal to floor pressures, then
  % select the maximum cluster center as reference pressure
  % K-Means, elbow on each dataset
  % K gives the number of floors and in this case C is a vector for overall pressure of each
  % floor as a cluster center. The clustering of pressure signal helps to
  % find the maximum of vector C as reference pressure 
  
  
  warning('off','all')
  [IDX,C,SUMD,K,distorted]= best_kmeans(smoothed_without_stairs');
  ref_pressure = max(C);
  
  % increase the length of each clustered floor pressure by interpolation
  % to help Kmeans
  
  %store each cluster separately
  
  
 aggregated_increased_clusts = cell(1,K);
  for g = 1:K
       % a floor pressure cluster with index g
       clust = find(IDX==g);
       floor_clust = smoothed_without_stairs(clust);
       % increase length of each floor cluster by Fourier interpolation
       increased_clust=interpft(floor_clust,500);
       aggregated_increased_clusts{g}=increased_clust;
  end 
     
     increased_smooth = cell2mat(aggregated_increased_clusts);
     
   switch a
       case 1
       Adelheid_13A_dataset_1_altitude_increased=sort(((power(ref_pressure./increased_smooth,1/5.257)-1)*(temps(a)+273.15))/0.0065,'ascend');
       figure
       plot (Adelheid_13A_dataset_1_altitude_increased)
       title('Adelheid13_A: altitude of dataset 1')
       case 2
       Adelheid_13A_dataset_2_altitude_increased=sort(((power(ref_pressure./increased_smooth,1/5.257)-1)*(temps(a)+273.15))/0.0065,'ascend');
       figure
       plot (Adelheid_13A_dataset_2_altitude_increased)
       title('Adelheid13_A: altitude of dataset 2')
       case 3
       Adelheid_13A_dataset_3_altitude_increased=sort(((power(ref_pressure./increased_smooth,1/5.257)-1)*(temps(a)+273.15))/0.0065,'ascend');
       plot (Adelheid_13A_dataset_3_altitude_increased)
       title('Adelheid13_A: altitude of dataset 3')
       case 4
       Adelheid_13A_dataset_4_altitude_increased=sort(((power(ref_pressure./increased_smooth,1/5.257)-1)*(temps(a)+273.15))/0.0065,'ascend');
       plot (Adelheid_13A_dataset_4_altitude_increased)
       title('Adelheid13_A: altitude of dataset 4')
       case 5
       Adelheid_13A_dataset_5_altitude_increased=soert(((power(ref_pressure./increased_smooth,1/5.257)-1)*(temps(a)+273.15))/0.0065,'ascend');
       plot (Adelheid_13A_dataset_5_altitude_increased)
       title('Adelheid13_A: altitude of dataset 5')
   end
  % Store the distortion percents of elbow method in a cell array to use
  % the array for final plot of elbows for each dataset
  distortions_Adel_13{a}=distorted;
  
end % end of main for loop

 % Aggregate altitude datasets into one aggregated altitude dataset
 if nummber_of_files == 5
   Adelheid_13A_Aggregated_Altitudes = horzcat(Adelheid_13A_dataset_1_altitude_increased,Adelheid_13A_dataset_2_altitude_increased, Adelheid_13A_dataset_3_altitude_increased,Adelheid_13A_dataset_4_altitude_increased,Adelheid_13A_dataset_5_altitude_increased);
 else % for this specific directory which has 4 datasets:
 Adelheid_13A_Aggregated_Altitudes = horzcat(Adelheid_13A_dataset_1_altitude_increased,Adelheid_13A_dataset_2_altitude_increased, Adelheid_13A_dataset_3_altitude_increased,Adelheid_13A_dataset_4_altitude_increased);   
 end
 
figure
plot(distortions_Adel_13{1,1},'b*--')
title('Adelheid13_A elbows')
hold on
for j=2:length(file_names)
    plot(distortions_Adel_13{1,j},'b*--')
end
hold off


figure
plot(Adelheid_13A_Aggregated_Altitudes)
title('Adelheid13_A: aggregated altitudes')



%% Now we run elbow algorithm on 5 (or here 4)aggregated altitude datasets
[IDX2,C2,SUMD2,K2,distorted2]= best_kmeans_2(Adelheid_13A_Aggregated_Altitudes');

% Finally the plot of  clustering result on aggregated altitude dataset
figure
plot(find(IDX2==1),Adelheid_13A_Aggregated_Altitudes(IDX2==1),'*')
hold on
plot(find(IDX2==2),Adelheid_13A_Aggregated_Altitudes(find(IDX2==2)),'*')
plot(find(IDX2==3),Adelheid_13A_Aggregated_Altitudes(find(IDX2==3)),'*')
plot(find(IDX2==4),Adelheid_13A_Aggregated_Altitudes(find(IDX2==4)),'*')
plot(find(IDX2==5),Adelheid_13A_Aggregated_Altitudes(find(IDX2==5)),'*')
plot(find(IDX2==6),Adelheid_13A_Aggregated_Altitudes(find(IDX2==6)),'*')
plot(find(IDX2==7),Adelheid_13A_Aggregated_Altitudes(find(IDX2==7)),'*')
plot(Adelheid_13A_Aggregated_Altitudes)

% To evaluate accurycy of each floor, you can use the resulting clusters of
% aggregated datasets

cluster_1 = Adelheid_13A_Aggregated_Altitudes(IDX2==1);

cluster_2 = Adelheid_13A_Aggregated_Altitudes(IDX2==2);

cluster_3 = Adelheid_13A_Aggregated_Altitudes(IDX2==3);

cluster_4 = Adelheid_13A_Aggregated_Altitudes(IDX2==4);

cluster_5 = Adelheid_13A_Aggregated_Altitudes(IDX2==5);

cluster_6 = Adelheid_13A_Aggregated_Altitudes(IDX2==6);

cluster_7 = Adelheid_13A_Aggregated_Altitudes(IDX2==7);




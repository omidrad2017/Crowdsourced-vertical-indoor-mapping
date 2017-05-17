% Floor numbers and corresponding altitudes determinator
% 
% Variables:
% Ks: Number of floors of each dataset
% Alt_of_Current_floor: gives you all altitude values of floors of a
% each dataset
% C: Corresponding pressure value of each cluster center 
% Cluster_centroids_ : Cluster centers of all floors of all datasets
% Cs = all cluster centers for all datasets
% temps: temperatures of datasets
% Reference pressure from maximum of vector C


%% read data files from current directory
file_names = dir('*.csv');
nummber_of_files = length(file_names);
my_data = cell(1,length(file_names));
my_data_smoothed = cell(1,length(file_names));

all_altitudes =NaN;

%% File temperature list

count =1;
% temps are sorted based on cels of fnames 
temps = [10,10,9,11,21];

 


%% movingSTD threshold for removing stairs
STD_threshold = 0.022;
sliding_win_size_movstd = 28.5;

%% Main for-loop

for a=1:length(file_names)
  fname = file_names(a).name;
  temp1 = xlsread(file_names(a).name);
  % read pressures
  my_data{a} = temp1(1:end,2);
  % Smooth raw data
  smoothed = medfilt1(cell2mat(my_data(a)),101);
  my_data_smoothed_with_stairs{a}=smoothed;
  % Moving STD
  new_press = movstd(smoothed,sliding_win_size_movstd ,1); % 1 is for normalization
  % Take those values from smoothed signal where SDT at that point is less
  % than threshold
  STDs{a}=new_press;
  for b = 1:size(cell2mat(my_data(a)),1)
      if new_press(b)< STD_threshold
          clean_set(b)=smoothed(b);
      else
          clean_set(b)=NaN;
      end  
  end
  % Plot smoothe data without stairs
  
  my_data_smoothed{a}=clean_set; 
  clean_set =NaN;
  
  figure
  plot(cell2mat(my_data_smoothed(a)))
  % K-Means, elbow on each dataset
  [IDX,C,SUMD,K,distorted]= best_kmeans(cell2mat(my_data_smoothed(a))');
  % Store closter centers of all datasets
  Cs{a}=C; 
  Ks{a}=K;
  distortions{a}=distorted;
  xx = cell2mat(my_data_smoothed(a))';
  %store each cluster separately
  for g = 1:K
       % a floor cluster with index g
       clust = find(IDX==g);
       % assign corresponding floor data from smoothed dataset without stairs
       clusts{g} = xx(clust);
       Floor_Temperature{g} = temps(count);
       % Compute altitude of this cluster
       % Set reference pressure as pressure of ground floor. This is equal
       % to maximum cluster center which correspond to ground floor
       Ref_pressure_current_file = max(C);
       Alt_of_Current_floor{g} =  ((power(Ref_pressure_current_file./xx(clust),1/5.257)-1)*(temps(a)+273.15))/0.0065;
  end 
  % Add altitude of current file to a struct
  Alts{a}= Alt_of_Current_floor;
    count = count+1;
    ClusterCentroids_Agness_35{a} = ((power(Ref_pressure_current_file./C,1/5.257)-1)*(temps(a)+273.15))/0.0065;
end % end of main for loop


figure
plot(distortions{1,1},'b*--')
title('Agness35 elbow')
hold on
for j=2:length(file_names)
    plot(distortions{1,j},'b*--')
end
hold off

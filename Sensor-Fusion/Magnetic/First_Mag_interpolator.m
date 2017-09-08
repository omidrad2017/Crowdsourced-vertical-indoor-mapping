

mag_file_names = dir('*.csv');
raw_mag = xlsread(mag_file_names.name);
unique_raw_mag= unique(raw_mag,'rows'); % using unique here looses lots of data!

 x_temp_mag = unique_raw_mag(:,1);
 v_temp_mag = unique_raw_mag(:,3);
 xq_temp_mag = unique_raw_mag(1,1):1:unique_raw_mag(length(unique_raw_mag),1); 
 
interpolated_mag = interp1(x_temp_mag,v_temp_mag,xq_temp_mag');
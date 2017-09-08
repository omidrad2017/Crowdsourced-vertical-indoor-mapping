% load Build1_4gps_flags.mat then run the code

GPS_file_names = dir('*.csv');
raw_GPS = xlsread(GPS_file_names.name);
unique_raw_GPS= unique(raw_GPS,'rows'); % using unique here looses lots of data!

 x_temp_gps = unique_raw_GPS(:,1);
 v_temp_gps = unique_raw_GPS(:,4);
 xq_temp_gps = unique_raw_GPS(1,1):1:unique_raw_GPS(length(unique_raw_GPS),1); 
 
interpolated_gps = interp1(x_temp_gps,v_temp_gps,xq_temp_gps');



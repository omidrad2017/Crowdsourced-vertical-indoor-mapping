% load Build1_4Light_flags.mat then run the code

Light_file_names = dir('*.csv');
raw_Light = xlsread(Light_file_names.name);
unique_raw_light= unique(raw_Light,'rows'); % using unique here looses lots of data!

 x_temp_light = unique_raw_light(:,1);
 v_temp_light = unique_raw_light(:,2);
 xq_temp_light = unique_raw_light(1,1):1:unique_raw_light(length(unique_raw_light),1); 
 
interpolated_light = interp1(x_temp_light,v_temp_light,xq_temp_light');

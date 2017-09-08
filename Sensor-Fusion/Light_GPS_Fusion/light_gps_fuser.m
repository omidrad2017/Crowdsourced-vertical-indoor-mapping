% load final_interpolated_gps_with_flags.mat and final_interpolated_light_with_flags


intersection_time_interval = intersect(final_interpolated_gps_with_flags(:,1) ,final_interpolated_light_with_flags(:,1),'rows');

start_flag=find(final_interpolated_light_with_flags==intersection_time_interval(1));
end_flag=find(final_interpolated_light_with_flags==intersection_time_interval(end));


current_flags_light = final_interpolated_light_with_flags(:,3);

intersected_flag = current_flags_light(start_flag:end_flag);
intersected_light_data = final_interpolated_light_with_flags(start_flag:end_flag,:);



start_flag_gps=find(final_interpolated_gps_with_flags==intersection_time_interval(1));
end_flag_gps=find(final_interpolated_gps_with_flags==intersection_time_interval(end));


current_flags_gps = final_interpolated_gps_with_flags(:,3);

intersected_flag_gps = current_flags_gps(start_flag_gps:end_flag_gps);
intersected_gps_data = final_interpolated_gps_with_flags(start_flag_gps:end_flag_gps,:);

for s = 1:length(intersected_gps_data)
    if intersected_gps_data(s,3)<0.5
     intersected_gps_data(s,3) =0;
    else
    intersected_gps_data(s,3) =1;
    end
end

for s = 1:length(intersected_light_data)
    if intersected_light_data(s,3)<0.5
     intersected_light_data(s,3) =0;
    else
    intersected_light_data(s,3) =1;
    end
end
final_fused_flag = bitand(intersected_light_data(:,3),intersected_gps_data(:,3));





figure
yyaxis('left')
plot(intersected_gps_data (:,2))
hold on
yyaxis('right')
plot(intersected_light_data (:,2))

figure
yyaxis('left')
plot(intersected_light_data (:,2))
yyaxis('right')
hold on
plot(interpolated_flag)

plot(final_fused_flag.*5000)

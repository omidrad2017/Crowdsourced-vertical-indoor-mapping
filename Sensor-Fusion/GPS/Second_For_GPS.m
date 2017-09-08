
uncert_raw = unique_raw_GPS(:,4);
uncert_raw(1)=8; % to avoid app bug

[counts,centers] = hist(uncert_raw,150);
figure
plot(centers,counts)

first_peaks = findpeaks(counts)
first_peaks (find(first_peaks<5))=0;

sort_seven_peaks = sort(first_peaks,'descend')

temp1 = centers(find(counts == sort_seven_peaks(1)));
temp2 = centers(find(counts == sort_seven_peaks(2)));


 if temp1(1)<17 || temp2(1)<17
  low = 4;
  high = 20;
 end


 if temp1(1)>temp2(1) && temp1(1)>17 && temp2(1) >17 && std(uncert_raw)>100
    low = temp2(1);
    high = temp1(1);
 end

 if temp1(1)>temp2(1) && temp1(1)>17 && temp2(1) >17 && std(uncert_raw)<100
    low = temp2(1)-13;
    high = temp1(1)-4;
 end
 
 
 
  if temp1(1)<temp2(1) && temp1(1)>17 && temp2(1) >17  && std(uncert_raw)>100
    low = temp1(1);
    high = temp2(1);
  end
  if temp1(1)<temp2(1) && temp1(1)>17 && temp2(1) >17  && std(uncert_raw)<100
    low = temp1(1)-13;
    high = temp2(1)-4;
  end  
    
    
    
  gaussed_x = imgaussfilt(uncert_raw, 8);
  hys = hysteresis(gaussed_x,low,high);
  for i=1:length(gaussed_x)
    if(hys(i))==1
        hys(i)=30;
    end
  end

  figure
  plot(uncert_raw,'r')
  hold on
  plot(gaussed_x)
  plot(hys,'g')
  new_low = low;
  new_high = high;
  new_hys = hysteresis(hys,new_low,new_high);

  for i=1:length(gaussed_x)
    if(new_hys(i))==1
        new_hys(i)=30;
    end
  end

  plot(new_hys,'c')
  new2_low = low;
  new2_high = high;
  new2_hys = hysteresis(new_hys,new2_low,new2_high);

  for i=1:length(gaussed_x)
    if(new2_hys(i))==1
        new2_hys(i)=30;
    end
  end
  plot(new2_hys,'yellow')
  
  
  if temp1>17 && temp2 >17 && std(uncert_raw)>200 
   for i=1:length(gaussed_x)
      if(new2_hys(i))<high+5
        new2_hys(i)=1;
      else
        new2_hys(i)=30;
      end
    end
  end
  
  if temp1>17 && temp2 >17 && std(uncert_raw)<200 
   for i=1:length(gaussed_x)
      if(new2_hys(i))<high-7
        new2_hys(i)=1;
      else
        new2_hys(i)=30;
      end
    end
  end
  
  
  if temp1<17 || temp2 <17 
   for i=1:length(gaussed_x)
      if(new2_hys(i))<17
        new2_hys(i)=1;
      else
        new2_hys(i)=30;
      end
    end
  end
  
  
  
  plot(new2_hys,'black')
  axis([0 length(new2_hys) 0 50])
  gps_flags_outdoor_indexes = find(new2_hys==1);
  gps_flags_indoor_indexes = find(new2_hys==30);
  flags = zeros (1,length(hys));
  flags(gps_flags_indoor_indexes)=1;
  flags(gps_flags_outdoor_indexes)=0;
  final_gps_flags=flags';
  
figure
subplot(2,1,1)
plot(uncert_raw)
subplot(2,1,2)
plot(centers,counts)


interpolated_flag_gps = interp1(x_temp_gps,final_gps_flags,xq_temp_gps');

final_interpolated_gps_with_flags = horzcat(xq_temp_gps',interpolated_gps);
final_interpolated_gps_with_flags = horzcat(final_interpolated_gps_with_flags,interpolated_flag_gps);


figure
plot(final_interpolated_gps_with_flags(:,1),final_interpolated_gps_with_flags(:,2))
hold on
yyaxis('right')
plot(final_interpolated_gps_with_flags(:,1),final_interpolated_gps_with_flags(:,3))
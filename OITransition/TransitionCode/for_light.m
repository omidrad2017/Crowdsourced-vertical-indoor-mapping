%uncert_raw = x;

clear all;
clc

light_file_name = dir('*.csv');
temp = xlsread(light_file_name.name);
temp2= unique(temp,'rows');
uncert_raw = temp2(:,2);
histogram_raw = histogram(uncert_raw);
hist_width = histogram_raw.BinLimits;

gaussed_x = imgaussfilt(uncert_raw, 40);

[pks,idx] = findpeaks(gaussed_x);

if isempty(max(pks))
    min_local_max = max(gaussed_x);
else
min_local_max = max(pks);
end

if isempty(max(-pks))
    temp22 =min(gaussed_x);
else  
temp22 = gaussed_x(gaussed_x==-max(-pks));
max_local_min = temp22(1);
end



high = min_local_max;
low = 10;



hys = hysteresis(gaussed_x,low,high);

for i=1:length(gaussed_x)
    if(hys(i))==1
        hys(i)=10000;
    end
end

figure
plot(uncert_raw,'r')
hold on
plot(gaussed_x)
plot(hys,'g')

new_high = min_local_max;
new_low = 10;



new_hys = hysteresis(hys,new_low,new_high);

for i=1:length(gaussed_x)
    if(new_hys(i))==1
        new_hys(i)=10000;
    end
end

plot(new_hys,'c')



new2_high = min_local_max;
new2_low = 10;



new2_hys = hysteresis(new_hys,new2_low,new2_high);

for i=1:length(gaussed_x)
    if(new2_hys(i))==1
        new2_hys(i)=10000;
    end
end

plot(new2_hys,'b')


hold off


for i=1:length(gaussed_x)
   
    if(new2_hys(i))<min_local_max/8.8989 
        new2_hys(i)=0;
    else
        new2_hys(i)=min_local_max/2+50;
    end
    
    
end

% night
if hist_width(2)<300
Light_flags_outdoor_indexes = find(new2_hys==0);
Light_flags_indoor_indexes = find(new2_hys==min_local_max/2+50);
flags = zeros (1,length(temp2(:,2)));
flags(Light_flags_indoor_indexes)=1;
flags(Light_flags_outdoor_indexes)=0;
final_light_flags=flags';
end

% day
if hist_width(2)>300
Light_flags_indoor_indexes = find(new2_hys==0);
Light_flags_outdoor_indexes = find(new2_hys==min_local_max/2+50);
flags = zeros (1,length(temp2(:,2)));
flags(Light_flags_indoor_indexes)=1;
flags(Light_flags_outdoor_indexes)=0;
final_light_flags=flags';
end

hold on
yyaxis('right')
plot(final_light_flags,'black');



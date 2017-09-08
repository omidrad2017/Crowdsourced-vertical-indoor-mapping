


mgn = raw_mag(:,3);

figure
plot(mgn)

moved = movstd(mgn,20,1);

figure
plot(mgn)
hold on
yyaxis('right')
plot(moved)

moved2 = movstd(moved,200,1);

figure
plot(mgn)
hold on
yyaxis('right')
plot(moved2)

softed = imgaussfilt(moved2,500);
figure
plot(softed)
hold on
yyaxis('right')
plot(mgn)


mag_flags=zeros(1,length(softed))';
for t = 1:length(softed)
    if softed(t)<mean(softed)
        mag_flags(t)=0;
    else
        mag_flags(t)=10;
    end
end


plot(mag_flags,'-black')

   
interpolated_flag_mag = interp1(x_temp_mag,mag_flags,xq_temp_mag');

final_interpolated_mag_with_flags = horzcat(xq_temp_mag',interpolated_mag);
final_interpolated_mag_with_flags = horzcat(final_interpolated_mag_with_flags,interpolated_flag_mag);


figure
plot(final_interpolated_mag_with_flags(:,1),final_interpolated_mag_with_flags(:,2))
hold on
yyaxis('right')
plot(final_interpolated_mag_with_flags(:,1),final_interpolated_mag_with_flags(:,3))


function [ new_1,new_2,new_3,new_4,new_5 ] = create_five_new_datasets( )

load('Day_1_separated_floor_alts_feb_11_night.mat')
load('Day_2_separated_floor_alts_Feb_11_temp6_till_fifth.mat')
load('Day_3_separated_floor_alts_Feb_12_till_fifth.mat')
load('Day_4_separated_floor_alts_4_Feb_21_pocket.mat')
load('Day_5_separated_floor_alts_march21_5.mat')

new_1 = horzcat(D1_0,D1_1, D2_0,D2_1,D2_2, D3_0,D3_1,D3_3, D4_0,D4_1,D4_4, D5_0,D5_1,D5_5);

figure
plot(new_1)

new_2 = horzcat(D1_0,D1_2, D2_0,D2_2,D2_3, D3_0,D3_2,D3_4, D4_0,D4_2,D4_5, D5_0,D5_1,D5_2);

figure
plot(new_2)

new_3 = horzcat(D1_0,D1_3, D2_0,D2_3,D2_4, D3_0,D3_3,D3_5, D4_0,D4_1,D4_3, D5_0,D5_2,D5_3);

figure
plot(new_3)


new_4 = horzcat(D1_0,D1_4, D2_0,D2_4,D2_5, D3_0,D3_1,D3_4, D4_0, D4_2,D4_4, D5_0,D5_3,D5_4);

figure
plot(new_4)

new_5 = horzcat(D1_0,D1_5, D2_0,D2_1, D3_0,D3_2,D3_5, D4_0,D4_3, D5_0,D5_4,D5_5);

figure
plot(new_5)
end

magn_file_names = dir('*.csv');

magn = xlsread(magn_file_names.name);
%p = unique(magn,'rows');
mgn = magn(:,3);

figure
plot(mgn)

moved = movstd(mgn,20);

figure
plot(mgn)
hold on
yyaxis('right')
plot(moved)

moved2 = movstd(moved,200);

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


flags=zeros(1,length(softed))';
for t = 1:length(softed)
    if softed(t)<mean(softed)
        flags(t)=0;
    else
        flags(t)=10;
    end
end


plot(flags)

   


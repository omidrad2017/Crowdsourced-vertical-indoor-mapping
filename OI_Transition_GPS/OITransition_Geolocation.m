%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Omidreza Moslehirad
%     Munich, Autumn 2017
%     
%
% This code performs two different methodologies, Hysteresis and Otsu
% methods to separate GPS uncertainty signal into two main parts: INDOORs 
% and 'OUTDOORs'. 
% 
%--------------------------------------------------------------------------
% Hysteresis Thresholding:
%
% We need to find an effective way of detecting major edges 
% in the uncertainty signal. We usually have very large edge in the
% uncertainty signal during outdoor-indoor transitions. 
%
% Hysteresis needs two thresholds: high and low.
% In a recursive manner, any value in the input signal over 'high' as well
% as 'low' will be assigned as '0', while the rest of the signal will be 
% preserved or stretched. This means that for indoor parts, we would have
% '0' values. However, for binary classification, we prefer to have logical
% 'True' values for indoors. The solution is simple. We just need to define
% a Zero vector and set its corresponding indexes for indoors to 1. This 
% will produce the binary classifier, where indoors have '1s' and
% outdoors '0s'.
%
%--------------------------------------------------------------------------
% Otsu's Method:
%
% It is an image processing method, which converts a gray image into a binary
% image. We need to give it an intial threshold (level). 
% 
% We can look at the uncertainty signal like a gray image, but with
% different scale. Since outdoor parts of uncertainty signal is more stable
% than indoor parts, we set a simple threshold of 'level =15m'. This
% function will assign '0' to values lower than the threshold and '1' to
% the higher values in an efficient way. As a result, we directly obtain
% the binary classifier for separation of signal into outdoors and indoors.

%%
clc
clear variables;
close all;

%% Read the Geolocation Dataset
% Read entire directory for *.csv files, store them in a struct
% In this directory, you must put only the GPS file you want to process
gps_file_name = dir('*.csv');
% Retrieve the file content, store it in an array
raw_data = xlsread(gps_file_name.name);
% Extract the 'Uncertainty' column
uncertainty_raw = raw_data(:,4);
uncertainty_raw(1)=7; % to avoid sudden large uncertainty error when app starts data collection
%% Plot 'Uncertainty'and its smoothed curve via Gaussian Filter
smoth = imgaussfilt(uncertainty_raw,5); % Apply Gaussian filter

figure
plot(uncertainty_raw, 'LineWidth',1)
title('Geolocation Uncertainy','FontSize', 20)
xlabel('Number of Samples','FontSize', 20)
ylabel('Uncertainty [m]','FontSize', 20)
hold on
plot(smoth,'LineWidth',2)
legend({'GPS Raw','GPS Smoothed(Gaussian)'},'FontSize', 15)
set(gca,'fontsize',20)
%% Histogram Analysis of Geolocation Uncertainty
% Plot histogram, then fit a smoothed curve on the histogram via Kernel-
% Smoothed Density.
% We need only to observe the 'first peak' of the density signal, which
% emphasize on outdoor GPS uncertainty. The reason is that in outdoor,
% GPS uncertainty is usually almost stable. After identification of the first
% peak, we can determine the initial 'low' and 'high' thresholds for
% hysteresis function.

figure
histogram(smoth,50,'Normalization','probability')
title('Histogram and Kernel Smoothing Density')
pts = 0 : 0.1 : max(smoth);
[f,xi] = ksdensity(smoth,pts);
hold on
f=imgaussfilt(f,2);
plot(xi,f,'LineWidth',2)
xlabel('Uncertainty [m]','FontSize',20)
ylabel('Probability','FontSize',20)
legend({'Frequency','KS Density'},'FontSize',20)
set(gca,'fontsize',20)

[p1,p2]=findpeaks(f) % Find peaks over the smoothed density
p2 = p2./10;

%% Hysteresis Analysis
% Select the first peak of the density signal for determination of initial 'low' and
% 'high' thresholds.
% We do not care about other peaks! Only first peak! 
% We add (subtract) 5m to (from) this peak to
% identify initial thresholds. For instance, if the first peak happens at
% uncertainty of 14m, then initial 'low = 14 - 5' and 'high = 14 + 5'. At
% each loop of the following For-Loop, we increase the distance between low
% and high thresholds by 1m for each thereshold. At the last loop, the high
% thereshold will reach to maximum uncertainty and low threshold will reach
% to zero uncertainty. Finally, indoor parts of the output signal will
% be equal to zero. We can simply define a binary classifier by setting a
% threshold of 1m to find indoor areas.

test = smoth;

if p2(1)<20 && p2(1)> 5
    gap = 5; % Add / subtract from first peak
    ii = (p2(1) - gap);
   for jj = (p2(1) + gap):ceil(max(smoth))
    if ii> 0
      morphed_Uncert = hysteresis(test,ii,jj);
      ii = ii-1;
      test = morphed_Uncert;
    else
      morphed_Uncert = hysteresis(test,1,jj);
      test = morphed_Uncert;  
    end
   end
else 
    test = zeros(size(smoth));
end

% The resulting signal would have values of '0' for indoor areas. This can
% help us to detect edges at transition points with good accuracies.

% No zero: only outdoor
% Only zero: only indoor

figure
title('Hysteresis Method','FontSize',20)
yyaxis('left')
plot(test,'black--','LineWidth',2.1)
hold on
plot(smoth,'LineWidth',1)
% We use values of zero in the variable 'test' as logical '1' for indication
% of indoor areas. 
Hysteresis_Binary_Result = zeros(size(test)); % initial binary classification
% Set threshold of 1m to find indoor areas on the output of hysteresis-
% method (the signal 'test'):
th = 1; % 1m threshold
Hysteresis_Binary_Result(test < th)=1; % indoor areas get value of '1', while outdoors get '0'
yyaxis('right')
plot(Hysteresis_Binary_Result,'LineWidth',2)
legend({'Hysteresis Result', 'GPS Uncertainty', 'Binary Hysteresis'},'FontSize',20)
ylim([-0.01 2])
ylabel('Binary Classification')
set(gca,'fontsize',20)

%% Alternative to Hysteresis: Global image threshold using Otsu's method
% We look at the Uncertainty signal as a one dimensional gray image
% We want to convert it into a binary image using a threshold
% The default level (threshold) is 15m
level =15;
Otsu_Binary_Result = imbinarize(smoth,level); 

figure
yyaxis('left')
title('Otsu Methood','FontSize', 20)
plot(uncertainty_raw, 'LineWidth',1)
xlabel('Number of Samples','FontSize', 20)
ylabel('Uncertainty [m]','FontSize', 20)
hold on
yyaxis('right')
plot(Otsu_Binary_Result,'LineWidth',2)
legend({'GPS Raw','Binary Result of Otsu Method'},'FontSize', 20)
ylabel('Binary Classification','FontSize', 20)
ylim([-0.01 2])
set(gca,'fontsize',20)
hold off

%% Now if we fuse the hysteresis result with Otsu's method result using AND operator:
Hyster_Otsu_Binary=and(Hysteresis_Binary_Result,Otsu_Binary_Result);

figure
title('Fusion of Hysteresis and Otsu Methods (AND Operator)','FontSize',20)
xlabel('Number of samples','FontSize',20)
yyaxis('left')
plot(smoth,'LineWidth',2)
ylabel('Uncertainty [m]', 'FontSize',20)
hold on
yyaxis('right')
plot(Hysteresis_Binary_Result,'g*','LineWidth',2.1)
plot(Otsu_Binary_Result, 'black--','LineWidth',3)
plot(Hyster_Otsu_Binary,'LineWidth',2.1)
ylabel('Binary Classification','FontSize',20)
ylim([-0.01 2])
legend({'Smoothed GPS', 'Only Hysteresis Method' 'Only Otsu Method', 'Fusion of Hysteresis and Otsu'},'Location','northwest','FontSize', 15)
set(gca,'fontsize',20)

%% Third method is simple thresholding
% We define a simple threshold of 13m
% Any values over this level is considered as indoor

simple_th = 13;
simple_binary = zeros(size(smoth));
for k = 1:size(smoth)
    if smoth(k) > simple_th
        simple_binary(k) = 1;
    end
end

figure 
title('Simple Thresholding: th = 13m', 'FontSize', 20)
yyaxis('left')
plot(smoth, 'LineWidth' , 2)
ylabel('Uncertainty [m]', 'FontSize', 20)
hold on
yyaxis('right')
plot(simple_binary, 'LineWidth' , 2)
ylabel('Binary Classification', 'FontSize', 20)
ylim([-0.01 2])
set(gca,'fontsize',20)
legend({'Smoothed GPS', 'Binarry Classification'},'FontSize', 20)

%% Finally, the fusion of these 3 methods
% fusion_gps_3_methods ---> method1 AND (method2 OR method3) OR (method2 AND method3)
% This is a ranking formula based on what the majority of these 3 method
% suggets. For example, if at least 2 of the methods tell a sample is for indoor,
% then it is indoor.
tem = bitand(Hysteresis_Binary_Result,bitor(Otsu_Binary_Result,simple_binary));     
fusion_gps_3_methods = bitor(tem,bitand(Otsu_Binary_Result,simple_binary));

figure
title('Fusion of 3 Methods: Hysteresis, Otsu, and Simple Thresholding', 'FontSize', 15)
yyaxis('left')
plot(smoth, 'LineWidth',2)
ylabel('Uncertainty [m]', 'FontSize', 20)
hold on
yyaxis('right')
plot(fusion_gps_3_methods, 'LineWidth',2)
ylim([-0.01 2])
ylabel('Binary Classification', 'FontSize', 20)
set(gca,'fontsize',20)
legend({'Smoothed GPS', 'Binarry Classification'},'FontSize', 20)

% Plot all classifier results

figure
subplot(5,1,1)
title('Hysteresis')
yyaxis('left')
plot(log2(smoth),'blue-','LineWidth',2.5)
ylabel('Log2(Uncer.[m])')
hold on
yyaxis('right')
plot(Hysteresis_Binary_Result,'r-','LineWidth',1)
ylabel('Bin. Cl.')
ylim([-0.01 2])
subplot(5,1,2)
title('Otsu')
yyaxis('left')
plot(log2(smoth),'blue-','LineWidth',2.5)
ylabel('Log2(Uncer.[m])')
hold on
yyaxis('right')
plot(Otsu_Binary_Result,'r-','LineWidth',1)
ylabel('Bin. Cl.')
ylim([-0.01 2])
subplot(5,1,3)
title('Fusion of Hysteresis and Otsu')
yyaxis('left')
plot(log2(smoth),'blue-','LineWidth',2.5)
ylabel('Log2(Uncer.[m])')
hold on
yyaxis('right')
plot(Hyster_Otsu_Binary,'r-','LineWidth',1)
ylabel('Bin. Cl.')
ylim([-0.01 2])
subplot(5,1,4)
title('Simple Thresholding')
yyaxis('left')
plot(log2(smoth),'blue-','LineWidth',2.5)
ylabel('Log2(Uncer.[m])')
hold on
yyaxis('right')
plot(simple_binary,'r-','LineWidth',1)
ylabel('Bin. Cl.')
ylim([-0.01 2])
subplot(5,1,5)
title('Fusion of Hysteresis, Otsu, and Simple Thresholding')
yyaxis('left')
plot(log2(smoth),'blue-','LineWidth',2.5)
ylabel('Log2(Uncer.[m])')
hold on
yyaxis('right')
plot(fusion_gps_3_methods,'r-','LineWidth',1 )
ylabel('Bin. Cl.')
ylim([-0.01 2])


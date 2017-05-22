# Floor number and floor altitude estimation for 5 new constructed datasets

TUM Main Campus building has 6 floors (ground floor to 5th floor). Assume that we have [five raw pressure datasets][oldpres] from TUM Main Campus building from different days with different temperature and humidity values. The proposed script examines the effect of these variables (temperature, humidity and weather conditions) on final estimation of number of floors and each floor altitude of this building.
To illustrate the robustness of our methodology, we construct manually 5 new datasets from these five original datasets based on the teble in the proposed paper:

- After smoothing and removal of stairs from the selected pressure datasets, we convert remained pressure values into altitude values using barometric formula and construct 5 new altitude datasets from them by aggregating the different altitude clusters. 
- Then we run elbow algorithm to find the number of clusters (floors) in each newly constructed dataset in an unsupervised manner. This is done through the [best kmeans][bestkm] function, which implements elbow method.
- The elbow method is sensitive to the percentage distortion we choose inside this function. The higher the percentage, the higher will be the number of clusters it finds. We have seen that if the number of aggregated datasets are less than 3 or 4, the percentage distortion of 0.987 is fine, but if the number of aggregated clusters increased to 5, it would be better to choose threshold of 0.99

# How to use the scripts? 
If you go to [this directory][mainFol], you will find main_Floor_Number_Estimator.m file. You just need to run this script and it will do everything you need. Detailed description of variables and functions are in the comments part of this file.

The most important variables:
>  K1,K2,..K5: number of estimated floors in each constructed dataset
>  C1,C2,..,C5: final floor altitude arrays of each constructed dataset
>  IDX1,..IDX5 are the corresponding indexes of each cluster sets 
> create_five_new_datasets(): constructs 5 new datasets from TUM Main Campus building datasets

License
----

This project is part of a master thesis at Technical University of Munich with the topic: Crowdsourced Vertical Indoor Mapping. The scripts are written by Omid Reza Moslehi Rad, 2017. The distribution, change or usage of them in any other projects is free with referencing the author.




   [dill]: <https://github.com/omidrad2017/Crowdsourced-vertical-indoor-mapping/tree/master/01-OITransition/TransitionCode>
   [oldpres]:<https://github.com/omidrad2017/Crowdsourced-vertical-indoor-mapping/tree/master/02-FloorNumberEstimation/01-Floor-Number-Estimation-For-FiveConstructedDatasets/FiveOriginalPressureDatasets>
  [bestkm]:<https://github.com/omidrad2017/Crowdsourced-vertical-indoor-mapping/blob/master/02-FloorNumberEstimation/01-Floor-Number-Estimation-For-FiveConstructedDatasets/best_kmeans.m>
  [mainFol]:<https://github.com/omidrad2017/Crowdsourced-vertical-indoor-mapping/tree/master/02-FloorNumberEstimation/01-Floor-Number-Estimation-For-FiveConstructedDatasets>
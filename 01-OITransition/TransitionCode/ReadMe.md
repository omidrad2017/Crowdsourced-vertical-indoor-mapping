# Outdoor to Indoor Transition detection

These scripts are used to see which parts of the GPS, light and magnetic signals correspond to indoor and which parts to outdoor, 

# New Features!

  - To evaluate a e.g. GPS signal, simply take any GPS dataset from any of these directories and run For_GPS.m 
  - Please note that each time you evaluate one dataset. Whenever the evaluation finished, remove the tested file and replace with a new one. You can do the same procedure for light and magnetic signals.
  - For GPS and Light signals, we used image processing techniques such as Gaussian smoothing and hysteresis thresholding. The thresholds for hysteresis are determined automatically using histogram analysis. 
  - For magnetic signal, as far as the magnetic disturbances inside a building is higher than outside, if we perform moving standard deviation analysis over the signal, we can distinguish outdoor from indoor part. To make it short, we use a formula like imgaussfilt(movstd(movstd(magdata,20),200),500) to identify disturbed area of magnetic signal.
 


It is still
  - under impprovement for increasing accuracy and adaption to any scenarios
  - powerful enough to fuse the 3 signals for a more accurate OI transition analysis

The idea behind OI analysis is

> To geolocate the building entrances.
> To extract indoor pressure signal automatically, then compute number of floors and floor height for that building which is interesting for many applications such as automation of creation of CityGML LoD2+ models.

### Tech

OI Transition uses an open source project to work properly:

* Hysteresis.c (2008, Massimo FierroAll) which is implementation of hysteresis algorithm based on C language and usable in Matlab. 

And of course OI Transition scripts are open source with a [public repository][dill]
 on GitHub.


### Any problem in evaluation?
If you still don't know how to evaluate, please follow these instructions:

- Open Matlab
- Create an empty folder
- Put e.g. For_light.m file into this folder
- Take an arbitrary light signal from any of the directories and put it to this folder
- Simply run the code. Very simple :)

License
----

This project is part of a master thesis at Technical University of Munich with the topic: Crowdsourced Vertical Indoor Mapping. The scripts are written by Omid Reza Moslehi Rad, 2017. The distribution, change or usage of them in any other projects is free with referencing the author.




   [dill]: <https://github.com/omidrad2017/Crowdsourced-vertical-indoor-mapping/tree/master/01-OITransition/TransitionCode>
  

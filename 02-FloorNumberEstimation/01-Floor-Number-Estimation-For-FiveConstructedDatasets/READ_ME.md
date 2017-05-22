## start the server

#### run this command in the `server` directory:
```
npm install
```

### start the server without the database:
```
node app.js
```

### OR 
### start the server with the database:
```
node database.js
```


## run the mobile app on an android device 

### 1. go to `www/js/services/constService.js` and change the IP adress in line 21 to the IP adress of your development computer
### 2. run these commands in the `mobile` directory:
 
```
npm install -g cordova ionic
```

```
npm install
```

```
bower install
```

```
ionic platform add android
```

```
ionic run android
```



## use the dashboard

### 1. run these commands in the `chart` directory:
```
npm install
```

```
bower install
```


```
npm start
```

### 2. use the dashboard by going to this URL:
`http://localhost:8000/app/index.html#/dashboard`


## test the mobile app

### to start running unit tests run this command from `mobile/tests` directory:
```
karma start unit-tests.conf.js
```

### to get coverage reports run this command from the `mobile` directory:
```
open "tests/coverage/PhantomJS 2.1.1 (Mac OS X 0.0.0)/services/index.html"
```

## train the classifier

1. go to the `modelbuilding/tools` directory

2. make sure data is in the correct format:
`
python checkdata.py yourFileName
`

3. split the data into training and test set:
`
python subset.py yourFileName numberOfTrainingSamples yourFileName.train yourFileName.test
`

4. find out best value for c and g:
`
python grid.py yourFileName.train
`

5. copy the training and test file from the `tools` directory to the main `modelbuilding` directory and make `modelbuilding` your current directory

6. train the model (bestG and bestC are the values that we got in step 4):
`
svm-train -g bestG -c bestC yourFileName.train 
`

7. try it out:
`
svm-predict yourFileName.test yourFileName.train.model output
`

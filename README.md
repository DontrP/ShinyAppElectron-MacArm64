# ShinyAppElectron-MacArm64
## Build self-contained R Shiny App using Electron for Mac arm64

This project leverage Shiny Electron from COVAIL's electron-quick-start (ref: https://github.com/COVAIL/electron-quick-start) to build self-contained R Shiny Application for Mac arm64. It aims to facilitate the distribution of Shiny application without dependency on server or installation of RStudio at the client's side. It is noted that the current version only work on Mac arm64 for both developer and users. The 'RPortableWin' path for window version included in the main.js is for future experiement purpose. 

The R Shiny application in this project uses data from Data Source: Bhanupratap Biswas. (2023). HR Analytics: Case Study [Data set]. Kaggle. 10.34740/kaggle/dsv/5905686. 

## To build the application, please folow this step.

### 1. Clone the git.
Use terminal and run this command line. 
```
git clone https://github.com/DontrP/ShinyAppElectron-MacArm64
```

### 2. Test the R Shiny application
Before proceeding to package the app, you may wish to test the app and make sure that your RStudio can run the app with all required libaries. You can do this by go to "ShinyApp" folder and open app.R in RStudio. Please proceed to install any required libraries.

### 3. Copy your RStudio into the directory you are building the app
First, create folder name "RPortableMac" in the same directory as main.js.Then, use terminal in Rstudio and go to the directory with main.js file. You can do this by eopening the main.js file in RStudio then go to Code --> Terminal --> Open New Terminal at File Location. And use command line in in the RStudio's terminal. It is noted that if you change the RPortableMac directory name, you are required to make change in main.js as well.
```
cp -r /Library/Frameworks/R.framework/Versions/Current/Resources/* /path-to-your/RPortableMac
```

### 4. Install Electron as development dependency 
Run this in Rstudio's terminal
```
npm install --save-dev electron
```

### 5. Install electron forge
```
npm install --save-dev @electron-forge/cli 
npx electron-forge import
```

### 6. Test your app before paskaging it
```
npm start
```

### 7. Package the app
```
npm run make -- --platform=darwin --arch=arm64
```

If success, the self-contained application will be available in folder "out", containing .dmg for installation and .app for running the app without installation required.



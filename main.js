// Import required modules
const { app, BrowserWindow } = require('electron');
const path = require('path');
const { spawn } = require('child_process');  // For running R script
const detectPort = require('detect-port');   // To check port availability

// Declare variable mainWindow
let mainWindow;

// Define the default port
const defaultPort = 4242;

// Define function to create new browser window
function createWindow(port) {
  mainWindow = new BrowserWindow({
    width: 1500,
    height: 1200,
    webPreferences: {
      nodeIntegration: true // enable Node.js integration
    }
  });

  // Define paths to Rscript executable based on operating system
  // Currently produce app for mac arm64 not yet working for window app
  const RPath = process.platform === 'darwin' ? path.join(__dirname, 
  'RPortableMac', 'Rscript') : path.join(__dirname, 'RPortableWin', 'bin', 'Rscript.exe');

  // Define path to shiny application
  const appPath = path.join(__dirname, 'ShinyApp', 'app.R');

  // Spawn R process on the given port without launching a browser
  const R = spawn(RPath, ['-e', `shiny::runApp('${appPath}', launch.browser=FALSE, port=${port})`]);

  // Log any output/error in the R console
  R.stdout.on('data', (data) => {
    console.log(`R stdout: ${data}`);
  });

  R.stderr.on('data', (data) => {
    console.error(`R stderr: ${data}`);
  });

  // Close main window if the process closes
  R.on('close', (code) => {
    console.log(`R process exited with code ${code}`);
    if (mainWindow) {
      mainWindow.close();
    }
  });

  // Add retry mechanism, block fail
  let attemptCount = 0;
  const maxAttempts = 5;
  const loadDelay = 2000;

  // Define function to load shiny app from localhost on the given port
  function loadShinyApp() {
    mainWindow.loadURL(`http://localhost:${port}`)
      .then(() => console.log('Successfully load shiny app!'))
      
      // Try to maxAttempts then kill the process if fail
      .catch((err) => {
        console.error('Failed to load Shiny app:', err);
        if (attemptCount++ < maxAttempts) {
          console.log(`Attempting to reload Shiny app (${attemptCount}/${maxAttempts})...`);
          setTimeout(loadShinyApp, loadDelay);
        } else {
          console.error('Max attempts reached, failed to load Shiny app.');
          R.kill('SIGINT');
        }
      });
  }

  // Initiate first attempt after delay
  setTimeout(loadShinyApp, loadDelay);

  // Handle window being closed
  mainWindow.on('closed', function () {
    mainWindow = null;
    R.kill('SIGINT');
  });
} // end createWindow function

// Function to find an available port if defult port is not available and then create the window
function findPortAndCreateWindow() {
  detectPort(defaultPort, (err, availablePort) => {
    if (err) {
      console.error('Error detecting port:', err);
      app.quit();
      return;
    }

    // Use the available port (default or suggested by detect-port)
    console.log(`Using port: ${availablePort}`);
    createWindow(availablePort);
  });
}

// Listener to call createWindow function
app.on('ready', findPortAndCreateWindow);

// Listener to quit app when all windows are closed
app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// Listener to create new window if the app is reactivated
app.on('activate', function () {
  if (mainWindow === null) {
    findPortAndCreateWindow();
  }
});

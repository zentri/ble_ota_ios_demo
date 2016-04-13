# Zentri-BLE-OTA for iOS
Zentri BLE OTA allows an application to perform an Over The Air (OTA) firmware update of Zentri BLE devices.

# Installation
To install the iOS Framework into your app:

1. Copy the BLE_OTA_Framework into your application
2. From your project settings, Select your app target and add the framework to the Embedded Binaries, ensuring that it is not also in the linked frameworks and libraries section.
3. You are now ready to start using the OTA Framework

# Usage



###Header
Importing the Framework

```
#import <BLE_OTA_Framework/OTAManager.h>
```

Register your class to be called as the delegate callback you need to call "OTAManagerDelegate". See example call below:

```
@interface MyClass : UIViewController <OTAManagerDelegate>
```

###Implementation
The OTAManager class is a singleton so to create an object in your own class call the "sharedInstance" method

```
/**
 * OTA Manager is a Singleton. You need to call this to initialise an instance of the object
 */
+(OTAManager *)sharedInstance;

/**
 * The call to scan for all bluetooth enabled devices to OTA
 * Devices are returned via callback didDiscoverPeripheralWithName:
 */
-(void)scanForOTADevices;

/**
 * This is the function to call when you want to stop the scanning for BLE devices
 * @return BOOL advising that scanning has stopped
 */
-(BOOL)stopScanningOTADevices;

/**
 * This is the function to connect to the device and start the process by reading the current firmware version. Your app will be notified via didConnectToDevice when you get a connection.
 * @param deviceName The name of the device which you want to connect to. This has been returned by delegate didDiscoverPeripheralWithName:
 */
-(void)connectToDevice:(NSString *)deviceName;

/**
 * This is the function to start the OTA process after selecting a device to OTA. Once the process has been started you will receive updates via several delegate methods. See below for all methods that can be implemented to provide feedback.
 * @param imageName this is the url of the firmware image to be downloaded
 */
-(void)startOtaProcessForDeviceWithImageName:(NSString *)imageName;

/**
 *
 * This is the function to stop an ota in progress
 */
-(void)stopOtaProcess;


/**
 *
 * Check to see if ota is in progress
 */
-(BOOL)isOtaInProgress;

/**
 * Function to check if there is an active connection to any BLE device
 * @return BOOL representing if there is a connection or not
 */
-(BOOL)isDeviceConnected;

/**
 * Function to disconnect any connected BLE device
 */
-(void)disconnectConnectedDevice;

/**
 * Function to clear the scan list items.
 */
-(void)clearScanListItems;

/**
 * Function to be used to reset the state back to initial state
 */
-(void)resetState;
```

###Delegate Callback Methods
The following are the callback methods your application will need to implement to receive data from the OTA Framework

```
/**
 * Delegate to provide a list of peripheral names to the calling app. This is called during the scanning process so will progressively return results 
 * @param peripheralName name of the peripheral discovered
 */
-(void)didDiscoverPeripheralWithName:(NSString *)peripheralName;

/**
 * Delegate to report the progress of the overall OTA progress
 * @param currentStep an int representing the current step being executed
 * @param totalNumberOfSteps an int representing the total number of steps to be completed in the OTA process
 */
-(void)progressUpdateCurrentStep:(NSInteger)currentStep ofTotalSteps:(NSInteger)totalNumberOfSteps;

/**
 * Delegate to report the progress of a download back to the UI so that a progress bar can display the progress
 * @param bytes the current number of bytes that have been downloaded
 * @param totalBytes total bytes to be downloaded for this file
 */
-(void)fileDownloadProgress:(uint64_t)bytes ofTotalBytes:(uint64_t)totalBytes;

/**
 * Delegate to report when an error has occurred during the downloading of a firmware image
 * @param fileUrl the url of the requested firmware file
 * @param error the NSError object describing what the error encountered was
 */
-(void)fileDownloadCompletedFile:(NSURL *)fileUrl WithError:(NSError *)error;

/**
 * This is mainly used to indicate if the intended file URL did not return a valid firmware image
 * @param error the error encountered during download.
 */
-(void)fileFailedToDownloadWithError:(NSError *)error;

/**
 * Delegate to report when the firmware version is read from the device as the current running firmware
 * @param currentFirmwareVersion String representation of the firmware version
 */
-(void)currentFirmwareVersionRead:(NSString *)currentFirmwareVersion;

/**
 * Delegate to report when a successful connection has been established
 */
-(void)didConnectToDevice;

/**
 * Delegate to report that the OTA of the selected device has completed
 */
-(void)otaDeviceCompleted;

/**
 * Delegate to report errors that may occur in the OTA process
 * @param error NSError object containing the error
 * @param step the OTA step which the error occurred
 */
-(void)otaErrorOccurred:(NSError *)error atStep:(NSInteger)step;

/**
 * Delegate for updating on the progress of the upload as this can take some time
 * @param bytes the number of bytes that has been uploaded
 * @param totalBytes the total number of bytes to be uploaded
 */
-(void)firmwareImageUploadProgress:(NSInteger)bytes ofTotalBytes:(NSInteger)totalBytes;

/**
 * Delegate to advise if the BLE device did not respond to an update within a timely fashion (3 seconds)
 */
-(void)otaDidTimeOutWaitingForUpdate;

/**
 * Delegate to advise if the BLE device did not respond to a response to a write request (3 seconds)
 */
-(void)otaDidTimeOutWaitingForResponse;


/**
 * Delegate to advise if the connection to the BLE device times out (3 seconds)
 */
-(void)otaDeviceConnectionTimeOut;


/**
 * Delegate to advise when the status of Bluetooth on the iOS device is no longer enabled
 */
-(void)bluetoothStatusNotEnabled;
```


# License
Copyright (C) 2016, Zentri, Inc. All Rights Reserved.

The Zentri BLE OTA Framework and Zentri BLE OTA Demo App example applications are provided free of charge by Zentri. The combined source code, and all derivatives, are licensed by Zentri SOLELY for use with devices manufactured by Zentri, or devices approved by Zentri.

Use of this software on any other devices or hardware platforms is strictly prohibited. THIS SOFTWARE IS PROVIDED BY THE AUTHOR AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
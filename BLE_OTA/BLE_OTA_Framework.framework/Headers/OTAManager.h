//
//  OTAManager.h
//  BLE_OTA_2_Framework
//
//  Created by Anthony Williams on 16/03/2016.
//  Copyright © 2016 Zentri. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OTAManagerDelegate;

@interface OTAManager : NSObject

@property (nonatomic) id<OTAManagerDelegate> delegate;

/**
 * OTA Manager is a Singleton. You need to call this to initialise an instance of the object
 */
+(OTAManager *)sharedInstance;

/**
 *the call to scan for all bluetooth enabled devices to OTA
 *
 */
-(void)scanForOTADevices;

/**
 * This is the function to call when you want to stop the scanning for BLE devices
 * @return BOOL advising that scanning has stopped
 */
-(BOOL)stopScanningOTADevices;

/**
 * This is the function to connect to the device and start the process by reading the current firmware version
 * @param deviceName The name of the device which you want to connect to. This has been returned by delegate didDiscoverPeripheralWithName:
 */
-(void)connectToDevice:(NSString *)deviceName;

/**
 * This is the function to start the OTA process after selecting a device to OTA
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

@end


@protocol OTAManagerDelegate <NSObject>
@optional
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
@end
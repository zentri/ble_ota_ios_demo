//
//  OTAViewController.m
//  BLE_OTA_2
//
//  Created by Anthony Williams on 24/03/2016.
//  Copyright © 2016 Zentri. All rights reserved.
//
/*
 License
 Copyright 2016, Zentri, Inc. All Rights Reserved.
 
 The Zentri BLE OTA iOS application is provided free of charge
 by Zentri. The combined source code, and all derivatives, are licensed by Zentri SOLELY for use
 with devices manufactured by Zentri, or devices approved by Zentri.
 
 Use of this software on any other devices or hardware platforms is strictly prohibited.
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
 BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "OTAViewController.h"

#define READ_VERSION_STATE  2
#define FINAL_READ_STATE    12
#define LEGACY_READ_ERROR   2001

@interface OTAViewController ()

//Outlets - Labels
@property (nonatomic, weak) IBOutlet UILabel *peripheralNameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *deviceStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceCurrentFirmwareLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentProcessLabel;

//Outlets - TextFields
@property (weak, nonatomic) IBOutlet UITextField *firmwareURLTextField;


//Outlets - Buttons
@property (nonatomic, weak) IBOutlet UIButton *otaButton;

//Outlets Progress View
@property (weak, nonatomic) IBOutlet UIProgressView *progressBarView;

//Actions
- (IBAction)otaButtonAction;


//Variables
@property (nonatomic, strong) OTAManager *otaManager;

@end

@implementation OTAViewController
#pragma mark - View Controller Functions

-(void)viewDidLoad
{
    [super viewDidLoad];
    // do other setup stuff here
    [_peripheralNameLabel setText:_peripheralName];
    
    _otaManager = [OTAManager sharedInstance];
    
    [_otaButton setTitle:@"Start OTA" forState:UIControlStateNormal];
    [_otaButton setTitle:@"Connecting..." forState:UIControlStateDisabled];
    [_otaButton setEnabled:NO];
    
    _progressBarView.progress = 0.0;
//    [_deviceStatusLabel setText:@"Not Connected"];
    [_deviceCurrentFirmwareLabel setText:@""];
    [_currentProcessLabel setText:@""];
    [_firmwareURLTextField setReturnKeyType:UIReturnKeyDone];
    [_firmwareURLTextField setDelegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_otaManager setDelegate:self];
    [_otaManager connectToDevice:_peripheralName];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if ([_otaManager isDeviceConnected])
    {
        [_otaManager disconnectConnectedDevice];
    }

    [_otaManager setDelegate:nil];
}

#pragma mark - OTAManager Delegate Functions

-(void)currentFirmwareVersionRead:(NSString *)currentFirmwareVersion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_deviceCurrentFirmwareLabel setText:currentFirmwareVersion];
        [_otaButton setEnabled:YES];
//        [_currentProcessLabel setText:@"Firmware Version Read"];
    });
}

-(void)progressUpdateCurrentStep:(NSInteger)currentStep ofTotalSteps:(NSInteger)totalNumberOfSteps
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (currentStep >= 3)
        {
            float progress = ((float)currentStep / (float)totalNumberOfSteps);
            [_progressBarView setProgress:progress animated:YES];
        }
        
        switch (currentStep)
        {
            case 1:
            {
//                [_currentProcessLabel setText: @"Connecting"];
                break;
            }
                
            case 2:
            {
//                [_currentProcessLabel setText: @"Reading Version"];
                break;
            }
                
            case 3:
            {
                [_currentProcessLabel setText: @"Checking Firmware"];
                break;
            }
                
            case 4:
            {
                [_currentProcessLabel setText: @"Downloading Firmware"];
                break;
            }
                
            case 5:
            {
                [_currentProcessLabel setText: @"Initalise Firmware"];
                break;
            }
                
            case 6:
            {
                [_currentProcessLabel setText: @"Set Firmware Type"];
                break;
            }
                
            case 7:
            {
                [_currentProcessLabel setText: @"Set Firmware Size"];
                break;
            }
                
            case 8:
            {
                [_currentProcessLabel setText: @"Uploading Firmware"];
                break;
            }
                
            case 9:
            {
                [_currentProcessLabel setText: @"CRC Check"];
                break;
            }
                
            case 10:
            {
                [_currentProcessLabel setText:@"Upload Complete"];
                break;
            }
                
            case 11:
            {
                [_currentProcessLabel setText:@"Connecting"];
                break;
            }
                
            case 12:
            {
                [_currentProcessLabel setText:@"Reading Version"];
                break;
            }
                
            case 13:
            {
                [_currentProcessLabel setText: @"OTA Complete"];
                break;
            }
                
            case 14:
            {
                [_currentProcessLabel setText: @"Error"];
                [_otaButton setTitle:@"OTA Error" forState:UIControlStateDisabled];
                [_otaButton setEnabled:NO];
                break;
            }
                
            default:
                [_currentProcessLabel setText: @""];
                break;
        }
    });
}

-(void)didConnectToDevice
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_deviceStatusLabel setText:@"Connected"];
        
//    });
}

-(void)otaDeviceCompleted
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [_deviceStatusLabel setText:@"OTA Complete"];
        [_otaButton setTitle:@"Completed" forState:UIControlStateDisabled];
        [_otaButton setEnabled:NO];
        [_progressBarView setProgress:1.0 animated:YES];
        UIAlertController *completeAlert = [UIAlertController alertControllerWithTitle:@"OTA Complete" message:@"OTA Process has completed successfully" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [completeAlert dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }];
        
        [completeAlert addAction:okAction];
        [self presentViewController:completeAlert animated:YES completion:nil];
    });
}

-(void)firmwareImageUploadProgress:(NSInteger)bytes ofTotalBytes:(NSInteger)totalBytes
{
    dispatch_async(dispatch_get_main_queue(), ^{
        float currentUploadProgress = (float)bytes / (float)totalBytes;
        [_progressBarView setProgress:currentUploadProgress animated:YES];
    });
}

-(void)otaErrorOccurred:(NSError *)error atStep:(NSInteger)step
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_otaButton setTitle:@"OTA Error" forState:UIControlStateDisabled];
        [_otaButton setEnabled:NO];
        UIAlertController *otaError;
        if (step == READ_VERSION_STATE || step == FINAL_READ_STATE)
        {
            if (error.code == LEGACY_READ_ERROR)
            {
                [_otaButton setTitle:@"OTA Complete" forState:UIControlStateDisabled];
                [_currentProcessLabel setText:@"OTA Complete"];
                otaError = [UIAlertController alertControllerWithTitle:@"OTA Complete" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            }
            else
            {
                otaError = [UIAlertController alertControllerWithTitle:@"OTA Error" message:@"There was an error communicating with your device to get the current firmware version. Please try turning bluetooth off and on if this error continues" preferredStyle:UIAlertControllerStyleAlert];
            }
        }
        else
        {
            otaError = [UIAlertController alertControllerWithTitle:@"OTA Error" message:[NSString stringWithFormat:@"An error has occured while trying to OTA your device. The error was: %@\n Step Number: %ld", error.localizedDescription, (long)step] preferredStyle:UIAlertControllerStyleAlert];
        }
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [otaError dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }];
        [otaError addAction:ok];
        [self presentViewController:otaError animated:YES completion:nil];
    });
}

-(void)fileDownloadCompletedFile:(NSURL *)fileUrl WithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_otaButton setTitle:@"OTA Error" forState:UIControlStateDisabled];
        [_otaButton setEnabled:NO];
        UIAlertController *otaError = [UIAlertController alertControllerWithTitle:@"OTA Error" message:@"An error has occured while trying to download the firmware file" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [otaError dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }];
        [otaError addAction:ok];
        [self presentViewController:otaError animated:YES completion:nil];
    });
}

-(void)fileFailedToDownloadWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_otaButton setTitle:@"OTA Error" forState:UIControlStateDisabled];
        [_otaButton setEnabled:NO];
        UIAlertController *otaError = [UIAlertController alertControllerWithTitle:@"OTA Error" message:[NSString stringWithFormat:@"An error has occured while trying to download the firmware file. Error was: %@", error.localizedDescription]  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [otaError dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }];
        [otaError addAction:ok];
        [self presentViewController:otaError animated:YES completion:nil];
    });
}

-(void)otaDidTimeOutWaitingForUpdate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *timeoutUpdateAlert = [UIAlertController alertControllerWithTitle:@"OTA Timeout" message:@"Your BLE device did not respond to a request for update" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [timeoutUpdateAlert dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }];
        
        [timeoutUpdateAlert addAction:okAction];
        
        [self presentViewController:timeoutUpdateAlert animated:YES completion:nil];
        
        [_currentProcessLabel setText: @"Error"];
        [_otaButton setTitle:@"OTA Error" forState:UIControlStateDisabled];
        [_otaButton setEnabled:NO];
    });
}

-(void)otaDidTimeOutWaitingForResponse
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *timeoutResponseAlert = [UIAlertController alertControllerWithTitle:@"OTA Timeout" message:@"Your BLE device did not respond to a request for write" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [timeoutResponseAlert dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }];
        
        [timeoutResponseAlert addAction:okAction];
        
        [self presentViewController:timeoutResponseAlert animated:YES completion:nil];
        
        [_currentProcessLabel setText: @"Error"];
        [_otaButton setTitle:@"OTA Error" forState:UIControlStateDisabled];
        [_otaButton setEnabled:NO];
    });
}

-(void)otaDeviceConnectionTimeOut
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *timeoutResponseAlert = [UIAlertController alertControllerWithTitle:@"OTA Timeout" message:@"Your BLE device did not respond to a request to connect" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [timeoutResponseAlert dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }];
        
        [timeoutResponseAlert addAction:okAction];
        
        [self presentViewController:timeoutResponseAlert animated:YES completion:nil];
        
        [_currentProcessLabel setText: @"Error"];
        [_otaButton setTitle:@"OTA Error" forState:UIControlStateDisabled];
        [_otaButton setEnabled:NO];
    });
}

-(void)bluetoothStatusNotEnabled
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *bluetoothAlert = [UIAlertController alertControllerWithTitle:@"Bluetooth Error" message:@"Your Bluetooth does not appear to be enabled. Please go into your settings and resolve this before continuing" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [bluetoothAlert dismissViewControllerAnimated:YES completion:nil];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }];
        
        [bluetoothAlert addAction:okAction];
        
        [self presentViewController:bluetoothAlert animated:YES completion:nil];
        
        [_currentProcessLabel setText: @"Error"];
        [_otaButton setTitle:@"OTA Error" forState:UIControlStateDisabled];
        [_otaButton setEnabled:NO];
    });
}

#pragma mark - Action Funcitons

- (IBAction)otaButtonAction
{
    if ([_otaManager isOtaInProgress])
    {
        [_otaButton setTitle:@"OTA Aborted" forState:UIControlStateDisabled];
        [_otaButton setEnabled:NO];
        [_otaManager stopOtaProcess];
    }
    else
    {
        [_otaButton setTitle:@"Abort OTA" forState:UIControlStateNormal];

        [_otaManager startOtaProcessForDeviceWithImageName:_firmwareURLTextField.text];
    }
    
}

#pragma mark - Textfield delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}
@end

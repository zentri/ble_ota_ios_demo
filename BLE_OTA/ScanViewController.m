//
//  ScanViewController.m
//  BLE_OTA_2
//
//  Created by Anthony Williams on 10/03/2016.
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

#import "ScanViewController.h"
#import "OTAViewController.h"

#define NUMBER_OF_SECTIONS          1

@interface ScanViewController ()

//Outlets
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;

//Actions
- (IBAction)scanAction;

//Variables
@property (nonatomic, strong) OTAManager *otaManager;
@property (nonatomic, strong) NSMutableArray *deviceListArray;
@property (nonatomic) BOOL cellSelected;
@end

@implementation ScanViewController

#pragma mark - View Controller Functions
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _deviceListArray = nil;
    _cellSelected = NO;
    
    _otaManager = [OTAManager sharedInstance];
    
    
    _deviceListArray = [[NSMutableArray alloc] init];
    
    [_scanButton setTitle:@"Scan" forState:UIControlStateNormal];
    [_scanButton setTitle:@"Scanning..." forState:UIControlStateDisabled];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_otaManager setDelegate:self];
    [_otaManager resetState];
    [_scanButton setEnabled:YES];
    
    [_otaManager clearScanListItems];
    [_deviceListArray removeAllObjects];
    [_deviceTableView reloadData];
    [self performSelector:@selector(startScanning) withObject:NULL afterDelay:0.5];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_otaManager setDelegate:nil];
    _cellSelected = NO;
}


#pragma mark - UITableViewController Functions

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_OF_SECTIONS;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_deviceListArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    
    // Do something to cell
    
    [cell.textLabel setText:[_deviceListArray objectAtIndex:indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _cellSelected = YES;
    [self performSegueWithIdentifier:@"otaDevice" sender:[_deviceListArray objectAtIndex:indexPath.row]];
}


#pragma mark - Navigation Functions

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"help"])
    {
        return YES;
    }
    
    return _cellSelected;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //segue identifier "otaDevice"
    if ([segue.identifier isEqualToString:@"otaDevice"])
    {
        OTAViewController *otaView = [segue destinationViewController];
        otaView.peripheralName = (NSString *)sender;
    }
}


#pragma mark - OTAManager Functions

-(void)didDiscoverPeripheralWithName:(NSString *)peripheralName
{
    [_deviceListArray addObject:peripheralName];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_deviceTableView reloadData];
    });
}

-(void)bluetoothStatusNotEnabled
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *bluetoothAlert = [UIAlertController alertControllerWithTitle:@"OTA Timeout" message:@"Your BLE device did not respond to a request to connect" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [bluetoothAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [bluetoothAlert addAction:okAction];
        
        [self presentViewController:bluetoothAlert animated:YES completion:nil];
        [_scanButton setEnabled:YES];
    });
}

#pragma mark - Action Functions

- (IBAction)scanAction
{
    [self startScanning];
}


#pragma mark - Private Functions

-(void)startScanning
{
    [_deviceListArray removeAllObjects];
    [_scanButton setEnabled:NO];
    [_otaManager scanForOTADevices];
    [self performSelector:@selector(stopScanning) withObject:NULL afterDelay:5.0];
}

-(void)stopScanning
{
    if ([_otaManager stopScanningOTADevices])
    {
        [_scanButton setEnabled:YES];
    }
}
@end

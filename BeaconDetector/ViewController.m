//
//  ViewController.m
//  BeaconDetector
//
//  Created by DiftCTO on 2016. 2. 20..
//  Copyright © 2016년 Minho. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    CBCentralManager *centralManager;
    CBPeripheral *tperipheral;
    CBPeripheralManager *peripheralManager;
}
@property (nonatomic, strong) CLLocationManager * locationManager;


@property (weak, nonatomic) IBOutlet UILabel *lbUUID;
@property (weak, nonatomic) IBOutlet UILabel *lbMajor;
@property (weak, nonatomic) IBOutlet UILabel *lbMinor;
@property (weak, nonatomic) IBOutlet UILabel *lbProximity;
@property (weak, nonatomic) IBOutlet UILabel *lbAccuracy;
@property (weak, nonatomic) IBOutlet UILabel *lbRSSI;
@property (weak, nonatomic) IBOutlet UILabel *lbRange;
@property (weak, nonatomic) IBOutlet UITextView *tvLog;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:regionUUID identifier:@"beacon"];
    
    //    [region setNotifyOnEntry:YES];
    //    [region setNotifyOnExit:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //    [self.locationManager requestAlwaysAuthorization];
    //    [self.locationManager startMonitoringForRegion:region];
    //    [self.locationManager startRangingBeaconsInRegion:region];
    
    [self findbluetooth];
}

- (void)findbluetooth {
    // Scan for all available CoreBluetooth LE devices
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

#pragma mark - CBCentralManagerDelegate


// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"centralmanager didconnect");
    NSLog(@"%@", peripheral);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if ([peripheral.name isEqualToString:@"MiniBeacon_36339"]) {
        NSLog(@"centralmanager diddiscover : %@", advertisementData);
        
        //    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
        //    if ([localName length] > 0) {
        //        NSLog(@"Found the heart rate monitor: %@", localName);
        ////        [self.centralManager stopScan];
        ////        self.polarH7HRMPeripheral = peripheral;
        //        peripheral.delegate = self;
        //        [centralManager connectPeripheral:peripheral options:nil];
        //    }
        NSLog(@"stop scan");
        [centralManager stopScan];
        NSLog(@"peripheral = %@", peripheral.identifier.UUIDString);
        NSLog(@"connected = %ld", (long)peripheral.state);
        NSLog(@"name = %@", peripheral.name);
        NSLog(@"rssi = %@", RSSI);
        
        tperipheral = peripheral;
        peripheral.delegate = self;
        [centralManager connectPeripheral:peripheral options:nil];
        [peripheral discoverServices:nil];
        
        
        NSLog(@"%@", [advertisementData valueForKey:CBAdvertisementDataServiceDataKey]);
        
        NSString *data = [NSString stringWithFormat:@"%@",[[advertisementData objectForKey:CBAdvertisementDataServiceDataKey] allValues]];
        Byte AdvDataArray[data.length];
        NSLog(@"AdvDataArray: ");
        for(int i=0; i<data.length; i++){
            AdvDataArray[i]=[data characterAtIndex:i];
            printf("%x",AdvDataArray[i]);
        }
        printf("\n");
    }
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralmanager didupdate");
    
    //Add the following under the else condition...
    if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    } else {
        NSLog(@"not poweredon");
    }
}

#pragma mark - CBPeripheralDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown: {
            NSLog(@"Unknown");
            break;
        }
        case CBPeripheralManagerStateResetting: {
            NSLog(@"Resetting");
            break;
        }
        case CBPeripheralManagerStateUnsupported: {
            NSLog(@"Unsupported");
            break;
        }
        case CBPeripheralManagerStateUnauthorized: {
            NSLog(@"Unauthorized");
            break;
        }
        case CBPeripheralManagerStatePoweredOff: {
            NSLog(@"PoweredOff");
            break;
        }
        case CBPeripheralManagerStatePoweredOn: {
            NSLog(@"PoweredOn");
            break;
        }
    }
}
// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"peripheral1 : %@", peripheral);
    
    CBService *svc;
    
    for (svc in peripheral.services) {
        NSLog(@"Service : %@", svc);
        [peripheral discoverCharacteristics:nil forService:svc];
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    CBCharacteristic *charicteristic;
    for (charicteristic in service.characteristics) {
        //        NSLog(@"Character : %@", charicteristic);
        [peripheral readValueForCharacteristic:charicteristic];
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"peripheral3 : %@", characteristic);
    
    [_tvLog setText:[[_tvLog.text stringByAppendingString:characteristic.description] stringByAppendingString:@"\n"]];
    
    
    //    println("\nCharacteristic \(characteristic.description) isNotifying: \(characteristic.isNotifying)\n")
    
    if (characteristic.isNotifying == true) {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

#pragma mark - Rest

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSString *strAlert = [NSString stringWithFormat:@"Entered Region '%@'", region.identifier];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:strAlert message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:actionOk];
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSString *strAlert = [NSString stringWithFormat:@"Left Region '%@'", region.identifier];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:strAlert message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:^{
    }];
    
//    UIAlertView * av = [[UIAlertView alloc] init];
//    av.title = [NSString stringWithFormat:@"Left Region '%@'", region.identifier];
//    [av addButtonWithTitle:@"OK"];
//    [av show];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed : %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"update location");
}

/*
 *  locationManager:didRangeBeacons:inRegion:
 *
 *  Discussion:
 *    Invoked when a new set of beacons are available in the specified region.
 *    beacons is an array of CLBeacon objects.
 *    If beacons is empty, it may be assumed no beacons that match the specified region are nearby.
 *    Similarly if a specific beacon no longer appears in beacons, it may be assumed the beacon is no longer received
 *    by the device.
 */
- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        [_lbUUID setText:beacon.proximityUUID.UUIDString];
        NSString *distance = @"Unknown";
        switch (beacon.proximity) {
            case CLProximityUnknown: {
                distance = @"Unknown";
                break;
            }
            case CLProximityImmediate: {
                distance = @"Immediate (very close)";
                break;
            }
            case CLProximityNear: {
                distance = @"Near (1~3m)";
                break;
            }
            case CLProximityFar: {
                distance = @"Far (> 3m)";
                break;
            }
        }
        [_lbProximity setText:distance];
        [_lbAccuracy setText:[NSString stringWithFormat:@"+/- %fm", beacon.accuracy]];
        [_lbMinor setText:beacon.minor.description];
        [_lbMajor setText:beacon.major.description];
        [_lbRSSI setText:[NSString stringWithFormat:@"%ld", beacon.rssi]];
    }
}

/*
 *  locationManager:rangingBeaconsDidFailForRegion:withError:
 *
 *  Discussion:
 *    Invoked when an error has occurred ranging beacons in a region. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    NSLog(@"ranging failed");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

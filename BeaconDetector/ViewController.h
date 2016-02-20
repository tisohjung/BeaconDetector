//
//  ViewController.h
//  BeaconDetector
//
//  Created by DiftCTO on 2016. 2. 20..
//  Copyright © 2016년 Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate, CBPeripheralDelegate, CBCentralManagerDelegate, CBPeripheralManagerDelegate>


@end

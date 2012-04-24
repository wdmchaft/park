//
//  ViewController.h
//  park
//
//  Created by Jon Wheatley on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CarLocation.h"



@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startingPoint;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *horizontalAccuracyLabel;
@property (strong, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *verticalAccuracyLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceTraveledLabel;

@property (strong, nonatomic) IBOutlet MKMapView *map;

@property (strong, nonatomic) IBOutlet UIImageView *compass;

@end

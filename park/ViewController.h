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
{
    NSTimer *countdownTimer;
    int timeTicketExpires;
    NSTimeInterval duration;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *carLocation;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *horizontalAccuracyLabel;
@property (strong, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *verticalAccuracyLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceTraveledLabel;

@property (strong, nonatomic) IBOutlet UILabel *minutesLeftLabel;

@property (strong, nonatomic) IBOutlet MKMapView *map;

@property (strong, nonatomic) IBOutlet UIImageView *compass;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;

- (IBAction) closedButtonPressed;
- (IBAction) parkButtonPressed;

- (IBAction) remindMeInPressed;

// i'm parked! page outlets

@property (strong, nonatomic) IBOutlet UIButton *imParkedButton;

@property (strong, nonatomic) IBOutlet UIImageView *clock;
@property (strong, nonatomic) IBOutlet UILabel *remindMeInTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *remindMeInMinutes;
@property (strong, nonatomic) IBOutlet UIButton *invisibleButton;

@property (strong, nonatomic) IBOutlet UIDatePicker *countdownPickerView;

- (IBAction) datePickerDateChanged;


@end

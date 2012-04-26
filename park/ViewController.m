//
//  ViewController.m
//  park
//
//  Created by Jon Wheatley on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize locationManager, carLocation, distanceTraveledLabel, currentLocation;
@synthesize map;
@synthesize minutesLeftLabel;
@synthesize compass;
@synthesize backgroundView;
@synthesize compassInterference;
@synthesize closeButton;
@synthesize closedButtonOverlay;

// i'm parked page outlets
@synthesize imParkedButton;
@synthesize clock;
@synthesize remindMeInTextLabel;
@synthesize remindMeInMinutes;
@synthesize invisibleButton;
@synthesize countdownPickerView;


- (void)checkStatusOnLoadAndLoadCorrectPage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *getLocationAndTimeData = [[defaults dictionaryRepresentation] objectForKey:@"locationAndTime"];
    
    // decode the shit
    NSDictionary *locationAndTime = [NSKeyedUnarchiver unarchiveObjectWithData:getLocationAndTimeData];
    
    if (locationAndTime == NULL)
    {
        NSLog(@"load up the homepage");
    }
    else 
    {
        NSLog(@"load up the map page");
        carLocation = [locationAndTime objectForKey:@"carLocation"];
        backgroundView.hidden = YES;
        imParkedButton.hidden = YES;
        clock.hidden = YES;
        remindMeInTextLabel.hidden = YES;
        remindMeInMinutes.hidden = YES;
        invisibleButton.hidden = YES;
        countdownPickerView.hidden = YES;
        closeButton.hidden = NO;
        closedButtonOverlay.hidden = NO;
        
        // add car location to map
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = carLocation.coordinate.latitude;
        coordinate.longitude = carLocation.coordinate.longitude;
        
        CarLocation *carLocationAnnotation = [[CarLocation alloc] initWithName:@"Your Car" address:@"is here" coordinate:coordinate];
        
        // display location on the map
        map.showsUserLocation = YES;
        
        [map addAnnotation:carLocationAnnotation];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    map.showsUserLocation = YES;
    
    [self checkStatusOnLoadAndLoadCorrectPage];
    
    // change font for distance 
    distanceTraveledLabel.font = [UIFont fontWithName:@"Gotham Rounded" size:20.0];
    
    // change font for time left
    minutesLeftLabel.font = [UIFont fontWithName:@"Gotham Rounded" size:20.0];
    
    // change font in initial popup
    remindMeInTextLabel.font = [UIFont fontWithName:@"Gotham Rounded" size:16.0];
    remindMeInMinutes.font = [UIFont fontWithName:@"Gotham Rounded" size:20.0];
    
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (carLocation == nil)
    {
        self.carLocation = newLocation;
    }
    
    // set map zoom and location
    CLLocationCoordinate2D coord;
    
    coord.latitude = newLocation.coordinate.latitude;
    coord.longitude = newLocation.coordinate.longitude;
    
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.001;
    span.longitudeDelta = 0.001;
    
    MKCoordinateRegion region;
    
    region.center = coord;
    region.span = span;
    
    [map setRegion:region];
    
    CLLocationDistance distance = [newLocation distanceFromLocation:carLocation];
    NSString *distanceString = [NSString stringWithFormat:@"%.02fm", distance];
    distanceTraveledLabel.text = distanceString;
    
    currentLocation = newLocation;
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{    
    
    if (newHeading.headingAccuracy > 0)
    {
        
        if (compass.hidden)
        {
            // show the compass
            [compassInterference setAlpha:0.0];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [compassInterference setAlpha:1.0];
            [UIView commitAnimations];
            compassInterference.hidden = YES;
            
            compass.hidden = NO;
            [compass setAlpha:0.0];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [compass setAlpha:1.0];
            [UIView commitAnimations];
        }
        
        // algo is based upon http://www.movable-type.co.uk/scripts/latlong.html
        
        float dlon = ((carLocation.coordinate.longitude - currentLocation.coordinate.longitude) * 0.0174532925);
        
        float y = sin(dlon) * cos(carLocation.coordinate.latitude * 0.0174532925);
        float x = cos(currentLocation.coordinate.latitude * 0.0174532925) * sin(carLocation.coordinate.latitude * 0.0174532925) - sin(currentLocation.coordinate.latitude* 0.0174532925) * cos(carLocation.coordinate.latitude* 0.0174532925) * cos(dlon);
        
        int bearing = (atan2(y, x) * 57.2957795);
        int normalizedBearing = (bearing +360) % 360;
        int normalizedBearingToRadians = normalizedBearing * 0.0174532925;
        
        NSLog(@"BARING SHOULD BE: %i", normalizedBearing);
        
        // rotate the compass image
        compass.transform = CGAffineTransformMakeRotation((0 - (newHeading.trueHeading * 0.0174532925)) + normalizedBearingToRadians);
        
        // distanceTraveledLabel.text = [[NSString alloc] initWithFormat:@"Bearing: %i", normalizedBearing];

    }
    else 
    {
        // only run this once or the animations would keep going
        if (!compass.hidden)
        {
            // hide the compass
            [compass setAlpha:1.0];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [compass setAlpha:0.0];
            [UIView commitAnimations];
            compass.hidden = YES;
            
            
            compassInterference.hidden = NO;
            [compassInterference setAlpha:0.0];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [compassInterference setAlpha:1.0];
            [UIView commitAnimations];
            
        }
    
    }
    

    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation 
{
    static NSString *identifier = @"CarLocation";   
    if ([annotation isKindOfClass:[CarLocation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [map dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image=[UIImage imageNamed:@"car.png"];
        
        return annotationView;
    }

    return nil;    
}

- (void) closedButtonPressed
{
    NSLog(@"closed");
    backgroundView.hidden = NO;
    [backgroundView setAlpha:0.0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [backgroundView setAlpha:1.0];
    [UIView commitAnimations];
    
    imParkedButton.hidden = NO;
    [imParkedButton setAlpha:0.0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [imParkedButton setAlpha:1.0];
    [UIView commitAnimations];
    
    clock.hidden = NO;
    [clock setAlpha:0.0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [clock setAlpha:1.0];
    [UIView commitAnimations];
    
    remindMeInTextLabel.hidden = NO;
    [remindMeInTextLabel setAlpha:0.0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [remindMeInTextLabel setAlpha:1.0];
    [UIView commitAnimations];
    
    remindMeInMinutes.hidden = NO;
    [remindMeInMinutes setAlpha:0.0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [remindMeInMinutes setAlpha:1.0];
    [UIView commitAnimations];
    
    invisibleButton.hidden = NO;
    invisibleButton.enabled = YES;
    
    closeButton.hidden = NO;
    closedButtonOverlay.hidden = NO;
    
    compassInterference.hidden = YES;
    
    // remove all annotations 
    
    [map removeAnnotations:map.annotations];
    
    NSLog(@"%f", duration);
    
    // reset duration
    duration = 0;
    
    NSLog(@"%f", duration);
    
    remindMeInMinutes.text = @"0 min";
    
    // reset NSUserDefaults
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"locationAndTime"];
    [defaults synchronize];
    
    // invalidate the NSTimer
    [countdownTimer invalidate];
        
}

- (void) workOutAndUpdateTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *getLocationAndTimeData = [[defaults dictionaryRepresentation] objectForKey:@"locationAndTime"];
    
    // decode the shit
    NSDictionary *locationAndTime = [NSKeyedUnarchiver unarchiveObjectWithData:getLocationAndTimeData];
    
    NSLog(@"BLAJHSGKSFDLFSDJLFKDS: %@", locationAndTime);
    
    // get current timestamp
    int currentTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if (currentTimestamp > [[locationAndTime objectForKey:@"timeWhenParkingExpires"] intValue])
    {
        minutesLeftLabel.text = @"Expired";
        [countdownTimer invalidate];
    }
    else
    {
        int secondsLeft = [[locationAndTime objectForKey:@"timeWhenParkingExpires"] intValue] - currentTimestamp;
        
        int minutesLeft = secondsLeft / 60;
        
        minutesLeftLabel.text = [[NSString alloc] initWithFormat:@"%i min left", minutesLeft];
        
    }
}

- (void) start
{

    [self workOutAndUpdateTime];
                                     
}

- (IBAction) parkButtonPressed
{
    imParkedButton.hidden = YES;
    clock.hidden = YES;
    remindMeInTextLabel.hidden = YES;
    remindMeInMinutes.hidden = YES;
    backgroundView.hidden = YES;
    countdownPickerView.hidden = YES;
    closeButton.hidden = NO;
    closedButtonOverlay.hidden = NO;
    
    invisibleButton.hidden = YES;
    invisibleButton.enabled = NO;
    compass.hidden = NO;
    [compass setAlpha:1.0];
    compassInterference.hidden = YES;
    [compassInterference setAlpha:0.0];
    
    // set car to current position and add it to NSUserDefaults
    NSLog(@"%@", self.carLocation);
    
    NSLog(@"%@", self.currentLocation);
    
    self.carLocation = self.currentLocation;
    
    // update distance label
    CLLocationDistance distance = [currentLocation distanceFromLocation:carLocation];
    NSString *distanceString = [NSString stringWithFormat:@"%.02fm", distance];
    distanceTraveledLabel.text = distanceString;
    
    
    // update location on map
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = carLocation.coordinate.latitude;
    coordinate.longitude = carLocation.coordinate.longitude;
    
    CarLocation *carLocationAnnotation = [[CarLocation alloc] initWithName:@"Your Car" address:@"is here" coordinate:coordinate];

    // display location on the map
    map.showsUserLocation = YES;
    
    [map addAnnotation:carLocationAnnotation];

    
    NSLog(@"%f", duration);
    
    
    if (duration != 0)
    {
        
        // save time parking expires and location 
        
        int timeInSeconds = duration;
        int currentTimestamp = [[NSDate date] timeIntervalSince1970];
        
        // set push notifications
        
        UIApplication *app                = [UIApplication sharedApplication];
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        // remove old push notifications first
        
        NSArray *oldNotifications = [app scheduledLocalNotifications];
        if ([oldNotifications count] > 0) {
            [app cancelAllLocalNotifications];
        }
        
        if (notification == nil)
            return;
        
        NSDate *notificationDate = [NSDate dateWithTimeIntervalSince1970:currentTimestamp + timeInSeconds];
        
        notification.fireDate  = notificationDate;
        notification.timeZone  = [NSTimeZone systemTimeZone];
        notification.alertBody = @"Your parking has expired!";
//      notification.soundName = @"countdownpush.mp3";
        
        [app scheduleLocalNotification:notification];
        
        
        NSString *timeWhenParkingExpires = [[NSString alloc] initWithFormat:@"%i",timeInSeconds + currentTimestamp];
        NSDictionary *locationAndTime = [[NSDictionary alloc] initWithObjectsAndKeys:timeWhenParkingExpires, @"timeWhenParkingExpires", carLocation, @"carLocation", nil];
        
        // encrypt the shit first
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:locationAndTime];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:@"locationAndTime"];
        [defaults synchronize];
        
        [self workOutAndUpdateTime];
        
        // start the NSTimer and start counting down
        countdownTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(start) userInfo:nil repeats:YES];
        
    }
    else
    {
        // remove the old label text
        minutesLeftLabel.text = @"";
        
        // save location to NSUSerDefaults
        NSDictionary *locationAndTime = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"timeWhenParkingExpires", carLocation, @"carLocation", nil];
        
        // encrypt the shit first
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:locationAndTime];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:@"locationAndTime"];
        [defaults synchronize];
    }
}

- (IBAction) remindMeInPressed
{
    countdownPickerView.hidden = NO;
    [countdownPickerView setAlpha:0.0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [countdownPickerView setAlpha:1.0];
    [UIView commitAnimations];
    
    invisibleButton.hidden = YES;
    invisibleButton.enabled = NO;
}

- (IBAction) datePickerDateChanged
{
    // update the duration
    duration = countdownPickerView.countDownDuration;
    
    //  update the label
    int minutes = ((int)duration)/60;
    remindMeInMinutes.text = [[NSString alloc] initWithFormat:@"%i min", minutes];
}

@end

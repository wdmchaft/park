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

@synthesize locationManager, startingPoint, latitudeLabel, longitudeLabel, horizontalAccuracyLabel, altitudeLabel, verticalAccuracyLabel, distanceTraveledLabel, currentLocation;

@synthesize map;

@synthesize compass;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    map.showsUserLocation = YES;
    
    
    // change font for distance 
    distanceTraveledLabel.font = [UIFont fontWithName:@"Gotham Rounded" size:20.0];
    
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
    
    
    self.locationManager = nil;
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
    self.horizontalAccuracyLabel = nil;
    self.altitudeLabel = nil;
    self.verticalAccuracyLabel = nil;
    self.distanceTraveledLabel = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (startingPoint == nil)
    {
        self.startingPoint = newLocation;
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
    
    
    NSString *latitudeString = [NSString stringWithFormat:@"%g\u00b0", newLocation.coordinate.latitude];
    latitudeLabel.text = latitudeString;
    
    NSString *longitudeString = [NSString stringWithFormat:@"%g\u00b0", newLocation.coordinate.longitude];
    longitudeLabel.text = longitudeString;
    
    NSString *horizontalAccuracyString = [NSString stringWithFormat:@"%gm", newLocation.horizontalAccuracy];
    horizontalAccuracyLabel.text = horizontalAccuracyString;
    
    NSString *altitudeString = [NSString stringWithFormat:@"%gm", newLocation.altitude];
    altitudeLabel.text = altitudeString;
    
    NSString *verticalAccuracyString = [NSString stringWithFormat:@"%gm", newLocation.verticalAccuracy];
    verticalAccuracyLabel.text = verticalAccuracyString;
    
    CLLocationDistance distance = [newLocation distanceFromLocation:startingPoint];
    NSString *distanceString = [NSString stringWithFormat:@"%.02fm", distance];
    distanceTraveledLabel.text = distanceString;
    
    currentLocation = newLocation;
    
    // update point on map
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = startingPoint.coordinate.latitude;
    coordinate.longitude = startingPoint.coordinate.longitude;
    
    CarLocation *carLocation = [[CarLocation alloc] initWithName:@"Your Car" address:@"is here" coordinate:coordinate];
    
    [map addAnnotation:carLocation];

    

    
    NSLog(@"now");
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
    NSLog(@"New magnetic heading: %f", newHeading.magneticHeading);
	NSLog(@"New true heading: %f", newHeading.trueHeading);
    
    NSLog(@"accuracy: %f", newHeading.headingAccuracy);
    
    
    // work out the shit i don't understand
    float dy = currentLocation.coordinate.latitude - startingPoint.coordinate.latitude;
    float dx = cosf(M_PI/180*startingPoint.coordinate.latitude)*(currentLocation.coordinate.longitude - startingPoint.coordinate.longitude);
    float angle = atan2f(dy, dx);
    
    NSLog(@"Angle: %f", angle);
    NSLog(@"Degress from north: %f", angle * 57.2957795);
    NSLog(@"Rotate to: %f",(newHeading.magneticHeading * 0.0174532925) + angle );
    
    // rotate the compass image
    compass.transform = CGAffineTransformMakeRotation((0 - (newHeading.magneticHeading * 0.0174532925)) + angle);
    
    
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
        
        annotationView.enabled = NO;
        annotationView.canShowCallout = NO;
        annotationView.image=[UIImage imageNamed:@"car.png"];
        
        
        
        return annotationView;
        
    }

    return nil;    
}

@end

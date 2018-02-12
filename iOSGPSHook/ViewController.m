//
//  ViewController.m
//  iOSGPSHook
//
//  Created by BoBo on 2018/2/12.
//  Copyright © 2018年 JR_Dun. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>

@property(nonatomic, strong) UILabel            *labelTips;
@property(nonatomic, strong) CLLocationManager  *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self initUI];
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"开始定位");
        //开始定位
        [self.locationManager startUpdatingLocation];
        NSLog(@"开始定位 2");
    }
    else
    {
        NSLog(@"没权限访问");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CLLocationManager *)locationManager
{
    if(!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
        [_locationManager requestAlwaysAuthorization];
    }
    
    return _locationManager;
}

- (void)initUI
{
    self.labelTips = [UILabel new];
    self.labelTips.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelTips];
    
    self.labelTips.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelTips attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelTips attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelTips attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //打印出精度和纬度
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    NSLog(@"精度：%f 纬度：%f",coordinate.latitude,coordinate.longitude);
    //计算两个位置的距离
//    float distance = [newLocation distanceFromLocation:oldLocation];
//    
//    NSLog(@" 距离 %f",distance);
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    CLLocationCoordinate2D coor = currentLocation.coordinate;
    
    
    NSLog(@"lat:%f  lan:%f", coor.latitude, coor.longitude);
    self.labelTips.text = [NSString stringWithFormat:@"%f,%f", coor.latitude, coor.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
        NSLog(@"%ld",(long)error.code);
    }
}



@end

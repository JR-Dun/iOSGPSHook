//
//  ViewController.m
//  iOSGPSHook
//
//  Created by BoBo on 2018/2/12.
//  Copyright © 2018年 JR_Dun. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) UILabel            *labelTips;
@property (nonatomic, strong) CLLocationManager  *locationManager;

@property (nonatomic, strong) MKMapView          *mapView;

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

- (UILabel *)labelTips {
    if(!_labelTips) {
        _labelTips = [UILabel new];
        _labelTips.textAlignment = NSTextAlignmentCenter;
        _labelTips.backgroundColor = RGB16withAlpha(0xffffff, 0.5);
        [self.view addSubview:_labelTips];
        
        self.labelTips.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelTips attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:5]];
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelTips attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.labelTips attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-5]];
    }
    
    return _labelTips;
}

- (MKMapView *)mapView {
    if(!_mapView) {
        _mapView = [MKMapView new];
        // 设置地图显示样式(必须注意,设置时 注意对应的版本)
        _mapView.mapType = MKMapTypeStandard;
        // 设置地图是否可以缩放
        _mapView.zoomEnabled = YES;
        //是否可以滚动
        _mapView.scrollEnabled = YES;
        //旋转
        _mapView.rotateEnabled = YES;
        //设置显示用户当前位置
        _mapView.showsUserLocation = YES;
        
        [self.view addSubview:_mapView];
        
        self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    }
    
    return _mapView;
}

- (void)initUI
{
    // 显示用户位置, 但是地图并不会自动放大到合适比例
    self.mapView.hidden = NO;
    self.labelTips.hidden = NO;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    [self.mapView addGestureRecognizer:tapRecognizer];
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
    self.labelTips.text = [NSString stringWithFormat:@"%f, %f", coor.latitude, coor.longitude];
    
    // 地图上显示点
    [self mapViewLatitude:coor.latitude longitude:coor.longitude];
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

- (void)mapViewLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    // 设置地图中心的经、纬度
    CLLocationCoordinate2D center = {latitude, longitude};
    // 设置地图显示的范围
    MKCoordinateSpan span;
    // 地图显示范围越小，细节越清楚
    span.latitudeDelta = 0.1;
    span.longitudeDelta = 0.1;
    // 创建MKCoordinateRegion对象，该对象代表了地图的显示中心和显示范围。
    MKCoordinateRegion region = {center, span};
    
    if(self.mapView.region.center.latitude != center.latitude || self.mapView.region.center.longitude != center.longitude) {
        // 设置当前地图的显示中心和显示范围
        [self.mapView setRegion:region animated:YES];
    }
}

- (void)tapPress:(UIGestureRecognizer *)gestureRecognizer {
    //这里touchPoint是点击的某点在地图控件中的位置
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    //这里touchMapCoordinate就是该点的经纬度了
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    self.labelTips.text = [NSString stringWithFormat:@"%f, %f", touchMapCoordinate.latitude, touchMapCoordinate.longitude];
}


@end

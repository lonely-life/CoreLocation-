//
//  ViewController.m
//  02、MKMapView添加标注视图
//
//  Created by kinglinfu on 16/9/7.
//  Copyright © 2016年 tens. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;

@property (strong, nonatomic) void(^geocodeComplatHandle)(NSString *name);

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestAction:)];
    
    [self.mapView addGestureRecognizer:longGest];
    
    self.mapView.showsUserLocation = YES;
    
    if ([CLLocationManager instanceMethodForSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [self.locationManager requestWhenInUseAuthorization];
    }
}


- (void)longGestAction:(UILongPressGestureRecognizer *)longGest {
    
    // 1、获取触摸点所在地图上的CGPoint坐标
    CGPoint point = [longGest locationInView:self.mapView];
    
    // 2、将地图所在触摸点的坐标 CGPoint 转为对应的经纬度 CLLocationCoordinate2D
    CLLocationCoordinate2D coordinate2D = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    if (longGest.state == UIGestureRecognizerStateBegan) {
        
        // 3、创建并添加一个标注视图到mapView上
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.title = @"XXXX";
        annotation.coordinate = coordinate2D;
        annotation.subtitle = [NSString stringWithFormat:@"%f, %f",annotation.coordinate.latitude, annotation.coordinate.longitude];
    
        [self setGeocodeComplatHandle:^(NSString *locationName) {
            
            annotation.title = locationName;
        }];
        
        [self geocoder:coordinate2D];
        
        //4、将标注添加到地图上
        [self.mapView addAnnotation:annotation];
        
    }
}


#pragma mark - 地理位置编码
- (void)geocoder:(CLLocationCoordinate2D)coordinate2D {
    
    if (!_geocoder) {
        
        _geocoder = [[CLGeocoder alloc] init];
    }
    
    // 创建一个经纬度位置 CLLocation
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
    
    // 1、通过经纬度获取对应的地理位置，查询位置是一个异步操作
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        CLPlacemark *placemark = [placemarks lastObject];
        
        NSLog(@"%@ %@ %@",placemark.name, placemark.thoroughfare,placemark.subThoroughfare);
        
        // 将地理位置名称显示在标注视图上
        if (self.geocodeComplatHandle) {
            
            self.geocodeComplatHandle(placemark.name);
        }
    }];
    
}


- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
    }
    
    return _locationManager;
}


#pragma mark - <MKMapViewDelegate> {

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    MKCoordinateSpan span = {0.05,0.05};
    [mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
}


// 添加标注视图时调用，这里可以自定义标注视图
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    NSLog(@"viewForAnnotation");
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        return nil;
    }
    
    
    static NSString *identifer = @"annotation";

    
    MKAnnotationView *annatationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifer];
    
    if (!annatationView) {
        
        annatationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifer];
        
        // 是否显示辅助标注视图
        annatationView.canShowCallout = YES;
        
        // 使用图片作为标注
        annatationView.image = [UIImage imageNamed:@"icon"];
        
        // 是否可以拖拽
        annatationView.draggable = YES;
        
        UIImageView *leftView = [[UIImageView  alloc] initWithImage: [UIImage imageNamed:@"头像"]];
        leftView.frame = CGRectMake(0, 0, 50, 50);
        // 设置左边的辅助视图
        annatationView.leftCalloutAccessoryView = leftView;
        
        // 设置右边的辅助视图
        annatationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        
    }
    
    return annatationView;
}


@end

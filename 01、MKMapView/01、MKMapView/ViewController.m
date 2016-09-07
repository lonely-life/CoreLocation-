//
//  ViewController.m
//  01、MKMapView
//
//  Created by kinglinfu on 16/9/7.
//  Copyright © 2016年 tens. All rights reserved.
//

#import "ViewController.h"
/**
 注意：
 当我们在手动拖入一个MapVIew时，需要手动导入包文件不然无法实用地图的框架，
 地图和定位的框架是一个专用的框架，而我们平时搭建的项目是直接基于cocotach框架上搭建的，
 所以当我们在使用MapView时需要去手动导入包文件
 **/
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ViewController ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 
     MKMapTypeStandard = 0, 平面地图
     MKMapTypeSatellite, 卫星地图
     MKMapTypeHybrid, 混合地图
     MKMapTypeSatelliteFlyover NS_ENUM_AVAILABLE(10_11, 9_0),
     MKMapTypeHybridFlyover**/
    
    // 设置地图的样式
    self.mapView.mapType = MKMapTypeStandard;
    
    // 是否显示用户位置
    self.mapView.showsUserLocation = YES;
    
    
    /* 授权定位用户的位置，需要在info.plist文件中添加(以下二选一，两个都添加默认使用NSLocationWhenInUseUsageDescription)：
    
     *NSLocationWhenInUseUsageDescription 允许在前台使用时获取GPS的描述
     *NSLocationAlwaysUsageDescription 允许永远可获取GPS的描述
     
     */
    if ([CLLocationManager instanceMethodForSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [self.locationManager requestWhenInUseAuthorization];
    }
}


- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
     
        _locationManager = [[CLLocationManager alloc] init];
        // 定位的精确度
        
        /**
            kCLLocationAccuracyBestForNavigation   // 导航定位最精准的
            kCLLocationAccuracyBest;               //静止是定位精准度最好
            kCLLocationAccuracyNearestTenMeters;   //错误偏差10米以内
            kCLLocationAccuracyHundredMeters;      //错误偏差百米以内
            kCLLocationAccuracyKilometer;          //错误偏差1公里以内
            kCLLocationAccuracyThreeKilometers;    //错误偏差3公里以内
         */
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        // 多远距离更新位置
        _locationManager.distanceFilter = 10;
    }
    
    return _locationManager;
}


#pragma mark - <MKMapViewDelegate>

// 定位用户位置完成
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    
    NSLog(@"%s %f, %f",__func__, mapView.userLocation.coordinate.longitude, mapView.userLocation.coordinate.latitude);
    
}

// 用户位置更新后调用
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    //设置中心点
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    
    // 设置跨度
    MKCoordinateSpan span = {0.01,0.01};
    
    // 设置地图显示的范围
    [self.mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
    
    NSLog(@"用户位置发生改变");
}



@end

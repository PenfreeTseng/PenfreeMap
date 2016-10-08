//
//  BaiduMapViewController.m
//  PenfreeMap
//
//  Created by ZengPengfei on 16/10/8.
//  Copyright © 2016年 Penfree.Tseng. All rights reserved.
//

#import "BaiduMapViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface BaiduMapViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate>
@property (nonatomic, weak) BMKMapView *mapView;
@property (nonatomic, strong) BMKLocationService *locService;
@end

@implementation BaiduMapViewController
- (BMKLocationService *)locService {
    if (!_locService) {
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
    }
    return _locService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"百度地图";
    
    BMKMapView *mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate = self;
    self.mapView = mapView;
    [self.view addSubview:mapView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 100, 44, 44)];
    [btn addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:btn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

- (void)action {
    [self.locService startUserLocationService];
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
}
@end

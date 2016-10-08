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

@interface PFAnnotation : NSObject <BMKAnnotation>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation PFAnnotation
@end

@interface BaiduMapViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate, BMKPoiSearchDelegate, BMKGeoCodeSearchDelegate>

/// 基础地图
@property (nonatomic, weak) BMKMapView *mapView;
/// 定位服务
@property (nonatomic, strong) BMKLocationService *locService;
/// 检索器
@property (nonatomic, strong) BMKPoiSearch *searcher;
@property (nonatomic, strong) BMKGeoCodeSearch *geoCoder;
@end

@implementation BaiduMapViewController
- (BMKMapView *)mapView {
    if (!_mapView) {
        BMKMapView *mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
        mapView.showMapScaleBar = YES;
        mapView.delegate = self;
        mapView.showsUserLocation = YES;
        mapView.userTrackingMode = BMKUserTrackingModeFollow;
        mapView.zoomLevel = 15;
        mapView.logoPosition = BMKLogoPositionLeftTop;
        _mapView = mapView;
        return mapView;
    }
    return _mapView;
}

- (BMKLocationService *)locService {
    if (!_locService) {
        _locService = [[BMKLocationService alloc] init];
        _locService.distanceFilter = 10;
        _locService.delegate = self;
    }
    return _locService;
}

- (BMKPoiSearch *)searcher {
    if (!_searcher) {
        _searcher = [[BMKPoiSearch alloc] init];
        _searcher.delegate = self;
    }
    return _searcher;
}

- (BMKGeoCodeSearch *)geoCoder {
    if (!_geoCoder) {
        _geoCoder = [[BMKGeoCodeSearch alloc] init];
        _geoCoder.delegate = self;
    }
    return _geoCoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"百度地图";
    
    [self.view addSubview:self.mapView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 100, 30, 30)];
    [btn addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"locate"] forState:UIControlStateNormal];
    [self.view addSubview:btn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
}

- (void)action {
//    [self.locService startUserLocationService];
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc] init];
    citySearchOption.pageCapacity = 10;
    citySearchOption.city= @"杭州";
    citySearchOption.keyword = @"西城时代";
    BOOL flag = [self.searcher poiSearchInCity:citySearchOption];
    if (flag) {
        NSLog(@"检索成功");
    } else {
        NSLog(@"检索失败");
    }
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    NSLog(@"一直定位");
    [self.mapView updateLocationData:userLocation];
}

- (void)didFailToLocateUserWithError:(NSError *)error {
    // 提醒用户定位失败
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorPurple;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
        
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}

- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    NSLog(@"didAddAnnotationViews");
}

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
    NSLog(@"%@", view.annotation.title);
    NSLog(@"纬度%f", view.annotation.coordinate.latitude);
    NSLog(@"经度%f", view.annotation.coordinate.longitude);
    [self reverseGeocode:view.annotation.coordinate];
    
}

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSLog(@"onClickedMapPoi-%@",mapPoi.text);
    NSString* showmeg = [NSString stringWithFormat:@"您点击了底图标注:%@,\r\n当前经度:%f,当前纬度:%f,\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d", mapPoi.text,mapPoi.pt.longitude,mapPoi.pt.latitude, (int)_mapView.zoomLevel,_mapView.rotation,_mapView.overlooking];
    NSLog(@"%@", showmeg);
//    PFAnnotation *annotation = [[PFAnnotation alloc] init];
//    annotation.title = mapPoi.text;
//    [self mapView:mapView viewForAnnotation:annotation];
    BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
    item.coordinate = mapPoi.pt;
    item.title = mapPoi.text;
    [self.mapView addAnnotation:item];
//    _mapView.centerCoordinate = mapPoi.location;
    [self reverseGeocode:mapPoi.pt];
}

#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *annotations = [NSMutableArray array];
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            
            item.coordinate = poi.pt;
            item.title = poi.name;
            [annotations addObject:item];
        }
        [_mapView addAnnotations:annotations];
        [_mapView showAnnotations:annotations animated:YES];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
}

/// 反向地理编码
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
//    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
//        [_mapView addAnnotation:item];
//        _mapView.centerCoordinate = result.location;
        NSString* titleStr;
        NSString* showmeg;
        titleStr = @"反向地理编码";
        showmeg = [NSString stringWithFormat:@"%@",item.title];
        
//        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:titleStr message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
//        [myAlertView show];
        NSLog(@"检索地址 %@", showmeg);
    }
}



- (void)reverseGeocode:(CLLocationCoordinate2D)pt;
{
//    isGeoSearch = false;
//    if (pt.latitude || pt.longitude) {
//        
//    }
//    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
//    if (_coordinateXText.text != nil && _coordinateYText.text != nil) {
//        pt = (CLLocationCoordinate2D){[_coordinateYText.text floatValue], [_coordinateXText.text floatValue]};
//    }
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.geoCoder reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}

@end

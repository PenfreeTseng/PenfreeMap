//
//  ViewController.m
//  PenfreeMap
//
//  Created by Penfree.Tseng on 16/10/5.
//  Copyright © 2016年 Penfree.Tseng. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationMgr;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *authStatusLabel;

@end

@implementation ViewController
- (CLLocationManager *)locationMgr {
    if (!_locationMgr) {
        // 创建Location Manager(*** 后文简称"LM" ***)，由于这个对象不是单例，因此需要一个strong类型全局变量。
        _locationMgr = [[CLLocationManager alloc] init];
        
        // 当LM获取到设备的位置信息后，会通知其代理。
        _locationMgr.delegate = self;
        
        // 距离过滤(每隔多远定位一次)
        // _locationMgr.distanceFilter = 1000;
        
        /** 定位精确度，经度越高，时间越长，越耗电。
         *  kCLLocationAccuracyBestForNavigation; 最适合导航
         *  kCLLocationAccuracyBest; 最好的(精确度仅次于上面)
         *  kCLLocationAccuracyNearestTenMeters; 10米
         *  kCLLocationAccuracyHundredMeters; 100米
         *  kCLLocationAccuracyKilometer; 1000米
         *  kCLLocationAccuracyThreeKilometers; 3000米
         */
        _locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
        
        /** 系统适配说明:
         *  >> iOS6.0 ~ 8.0，苹果在保护用户隐私方面做了些加强：
         *  因此在获取一些敏感信息时(例如:位置信息、通讯录、日历、相机、相册)会自动弹窗请求用户授权
         *  开发者可以在工程Info.plist文件中添加这个key "Privacy - Location Usage Description"(在iOS8.0之后不再读取此key)
         *
         *  >> iOS8.0，苹果在保护用户隐私方面做了进一步加强，参考下方演示说明
         *
         *  >> iOS9.0，参考下方演示说明
         */
        
        float sysVer = [[UIDevice currentDevice].systemVersion floatValue];
        if (sysVer >= 8.0 && sysVer < 9.0) {
            // 以下两个方法是iOS8.0之后的，因此要做适配，否则在iOS8.0之前的设备上会crash。
            
            // 请求仅仅在使用App中访问用户位置信息(默认是不允许在后台获取位置，除非在配置中勾选后台模式(Location updates)，但在后台访问位置时会在主界面出现蓝条警告)
            // 注意:要想此方法生效，必须在Info.plist文件中添加这个key:"NSLocationWhenInUseUsageDescription"。
            [_locationMgr requestWhenInUseAuthorization];
            
            // 请求在前后台都可以访问用户位置信息
            // 注意:要想此方法生效，必须在Info.plist文件中添加这个key:"NSLocationAlwaysUsageDescription"。
            [_locationMgr requestAlwaysAuthorization];
        }
        
        if (sysVer >= 9.0) {
            // 注意allowsBackgroundLocationUpdates是iOS9.0之后的，因此要做适配，否则在iOS9.0之前的设备上会crash。
            
            // 请求仅仅在使用App中访问用户位置信息
            // 注意:要想此方法生效，必须在Info.plist文件中添加这个key:"NSLocationWhenInUseUsageDescription"。
            [_locationMgr requestWhenInUseAuthorization];
            
            // 在9.0之后，若没有请求始终允许使用位置信息(注意这个必要条件)，则必须将下面属性置为YES。
            // 否则即使在配置文件中勾选了后台模式(Location updates)，也无法在后台获取位置信息。
            // 使用注意: 此属性要求必须在配置文件中勾选了后台模式(Location updates)，否则运行会crash。
            // 若已经在配置中勾选后台模式(Location updates)，但在后台访问位置时会在主界面出现蓝条，若想去掉蓝条需要请求始终允许使用位置信息(参考下方)。
            _locationMgr.allowsBackgroundLocationUpdates = YES;
            
            // 请求在前后台都可以访问用户位置信息
            // 注意:要想此方法生效，必须在Info.plist文件中添加这个key:"NSLocationAlwaysUsageDescription"。
//            [_locationMgr requestAlwaysAuthorization];
        }
        
        /** 以上通过判断版本号来判断某方法的可用性只是方便演示，
         这样做有一些弊端:代码中大量使用版本号来管理方法可用性会导致混乱(比如某方法是8.0之后，而某某方法则是7.0之后)
         因此建议更多的通过以下方式，而不用关心iOS版本。
        if ([_locationMgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationMgr requestWhenInUseAuthorization];
        }
        if ([_locationMgr respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationMgr requestAlwaysAuthorization];
        }
         */
    }
    return _locationMgr;
}

//
- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - LM 代理方法。
/// 更新到位置之后，会调用这个方法。
static NSInteger locateTimes = 1;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // 苹果官文: locations is an array of CLLocation objects in chronological order.
    // locations 是一个按时间排序的数组
    CLLocation *location = [locations lastObject];
    
    self.infoLabel.text = [NSString stringWithFormat:@"第%ld次定位\n经度:%f \n 纬度:%f", locateTimes, location.coordinate.latitude, location.coordinate.longitude];
    NSLog(@"定位%ld", locateTimes++);
    NSLog(@"%@", location);
}

/// 授权状态发生改变时调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            self.authStatusLabel.text = @"用户未决定";
            break;
        case kCLAuthorizationStatusRestricted:
            self.authStatusLabel.text = @"访问位置受限";
            break;
        case kCLAuthorizationStatusDenied: {
            if ([CLLocationManager locationServicesEnabled]) {
                self.authStatusLabel.text = @"定位服务开启，访问位置被拒";
            } else {
                self.authStatusLabel.text = @"定位服务关闭";
            }
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            self.authStatusLabel.text = @"始终允许访问位置";
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            self.authStatusLabel.text = @"使用应用期间允许访问位置";
            break;
        default:
            self.authStatusLabel.text = @"未知";
            break;
    }
}

#pragma mark - 开始定位
/// 更新位置
- (IBAction)locate:(id)sender {
    // 开始更新位置。
    [self.locationMgr startUpdatingLocation];
    
    // 开始更新位置，定位精确度从模糊到精确，注意调用此方法必须要实现代理方法locationManager:didFailWithError: 其他使用注意请参考苹果文档。
    // [self.locationMgr requestLocation];
    
    // 以上两种方法同时只可有一种存在，苹果文档中有说明。
}
@end

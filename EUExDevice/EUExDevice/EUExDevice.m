//
//  EUExDeviceInfo.m
//  testjs1
//
//  Created by AppCan on 11-8-26.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExDevice.h"
#import <AudioToolbox/AudioToolbox.h>
#import "EUtility.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "Reachability_Device.h"
#import <sys/mount.h>
#import <sys/param.h>
#import "EUExBaseDefine.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreLocation/CoreLocation.h>
//#import <CoreBluetooth/CoreBluetooth.h>
#import <CFNetwork/CFNetwork.h>
#import "Reachability_Device.h"
#import <SystemConfiguration/SystemConfiguration.h>

#include <sys/sysctl.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <AppCanKit/ACEXTScope.h>


@interface EUExDevice()

@property (nonatomic, strong) Reachability_Device * netState;

@end

@implementation EUExDevice



- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    self = [super initWithWebViewEngine:engine];
    if (self) {
        
    }
    return self;
}
- (void)clean{
    [self stopVibrate];
}

- (void)dealloc{
    [self clean];
}

#pragma mark -
#pragma mark - device info

//iPod1,1   -> iPod touch 1G
//iPod2,1   -> iPod touch 2G
//iPod2,2   -> iPod touch 2.5G
//iPod3,1   -> iPod touch 3G
//iPod4,1   -> iPod touch 4G
//iPad1,1   -> iPad 1G, WiFi
- (NSString *)getCupFrequency{
    return @"0";
}

- (NSString *)getOSVersion{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)getManuFacturer{
    return @"Apple";
}

- (NSString *)getKeyBoardType{
    return @"0";
}

- (NSString *)getBlueToothSupport{
    return @"0";
}

- (NSString *)getWifiSupport{
    return @"1";
}

- (NSString *)getCameraSupport{
    
    NSString *sysVersion = [EUtility getPlatform];
    if ([sysVersion isEqualToString:@"iPod1,1"]||[sysVersion isEqualToString:@"iPod2,1"]||[sysVersion isEqualToString:@"iPod2,2"]||[sysVersion isEqualToString:@"iPod3,1"]||[sysVersion isEqualToString:@"iPad1,1"]||[sysVersion isEqualToString:@"i386"]) {
        return @"0";
    }else {
        return @"1";
    }
}

- (NSString *)getGpsSupport{
    //07.18 update
    if ([[[UIDevice currentDevice] systemVersion]floatValue ]<4.0) {
        return @"0";
    }
    CTTelephonyNetworkInfo *ctni = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [ctni subscriberCellularProvider];
    NSString *carrierName =carrier.carrierName;
    if ([carrierName length]>0) {
        return @"1";
    }
    return @"0";
    
}

- (NSString *)getGprsSupport{
    if ([[Reachability_Device reachabilityWithHostName:@"http://www.baidu.com"] currentReachabilityStatus]==ReachableVia2G) {
        return @"1";
    }
    return @"0";
}

- (NSString *)getTouchScreenType{
    return @"1";
}

- (NSString *)getImei{
    //getImei 是私有方法
    return [EUtility deviceIdentifyNo];
}

- (NSString *)getDeviceToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *devToken = [defaults objectForKey:@"deviceToken"];
    if ([devToken isKindOfClass:[NSString class]] && devToken.length>0) {
        return devToken;
    }else{
        return @"";
    }
}

- (NSString *)getDeviceType{
    NSString *resStr = [[UIDevice currentDevice] model];
    if ([resStr isEqualToString:@"iPad"]) {
        return @"1";
    }else if ([resStr isEqualToString:@"iPod touch"]) {
        return @"2";
    }else {
        return @"0";
    }
}
typedef enum {
    NETWORK_TYPE_NONE =-1,
    NETWORK_TYPE_WIFI,
    NETWORK_TYPE_3G,
    NETWORK_TYPE_2G,
    NETWORK_TYPE_4G,
}NETWORK_TYPE;

//然后通过获取手机信号栏上面的网络类型的标志
- (NSInteger)dataNetworkTypeFromStatusBar {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    NSInteger netType = NETWORK_TYPE_NONE;
    NSNumber *num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    if (num == nil) {
        netType = NETWORK_TYPE_NONE;
    }else{
        NSInteger n = [num intValue];
        if (n == 0) {
            netType = NETWORK_TYPE_NONE;
        }else if (n == 1){
            netType = NETWORK_TYPE_2G;
        }else if (n == 2){
            netType = NETWORK_TYPE_3G;
        }else if (n == 3){
            netType = NETWORK_TYPE_WIFI;
        }else if (n == 4){
            netType = NETWORK_TYPE_4G;
        }else if (n == 5){
            netType = NETWORK_TYPE_WIFI;
        }else{
            netType = NETWORK_TYPE_NONE;
        }
    }
    return netType;
}
- (NSInteger) networkStatusForFlags: (SCNetworkReachabilityFlags) flags
{
//    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
//    {
//        return NotReachable;
//    }
//    
//    BOOL retVal = NotReachable;
//    
//    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
//    {
//        retVal = ReachableViaWiFi;
//    }
//    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
//         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
//    {
//        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
//        {
//            retVal = ReachableViaWiFi;
//        }
//    }
//    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
//            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
//            if (currentRadioAccessTechnology) {
//                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
//                    retVal =  ReachableVia4G;
//                } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
//                    retVal =  ReachableVia2G;
//                } else {
//                    retVal =  ReachableVia3G;
//                }
//            }
//        }
//        if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {
//            if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
//                retVal =  ReachableVia2G;
//            }
//            retVal =  ReachableVia3G;
//        }
//    }
//    return retVal;
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        return NotReachable;
    }
    NSInteger retVal = NotReachable;
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        retVal = ReachableViaWiFi;
    }
    if (
        ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0
        )
    {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            retVal = ReachableViaWiFi;
        }
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        retVal = ReachableVia3G;
        if((flags & kSCNetworkReachabilityFlagsReachable) == kSCNetworkReachabilityFlagsReachable)
        {
            if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection)
            {
                retVal = ReachableVia3G;
                if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired)
                {
                    retVal = ReachableVia2G;
                }
            }
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
            if (currentRadioAccessTechnology) {
                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                    retVal =  ReachableVia4G;
                }
            }}}
    return retVal;
}

- (NSString *)getConnectStatus{
    if (![EUtility isNetConnected]) {
        return @"-1";
    }
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    NSInteger status= [self networkStatusForFlags:flags];
    //int status = [[Reachability_Device reachabilityForInternetConnection] currentReachabilityStatus];
    //int status = [self dataNetworkTypeFromStatusBar];
    switch (status) {
        case NETWORK_TYPE_NONE:
            return @"-1";
            break;
        case NETWORK_TYPE_WIFI:
            return @"0";
            break;
        case NETWORK_TYPE_3G:
            return @"1";
            break;
        case NETWORK_TYPE_2G:
            return @"2";
            break;
        case NETWORK_TYPE_4G:
            return @"3";
            break;
        default:
            break;
    }
    return @"";
}

-(float)getTotalDiskSpaceInBytes {
    float totalSpace = 0.0f;
    NSError *error = nil;
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
    } else {
        PluginLog(@"Error Obtaining File System Info: Domain = %@, Code = %@", [error domain], [error code]);
    }
    return totalSpace;
}

- (long long) freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    
    if(statfs([NSHomeDirectory() UTF8String], &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
}
- (NSString *)getDiskRestSize{
    //07.18 update
    return [NSString stringWithFormat:@"%lld",[self freeDiskSpaceInBytes]];
}
- (NSString *)getCarrier{
    if ([[self getOSVersion] floatValue]<4.0) {
        return @"";
    }
    if ([[self getDeviceType] isEqualToString:@"0"]) {
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = info.subscriberCellularProvider;
        NSString * carrierName = carrier.carrierName;

        if (!carrierName || [carrierName isKindOfClass:[NSNull class]]) {
            return @"";
        }
        return carrierName;
    }else{
        return @"";
    }
}

- (NSString*)getDeviceVer{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (NSString *)getHardwareSys{
    NSString *platform = [self getDeviceVer];
    
    NSString *resourceBundlePath = [[EUtility bundleForPlugin:@"uexDevice"] resourcePath];
    //https://www.theiphonewiki.com/wiki/Models
    NSDictionary *platformInfoDictionary = [NSDictionary dictionaryWithContentsOfFile:[resourceBundlePath stringByAppendingPathComponent:@"DeviceVersion.plist"]];
    
    if([platformInfoDictionary objectForKey:platform]){
        return [platformInfoDictionary objectForKey:platform];
    }
    return platform;
}

- (NSString *)getModel{
    return [self getHardwareSys];
}

- (NSString *)getResolutionRatio{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize Size = [MainScreen bounds].size;
    CGFloat scale = [MainScreen scale];
    int screenWidth = Size.width * scale;
    int screenHeight = Size.height * scale;
    NSString *str = [NSString stringWithFormat:@"%d*%d",screenWidth,screenHeight];
    return str;
}

- (NSString *)getUUID{
    NSUUID *uuid = [NSUUID UUID];
    return uuid.UUIDString;
}

- (NSString *)getInfo:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *inID) = inArguments;
    NSInteger inInfoID = inID.integerValue;
    NSString *outStr = @"";
    NSString *outKey = nil;
    //枚举替代整数值
    //0 不支持
    //1 支持
    switch (inInfoID) {
        case F_DEVICE_INFO_ID_CPU_FREQUENCY:
        {
            outKey = UEX_JKCPU;
            outStr = [self getCupFrequency];
        }
            break;
        case F_DEVICE_INFO_ID_OS_VERSION:
        {
            outKey = UEX_JKOS;
            outStr = [self getOSVersion];
        }
            break;
        case F_DEVICE_INFO_ID_MANUFACTURER:
        {
            outKey = UEX_JKManufacturer;
            outStr = [self getManuFacturer];
        }
            break;
        case F_DEVICE_INFO_ID_KEYBOARD_S:
        {
            outKey = UEX_JKKeyboard;
            outStr = [self getKeyBoardType];
        }
            break;
        case F_DEVICE_INFO_ID_BLUETOOCH_S:
        {
            outKey = UEX_JKBlueTooth;
            outStr = [self getBlueToothSupport];
        }
            break;
        case F_DEVICE_INFO_ID_WIFI_S:
        {
            outKey = UEX_JKWIFI;
            outStr = [self getWifiSupport];
        }
            break;
        case F_DEVICE_INFO_ID_CAMERA_S:
        {
            outKey = UEX_JKCamera;
            outStr = [self getCameraSupport];
        }
            break;
        case F_DEVICE_INFO_ID_GPS_S:
        {
            outKey = UEX_JKGPS;
            outStr = [self getGpsSupport];
        }
            break;
        case F_DEVICE_INFO_ID_GPRS_S:
        {
            outKey = UEX_JKGPRS;
            outStr = [self getGprsSupport];
        }
            break;
        case F_DEVICE_INFO_ID_TOUCH:
        {
            outKey = UEX_JKTouch;
            outStr = [self getTouchScreenType];
        }
            break;
        case F_DEVICE_INFO_ID_IMEI:
        {
            outKey = UEX_JKIMEI;
            outStr = [self getImei];
        }
            break;
        case F_DEVICE_INFO_ID_DEVICETOKEN:
        {
            outKey = UEX_JKDeviceToken;
            outStr = [self getDeviceToken];
        }
            break;
        case F_DEVICE_INFO_ID_DEVICETYPE:
        {
            outKey = UEX_JKDeviceType;
            outStr = [self getDeviceType];
            break;
        }
        case F_DEVICE_INFO_ID_CONNECT_STATUS:
            outKey = UEX_JKConnectStatus;
            outStr = [self getConnectStatus];
            break;
        case F_DEVICE_INFO_ID_REST_DISK_SIZE:
            outKey = UEX_JKRestDiskSize;
            outStr = [self getDiskRestSize];
            break;
        case F_DEVICE_INFO_ID_CARRIER:
            outKey = UEX_JKCarrier;
            outStr = [self getCarrier];
            break;
        case F_DEVICE_INFO_ID_MACADDRESS:
            outKey = UEX_JKMacAddress;
            outStr = [EUtility macAddress];
            break;
        case F_DEVICE_INFO_ID_Model:
            outKey = UEX_JKModel;
            outStr = [self getModel];
            break;
        case F_DEVICE_INFO_ID_ResolutionRati:
            outKey = UEX_JKResolutionRatio;
            outStr = [self getResolutionRatio];
            break;
        case F_DEVICE_INFO_ID_SimSerialNumber:
            outKey = UEX_JKSimSerialNumber;
            outStr = @"";
            break;
        case F_DEVICE_INFO_ID_UUID:
            outKey = UEX_JKUUID;
            outStr = [self getUUID];
            break;
        default:
            break;
    }
    NSMutableDictionary *argsDict = [[NSMutableDictionary alloc] initWithCapacity:UEX_PLATFORM_CALL_ARGS];
    if (outKey && outStr) {
        [argsDict setObject:outStr forKey:outKey];
    }
    //[self jsSuccessWithName:@"uexDevice.cbGetInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[argsDict JSONFragment]];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexDevice.cbGetInfo" arguments:ACArgsPack(@0,@1,[argsDict ac_JSONFragment])];
    return outStr;
}

#pragma mark -
#pragma mark - Vibrate

static dispatch_source_t _vibrateTimer;
static NSDate *_vibrateDeadline;



- (void)stopVibrate{
    if (_vibrateTimer) {
        dispatch_source_cancel(_vibrateTimer);
        _vibrateTimer = nil;
        _vibrateDeadline = nil;
    }

}

- (void)vibrate:(NSMutableArray *)inArguments {

    ACArgsUnpack(NSNumber* durationNumber) = inArguments;
    NSTimeInterval duration = durationNumber.doubleValue / 1000;
    UEX_PARAM_GUARD(duration > 0);
    [self stopVibrate];
    _vibrateDeadline = [NSDate dateWithTimeIntervalSinceNow:duration];
    _vibrateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_vibrateTimer, DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.4, NSEC_PER_SEC * 0.1);

    dispatch_source_set_event_handler(_vibrateTimer, ^{
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        if ([[NSDate date] compare:_vibrateDeadline] != NSOrderedAscending) {
            [self stopVibrate];
        }
    });
    dispatch_resume(_vibrateTimer);

}


//取消震动
- (void)cancelVibrate:(NSMutableArray *)inArguments {
    [self stopVibrate];
}

#pragma mark -
#pragma mark - Screen Capture

- (void)screenCapture:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber* qualityNumber,ACJSFunctionRef *callback) = inArguments;
    CGFloat quality = qualityNumber.floatValue;
    if (quality > 1){
        quality = 1;
    }
    if (quality < 0) {
        quality = 0;
    }
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(screenWindow.frame.size, NO, 0.0);
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
        NSString *fileName = [NSString stringWithFormat:@"%d.jpg",arc4random_uniform(1000000)];
        NSString *widgetId = self.webViewEngine.widget.widgetId ?: @"";
        NSString *filePath = [NSString pathWithComponents:@[documentPath,@"apps",widgetId,@"uexDevice",fileName]];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filePath]) {
            [fm removeItemAtPath:filePath error:nil];
        }
        NSData *imageData = UIImageJPEGRepresentation(viewImage, quality);
        UEX_ERROR e = kUexNoError;
        if (!imageData || ![imageData writeToFile:filePath atomically:YES]) {
            e = uexErrorMake(1);
            filePath = @"";
        }
        NSDictionary *dict = @{@"savePath": filePath};
        [callback executeWithArguments:ACArgsPack(e,dict)];
        [self callbackJSONWithFunctionName:@"cbScreenCapture" object:dict];
        
    });
}


#pragma mark -
#pragma mark - Volume

- (void)setVolume:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *volume) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(volume);
    CGFloat volumeValue = volume.floatValue;
    if (volumeValue < 0 || volumeValue > 1) {
        return;
    }
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    volumeView.showsVolumeSlider = NO;
    volumeView.hidden = NO;
    [volumeViewSlider setValue:volumeValue animated:NO];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];

}
- (NSNumber *)getVolume:(NSMutableArray *)inArguments{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat volumeValue = audioSession.outputVolume;
    NSMutableDictionary *volumeVal = [NSMutableDictionary dictionary];
    [volumeVal setValue:@(volumeValue) forKey:@"volume"];
    [self callbackJSONWithFunctionName:@"cbGetVolume" object:volumeVal];
    return @(volumeValue);
}

#pragma mark -
#pragma mark - Audio Category

- (void)setAudioCategory:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSNumber *category) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(category);

    NSInteger audioType = category.integerValue;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if(audioType == 0){
        //扬声器模式
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    if(audioType == 1){
        //听筒模式
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
}

#pragma mark -
#pragma mark - set Screen Always Bright

- (void)setScreenAlwaysBright:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *alwaysBright) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(alwaysBright);
    [UIApplication sharedApplication].idleTimerDisabled = alwaysBright.boolValue;

}

#pragma mark -
#pragma mark - Screen Brightness

- (void)setScreenBrightness:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *brightness) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(brightness);
    CGFloat brightnessValue = brightness.floatValue;
    if(brightnessValue > 1 || brightnessValue < 0){
        return;
    }
    [[UIScreen mainScreen] setBrightness:brightnessValue];
}
- (NSNumber *)getScreenBrightness:(NSMutableArray *)inArguments{
    CGFloat brightness = [[UIScreen mainScreen] brightness];
    NSMutableDictionary *brightnessVal = [NSMutableDictionary dictionary];
    [brightnessVal setValue:@(brightness) forKey:@"brightness"];
    [self callbackJSONWithFunctionName:@"cbGetScreenBrightness" object:brightnessVal];
    return @(brightness);
}

#pragma mark -
#pragma mark - WIFI

- (void)openWiFiInterface:(NSMutableArray *)inArguments{
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0){
        return;
    }
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (NSString *)getIP:(NSMutableArray *)inArguments{

    struct ifaddrs *interfaces = NULL;
    if (getifaddrs(&interfaces) == 0) {
        @onExit{
            freeifaddrs(interfaces);
        };
        while (interfaces != NULL) {
            if (interfaces->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:interfaces->ifa_name] isEqualToString:@"en0"]) {
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)interfaces->ifa_addr)->sin_addr)];
                }
            }
            interfaces = interfaces->ifa_next;
        }
    }
    
    return nil;
}






#pragma mark - setting
- (void)isFunctionEnable:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *func) = inArguments;
    if(!info){
        return;
    }
    NSString *setting = stringArg(info[@"setting"]);
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setValue:setting forKey:@"setting"];
    __block NSNumber *state = @(NO);
    
    if([setting isEqualToString:@"GPS"]){
        state = @([CLLocationManager locationServicesEnabled]);
    }else if([setting isEqualToString:@"CAMERA"]){
        NSString *mediaType = AVMediaTypeVideo;
         AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        switch (authStatus) {
            case AVAuthorizationStatusNotDetermined:{
                // 许可对话没有出现，发起授权许可
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    state = @(granted);
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized:{
                // 已经开启授权，可继续
                 state = @(YES);
                break;
            }
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                // 用户明确地拒绝授权，或者相机设备无法访问
                state = @(NO);
                break;
        }
    }
    
    [result setValue:state forKey:@"isEnable"];
    [self callbackJSONWithFunctionName:@"cbIsFunctionEnable" object:result];
    [func executeWithArguments:ACArgsPack(state)];
}

- (void)openSetting:(NSMutableArray *)inArguments{
    
    __block NSMutableDictionary *result=[NSMutableDictionary dictionary];
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *setting = stringArg(info[@"setting"])?:@"";
    [result setValue:setting forKey:@"setting"];
    void (^callback)(BOOL isSuccess) = ^(BOOL isSuccess){
        NSNumber *state = isSuccess? @0 : @1;
        [result setValue:state forKey:@"errorCode"];
        [self callbackJSONWithFunctionName:@"cbOpenSetting" object:result];
    };
    
    // UIApplicationOpenSettingsURLString 只支持8.0+系统
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0){
        callback(NO);
        return;
    }
    BOOL isSuccess = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    callback(isSuccess);
}


/**
 * 开启网络状况的监听
 * onNetStatusChanged
 */

- (void)startNetStatusListener:(NSMutableArray *)inArguments {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetStatusChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    
    self.netState = [Reachability_Device reachabilityForInternetConnection];
    [self.netState startNotifier];
}

- (void)onNetStatusChanged:(NSNotification *)notification {
    
    NSString *netStatus = [self getConnectStatus];
    
    NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexDevice.onNetStatusChanged!=null){uexDevice.onNetStatusChanged(%@);}",netStatus];
    [EUtility brwView:self.meBrwView evaluateScript:jsSuccessStr];
}

- (void)stopsNetStatusListener:(NSMutableArray *)inArguments {
    
    //关闭网络状况的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
}

#pragma mark - Callback Method
static NSString *const kPluginName = @"uexDevice";
- (void)callbackJSONWithFunctionName:(NSString *)functionName object:(NSDictionary*)obj{
    NSString *jsonStr = [NSString stringWithFormat:@"%@.%@",kPluginName,functionName];
    NSArray * args = ACArgsPack(obj.ac_JSONFragment);
    [self.webViewEngine callbackWithFunctionKeyPath:jsonStr arguments:args completion:nil];
    
}


@end


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
#import <CoreBluetooth/CoreBluetooth.h>
#import <CFNetwork/CFNetwork.h>
#import "Reachability_Device.h"
#import <SystemConfiguration/SystemConfiguration.h>

#include <sys/sysctl.h>
@interface EUExDevice()<CBCentralManagerDelegate>
@property (nonatomic,strong)CBCentralManager *CBManager;
@property(nonatomic,strong)ACJSFunctionRef *funRef;
@end

@implementation EUExDevice



- (void)dealloc{

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
    
    NSDictionary *platformInfoDictionary = [NSDictionary dictionaryWithContentsOfFile:[resourceBundlePath stringByAppendingPathComponent:@"DeviceVersion.plist"]];
    
  /*
    NSDictionary * platformInfoDictionary =@{//https://www.theiphonewiki.com/wiki/Models
                                             //iPhone
                                             @"iPhone1,1":@"iPhone 1G",
                                             @"iPhone1,2":@"iPhone 3G",
                                             @"iPhone2,1":@"iPhone 3GS",
                                             @"iPhone3,1":@"iPhone 4",
                                             @"iPhone3,2":@"iPhone 4",
                                             @"iPhone3,3":@"iPhone 4",
                                             @"iPhone4,1":@"iPhone 4s",
                                             @"iPhone5,1":@"iPhone 5",
                                             @"iPhone5,2":@"iPhone 5",
                                             @"iPhone5,3":@"iPhone 5c",
                                             @"iPhone5,4":@"iPhone 5c",
                                             @"iPhone6,1":@"iPhone 5s",
                                             @"iPhone6,2":@"iPhone 5s",
                                             @"iPhone7,1":@"iPhone 6 Plus",
                                             @"iPhone7,2":@"iPhone 6",
                                             @"iPhone8,1":@"iPhone 6s",
                                             @"iPhone8,2":@"iPhone 6s Plus",
                                             //iPod Touch
                                             @"iPod1,1":@"iPod touch",
                                             @"iPod2,1":@"iPod touch 2G",
                                             @"iPod3,1":@"iPod touch 3G",
                                             @"iPod4,1":@"iPod touch 4G",
                                             @"iPod5,1":@"iPod touch 5G",
                                             @"iPod7,1":@"iPod touch 6G",
                                             //iPad
                                             @"iPad1,1":@"iPad",
                                             @"iPad2,1":@"iPad 2",
                                             @"iPad2,2":@"iPad 2",
                                             @"iPad2,3":@"iPad 2",
                                             @"iPad2,4":@"iPad 2",
                                             @"iPad2,5":@"iPad mini 1G",
                                             @"iPad2,6":@"iPad mini 1G",
                                             @"iPad2,7":@"iPad mini 1G",
                                             @"iPad3,1":@"iPad 3",
                                             @"iPad3,2":@"iPad 3",
                                             @"iPad3,3":@"iPad 3",
                                             @"iPad3,4":@"iPad 4",
                                             @"iPad3,5":@"iPad 4",
                                             @"iPad3,6":@"iPad 4",
                                             @"iPad4,1":@"iPad Air",
                                             @"iPad4,2":@"iPad Air",
                                             @"iPad4,3":@"iPad Air",
                                             @"iPad4,4":@"iPad mini 2",
                                             @"iPad4,5":@"iPad mini 2",
                                             @"iPad4,6":@"iPad mini 2",
                                             @"iPad4,7":@"iPad mini 3",
                                             @"iPad4,8":@"iPad mini 3",
                                             @"iPad4,9":@"iPad mini 3",
                                             @"iPad5,1":@"iPad mini 4",
                                             @"iPad5,2":@"iPad mini 4",
                                             @"iPad5,3":@"iPad Air 2",
                                             @"iPad5,4":@"iPad Air 2",
                                             @"iPad6,7":@"iPad Pro",
                                             @"iPad6,8":@"iPad Pro",
                                             //iPhone Simulator
                                             @"i386":@"iPhone Simulator",
                                             @"x86_64":@"iPhone Simulator",
                                             };
    */
    
    if([platformInfoDictionary objectForKey:platform]){
        return [platformInfoDictionary objectForKey:platform];
    }
    /*
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch Second Generation";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch Third Generation";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch Fourth Generation";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch Fifth Generation";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"])      return @"3rd Generation iPad";
    if ([platform isEqualToString:@"iPad3,4"])      return @"4th Generation iPad";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])         return @"iPhone Simulator";
    */
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
    PluginLog(@"[EUExDevice getInfo]");
    NSInteger inInfoID = [[inArguments objectAtIndex:0] integerValue];
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
    if (outKey) {
        if (outStr) {
            [argsDict setObject:outStr forKey:outKey];
        }
    }
    //[self jsSuccessWithName:@"uexDevice.cbGetInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[argsDict JSONFragment]];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexDevice.cbGetInfo" arguments:ACArgsPack(@0,@1,[argsDict ac_JSONFragment])];
    return outStr;
}

#pragma mark -
#pragma mark - Vibrate

- (void)stopVibrate{
    //AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    if (vibrateTimer) {
        [vibrateTimer invalidate];
        vibrateTimer = nil;
    }
    if (times) {
        [times invalidate];
        times = nil;
    }
}

- (void)playVibrate:(NSTimer *)timer{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //float vibrateTime = [(NSString *)[timer userInfo] floatValue];
}

- (void)vibrate:(NSMutableArray *)inArguments {
    PluginLog(@"[EUExDevice vibrate]");
    ACArgsUnpack(NSNumber*inMilliseconds) = inArguments;
    if (vibrateTimer) {
        return;
    }
    if (times) {
        return;
    }
    //inMilliseconds = [inMilliseconds stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playVibrate:) userInfo:inMilliseconds repeats:YES];
    float vibrateTime = [inMilliseconds floatValue]/1000.0;
    times = [NSTimer scheduledTimerWithTimeInterval:vibrateTime target:self selector:@selector(stopVibrate) userInfo:nil repeats:NO];
}

- (void)vibrateWithPattern:(NSArray*)inPattern repeat:(int)inRepeat{
    PluginLog(@"[EUExDevice vibrateWithPattern]");
}

//取消震动
- (void)cancelVibrate:(NSMutableArray *)inArguments {
    PluginLog(@"[EUExDevice cancelVibrate]");
    if (vibrateTimer) {
        [vibrateTimer invalidate];
        vibrateTimer = nil;
    }
    if (times) {
        [times invalidate];
        times = nil;
    }
}

#pragma mark -
#pragma mark - Screen Capture

- (void)screenCapture:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber*info,ACJSFunctionRef *func) = inArguments;
    if(inArguments.count < 1){
        return;
    }
    NSNumber *state = @1;
    CGFloat quality=[info floatValue];
    if(quality <=1&& quality>=0){
        UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
        UIGraphicsBeginImageContext(screenWindow.frame.size);//全屏截图，包括window
        [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSString *savePath=[self saveImage:viewImage quality:quality];
        if (savePath) {
            state = @0;
            [self cbSavePath:savePath FunctionRef:func State:state];
        }else{
            [func executeWithArguments:ACArgsPack(state,@{@"savePath":@""})];
        }
        
        //保存到系统相册
        //UIImageWriteToSavedPhotosAlbum(viewImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    else{
        [func executeWithArguments:ACArgsPack(state,@{@"savePath":@""})];
        return;
    }
}
//callback
- (void)cbSavePath:(NSString*)savePath FunctionRef:(ACJSFunctionRef*)func State:(NSNumber*)state{
    NSMutableDictionary *path=[NSMutableDictionary dictionary];
    [path setValue:savePath forKey:@"savePath"];
    [self callBackJsonWithFunction:@"cbScreenCapture" dicParameter:path];
    [func executeWithArguments:ACArgsPack(state,@{@"savePath":savePath})];
}

- (NSString *)getSaveDirPath{
    NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/apps"];
    NSString *wgtTempPath=[tempPath stringByAppendingPathComponent:[[self.webViewEngine widget] widgetId]];
    return [wgtTempPath stringByAppendingPathComponent:@"uexDevice"];
}
// save to Disk
- (NSString *)saveImage:(UIImage *)image quality:(CGFloat)quality{
    NSData *imageData=UIImageJPEGRepresentation(image, quality);
    NSString *imageSuffix= @"jpg";
    
    if(!imageData) return nil;
    
    NSFileManager *fmanager = [NSFileManager defaultManager];
    
    NSString *uexImageSaveDir=[self getSaveDirPath];
    if (![fmanager fileExistsAtPath:uexImageSaveDir]) {
        [fmanager createDirectoryAtPath:uexImageSaveDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *timeStr = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate]];
    
    NSString *imgName = [NSString stringWithFormat:@"%@.%@",[timeStr substringFromIndex:([timeStr length]-6)],imageSuffix];
    NSString *imgTmpPath = [uexImageSaveDir stringByAppendingPathComponent:imgName];
    if ([fmanager fileExistsAtPath:imgTmpPath]) {
        [fmanager removeItemAtPath:imgTmpPath error:nil];
    }
    if([imageData writeToFile:imgTmpPath atomically:YES]){
        return imgTmpPath;
    }else{
        return nil;
    }
    
}

#pragma mark -
#pragma mark - Volume

- (void)setVolume:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    CGFloat volumeValue=[inArguments[0] floatValue];
    if(volumeValue <=1&& volumeValue>=0){
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        UISlider* volumeViewSlider = nil;
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)view;
                break;
            }
        }
        //不显示滑动条和音量界面
        volumeView.showsVolumeSlider = NO;
        volumeView.hidden=NO;
        [volumeViewSlider setValue:volumeValue animated:NO];
        [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        //[[MPMusicPlayerController applicationMusicPlayer] setVolume:volumeValue];
    }
    else{
        return;
    }
}
- (NSNumber *)getVolume:(NSMutableArray *)inArguments{
    CGFloat volumeValue=[[MPMusicPlayerController applicationMusicPlayer] volume];
    NSMutableDictionary *volumeVal=[NSMutableDictionary dictionary];
    [volumeVal setValue:@(volumeValue) forKey:@"volume"];
    [self callBackJsonWithFunction:@"cbGetVolume" dicParameter:volumeVal];
    return @(volumeValue);
}

#pragma mark -
#pragma mark - Audio Category

- (void)setAudioCategory:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    int audioType=[inArguments[0] intValue];
//    UInt32 doChangeDefaultRoute = kAudioSessionOverrideAudioRoute_None;
//    AudioSessionSetProperty (
//                             kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
//                             sizeof (doChangeDefaultRoute),
//                             &doChangeDefaultRoute
//                             );
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //NSLog(@"category---->%@",[audioSession category]);
    if(audioType==0){
        //扬声器模式
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    if(audioType==1){
        //听筒模式
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
}

#pragma mark -
#pragma mark - set Screen Always Bright

- (void)setScreenAlwaysBright:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    int brightValue=[inArguments[0] intValue];
    if(brightValue==0){
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    if(brightValue==1){
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

#pragma mark -
#pragma mark - Screen Brightness

- (void)setScreenBrightness:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    CGFloat brightnessValue=[inArguments[0] floatValue];
    if(brightnessValue <=1&& brightnessValue>=0){
        [[UIScreen mainScreen]setBrightness:brightnessValue];
    }
    else{
        return;
    }
    
}
-(NSNumber *)getScreenBrightness:(NSMutableArray *)inArguments{
    CGFloat brightness=[[UIScreen mainScreen] brightness];
    NSMutableDictionary *brightnessVal=[NSMutableDictionary dictionary];
    [brightnessVal setValue:@(brightness) forKey:@"brightness"];
    [self callBackJsonWithFunction:@"cbGetScreenBrightness" dicParameter:brightnessVal];
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
#pragma mark - setting
- (void)isFunctionEnable:(NSMutableArray *)inArguments{
     ACArgsUnpack(NSDictionary*info,ACJSFunctionRef *func) = inArguments;
    if(inArguments.count<1){
        return;
    }
    NSString *setting=[info objectForKey:@"setting"];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [result setValue:setting forKey:@"setting"];
    __block NSNumber *state = @(NO);
    if([setting isEqualToString:@"GPS"]){
        if ([CLLocationManager locationServicesEnabled]){
            [result setValue:@(YES) forKey:@"isEnable"];
            state = @(YES);
        }
        else{
            [result setValue:@(NO) forKey:@"isEnable"];
            state = @(NO);
        }
    }
    else if([setting isEqualToString:@"BLUETOOTH"]){
        self.funRef = func;
        self.CBManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        return;
    }else if([setting isEqualToString:@"CAMERA"]){
        NSString *mediaType = AVMediaTypeVideo;
         AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        NSLog(@"authStatus:%ld",authStatus);
        switch (authStatus) {
            case AVAuthorizationStatusNotDetermined:{
                // 许可对话没有出现，发起授权许可
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        //第一次用户接受
                        state = @(YES);
                    }else{
                        //用户拒绝
                        state = @(NO);
                    }
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
            default:
                break;
        }
        
    }else{
        state = @(NO);
        [result setValue:@(NO) forKey:@"isEnable"];
    }
    [self callBackJsonWithFunction:@"cbIsFunctionEnable" dicParameter:result];
    [func executeWithArguments:ACArgsPack(state)];
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [result setValue:@"BLUETOOTH" forKey:@"setting"];
    NSNumber *state = @(NO);
    if(central.state==5){
        [result setValue:@(YES) forKey:@"isEnable"];
        state = @(YES);
    }
    else{
        [result setValue:@(NO) forKey:@"isEnable"];
        state = @(NO);
    }
    [self callBackJsonWithFunction:@"cbIsFunctionEnable" dicParameter:result];
    [self.funRef executeWithArguments:ACArgsPack(state)];
    self.CBManager = nil;
    self.funRef = nil;
}
- (void)openSetting:(NSMutableArray *)inArguments{
    
    __block NSMutableDictionary *result=[NSMutableDictionary dictionary];
    ACArgsUnpack(NSDictionary*info) = inArguments;
    //ACJSFunctionRef *func = JSFunctionArg(inArguments.lastObject);
    NSString *setting = stringArg(info[@"setting"])?:@"";
    [result setValue:setting forKey:@"setting"];
    void (^callback)(BOOL isSuccess) = ^(BOOL isSuccess){
        NSNumber *state = isSuccess?@0:@1;
        [result setValue:state forKey:@"errorCode"];
        [self callBackJsonWithFunction:@"cbOpenSetting" dicParameter:result];
        //[func executeWithArguments:ACArgsPack(state,@{@"setting":setting})];
    };
    
    // UIApplicationOpenSettingsURLString 只支持8.0+系统
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0){
        callback(NO);
        return;
    }
    BOOL isSuccess = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    callback(isSuccess);
}

#pragma mark - CallBack Method
const static NSString *kPluginName=@"uexDevice";
- (void)callBackJsonWithFunction:(NSString *)functionName dicParameter:(NSMutableDictionary*)obj{
    NSString *jsonStr = [NSString stringWithFormat:@"%@.%@",kPluginName,functionName];
    NSArray * args = ACArgsPack(obj.ac_JSONFragment);
    [self.webViewEngine callbackWithFunctionKeyPath:jsonStr arguments:args completion:^(JSValue * _Nonnull returnValue) {
        if (returnValue) {
            NSLog(@"回调成功!");
        }
    }];
    
}
@end


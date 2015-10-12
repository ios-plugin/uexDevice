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
#import "JSON.h"
#import "Reachability_Device.h"
#import <sys/mount.h>
#import <sys/param.h>
#import "EUExBaseDefine.h"
#include <sys/sysctl.h>

@implementation EUExDevice

-(id)initWithBrwView:(EBrowserView *) eInBrwView{
    if (self = [super initWithBrwView:eInBrwView]) {
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
}

#pragma mark -
#pragma mark - device info

//iPod1,1   -> iPod touch 1G
//iPod2,1   -> iPod touch 2G
//iPod2,2   -> iPod touch 2.5G
//iPod3,1   -> iPod touch 3G
//iPod4,1   -> iPod touch 4G
//iPad1,1   -> iPad 1G, WiFi
-(NSString *)getCupFrequency{
    return @"0";
}

-(NSString *)getOSVersion{
    return [[UIDevice currentDevice] systemVersion];
}

-(NSString *)getManuFacturer{
    return @"Apple";
}

-(NSString *)getKeyBoardType{
    return @"0";
}

-(NSString *)getBlueToothSupport{
    return @"0";
}

-(NSString *)getWifiSupport{
    return @"1";
}

-(NSString *)getCameraSupport{
    
    NSString *sysVersion = [EUtility getPlatform];
    if ([sysVersion isEqualToString:@"iPod1,1"]||[sysVersion isEqualToString:@"iPod2,1"]||[sysVersion isEqualToString:@"iPod2,2"]||[sysVersion isEqualToString:@"iPod3,1"]||[sysVersion isEqualToString:@"iPad1,1"]||[sysVersion isEqualToString:@"i386"]) {
        return @"0";
    }else {
        return @"1";
    }
}

-(NSString *)getGpsSupport{
    //07.18 update
    if ([[[UIDevice currentDevice] systemVersion]floatValue ]<4.0) {
        return @"0";
    }
    CTTelephonyNetworkInfo *ctni = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [ctni subscriberCellularProvider];
    NSString *carrierName =carrier.carrierName;
    [ctni release];
    if ([carrierName length]>0) {
        return @"1";
    }
    return @"0";
    
}

-(NSString *)getGprsSupport{
    if ([[Reachability_Device reachabilityWithHostName:@"http://www.baidu.com"] currentReachabilityStatus]==ReachableVia2G) {
        return @"1";
    }
    return @"0";
}

-(NSString *)getTouchScreenType{
    return @"1";
}

-(NSString *)getImei{
    //getImei 是私有方法
    return [EUtility deviceIdentifyNo];
}

-(NSString *)getDeviceToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *devToken = [defaults objectForKey:@"deviceToken"];
    if ([devToken isKindOfClass:[NSString class]] && devToken.length>0) {
        return devToken;
    }else{
        return @"";
    }
}

-(NSString *)getDeviceType{
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

-(NSString *)getConnectStatus{
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
-(NSString *)getDiskRestSize{
    //07.18 update
    return [NSString stringWithFormat:@"%lld",[self freeDiskSpaceInBytes]];
}
-(NSString*)getCarrier{
    if ([[self getOSVersion] floatValue]<4.0) {
        return @"";
    }
    if ([[self getDeviceType] isEqualToString:@"0"]) {
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = info.subscriberCellularProvider;
        NSString * carrierName = carrier.carrierName;
        [info release];
        
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

-(NSString*)getHardwareSys{
    NSString *platform = [self getDeviceVer];
    
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
                                             //iPhone Simulator
                                             @"i386":@"iPhone Simulator",
                                             @"x86_64":@"iPhone Simulator",
                                             };
    
    
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

-(NSString*)getModel{
    return [self getHardwareSys];
}

-(NSString*)getResolutionRatio{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize Size = [MainScreen bounds].size;
    CGFloat scale = [MainScreen scale];
    int screenWidth = Size.width * scale;
    int screenHeight = Size.height * scale;
    NSString *str = [NSString stringWithFormat:@"%d*%d",screenWidth,screenHeight];
    return str;
}

-(NSString *)getUUID{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFStringCreateCopy( NULL, uuidString);
    CFRelease(puuid);
    CFRelease(uuidString);
    return [result autorelease];
}

-(void)getInfo:(NSMutableArray *)inArguments {
    PluginLog(@"[EUExDevice getInfo]");
    NSString *inInfoID = [inArguments objectAtIndex:0];
    NSString *outStr = nil;
    NSString *outKey = nil;
    //枚举替代整数值
    //0 不支持
    //1 支持
    switch ([inInfoID intValue]) {
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
    [self jsSuccessWithName:@"uexDevice.cbGetInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[argsDict JSONFragment]];
    [argsDict release];
}

#pragma mark -
#pragma mark - Vibrate

-(void)stopVibrate{
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

-(void)playVibrate:(NSTimer *)timer{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //float vibrateTime = [(NSString *)[timer userInfo] floatValue];
}

-(void)vibrate:(NSMutableArray *)inArguments {
    PluginLog(@"[EUExDevice vibrate]");
    NSString *inMilliseconds = [inArguments objectAtIndex:0];
    if (vibrateTimer) {
        return;
    }
    if (times) {
        return;
    }
    inMilliseconds = [inMilliseconds stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playVibrate:) userInfo:inMilliseconds repeats:YES];
    float vibrateTime = [inMilliseconds floatValue]/1000.0;
    times = [NSTimer scheduledTimerWithTimeInterval:vibrateTime target:self selector:@selector(stopVibrate) userInfo:nil repeats:NO];
}

-(void)vibrateWithPattern:(NSArray*)inPattern repeat:(int)inRepeat{
    PluginLog(@"[EUExDevice vibrateWithPattern]");
}

//取消震动
-(void)cancelVibrate:(NSMutableArray *)inArguments {
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

@end


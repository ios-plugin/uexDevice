//
//  EUExDeviceInfo.h
//  testjs1
//
//  Created by AppCan on 11-8-26.
//  Copyright 2011 AppCan. All rights reserved.
//


#import <UIKit/UIKit.h>

#define UEX_JKCPU					@"cpu"
#define UEX_JKOS					@"os"
#define UEX_JKManufacturer			@"manufacturer"
#define UEX_JKKeyboard				@"keyboard"
#define UEX_JKBlueTooth				@"blueTooth"
#define UEX_JKWIFI					@"wifi"
#define UEX_JKCamera				@"camera"
#define UEX_JKGPS					@"gps"
#define UEX_JKGPRS					@"gprs"
#define UEX_JKTouch					@"touch"
#define UEX_JKIMEI					@"imei"
#define UEX_JKDeviceToken			@"deviceToken"
#define UEX_JKDeviceType			@"deviceType"
#define UEX_JKConnectStatus			@"connectStatus"
#define UEX_JKRestDiskSize			@"restDiskSize"
#define UEX_JKCarrier               @"mobileOperatorName"
#define UEX_JKMacAddress			@"macAddress"
#define UEX_JKModel                 @"model"
#define UEX_JKResolutionRatio       @"resolutionRatio"
#define UEX_JKSimSerialNumber       @"simSerialNumber"
#define UEX_JKUUID                  @"uuid"


#define F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT				1
#define F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT			2
#define F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN	4
#define F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT		8

enum DeviceInfo {
	F_DEVICE_INFO_ID_CPU_FREQUENCY = 0,
	F_DEVICE_INFO_ID_OS_VERSION,   
	F_DEVICE_INFO_ID_MANUFACTURER, 
	F_DEVICE_INFO_ID_KEYBOARD_S,
	F_DEVICE_INFO_ID_BLUETOOCH_S, 
	F_DEVICE_INFO_ID_WIFI_S,
	F_DEVICE_INFO_ID_CAMERA_S,
	F_DEVICE_INFO_ID_GPS_S,
	F_DEVICE_INFO_ID_GPRS_S,
	F_DEVICE_INFO_ID_TOUCH,
	F_DEVICE_INFO_ID_IMEI,
	F_DEVICE_INFO_ID_DEVICETOKEN,
	F_DEVICE_INFO_ID_DEVICETYPE,
	F_DEVICE_INFO_ID_CONNECT_STATUS,
	F_DEVICE_INFO_ID_REST_DISK_SIZE,
    F_DEVICE_INFO_ID_CARRIER,
    F_DEVICE_INFO_ID_MACADDRESS,  //16
    F_DEVICE_INFO_ID_Model,
    F_DEVICE_INFO_ID_ResolutionRati,
    F_DEVICE_INFO_ID_SimSerialNumber,
    F_DEVICE_INFO_ID_UUID
};

@interface EUExDevice : EUExBase 
@end

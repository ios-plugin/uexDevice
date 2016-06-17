//
//  AppCanAnalysis.h
//  AppCanAnalysis
//
//  Created by leilei.xu on 11-5-7.
//  Copyright 2011 zywx. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppCanDataAnalysisDelegate <NSObject>
/*
 *数据统计成功回调的代理方法
 */
-(void)dataAnalysisResult:(NSDictionary*)inDict;
/*
 *数据统计失败回调的方法
 */
-(void)dataFaildAnalysisResult:(int)failStatus;
@end

typedef enum{
	EVERYSTART = 0, //启动上报
	REALTIME,  //实时上报
	EVERYDAY,  //每天上报
	ONLYWIFI   //仅在wifi上报
}ReportStrategy;

@interface AppCanAnalysis : NSObject {
    id<AppCanDataAnalysisDelegate> _delegate;
}
@property(nonatomic,assign)id<AppCanDataAnalysisDelegate> _delegate;
/*
 *获取单例对象
 */
+(AppCanAnalysis*)ACInstance;

/*
 *启动上报
 *设置appid，如果为空，不予上报
 *启动上报，每次启动必须上报，
 *上报信息包括，基本信息，应用在线时长，启动时间等等
 *从服务器获取信息为应用更新url,跳转到更新网址;
 *应用ID非法，则强制退出;
 */
-(void)setAppId:(NSString*)inAppId;
/*
 设置AppKey
 */
-(void)startWithAppKey:(NSString*)inAppkey;

/*
 *设置渠道信息,默认AppCan，
 */
-(void)setAppChannel:(NSString*)inChannel;


//配合background统计应用前台时间
-(void)setAppBecomeActive;
-(void)setAppBecomeBackground;
    
/*页面跳转统计
 *show controller's view  
 * inView    view 定义的名称
 *  建议写在controller 的viewWillAppear方法中
 */
-(void)setViewBecomeActive:(NSString*)inView;

    /* hide controller's view  
     * inView      view 定义的名称
     * 建议写在controller 的viewWillDisappear方法中
     */
-(void)setViewBecomeBackground:(NSString*)inView;

/* 自定义事件 
     click event  
     * inView     从appcan平台注册
     * inAttriDict   可以为空，但是建议填写，上传到appcan统计平台来区分用户的一些操作描述
     */
-(void)setEvent:(NSString*)inEventID attri:(NSDictionary*)inAttriDict;

    /* 事件时长统计
     user begin event duration time 
     * inEventID     从appcan平台注册
     * inKey         可以为空，但是建议填写，以区别统一EventId 在客户端的统计存储功能；
     * inAttriDict   可以为空，但是建议填写，上传到appcan统计平台来区分用户的一些操作描述
     */
-(void)beginEvent:(NSString*)inEventID keyWord:(NSString*)inKey attri:(NSDictionary*)inAttriDict;

    /* user end event duration time 
     * inEventID     从appcan平台注册
     * inKey         可以为空，但是建议填写，以区别统一EventId 在客户端的统计存储功能；
     */
-(void)endEvent:(NSString*)inEventID keyWord:(NSString*)inKey;

    /* analysis the exception 
     * inTrue  设置true，则会如果程序有能捕捉到的异常，则会在下次应用启动发送到数据统计平台，供开发者查询
     */
-(void)setErrorReport:(BOOL)inTrue;

/*
 *获取服务器配置策略
 */
-(NSDictionary*)updateParam;

/*
 *服务器配置绑定接收推送用户信息
 */
-(void)bindUserWithId:(NSString*)inUId userName:(NSString*)inUserName deviceToken:(NSString*)inDeviceToken;
/*
 *服务器返回
 */
-(BOOL)isPushToUsers;

+(NSString*)md5SoftToken;
-(NSString *)initBaseData;
//MAM
//设置审核ID，获取审核id,移除审核id
+(void)setAuditSid:(NSString*)inID;
+(NSString*)getAuditSid;
+(void)removeAuditSid;

//设置AT，获取AT,移除AT
+(void)setAuthorAT:(NSString*)inAccessToken;
+(NSString*)getAuthorAT;
+(void)removeAuthorAT;

//设置AuthId，获取AuthId,移除AuthId
+(void)setAuthSId:(NSString*)inAuthSid;
+(NSString*)getAuthSId;
+(void)removeAuthSId;

@end

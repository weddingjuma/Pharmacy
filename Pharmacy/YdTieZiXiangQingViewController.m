//
//  YdTieZiXiangQingViewController.m
//  Pharmacy
//
//  Created by suokun on 16/5/12.
//  Copyright © 2016年 sk. All rights reserved.
//

#import "YdTieZiXiangQingViewController.h"
#import "Color+Hex.h"
#import "WarningBox.h"
#import "AFNetworking 3.0.4/AFHTTPSessionManager.h"
#import "SBJson.h"
#import "hongdingyi.h"
#import "lianjie.h"
#import "UIImageView+WebCache.h"
#import "YdfabiaopinglunViewController.h"
#import "YdpinglunliebiaoViewController.h"

@interface YdTieZiXiangQingViewController ()
{
    CGFloat width;
    CGFloat height;
    
    NSDictionary *arr;
    NSArray *imagearray;
    
    int zhi;
    NSString *dian;
}
@end

@implementation YdTieZiXiangQingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _touxiang.hidden=YES;
    _biaoqian.hidden=YES;
    _image1.hidden = YES;
    _image2.hidden = YES;
    _image3.hidden = YES;
    _dianzan.hidden= YES;
    //解决tableview多出的白条
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    width = [UIScreen mainScreen].bounds.size.width;
    height = [UIScreen mainScreen].bounds.size.height;
    
    //状态栏名称
    self.navigationItem.title = @"病友交流";
    //设置self.view背景颜色
    self.view.backgroundColor = [UIColor colorWithHexString:@"f4f4f4" alpha:1];
    //设置导航栏左按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"@3x_xx_06.png"] style:UIBarButtonItemStyleDone target:self action:@selector(fanhui)];
    //设置导航栏左按钮
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:@"评论" style:UIBarButtonItemStyleDone target:self action:@selector(pinglun)];
    
    [self jiekou];
    
}
//界面控件设置
-(void)jiemian
{
    NSLog(@"%lu",(unsigned long)imagearray.count);
    //头像
    _touxiang.layer.cornerRadius = 40;
    _touxiang.layer.masksToBounds = YES;
    NSString*path=[NSString stringWithFormat:@"%@%@",service_host,_touxiang1];
    [_touxiang sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"IMG_0800.jpg" ]];
    //昵称
    self.name.text = [NSString stringWithFormat:@"%@",[[arr objectForKey:@"vipinfo"] objectForKey:@"name"]];
    self.name.font = [UIFont systemFontOfSize:15];
    //时间
    self.time.font = [UIFont systemFontOfSize:13];
    self.time.text = [NSString stringWithFormat:@"%@",[arr objectForKey:@"createTime"]];
    //标签
    self.biaoqian.font = [UIFont systemFontOfSize:13];
    self.biaoqian.text = _bingzheng;
    //标题
    self.biaoti.font = [UIFont systemFontOfSize:15];
    self.biaoti.text = [NSString stringWithFormat:@"%@",[arr objectForKey:@"title"]];
    //内容
    self.neirong.font = [UIFont systemFontOfSize:13];
    self.neirong.text = [NSString stringWithFormat:@"%@",[arr objectForKey:@"context"]];
    self.neirong.delegate = self;
    //图片1
    _image1.layer.cornerRadius = 8;
    _image1.layer.masksToBounds = YES;
    //_image1.hidden = YES;
    //图片2
    _image2.layer.cornerRadius = 8;
    _image2.layer.masksToBounds = YES;
    //_image2.hidden = YES;
    //图片3
    _image3.layer.cornerRadius = 8;
    _image3.layer.masksToBounds = YES;
    //_image3.hidden = YES;
    
    //按钮
    _pinglunButton.layer.cornerRadius = 5;
    _pinglunButton.layer.masksToBounds = YES;
    
    if ([dian isEqualToString:@"0"])
    {
        zhi = 2;
        [self.dianzan setBackgroundImage:[UIImage imageNamed:@"clicklike_light.png"] forState:UIControlStateNormal];
    }
    else if([dian isEqualToString:@"1"])
    {
        zhi = 1;
        [self.dianzan setBackgroundImage:[UIImage imageNamed:@"iconfont-zanzan@3x.png"] forState:UIControlStateNormal];
    }

    
}
//textview禁止编辑
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}
-(void)jiekou
{
    arr = [[NSDictionary alloc]init];
    [WarningBox warningBoxModeIndeterminate:@"帖子加载中..." andView:self.view];
    //userID    暂时不用改
    NSString * userID=@"0";
    
    //请求地址   地址不同 必须要改
    NSString * url =@"/share/vipTopicDetail";
    
    //时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f",a];
    
    
    //将上传对象转换为json格式字符串
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/plain",@"text/html", nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc]init];
    //出入参数：
    NSString*vip;
    NSString *path6 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/GRxinxi.plist"];
    NSDictionary*pp=[NSDictionary dictionaryWithContentsOfFile:path6];
    vip=[NSString stringWithFormat:@"%@",[pp objectForKey:@"id"]];
    NSDictionary*datadic=[NSDictionary dictionaryWithObjectsAndKeys:_tieziId,@"id",vip,@"vipId", nil];
    
    NSString*jsonstring=[writer stringWithObject:datadic];
    
    //获取签名
    NSString*sign= [lianjie getSign:url :userID :jsonstring :timeSp ];
    
    NSString *url1=[NSString stringWithFormat:@"%@%@%@%@",service_host,app_name,api_url,url];
    
    //电泳借口需要上传的数据
    NSDictionary*dic=[NSDictionary dictionaryWithObjectsAndKeys:jsonstring,@"params",appkey, @"appkey",userID,@"userid",sign,@"sign",timeSp,@"timestamp", nil];
    
    [manager GET:url1 parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [WarningBox warningBoxHide:YES andView:self.view];
        @try
        {
            NSLog(@"=============arr===================%@",responseObject);
            if ([[responseObject objectForKey:@"code"] intValue]==0000) {
                
                NSDictionary*datadic=[responseObject valueForKey:@"data"];
                
                arr = [datadic objectForKey:@"vipTopicDetail"];
                dian = [datadic objectForKey:@"clickMark"];
                NSLog(@"=============arr===================%@",dian);
                imagearray = [arr objectForKey:@"urls"];
                
                //设置图片显示
                //                if (imagearray.count == 0) {
                //                    _image1.hidden = YES;
                //                    _image2.hidden = YES;
                //                    _image3.hidden = YES;
                //                }
                //                else if (imagearray.count == 1) {
                //
                //                    NSString*path=[NSString stringWithFormat:@"%@%@",service_host,[arr objectForKey:@"url1"]];
                //                    [_image1 sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"IMG_0800.jpg" ]];
                //                    _image1.hidden = NO;
                //                    _image2.hidden = YES;
                //                    _image3.hidden = YES;
                //                }
                //                else if (imagearray.count == 2) {
                //                    NSString*path=[NSString stringWithFormat:@"%@%@",service_host,[arr objectForKey:@"url1"]];
                //                    [_image1 sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"IMG_0800.jpg" ]];
                //                    NSString*path1=[NSString stringWithFormat:@"%@%@",service_host,[arr objectForKey:@"url2"]];
                //                    [_image2 sd_setImageWithURL:[NSURL URLWithString:path1] placeholderImage:[UIImage imageNamed:@"IMG_0800.jpg" ]];
                //                    _image1.hidden = NO;
                //                    _image2.hidden = NO;
                //                    _image3.hidden = YES;
                //                }
                //                else if (imagearray.count == 2) {
                NSString*path=[NSString stringWithFormat:@"%@%@",service_host,[arr objectForKey:@"url1"]];
                [_image1 sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"" ]];
                NSString*path1=[NSString stringWithFormat:@"%@%@",service_host,[arr objectForKey:@"url2"]];
                [_image2 sd_setImageWithURL:[NSURL URLWithString:path1] placeholderImage:[UIImage imageNamed:@"" ]];
                NSString*path2=[NSString stringWithFormat:@"%@%@",service_host,[arr objectForKey:@"url3"]];
                [_image3 sd_setImageWithURL:[NSURL URLWithString:path2] placeholderImage:[UIImage imageNamed:@"" ]];
                _image1.hidden = NO;
                _image2.hidden = NO;
                _image3.hidden = NO;
                _biaoqian.hidden=NO;
                _touxiang.hidden=NO;
                _dianzan.hidden=NO;
                //                }
                
                [self jiemian];
                
            }
        }
        @catch (NSException * e) {
            
            [WarningBox warningBoxModeText:@"请检查你的网络连接!" andView:self.view];
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WarningBox warningBoxHide:YES andView:self.view];
        [WarningBox warningBoxModeText:@"网络连接失败！" andView:self.view];
        NSLog(@"错误：%@",error);
    }];
    
}
-(void)fanhui
{
    //返回上一页
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)pinglun
{
    
    YdpinglunliebiaoViewController *pinglunliebiao = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinglunliebiao"];
    pinglunliebiao.tieziID = _tieziId;
    [self.navigationController pushViewController:pinglunliebiao animated:YES];
    
}
- (IBAction)dianzan:(id)sender {
    
    if (zhi == 1) {
        
        [self.dianzan setBackgroundImage:[UIImage imageNamed:@"clicklike_light.png"] forState:UIControlStateNormal];
        
        zhi = 2;
        //userID    暂时不用改
        NSString * userID=@"0";
        
        //请求地址   地址不同 必须要改
        NSString * url =@"/share/clickLike";
        
        //时间戳
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970];
        NSString *timeSp = [NSString stringWithFormat:@"%.0f",a];
        
        
        //将上传对象转换为json格式字符串
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/plain",@"text/html", nil];
        SBJsonWriter *writer = [[SBJsonWriter alloc]init];
        //出入参数：
        NSString*vip;
        NSString *path6 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/GRxinxi.plist"];
        NSDictionary*pp=[NSDictionary dictionaryWithContentsOfFile:path6];
        vip=[NSString stringWithFormat:@"%@",[pp objectForKey:@"id"]];
        NSDictionary*datadic=[NSDictionary dictionaryWithObjectsAndKeys:_tieziId,@"id",@"2",@"flag",vip,@"vipId",@"0",@"clickMark", nil];
        
        NSString*jsonstring=[writer stringWithObject:datadic];
        
        //获取签名
        NSString*sign= [lianjie getSign:url :userID :jsonstring :timeSp ];
        
        NSString *url1=[NSString stringWithFormat:@"%@%@%@%@",service_host,app_name,api_url,url];
        
        //电泳借口需要上传的数据
        NSDictionary*dic=[NSDictionary dictionaryWithObjectsAndKeys:jsonstring,@"params",appkey, @"appkey",userID,@"userid",sign,@"sign",timeSp,@"timestamp", nil];
        
        [manager GET:url1 parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [WarningBox warningBoxHide:YES andView:self.view];
            @try
            {
               // [WarningBox warningBoxModeText:[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"msg"]] andView:self.view];
                
                if ([[responseObject objectForKey:@"code"] intValue]==0000) {
                    
                    [WarningBox warningBoxModeText:@"点赞成功" andView:self.view];
                    
                }
            }
            @catch (NSException * e) {
                
                [WarningBox warningBoxModeText:@"请检查你的网络连接!" andView:self.view];
                
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [WarningBox warningBoxHide:YES andView:self.view];
            [WarningBox warningBoxModeText:@"网络连接失败！" andView:self.view];
            NSLog(@"错误：%@",error);
        }];
        
        
    }
    else if (zhi == 2) {
        
        [self.dianzan setBackgroundImage:[UIImage imageNamed:@"iconfont-zanzan@3x.png"] forState:UIControlStateNormal];
        
        zhi = 1;
        
        //userID    暂时不用改
        NSString * userID=@"0";
        
        //请求地址   地址不同 必须要改
        NSString * url =@"/share/clickLike";
        
        //时间戳
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970];
        NSString *timeSp = [NSString stringWithFormat:@"%.0f",a];
        
        
        //将上传对象转换为json格式字符串
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/plain",@"text/html", nil];
        SBJsonWriter *writer = [[SBJsonWriter alloc]init];
        //出入参数：
        NSString*vip;
        NSString *path6 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/GRxinxi.plist"];
        NSDictionary*pp=[NSDictionary dictionaryWithContentsOfFile:path6];
        vip=[NSString stringWithFormat:@"%@",[pp objectForKey:@"id"]];
        NSDictionary*datadic=[NSDictionary dictionaryWithObjectsAndKeys:_tieziId,@"id",@"2",@"flag",vip,@"vipId",@"1",@"clickMark", nil];
        
        NSString*jsonstring=[writer stringWithObject:datadic];
        
        //获取签名
        NSString*sign= [lianjie getSign:url :userID :jsonstring :timeSp ];
        
        NSString *url1=[NSString stringWithFormat:@"%@%@%@%@",service_host,app_name,api_url,url];
        
        //电泳借口需要上传的数据
        NSDictionary*dic=[NSDictionary dictionaryWithObjectsAndKeys:jsonstring,@"params",appkey, @"appkey",userID,@"userid",sign,@"sign",timeSp,@"timestamp", nil];
        
        [manager GET:url1 parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [WarningBox warningBoxHide:YES andView:self.view];
            @try
            {
               // [WarningBox warningBoxModeText:[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"msg"]] andView:self.view];
                
                if ([[responseObject objectForKey:@"code"] intValue]==0000) {
                    
                    [WarningBox warningBoxModeText:@"点赞取消" andView:self.view];
                    
                }
            }
            @catch (NSException * e) {
                
                [WarningBox warningBoxModeText:@"请检查你的网络连接!" andView:self.view];
                
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [WarningBox warningBoxHide:YES andView:self.view];
            [WarningBox warningBoxModeText:@"网络连接失败！" andView:self.view];
            NSLog(@"错误：%@",error);
        }];
        

    }
    
    
}

- (IBAction)pinglunButton:(id)sender {
    
    YdfabiaopinglunViewController *fabiaopinglun = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"fabiaopinglun"];
    fabiaopinglun.tieziID = _tieziId;
    [self.navigationController pushViewController:fabiaopinglun animated:YES];
    
}
@end

//
//  YDJifenViewController.m
//  Pharmacy
//
//  Created by 小狼 on 16/5/27.
//  Copyright © 2016年 sk. All rights reserved.
//

#import "YDJifenViewController.h"
#import "hongdingyi.h"
#import "lianjie.h"
#import "AFHTTPSessionManager.h"
#import "SBJsonWriter.h"
#import "MJRefresh.h"
#import "YDJifenxiangViewController.h"
#import "WarningBox.h"
#import "Color+Hex.h"
#import "UIImageView+WebCache.h"
#import "YDJifenxiangViewController.h"
@interface YDJifenViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray*presentarray;
    float width;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation YDJifenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarController.tabBar.tintColor = [UIColor colorWithHexString:@"32BE60" alpha:1];
    //状态栏名称
    self.navigationItem.title = @"积分礼品";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"@3x_xx_06.png"] style:UIBarButtonItemStyleDone target:self action:@selector(fanhui)];
    //设置self.view背景颜色
    self.view.backgroundColor = [UIColor colorWithHexString:@"f4f4f4" alpha:1];
    
    _tableview.delegate=self;
    _tableview.dataSource=self;
    //解决tableview多出的白条
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    width = [UIScreen mainScreen].bounds.size.width;
    [self jiekou];
    

}
-(void)jiekou{
    //userID    暂时不用改
    NSString * userID=@"0";
    
    //请求地址   地址不同 必须要改
    NSString * url =@"/integralGift/integralGiftList";
    
    //时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f",a];
    
    
    //将上传对象转换为json格式字符串
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/plain",@"text/html", nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc]init];
    //出入参数：
    NSString*zhid;
    NSUserDefaults*uiwe=  [NSUserDefaults standardUserDefaults];
    zhid=[NSString stringWithFormat:@"%@",[uiwe objectForKey:@"officeid"]];
    NSDictionary*datadic=[NSDictionary dictionaryWithObjectsAndKeys:zhid,@"officeId",@"1",@"pageNo",@"6",@"pageSize", nil];
    
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
            NSLog(@"－＊－＊－＊－＊－＊－＊积分礼品列表＊－＊－＊－＊－\n\n\n%@",responseObject);
            [WarningBox warningBoxModeText:[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"msg"]] andView:self.view];
            
            if ([[responseObject objectForKey:@"code"] intValue]==0000) {
                
                NSDictionary*datadic=[responseObject valueForKey:@"data"];
                
                presentarray = [NSMutableArray arrayWithArray:[datadic objectForKey:@"integralGiftList"] ];
                
                
                
                [self.tableview reloadData];
                
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return presentarray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *id1 =@"cell1";
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id1];
    }
    
    UIImageView *image = [[UIImageView alloc]init];
    image.frame = CGRectMake(5, 5, 80, 80);
    //image.image = [UIImage imageNamed:@"IMG_0801.jpg"];
    NSString*path=[NSString stringWithFormat:@"%@%@",service_host,[presentarray[indexPath.row] objectForKey:@"url"]] ;
    [image sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"IMG_0800.jpg" ]];
    
    UILabel *name = [[UILabel alloc]init];
    name.frame = CGRectMake(90, 5, width - 95, 20);
    name.font = [UIFont systemFontOfSize:15];
    name.textColor = [UIColor colorWithHexString:@"323232" alpha:1];
    name.text = [NSString stringWithFormat:@"%@",[presentarray[indexPath.row] objectForKey:@"name"]];
    
    UILabel *chufang = [[UILabel alloc]init];
    chufang.frame = CGRectMake(90, 25, width - 95 , 20);
    chufang.font = [UIFont systemFontOfSize:13];
//    chufang.textColor = [UIColor colorWithHexString:@"32be60" alpha:1];
        chufang.text = [NSString stringWithFormat:@"%@",[presentarray[indexPath.row] objectForKey:@"manufacturer"]];
    
    UILabel *guige = [[UILabel alloc]init];
    guige.frame = CGRectMake(90, 45, width - 95, 20);
    guige.font = [UIFont systemFontOfSize:11];
    guige.textColor = [UIColor colorWithHexString:@"646464" alpha:1];
    guige.text = [NSString stringWithFormat:@"%@",[presentarray[indexPath.row] objectForKey:@"specification"]];
    
    UILabel *changjia = [[UILabel alloc]init];
    changjia.frame = CGRectMake(90, 64, width - 95, 20);
    changjia.font = [UIFont systemFontOfSize:11];
    changjia.textColor = [UIColor colorWithHexString:@"646464" alpha:1];
    changjia.text = [NSString stringWithFormat:@"%@",[presentarray[indexPath.row] objectForKey:@"manufacturer"]];
    
    UILabel *jianjie = [[UILabel alloc]init];
    jianjie.frame = CGRectMake(5, 85, width - 10, 30);
    jianjie.font = [UIFont systemFontOfSize:11];
    jianjie.textColor = [UIColor colorWithHexString:@"646464" alpha:1];
    jianjie.numberOfLines = 2;
    jianjie.text = [NSString stringWithFormat:@"%@",[presentarray[indexPath.row] objectForKey:@"remark"]];
    
    
    UIView *xian = [[UIView alloc]init];
    xian.frame = CGRectMake(0, 115, width, 1);
    xian.backgroundColor = [UIColor colorWithHexString:@"e2e2e2" alpha:1];
    
    [cell.contentView addSubview:image];
    [cell.contentView addSubview:name];
    [cell.contentView addSubview:chufang];
    [cell.contentView addSubview:guige];
    [cell.contentView addSubview:changjia];
    [cell.contentView addSubview:jianjie];
    [cell.contentView addSubview:xian];
    
    //cell点击不变色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YDJifenxiangViewController *xiang=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"jifenxiang"];
    xiang.haha=[NSString stringWithFormat:@"%@",[presentarray[indexPath.row] objectForKey:@"id"]];
    [self.navigationController pushViewController:xiang animated:YES];
}
-(void)fanhui{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
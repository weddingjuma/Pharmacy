//
//  YdmingchengViewController.m
//  Pharmacy
//
//  Created by suokun on 16/8/1.
//  Copyright © 2016年 sk. All rights reserved.
//

#import "YdmingchengViewController.h"
#import "Color+Hex.h"
#import "YdBZxiangqingViewController.h"
#import "YdmingchengsearchViewController.h"
#define FORCE_RECOPY_DB NO
@interface YdmingchengViewController ()
{
    CGFloat width;
    CGFloat height;
    NSMutableArray *arr;
}
@property (strong,nonatomic)UITableView *tableview;
@end

@implementation YdmingchengViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取屏幕高度
    width = [UIScreen mainScreen].bounds.size.width;
    height = [UIScreen mainScreen].bounds.size.height;
    //设置导航栏左按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"@3x_xx_06.png"] style:UIBarButtonItemStyleDone target:self action:@selector(fanhui)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"iconfont-search@2x.png"] style:UIBarButtonItemStyleDone target:self action:@selector(search)];
    //解决tableview多出的白条
    self.automaticallyAdjustsScrollViewInsets = NO;
    //状态栏名称
    self.navigationItem.title = @"病症名称";
    
    [self copyDatabaseIfNeeded];
    
}

- (void)copyDatabaseIfNeeded {
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *destinationPath = [documentsPath stringByAppendingPathComponent:@"bodydatabase.db"];
    
    void (^copyDb)(void) = ^(void){
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"bodydatabase" ofType:@"db"];
        NSAssert1(sourcePath, @"source db does not exist at path %@",sourcePath);
        
        NSError *copyError = nil;
        if( ![fm copyItemAtPath:sourcePath toPath:destinationPath error:&copyError] ) {
            NSLog(@"ERROR | db could not be copied: %@", copyError);
        }
    };
    if( FORCE_RECOPY_DB && [fm fileExistsAtPath:destinationPath] ) {
        [fm removeItemAtPath:destinationPath error:NULL];
        copyDb();
    }
    else if( ![fm fileExistsAtPath:destinationPath] ) {
        NSLog(@"INFO | db file needs copying");
        copyDb();
    }
    
    
    const char *dbpath = [destinationPath UTF8String];
    
    sqlite3_stmt *statement;
    
    arr = [[NSMutableArray alloc]init];
    
    if (sqlite3_open(dbpath, &dataBase)==SQLITE_OK) {
        
        NSString *sqlQuery = [[NSString alloc]initWithFormat:@"SELECT * FROM bodysick where place LIKE '%%%@%%'",self.sanji];
        //NSString *sqlQuery = @"SELECT * FROM bodysick where place LIKE '%肝%'";
        if (sqlite3_prepare_v2(dataBase, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                char *name = (char*)sqlite3_column_text(statement, 1);
                NSString *nsNameStr = [[NSString alloc]initWithUTF8String:name];
                
//                int _id = sqlite3_column_int(statement, 0);
//                
//                char *Place = (char*)sqlite3_column_text(statement, 5);
//                NSString *nsPlaceStr = [[NSString alloc]initWithUTF8String:Place];
                [arr addObject:nsNameStr];
                
            }
        }
        
        sqlite3_close(dataBase);
        
        self.tableview = [[UITableView alloc]init];
        self.tableview.frame = CGRectMake(0, 64, width, height - 64);
        self.tableview.backgroundColor = [UIColor colorWithHexString:@"f4f4f4" alpha:1];
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        self.tableview.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:self.tableview];
        
    }
}
//组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr.count;
}
//cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 30;
}
//编辑Cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *id1 =@"cell1";
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id1];
    }
    UILabel *bingzheng = [[UILabel alloc]init];
    bingzheng.frame = CGRectMake(0, 0, width, 29);
    bingzheng.backgroundColor = [UIColor clearColor];
    bingzheng.text = [NSString stringWithFormat:@"%@",arr[indexPath.row]];
    bingzheng.textColor = [UIColor colorWithHexString:@"323232" alpha:1];
    bingzheng.textAlignment = NSTextAlignmentCenter;
    bingzheng.font = [UIFont systemFontOfSize:15.0];
    [cell.contentView addSubview:bingzheng];
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 29, width, 1);
    view.backgroundColor = [UIColor colorWithHexString:@"e2e2e2" alpha:1];
    [cell.contentView addSubview:view];
    
    //自定义cell选中颜色
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithHexString:@"f4f4f4" alpha:1];
    [cell setSelectedBackgroundView:bgColorView];
    
    //cell点击不变色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //线消失
    self.tableview.separatorStyle = UITableViewCellSelectionStyleNone;
    //隐藏滑动条
    self.tableview.showsVerticalScrollIndicator =NO;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //  跳页
    YdBZxiangqingViewController *BZxiangqing = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"bzxiangqing"];
    
    BZxiangqing.mingcheng = [NSString stringWithFormat:@"%@",arr[indexPath.row]];
    
    [self.navigationController pushViewController:BZxiangqing animated:YES];
    
}
-(void)search
{
    YdmingchengsearchViewController *mingchengsearch = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mingchengsearch"];
    
    [self.navigationController pushViewController:mingchengsearch animated:YES];
}

-(void)fanhui
{
    //返回上一页
    [self.navigationController popViewControllerAnimated:YES];
}
@end

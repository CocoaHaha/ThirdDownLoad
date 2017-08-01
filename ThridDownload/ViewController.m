//
//  ViewController.m
//  ThridDownload
//
//  Created by SXF on 2017/4/1.
//  Copyright © 2017年 SXF. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"

#import "UIImageView+WebCache.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate>

@property (strong, nonatomic) NSArray *movies;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSURL *urlStr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *str = [[NSString stringWithFormat:@"%@", self.urlStr] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.view addSubview:self.tableView];
    
    NSString *path = @"http://api.map.baidu.com/telematics/v3/movie?output=json&qt=hot_movie&location=郑州&ak=sqkgk4YWBezLIkjIiVyAXXe5";
    NSString *encodePath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    /**方法一*/
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:encodePath]];
    request.delegate = self;
    [request startAsynchronous];
    
    
    /**方法二*/
//    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:encodePath]];
//    // 发送同步请求, data就是返回的数据
//    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
//    if (data == nil) {
//        NSLog(@"send request failed!");
//    }
//    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    NSDictionary *resultDic = responseDic[@"result"];
//    NSArray *movieArray = resultDic[@"movie"];
//    
//    self.movies = movieArray;
//    [_tableView reloadData];
    
}

- (UITableView *)tableView{
    
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100.f;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

#pragma mark -
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *dic = _movies[indexPath.row];
    
    cell.textLabel.text = dic[@"movie_starring"];
    
    NSURL *url = [NSURL URLWithString:dic[@"movie_picture"]];
    
    [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"icon_base"]];
    
    //判断缓存 有没有
    
    //如果没有 下载
    //    [NSThread detachNewThreadSelector:@selector(detachThread:) toTarget:self withObject:@[dic, cell]];
    
    return cell;
}

- (void)detachThread:(NSArray *)array
{
    NSLog(@"%@", array);
    NSDictionary *dic = array[0];
    UITableViewCell *cell = array[1];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:dic[@"movie_picture"]]];
    
    [self performSelectorOnMainThread:@selector(reloadUI:) withObject:@[cell, data] waitUntilDone:NO];
}

- (void)reloadUI:(NSArray *)array
{
    UITableViewCell *cell = array[0];
    NSData *data = array[1];
    
    cell.imageView.image = [UIImage imageWithData:data];
    
    //做缓存 内存 存沙盒
}


#pragma mark -
#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@", request.responseString);
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *resultDic = responseDic[@"result"];
    NSArray *movieArray = resultDic[@"movie"];
    
    self.movies = movieArray;
    [_tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

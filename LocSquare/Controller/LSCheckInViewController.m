//
//  LSCheckInViewController.m
//  LocSquare
//
//  Created by koogawa on 2013/06/02.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "LSCheckInViewController.h"

enum {
    LSCheckInViewControllerTypeFsq = 1,
    LSCheckInViewControllerTypeLoc
};

@interface LSCheckInViewController ()

@end

@implementation LSCheckInViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"ロケスク！";
        venues_ = [[NSMutableArray alloc] init];
        spots_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"開発中！";

    // 次へボタンを追加
    UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Checkin"
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(logoutButtonAction)];
    self.navigationItem.rightBarButtonItem = nextButtonItem;

    // foursquare用テーブルビュー
    fsqTableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 200) style:UITableViewStylePlain];
    fsqTableView_.dataSource = self;
    fsqTableView_.delegate = self;
    fsqTableView_.tag = LSCheckInViewControllerTypeFsq;
    [self.view addSubview:fsqTableView_];
    
//    UISearchBar *fsqSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    fsqTableView.tableHeaderView = fsqSearchBar;

    // ロケタッチ用テーブルビュー
    locTableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, 320, 200) style:UITableViewStylePlain];
    locTableView_.dataSource = self;
    locTableView_.delegate = self;
    locTableView_.tag = LSCheckInViewControllerTypeLoc;
    [self.view addSubview:locTableView_];
    
//    UISearchBar *locSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    locTableView.tableHeaderView = locSearchBar;
    
    // 現在地取得開始
    locationManager_ = [[CLLocationManager alloc] init];
    [locationManager_ setDelegate:self];
    [locationManager_ startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private method

- (void)fetchVenues
{
    // APIからベニューリストを取得
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&client_id=&client_secret=&v=20130605", coordinate_.latitude, coordinate_.longitude];
    //, latitude, longitude];
	NSLog(@"urlString = %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
	NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"response = %@", response);
    
    // エラーコードをログに出力
	NSInteger errorCode = [[[jsonDic objectForKey:@"meta"] objectForKey:@"code"] intValue];
	NSLog(@"errorCode = %d", errorCode);
    
	// 結果取得
	NSArray *venues = [[jsonDic objectForKey:@"response"] objectForKey:@"venues"];
    venues_ = [venues mutableCopy];
    NSLog(@"venues %@", venues_);
    
    [fsqTableView_ reloadData];
}

- (void)fetchSpots
{
    // APIからベニューリストを取得
    NSString *urlString = [NSString stringWithFormat:@"https://api.loctouch.com/v1/spots/search?lat=%f&lng=%f", coordinate_.latitude, coordinate_.longitude];
	NSLog(@"urlString = %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
	NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    // エラーコードをログに出力
	NSInteger errorCode = [[[jsonDic objectForKey:@"meta"] objectForKey:@"code"] intValue];
	NSLog(@"errorCode = %d", errorCode);
    
	// 結果取得
	NSArray *spots = [jsonDic objectForKey:@"spots"];
    spots_ = [spots mutableCopy];
    NSLog(@"spots %@", spots);
    
    [locTableView_ reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (tableView.tag)
    {
        case LSCheckInViewControllerTypeFsq:
            return [venues_ count];
            break;
            
        case LSCheckInViewControllerTypeLoc:
            return [spots_ count];
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (tableView.tag)
    {
        case LSCheckInViewControllerTypeFsq:
            return @"foursquare";
            break;
            
        case LSCheckInViewControllerTypeLoc:
            return @"ロケタッチ";
            break;
            
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    switch (tableView.tag)
    {
        case LSCheckInViewControllerTypeFsq:
        {
            if (indexPath.row == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
            NSData *data = [NSData dataWithContentsOfURL:
                          [NSURL URLWithString:@"https://foursquare.com/img/points/swarm.png"]];
            UIImage *image = [UIImage imageWithData:data];
            cell.imageView.image = image;
            cell.textLabel.text = [[venues_ objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.detailTextLabel.text = [[[venues_ objectAtIndex:indexPath.row] objectForKey:@"location"] objectForKey:@"address"];
            
            break;
        }
            
        case LSCheckInViewControllerTypeLoc:
        {
            if (indexPath.row == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
            NSString *urlString = [[[spots_ objectAtIndex:indexPath.row] objectForKey:@"icon"] objectForKey:@"small"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            UIImage *image = [UIImage imageWithData:data];
            cell.imageView.image = image;
            cell.textLabel.text = [[spots_ objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.detailTextLabel.text = [[spots_ objectAtIndex:indexPath.row] objectForKey:@"address"];
            
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark - CLLocationManager delegate

// GPSの位置情報が更新されたら呼ばれる
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%s", __func__);
    
    if (isInitialized_ == YES) return;
    isInitialized_ = YES;
    
	// 緯度・経度取得
    coordinate_ = newLocation.coordinate;
    
    [self fetchVenues];
    [self fetchSpots];
}

@end

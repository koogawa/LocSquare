//
//  LSCheckInViewController.h
//  LocSquare
//
//  Created by koogawa on 2013/06/02.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LSCheckInViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
{
    NSMutableArray      *spots_;    // ロケタッチ用
    NSMutableArray      *venues_;   // foursquare用
    
    CLLocationManager       *locationManager_;  // 位置情報取得用
    CLLocationCoordinate2D  coordinate_;        // 現在位置を記録し続ける
    BOOL                    isInitialized_;
    
    UITableView *fsqTableView_; // foursquare用テーブルビュー
    UITableView *locTableView_; // ロケタッチ用テーブルビュー
}

@end

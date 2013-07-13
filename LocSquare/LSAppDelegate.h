//
//  LSAppDelegate.h
//  LocSquare
//
//  Created by koogawa on 2013/06/02.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSCheckInViewController;

@interface LSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LSCheckInViewController *viewController;

@end

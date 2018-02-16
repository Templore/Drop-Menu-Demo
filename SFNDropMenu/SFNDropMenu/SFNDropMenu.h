
/**
 *  Project: SFNDropMenu version 1.0
 *  Created by Siksfonine on 2015.02.16
 *  Copyright (c) 2015 Siksfonine. All rights reserved.
 *
 *  SFNDropMenu.h
 */

#import <UIKit/UIKit.h>
@class SFNDropMenu;

@protocol SFNDropMenuDataSource <NSObject>

@required
- (NSInteger)numberOfSectionsInDropMenu:(SFNDropMenu *)dropMenu;
- (NSInteger)dropMenu:(SFNDropMenu *)dropMenu numberOfRowsInSection:(NSInteger)section;
- (NSString *)dropMenu:(SFNDropMenu *)dropMenu titleForRowAtIndex:(NSInteger)index section:(NSInteger)section;

@end

@protocol SFNDropMenuDelegate <NSObject>

@optional
- (void)dropMenu:(SFNDropMenu *)dropMenu didSelectRowAtIndex:(NSInteger)index section:(NSInteger)section;

@end

@interface SFNDropMenu : UIView <UITableViewDataSource,
                                 UITableViewDelegate,
                                 UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <SFNDropMenuDataSource> dataSource;
@property (nonatomic, weak) id <SFNDropMenuDelegate> delegate;

- (instancetype)initWithOrigin:(CGPoint)origin
                        height:(CGFloat)height
                    dataSource:(id)dataSource
                      delegate:(id)delegate
                        titles:(NSArray *)titles;

@end
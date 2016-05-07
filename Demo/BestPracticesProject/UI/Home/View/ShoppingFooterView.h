//
//  ShoppingFooterView.h
//  BestPracticesProject
//
//  Created by A on 16/5/7.
//  Copyright © 2016年 sy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShoppingFooterViewDelegate <NSObject>

- (NSString *)checkBoxSelect:(BOOL)select;

@end

@interface ShoppingFooterView : UIView
@property (assign, nonatomic) id<ShoppingFooterViewDelegate> delegate;

- (void)setTotal:(NSString *)total;
@end

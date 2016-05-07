//
//  ShoppingCell.h
//  BestPracticesProject
//
//  Created by A on 16/5/7.
//  Copyright © 2016年 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingLogicModel.h"
@protocol ShoppingCellDelegate <NSObject>
- (void)checkCellButton;
@end

@interface ShoppingCell : UITableViewCell
@property (assign, nonatomic) id<ShoppingCellDelegate> delegate;

@property (strong, nonatomic) ShoppingList *model;
@end

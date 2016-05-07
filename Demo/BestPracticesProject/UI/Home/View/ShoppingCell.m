//
//  ShoppingCell.m
//  BestPracticesProject
//
//  Created by A on 16/5/7.
//  Copyright © 2016年 sy. All rights reserved.
//

#import "ShoppingCell.h"

@interface ShoppingCell()
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMoney;

@end

@implementation ShoppingCell

- (void)setModel:(ShoppingList *)model {
    _model = model;
    self.lblTitle.text = model.title;
    self.lblMoney.text = model.money;
    self.btnCheck.selected = model.isCheck;
}

- (IBAction)btnCheckClick:(id)sender {
    self.btnCheck.selected = !self.btnCheck.selected;
    self.model.isCheck = self.btnCheck.selected;
    if ([self.delegate respondsToSelector:@selector(checkCellButton)]) {
        [self.delegate checkCellButton];
    }
}

- (void)dealloc{
    self.delegate = nil;
}
@end

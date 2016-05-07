//
//  ShoppingFooterView.m
//  BestPracticesProject
//
//  Created by A on 16/5/7.
//  Copyright © 2016年 sy. All rights reserved.
//

#import "ShoppingFooterView.h"

@interface ShoppingFooterView()
@property (weak, nonatomic) IBOutlet UILabel *lblTotal;
@property (weak, nonatomic) IBOutlet UIButton *btnAllSelect;

@end

@implementation ShoppingFooterView

- (IBAction)btnAllCheckClick:(UIButton *)sender {
    self.btnAllSelect.selected = !self.btnAllSelect.selected;
    if ([self.delegate respondsToSelector:@selector(checkBoxSelect:)]) {
        self.lblTotal.text = [self.delegate checkBoxSelect:self.btnAllSelect.selected];
    }
}

- (void)setTotal:(NSString *)total{
    self.lblTotal.text = total;
}

- (void)dealloc{
    self.delegate = nil;
}
@end

//
//  HomeViewController.m
//  BestPracticesProject
//
//  Created by A on 16/5/6.
//  Copyright © 2016年 sy. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeDataManager.h"
#import "ShoppingParamModel.h"
#import "ShoppingLogicModel.h"
#import "ShoppingCell.h"
#import "ShoppingFooterView.h"
@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,ShoppingFooterViewDelegate,ShoppingCellDelegate>

//view
@property (strong, nonatomic) UITableView *tbv;
@property (strong, nonatomic) ShoppingFooterView *footerView;
//data
@property (strong, nonatomic) ShoppingLogicModel *shoppingModel;
@end

@implementation HomeViewController

#pragma mark - liftCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"最佳实践Demo";
    
    [self.view addSubview:self.tbv];
    [self.view addSubview:self.footerView];
    
    [self setupLayout];
    [self getShoppingList];
    
}


#pragma mark -searchData
- (void)getShoppingList{
    [SVProgressHUD showWithStatus:Loading];
    ShoppingParamModel *param = [[ShoppingParamModel alloc] initWithName:@"小明" age:18];
    [[HomeDataManager sharedManager] getShoppingList:param success:^(ShoppingLogicModel *model) {
        self.shoppingModel = model;
        [self.tbv reloadData];
        [SVProgressHUD dismiss];
       
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - delegate|dataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShoppingCell *shoppingCell = [tableView dequeueReusableCellWithIdentifier:@"ShoppingViewCellIdentity"];
    shoppingCell.delegate = self;
    shoppingCell.model = self.shoppingModel.array[indexPath.row];
    return shoppingCell;  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.shoppingModel.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark ShoppingCellDelegate
- (void)checkCellButton{
    CGFloat total = 0;
    for (ShoppingList *list in self.shoppingModel.array) {
        if (list.isCheck) {
            total = total + [list.money integerValue];
        }
    }
    [self.footerView setTotal:[NSString stringWithFormat:@"%.2f",total]];
}

#pragma makr ShoppingFooterViewDelegate
- (NSString *)checkBoxSelect:(BOOL)select{
    CGFloat total = 0;
    for (ShoppingList *list in self.shoppingModel.array) {
        list.isCheck = select;
        total = total + [list.money integerValue];
    }
    [self.tbv reloadData];
    
    if (!select) {
        total = 0;
    }
    return [NSString stringWithFormat:@"%.2f",total];
}

#pragma mark - eventRespone

#pragma mark - getters and setter
- (UITableView *)tbv{
    if (!_tbv) {
        _tbv = ({
            UITableView *tableview = [[UITableView alloc] init];
            tableview.delegate = self;
            tableview.dataSource = self;
            [tableview registerNib:[UINib nibWithNibName:@"ShoppingCell" bundle:nil] forCellReuseIdentifier:@"ShoppingViewCellIdentity"];

            tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableview;
        });
    }
    return _tbv;
}

- (ShoppingFooterView *)footerView{
    if (!_footerView) {
        _footerView = ({
            NSArray  *arr= [[NSBundle mainBundle]loadNibNamed:@"ShoppingFooterView" owner:nil options:nil];
            ShoppingFooterView *view = [arr firstObject];
            view.delegate = self;
            view;
        });
    }
    return _footerView;
}


#pragma mark - Layout
- (void)setupLayout{
    __weak typeof(self) weakSelf = self;
    
    [self.tbv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.bottom.equalTo(weakSelf.footerView.mas_top).offset(-10);
        make.right.equalTo(@-10);
        make.top.equalTo(@20);
    }];
    
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.bottom.equalTo(weakSelf.view).equalTo(@-10);
        make.left.equalTo(@10);
        make.right.equalTo(@-10);
    }];
}
#pragma mark - other




@end

//
//  PKPickerView.m
//  sss
//
//  Created by pengkang on 2020/8/13.
//  Copyright © 2020 pengkang. All rights reserved.
//

#import "PKPickerView.h"

@interface PKPickerViewTableCell : UITableViewCell

@property(nonatomic,strong) UILabel *label;
@property(nonatomic,strong) UIView *cellView;
@end

@implementation PKPickerViewTableCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self.contentView addSubview:self.label];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self refresh];
    if (_cellView) {
        _cellView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    }
    self.label.frame = self.bounds;
}

-(UILabel *)label{
    if (!_label ) {
        _label = [[UILabel alloc]init];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (void)setCellView:(UIView *)cellView{
    if (![_cellView isEqual:cellView]) {
        [_cellView removeFromSuperview];
        _cellView = nil;
    }
    _cellView = cellView;
    [self refresh];
}

- (void)refresh{
    if (_cellView) {
        [self.contentView addSubview:self.cellView];
        [_label removeFromSuperview];
        _label = nil;
        return;
    }
    
    [self.contentView addSubview:self.label];
}

@end

@interface PKPickerViewTableView : UITableView
@property(nonatomic) NSMutableArray *data;
@property(nonatomic) CGFloat cellHeight;
@property(nonatomic) BOOL isScrollDown;
@property(nonatomic) CGFloat lastContentOffsetY;
@property(nonatomic) NSInteger selectRow;
@property(nonatomic) CGFloat index;
@end

@implementation PKPickerViewTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews{
    self.cellHeight = 40;
    self.isScrollDown = NO;
    self.lastContentOffsetY = 0;
}

-(NSMutableArray *)data{
    if (!_data) {
        _data = @[].mutableCopy;
    }
    return _data;;
}


@end

@interface PKPickerView()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic) NSMutableArray *tableArrs;
@property(nonatomic) UIView *topLine;
@property(nonatomic) UIView *bottomLine;
@property(nonatomic) CGFloat cellHeight;

@end

@implementation PKPickerView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews{
    self.cellHeight = 50;
    self.clipsToBounds = YES;
    [self addSubview:self.topLine];
    [self addSubview:self.bottomLine];
}

#pragma mark public
- (void)reloadAllComponents{
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(PKPickerViewRowHeight:)]) {
        self.cellHeight =  [self.dataSource PKPickerViewRowHeight:self];
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    self.topLine.frame = CGRectMake(0, self.frame.size.height/2.0 - self.cellHeight/2.0, self.frame.size.width, 1/scale);
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height/2.0 + self.cellHeight/2.0, self.frame.size.width, 1/scale);
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(PKPickerViewSeparatorlineColor:)]){
        self.topLine.backgroundColor = [self.dataSource PKPickerViewSeparatorlineColor:self];
        self.bottomLine.backgroundColor = [self.dataSource PKPickerViewSeparatorlineColor:self];
    }
    
    for (PKPickerViewTableView *table in self.tableArrs){
        [table removeFromSuperview];
    }
    
    [self.tableArrs removeAllObjects];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfComponentsInPKPickerView:)]) {
        NSInteger component = [self.dataSource numberOfComponentsInPKPickerView:self];
        if (component == 0) {
            return;
        }
        if (component > self.tableArrs.count ) {
            for (NSInteger i = self.tableArrs.count; i < component; i++) {
                PKPickerViewTableView *table = [[PKPickerViewTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
                table.index = i;
                table.delegate = self;
                table.dataSource = self;
                table.contentInset = UIEdgeInsetsMake(self.frame.size.height/2.0 - self.cellHeight/2.0, 0, self.frame.size.height/2.0 - self.cellHeight/2.0 , 0);
                table.separatorStyle = UITableViewCellSeparatorStyleNone;
                table.showsVerticalScrollIndicator = NO;
                table.showsHorizontalScrollIndicator = NO;
                NSString *cell = @"PKPickerViewTableCell";
                [table registerClass:PKPickerViewTableCell.class forCellReuseIdentifier:cell];
                table.clipsToBounds = NO;
                [self addSubview:table];
                [self.tableArrs addObject:table];
            }
        }
    }
    
    [self bringSubviewToFront:self.topLine];
    [self bringSubviewToFront:self.bottomLine];
    
    CGFloat leftSpace = self.leftMargin;
    CGFloat width = self.frame.size.width/self.tableArrs.count;
    BOOL hasWidth = self.dataSource && [self.dataSource respondsToSelector:@selector(PKPickerView:widthForComponent:)];
    for (NSInteger i = 0; i < self.tableArrs.count; i++) {
        PKPickerViewTableView *tableView = (PKPickerViewTableView *)self.tableArrs[i];
        CGFloat tableWidth = 0;
        if (hasWidth) {
            tableWidth = [self.dataSource PKPickerView:self widthForComponent:i];
        }else{
            tableWidth = width;
        }
        CGFloat height = self.frame.size.height;
        CGRect frame = CGRectMake(leftSpace, 0, tableWidth, height);
        tableView.frame = frame;
        leftSpace += tableWidth;
    }
    
    for (PKPickerViewTableView *table in self.tableArrs) {
        [table reloadData];
    }
}

- (void)reloadComponent:(NSInteger)component{
    if (component >= self.tableArrs.count || component < 0) {
        return;
    }
    PKPickerViewTableView *tableView = (PKPickerViewTableView *)self.tableArrs[component];
    [tableView reloadData];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated{
    if (component >= self.tableArrs.count || component < 0) {
        return;
    }
    PKPickerViewTableView *tableView = (PKPickerViewTableView *)self.tableArrs[component];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(PKPickerView:numberOfRowsInComponent:)]) {
        NSInteger number = [self.dataSource PKPickerView:self numberOfRowsInComponent:component];
#if DEBUG
    NSAssert(row >= 0, @"selected row can be < 0");
    NSString *warning = [NSString stringWithFormat:@"selected row can be large than max rows number %ld",number];
    NSAssert(row < number , warning);
#endif
        if (row < 0) {
            row = 0;
        }else if(row > number - 1){
            row = number;
        }
        tableView.selectRow = row;
        [self adjustCenter:tableView animated:animated];
    }
}

- (NSInteger)selectedRowInComponent:(NSInteger)component{
    if (component >= self.tableArrs.count || component < 0) {
        return 0;
    }
    PKPickerViewTableView *tableView = self.tableArrs[component];
    return tableView.selectRow;
}

- (NSInteger)numberOfComponent{
    return self.tableArrs.count;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self reloadAllComponents];
}

#pragma mark private method
- (void)adjustCenter:(PKPickerViewTableView *)tableView animated:(BOOL)animated{
    CGFloat y = self.cellHeight * tableView.selectRow - tableView.contentInset.top ;
    [tableView setContentOffset:CGPointMake(0, y) animated:animated];
}

#pragma mark UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.dataSource respondsToSelector:@selector(PKPickerView:numberOfRowsInComponent:)]) {
        NSInteger rows = [self.dataSource PKPickerView:self numberOfRowsInComponent:((PKPickerViewTableView *)tableView).index];
        return rows;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PKPickerViewTableView *table = (PKPickerViewTableView *)tableView;
    PKPickerViewTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PKPickerViewTableCell" forIndexPath:indexPath];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(PKPickerView:viewForRow:forComponent:reusingView:)] ) {
        UIView *view = [self.dataSource PKPickerView:self viewForRow:indexPath.row forComponent:indexPath.row reusingView:cell.cellView];
        cell.cellView = view;
        return cell;
    }
    cell.cellView = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(PKPickerView:attributedTitleForRow:forComponent:)] ) {
        NSAttributedString *str = [self.dataSource PKPickerView:self attributedTitleForRow:indexPath.row forComponent:table.index];
        if (str && [str isKindOfClass:NSAttributedString.class]) {
            cell.label.attributedText = str;
            return cell;
        }
    }
    cell.label.attributedText = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(PKPickerView:titleForRow:forComponent:)] ) {
        NSString *str = [self.dataSource PKPickerView:self titleForRow:indexPath.row forComponent:table.index];
        if (str && [str isKindOfClass:NSString.class]) {
            cell.label.text = str;
            return cell;
        }
    }
    cell.label.text = nil;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(PKPickerViewRowHeight:)]) {
        return [self.dataSource PKPickerViewRowHeight:self];
    }
    return self.cellHeight;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat originOffset = -self.frame.size.height/2.0;
    NSInteger index = (scrollView.contentOffset.y - originOffset)/self.cellHeight;
    PKPickerViewTableView *tableView = (PKPickerViewTableView *)scrollView;
    tableView.selectRow = index;
    if(self.delegate && [self.delegate respondsToSelector:@selector(PKPickerView:didSelectRow:inComponent:)]){
        [self.delegate PKPickerView:self didSelectRow:index inComponent:((PKPickerViewTableView *)scrollView).index];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    PKPickerViewTableView *tableView = (PKPickerViewTableView *)scrollView;
    [self adjustCenter:tableView animated:YES];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    PKPickerViewTableView *tableView = (PKPickerViewTableView *)scrollView;
    CGFloat originOffset = -self.frame.size.height/2.0;
    float index = (targetContentOffset->y - originOffset)/self.cellHeight;
    NSInteger targetIndex = (NSInteger)index;
    
    if (index - floorf(index) >= 0.5) {
        targetIndex = (NSInteger)index + 1 ;
    }
    NSInteger num = [self.dataSource PKPickerView:self numberOfRowsInComponent:tableView.index];
    if (targetIndex > num - 1 ) {
        targetIndex--;
    }
    if (!((PKPickerViewTableView *)scrollView).isScrollDown) {
        targetContentOffset->y = targetIndex * self.cellHeight + originOffset + self.cellHeight/2.0;
    }else{
        targetContentOffset->y = targetIndex * self.cellHeight + originOffset - self.cellHeight/2.0;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    PKPickerViewTableView *tableView = (PKPickerViewTableView *)scrollView;
    tableView.isScrollDown = tableView.contentOffset.y - tableView.lastContentOffsetY < 0;
    tableView.lastContentOffsetY = tableView.contentOffset.y;
}

#pragma mark getter
-(NSMutableArray *)tableArrs{
    if (!_tableArrs) {
        _tableArrs = @[].mutableCopy;
    }
    return _tableArrs;
}

- (UIView *)topLine{
    if (!_topLine) {
        _topLine = [[UILabel alloc]init];
        _topLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _topLine;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UILabel alloc]init];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _bottomLine;
}

@end

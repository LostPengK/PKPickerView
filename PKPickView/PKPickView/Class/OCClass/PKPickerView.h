//
//  PKPickerView.h
//  sss
//
//  Created by pengkang on 2020/8/13.
//  Copyright © 2020 pengkang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PKPickerView;
@protocol PKPickerViewDelegate <NSObject>

- (void)PKPickerView:(PKPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end

@protocol PKPickerViewDataSource <NSObject>

- (NSInteger)numberOfComponentsInPKPickerView:(PKPickerView *)PKPickerView;

- (NSInteger)PKPickerView:(PKPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

- (CGFloat)PKPickerViewRowHeight:(PKPickerView *)pickerView;

- (CGFloat)PKPickerView:(PKPickerView *)pickerView widthForComponent:(NSInteger)component;

@optional
- (nullable NSString *)PKPickerView:(PKPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;

- (nullable NSAttributedString *)PKPickerView:(PKPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component;

- (nullable UIView *)PKPickerView:(PKPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;

- (UIColor *)PKPickerViewSeparatorlineColor:(PKPickerView *)PKPickerView;

@end

@interface PKPickerView : UIView

@property(nullable,nonatomic,weak) id<PKPickerViewDataSource> dataSource;                // default is nil. weak reference

@property(nullable,nonatomic,weak) id<PKPickerViewDelegate>   delegate;

@property(nonatomic,assign) CGFloat leftMargin;

@property(nonatomic,assign) NSInteger numberOfComponent;

- (void)reloadAllComponents;

- (void)reloadComponent:(NSInteger)component;

// selection. in this case, it means showing the appropriate row in the middle
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;  // scrolls the specified row to center.

- (NSInteger)selectedRowInComponent:(NSInteger)component;

@end

NS_ASSUME_NONNULL_END

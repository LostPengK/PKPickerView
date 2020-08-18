//
//  ViewController.m
//  PKPickView
//
//  Created by pengkang on 2020/8/17.
//  Copyright © 2020 pengkang. All rights reserved.
//

#import "ViewController.h"
#import "PKPickerView.h"
#import "PKPickView-Bridging-Header.h"

@interface ViewController ()<PKPickerViewDelegate,PKPickerViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addOcPickerView];
    // Do any additional setup after loading the view.
}

- (void)addOcPickerView{
    PKPickerView *picker = [[PKPickerView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    [self.view addSubview:picker];
    picker.dataSource = self;
    picker.delegate = self;
    picker.leftMargin = 15;
    [picker reloadAllComponents];
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [picker selectRow:5 * i inComponent:i animated:YES];
        });
    }
}

- (void)addSwiftPickerView{
    
}


#pragma mark PKPickerViewDelegate,PKPickerViewDataSource

- (CGFloat)PKPickerViewRowHeight:(PKPickerView *)pickerView{
    return 50;
}

- (CGFloat)PKPickerView:(PKPickerView *)pickerView widthForComponent:(NSInteger)component{
    return (self.view.frame.size.width - 30 )/10.0;
}

-(NSInteger)numberOfComponentsInPKPickerView:(PKPickerView *)PKPickerView{
    return 10;
}

-(NSInteger)PKPickerView:(PKPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 50;
}

-(NSString *)PKPickerView:(PKPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    if(component == 0){
//        return  [NSString stringWithFormat:@"%02ld",row];
//    }
    return  [NSString stringWithFormat:@"%02ld",row];
}

//- (NSAttributedString *)PKPickerView:(PKPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    NSAttributedString *att = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",@(row).stringValue,@(component).stringValue] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:(component + 1)/2.0]}];
//    return att;
//}

//- (UIView *)PKPickerView:(PKPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (self.view.frame.size.width - 30 )/2.0, 50)];
//    label.text = @(row).stringValue;
//    label.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
//    label.textAlignment = NSTextAlignmentCenter;
//    return  label;
//}

- (void)PKPickerView:(PKPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"PKPickerView didSelectRow=%ld,component=%ld",row,component);
    if (component < 10) {
        [pickerView selectRow:arc4random_uniform(50) inComponent:component + 1 animated:YES];
    }
}

- (UIColor *)PKPickerViewSeparatorlineColor:(PKPickerView *)PKPickerView{
    return [UIColor redColor];
}

@end

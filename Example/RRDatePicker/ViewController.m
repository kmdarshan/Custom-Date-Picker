//
//  ViewController.m
//  RRDatePicker
//
//  Created by Darshan Katrumane on 5/4/15.
//  Copyright (c) 2015 Darshan Katrumane. All rights reserved.
//

#import "ViewController.h"
@interface ViewController (){
    RRDatePicker *datePicker;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor yellowColor]];
    UIButton *showCalendar = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [showCalendar setTitle:@"show calendar" forState:UIControlStateNormal];
    [showCalendar addTarget:self action:@selector(showCalendar) forControlEvents:UIControlEventTouchUpInside];
    [showCalendar setFrame:CGRectMake(0, 50, 200, 50)];
    [showCalendar setCenter:CGPointMake(self.view.center.x, showCalendar.center.y)];
    [showCalendar setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:showCalendar];
    datePicker = [[RRDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.frame.size.width, 265.0) forYear:@"2015" forMonth:@"10" forDay:@"01" forDateFormat:nil];
    [self.view addSubview:datePicker];
    datePicker.userSelectedDateDelegate = self;
}

-(void)setDate:(NSInteger)day forMonth:(NSInteger)month forYear:(NSInteger)year {
    NSLog(@"date has been set %d/%d/%d", month, day, year);
}

-(void) showCalendar {
    __block RRDatePicker *blockCalendarPickerView = datePicker;
    
    [UIView animateWithDuration:0.4 animations:^{
        [blockCalendarPickerView setFrame:CGRectMake(0, (blockCalendarPickerView.frame.origin.y - blockCalendarPickerView.frame.size.height) + 49, blockCalendarPickerView.frame.size.width, blockCalendarPickerView.frame.size.height)];
        blockCalendarPickerView = nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

# Custom Date Picker

This project basically replaces the current UIDatePicker component. The datepicker provided by apple doesn't help us change the data which can be displayed in it. Using this custom picker you can actually add custom data. 

How to use it
```objective-c
    RRDatePicker *datePicker = [[RRDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.frame.size.width, 265.0) forYear:@"2015" forMonth:@"10" forDay:@"01" forDateFormat:nil];
    [self.view addSubview:datePicker];
    datePicker.userSelectedDateDelegate = self;
```
Implement this delegate 
```objective-c
<RRDatePickerDelegate>
-(void)setDate:(NSInteger)day forMonth:(NSInteger)month forYear:(NSInteger)year {
    NSLog(@"date has been set %d/%d/%d", month, day, year);
}
```


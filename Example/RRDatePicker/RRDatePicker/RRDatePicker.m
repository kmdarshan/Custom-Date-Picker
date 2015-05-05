//
//  RRDatePicker.m
//
//  Created by Darshan Katrumane on 10/11/12.
//

#import "RRDatePicker.h"

@implementation RRDatePicker
@synthesize datepicker;
@synthesize userSelectedDateDelegate;


-(void) setup{
    
    // init selected row
    pickerSelectedRowDay = 0;
    pickerSelectedRowYear = MIN_YEAR;
    rowTextColor = [UIColor blackColor];
    
    // set the current date
    NSDate *tmpDate = [NSDate date];
    pickerCalendar = [NSCalendar currentCalendar];
    currentDate = [pickerCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:tmpDate];
    // init the disable values;
    disabledRows = [[NSMutableArray alloc] init];
    
    [self helperSetDiffYears];
    // need this for getting the circular feel
    [self initDatePickerToCurrentDate];
    [self setupDatavalueForPicker];
    
    datepicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] ;
    datepicker.showsSelectionIndicator = YES;
    datepicker.delegate = self;
    
    [self setPickerDate:[self getTestDate]];
}


# pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setup];
        [self addSubview:datepicker];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame forYear:(NSString*)tmpYear forMonth:(NSString*)tmpMonth forDay:(NSString*)tmpDay forDateFormat:(NSString*)tmpDateFormat{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setup];
        
        if(tmpDateFormat == nil)
            [self setDateFormat:@"yyyy-MM-dd"];
        else {
            [self setDateFormat:tmpDateFormat];
        }
        
        // set the date
        [self helperSetDatePickerDate:tmpYear forMonth:tmpMonth forDay:tmpDay];
        
        [self addSubview:datepicker];
        
    }
    return self;
}

#pragma mark pickerView data source

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    // 12 months
    if(component == 2 )
    {
        // get current year
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger year = [components year];
        
        // lets keep 121 years e.g. 1892 to 2012
        // add +1 for no clue string
        diffyears = year - MIN_YEAR;
        return diffyears+2;
    }
    // some random number
    return NUMBER_OF_ROWS;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

// customize each view based on each component
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    }
    retval.font = [UIFont fontWithName:COMPONENT_FONT size:COMPONENT_FONT_SIZE];
    
    if(component == 0)
    {
        retval.textAlignment = NSTextAlignmentRight;
        // select the month
        retval.text = [months objectAtIndex:(row%12)];
        // check for today's day
        // text color is blue
        NSString *tmpMonth = [months objectAtIndex:(row%12)];
        if([tmpMonth isEqualToString:[NSString stringWithFormat:@"%@", [self helperMonthNameForMonthNumber:[currentDate month]]]])
        {
            // today's day
            retval.textColor = [UIColor blueColor];
        }else {
            retval.textColor = [UIColor blackColor];
        }
    }
    if(component == 1)
    {
        retval.textAlignment = NSTextAlignmentCenter;
        NSString *tmpDay = [days objectAtIndex:(row%31)];
        
        // set the day
        retval.text = tmpDay;
        retval.textColor = [UIColor blackColor];
        
        // check if any of the disable values are present
        for(int i=0; i<[disabledRows count]; ++i) {
            NSString *tmpVal = [disabledRows objectAtIndex:i];
            if([tmpDay isEqualToString:tmpVal])
            {
                retval.textColor = [UIColor grayColor];
            }
        }
        
        // check for today's day
        // text color is blue
        if([tmpDay isEqualToString:[NSString stringWithFormat:@"%d", [currentDate day]]])
        {
            // today's day
            retval.textColor = [UIColor blueColor];
        }
    }
    if(component == 2)
    {
        // set it to clear color
        retval.backgroundColor = [UIColor clearColor];
        retval.textAlignment = NSTextAlignmentCenter;
        // end of the row
        if(row == diffyears+1)
        {
            retval.font = [UIFont fontWithName:COMPONENT_FONT size:16];
            retval.text = DASHDASH;
        }else {
            
            // set the year
            // start from the year 1892
            NSInteger year = MIN_YEAR;
            retval.text = [NSString stringWithFormat:@"%d", year+row];
        }
        
        // check for today's day
        // text color is blue
        if([retval.text isEqualToString:[NSString stringWithFormat:@"%d", [currentDate year]]])
        {
            // today's day
            retval.textColor = [UIColor blueColor];
        }else {
            retval.textColor = [UIColor blackColor];
        }
    }
    
    return retval;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if(component == 0)
        return COMPONENT_MONTH_WIDTH;
    if(component == 1)
        return COMPONENT_DAY_WIDTH;
    // remaining space
    return COMPONENT_YEAR_WIDTH;
}

/**
 * Statically assign the days and months to the variables
 * for displaying the rows and components
 */
-(void) setupDatavalueForPicker
{
    // setup the years
    months = [NSMutableArray arrayWithCapacity:12];
    [months addObject:@"January"];
    [months addObject:@"February"];
    [months addObject:@"March"];
    [months addObject:@"April"];
    [months addObject:@"May"];
    [months addObject:@"June"];
    [months addObject:@"July"];
    [months addObject:@"August"];
    [months addObject:@"September"];
    [months addObject:@"October"];
    [months addObject:@"November"];
    [months addObject:@"December"];
    
    days = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31", nil];
}

#pragma mark pickview select methods

-(void)pickerViewLoaded: (NSInteger)divisor forComponent:(NSInteger)tmpComponent {
    
	NSUInteger max = NUMBER_OF_ROWS;
    NSUInteger base10 = (max/2)- (max/2) % divisor;
    
    [self.datepicker selectRow:[self.datepicker selectedRowInComponent:tmpComponent] % divisor+ base10 inComponent:tmpComponent animated:FALSE];
}

-(NSInteger)pickerViewLoadedReturnRow: (NSInteger)divisor forComponent:(NSInteger)tmpComponent {
	NSUInteger max = NUMBER_OF_ROWS;
    NSUInteger base10 = (max/2)- (max/2) % divisor;
    return [self.datepicker selectedRowInComponent:tmpComponent] % divisor+ base10;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    // empty all cached values
    [disabledRows removeAllObjects];
    if(component==0)
    {
        [self helperRedoViewsBasedOnDates:pickerSelectedRowDay forComponent:component forColor:[UIColor blackColor]];
        pickerMonth = row%12 + 1;
        
        // select the row for months
        [self pickerViewLoaded:12 forComponent:component];
        
        // April, June, September, November have 30 days
        // February has 29 or 28 depending on leap years
        // get the text on that view
        
        [self helperSelectDaysAndMonth:TRUE];
        [self pickerViewLoaded:12 forComponent:component];
        [self checkForValidilityAndSetDelegate];
    }
    
    // this component is for the month
    if(component==1)
    {
        // redo row to black color
        pickerSelectedRowDay = [self pickerViewLoadedReturnRow: 31 forComponent:component];
        pickerDay = [[days objectAtIndex:(row%31)] intValue];
        
        [self helperSelectDaysAndMonth:FALSE];
        
        // set the day
        pickerDay = [[days objectAtIndex:(row%31)] intValue];
        [self pickerViewLoaded:31 forComponent:component];
        [self checkForValidilityAndSetDelegate];
    }
    
    if(component == 2)
    {
        pickerSelectedRowYear = row + MIN_YEAR;
        pickerYear = row + MIN_YEAR;
        
        // check for validity until its valid
        // validate for leap year and date
        if([self helperDateExistsYear:pickerYear month:pickerMonth day:pickerDay] != TRUE)
        {
            [self helperSetLeapYearDays:COMPONENT_DAY forDivisor:31];
            // we can return here, after setting the leap year days
            return;
        }
        [self helperValidateSelectedMonthAndDay];
        [self checkForValidilityAndSetDelegate];
        
    }
}

#pragma mark helper

-(void) helperSetDiffYears
{
    // get current year
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger year = [components year];
    
    // lets keep 121 years e.g. 1892 to 2012
    // add +1 for no clue string
    diffyears = year - 1892;
    
    // set maximum year, current year + 1
    // e.g. in 2013, 2014 will be max year
    maxYear = year;
}
-(void) initDatePickerToCurrentDate
{
    // set up calendar component, when user selects a date
    // in the view picker
    // set the default value to today's date
    
    pickerDate = [NSDate date];
    pickerCalendar = [NSCalendar currentCalendar];
    pickerDateComponents = [pickerCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                             fromDate:[NSDate date]];
    pickerMonth = [pickerDateComponents month];
    pickerDay = [pickerDateComponents day];
}

-(void) helperSetupDataNeedByPicker:(NSDateComponents*)components setDate:(BOOL)bDateSet{
    [datepicker selectRow:[components month]-1 inComponent:0 animated:YES];
    [datepicker selectRow:[components day]-1 inComponent:1 animated:YES];
    
    pickerMonth = [components month];
    pickerDay = [components day];
    
    if(bDateSet == FALSE)
    {
        // initially we have no clue for the year
        [datepicker selectRow:diffyears+1 inComponent:2 animated:YES];
    }else {
        // date is set by the user
        // we increment the cntr to reach the value set by the user
        // then we use this cntr to set the component
        int tmpStartVal=MIN_YEAR;
        int tmpCntr=0;
        while (tmpStartVal < [components year]) {
            ++tmpStartVal;
            ++tmpCntr;
        }
        // test scenario: when editing, pull down months, years and days to generate
        // new data, the pickerYear would get reset to zero and birthday label will be
        // reset, hence we need to set the year over here
        pickerYear = tmpCntr + MIN_YEAR;
        [datepicker selectRow:tmpCntr inComponent:2 animated:YES];
    }
    
    // set the disabling of rows here
    if(pickerMonth == 2)
    {
        // handle feb and leap years here
        if([self helperCheckLeapYear:pickerYear] == YES)
        {
            // leap year add 30,31
            [disabledRows addObject:@"30"];
            [disabledRows addObject:@"31"];
        }else {
            // leap year add 29,30,31
            [disabledRows addObject:@"29"];
            [disabledRows addObject:@"30"];
            [disabledRows addObject:@"31"];
        }
    }else {
        // not feb, just handle the other cases
        switch (pickerMonth) {
            case 4: // apr
            case 6: // jun
            case 9: // sep
            case 11: // nov
                [disabledRows addObject:@"31"];
                break;
        }
    }
    [[self datepicker] reloadComponent:1];
    
    // select the month/day for circular view
    [self pickerViewLoaded:12 forComponent:0];
    [self pickerViewLoaded:31 forComponent:1];
    
}
-(void) helperSetDatePickerDate:(NSString*)tmpYear forMonth:(NSString*)tmpMonth forDay:(NSString*)tmpDay
{
    BOOL bDateSet=TRUE;
    if(tmpYear != nil)
    {
        NSRange textRange;
        // custom year
        // set the pointer to No Clue in year
        textRange =[tmpYear rangeOfString:@"0000"];
        if(textRange.location != NSNotFound)
            bDateSet=FALSE;
    }
    // initialize the date
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[tmpDay intValue]];
    [components setMonth:[tmpMonth intValue]];
    [components setYear:[tmpYear intValue]];
    
    [self helperSetupDataNeedByPicker:components setDate:bDateSet];
    
}

#pragma MARK getter

-(NSString*)getDateFormat
{
    return dateformat;
}

-(NSDate*) getPickerDate
{
    if(pickerMonth != 0 && pickerDay != 0)
    {
        // validate for leap year and date
        if([self helperDateExistsYear:pickerYear month:pickerMonth day:pickerDay] == TRUE)
        {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *tmpdate;
            NSDateComponents *dateComponents = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay ) fromDate:tmpdate];
            [dateComponents setYear:pickerYear];
            [dateComponents setMonth:pickerMonth];
            [dateComponents setDay:pickerDay];
            
            NSDate *date = [calendar dateFromComponents:dateComponents];
            return date;
        }
    }
    return nil;
}

#pragma mark setter

-(void)setDateFormat:(NSString *)tmpFormat
{
    dateformat = tmpFormat;
}

-(void) setPickerDate:(NSDate*) tmpdate
{
    BOOL bDateSet=TRUE;
    if(tmpdate == nil)
    {
        bDateSet=FALSE;
        // set the date picker to point to current day
        tmpdate = [NSDate date];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:( NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitMonth ) fromDate:tmpdate];
    
    [datepicker selectRow:[components month]-1 inComponent:0 animated:YES];
    [datepicker selectRow:[components day]-1 inComponent:1 animated:YES];
    
    [self helperSetupDataNeedByPicker:components setDate:bDateSet];
    
}

#pragma mark test methods

-(NSDate*) getTestDate
{
    // test date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *tmpdate = [NSDate date];
	NSDateComponents *dateComponents = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay ) fromDate:tmpdate];
    
	[dateComponents setYear:2000];
	[dateComponents setMonth:8];
	[dateComponents setDay:15];
    NSDate *newDate = [calendar dateFromComponents:dateComponents];
    return newDate;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

# pragma mark delegate
-(void) checkForValidilityAndSetDelegate
{
    if(pickerMonth != 0 && pickerDay != 0)
    {
        // validate for leap year and date
        if([self helperDateExistsYear:pickerYear month:pickerMonth day:pickerDay] == TRUE)
        {
            [userSelectedDateDelegate setDate:pickerDay forMonth: pickerMonth forYear:pickerYear];
        }
    }
}

#pragma mark helper


-(BOOL) helperCheckLeapYear:(NSInteger)tmpyear
{
    // check for leap year
    if((tmpyear % 400) == 0)
        return TRUE;
    else if ((tmpyear % 100) == 0)
        return TRUE;
    else if ((tmpyear % 4) == 0)
        return TRUE;
    return FALSE;
}

-(BOOL) helperValidateDate:(NSDateComponents*) tmpPickerComponents
{
    // check for the number of days in a month
    int tmpmonth = [tmpPickerComponents month];
    int tmpdays = [tmpPickerComponents day];
    int tmpyear = [tmpPickerComponents year];
    
    switch (tmpmonth) {
            
        case 1:
        case 3:
        case 7: // august
        case 5:
        case 8:
        case 10:
        case 12:
            if(tmpdays < 32)
                return TRUE;
            // apr, jun, sep, nov
        case 4:
        case 6:
        case 9:
        case 11:
            if (tmpdays > 30)
                return FALSE;
            return TRUE;
            // feb
        case 2:
            // check for leap year
            if((tmpyear % 400) == 0)
            {
                // leap year
                if (tmpdays < 30) {
                    return TRUE;
                }
            }else if ((tmpyear % 100) == 0) {
                // leap year
                if (tmpdays < 30) {
                    return TRUE;
                }
            }else if ((tmpyear % 4) == 0) {
                // leap year
                if (tmpdays < 30) {
                    return TRUE;
                }
            }else {
                // not leap year
                if (tmpdays > 28) {
                    return FALSE;
                }
                return TRUE;
            }
        default:
            return FALSE;
    }
    return FALSE;
}

- (BOOL)helperDateExistsYear:(NSInteger)tmpyear month:(NSInteger)tmpmonth day:(NSInteger)tmpday
{
    // if user has no clue regarding the year
    if(tmpyear == maxYear)
    {
        // validate only the day and month
        switch (tmpmonth) {
            case 1:
            case 3:
            case 7: // august
            case 5:
            case 8:
            case 10:
            case 12:
                if(tmpday < 32)
                    return TRUE;
                // apr, jun, sep, nov
            case 4:
            case 6:
            case 9:
            case 11:
                if (tmpday < 31)
                    return TRUE;
            case 2:
                // feb
                if(tmpday < 30)
                    return TRUE;
            default:
                return FALSE;
        }
        
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *tmpdate = [NSDate date];
	NSDateComponents *dateComponents = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay ) fromDate:tmpdate];
	[dateComponents setYear:tmpyear];
	[dateComponents setMonth:tmpmonth];
	[dateComponents setDay:tmpday];
    // NSDate *date = [calendar dateFromComponents:dateComponents];
    // return nil != date; */
    
    return [self helperValidateDate:dateComponents];
}

-(void)helperRedoViewsBasedOnDates:(NSInteger)tmpRow forComponent:(NSInteger)tmpComponent forColor:(UIColor*) tmpColor
{
    // need to gray it
    UIView *tmpview = [self.datepicker viewForRow:tmpRow forComponent:tmpComponent];
    UILabel *tmplabel = (id)tmpview;
    if ([tmplabel.text isEqualToString:@"31"]) {
        if(tmplabel.textColor != tmpColor)
            tmplabel.textColor = tmpColor;
    }
}

-(void)helperRedoViewsBasedOnDates:(NSInteger)tmpRow forComponent:(NSInteger)tmpComponent forColor:(UIColor*) tmpColor forDays:(NSMutableArray*) tmpDays{
    for(int i=0; i<[tmpDays count]; i++) {
        NSString *tmpDay = [tmpDays objectAtIndex: i];
        [disabledRows addObject:tmpDay];
    }
    [self.datepicker reloadComponent:COMPONENT_DAY];
}

-(void)helperRedoViewsBasedOnColor:(NSInteger)tmpComponent forColor:(UIColor*) tmpColor{
    for (int cntr=0; cntr < NUMBER_OF_ROWS ; ++cntr) {
        // get the view and redo the view
        UIView *tmpview = [self.datepicker viewForRow:cntr forComponent:tmpComponent];
        UILabel *tmplabel = (id)tmpview;
        tmplabel.textColor = tmpColor;
    }
}

-(void)helperDisableRowsBasedOnDayMonthYear:(NSInteger)tmpComponent forRow:(NSInteger)tmpRow forColor:(UIColor*) tmpColor forDays:(NSInteger)tmpDays checkYear:(BOOL)tmpLeapYear checkFeb:(BOOL) tmpFeb {
    switch (tmpDays) {
        case 28:
            
            if(tmpFeb){
                
                // its feb
                if(tmpLeapYear && (pickerYear != maxYear + 1)){
                    // its a leap year
                    [disabledRows addObject:@"30"];
                    [disabledRows addObject:@"31"];
                }else{
                    // not a leap year
                    [disabledRows addObject:@"29"];
                    [disabledRows addObject:@"30"];
                    [disabledRows addObject:@"31"];
                }
            }
            break;
        case 1:
        case 2:
        case 29:
        case 30:
        case 31:
            if (tmpFeb) {
                // its feb
                if(tmpLeapYear)
                {
                    // its a leap year
                    [disabledRows addObject:@"30"];
                    [disabledRows addObject:@"31"];
                }else{
                    // not a leap year
                    [disabledRows addObject:@"29"];
                    [disabledRows addObject:@"30"];
                    [disabledRows addObject:@"31"];
                }
            }else {
                [disabledRows addObject:@"31"];
            }
            break;
    }
    [self.datepicker reloadComponent:COMPONENT_DAY];
    
}

-(void) helperSetLeapYearDays:(NSInteger)tmpComponent forDivisor:(NSInteger) tmpRowDivisor{
    [self helperValidateSelectedMonthAndDay];
    switch (pickerDay) {
        case 1:
        case 2:
            [self pickerViewLoaded:tmpRowDivisor forComponent:tmpComponent];
            [self helperDisableRowsBasedOnDayMonthYear:COMPONENT_DAY forRow:pickerSelectedRowDay forColor:[UIColor lightGrayColor] forDays:pickerDay checkYear:TRUE checkFeb:TRUE];
            break;
        case 28:
            [self helperDisableRowsBasedOnDayMonthYear:COMPONENT_DAY forRow:pickerSelectedRowDay forColor:[UIColor lightGrayColor] forDays:pickerDay checkYear:TRUE checkFeb:TRUE];
            break;
            
        case 29:
            // if its not a leap year we need to increment rows
            if([self helperCheckLeapYear:pickerYear] == FALSE)
            {
                if(pickerSelectedRowDay == 0)
                {
                    // this is the first time, user has selected this
                    // lets just add 91 more e.g. user changes to feb 29 from jan 29
                    // hacky fix to give the impression its a circular queue
                    pickerSelectedRowDay = pickerSelectedRowDay + 87;
                }
                // increment 2 rows
                [self.datepicker selectRow:pickerSelectedRowDay+3 inComponent:COMPONENT_DAY animated:FALSE];
                [self helperDisableRowsBasedOnDayMonthYear:COMPONENT_DAY forRow:pickerSelectedRowDay forColor:[UIColor lightGrayColor] forDays:pickerDay checkYear:FALSE checkFeb:TRUE];
                
                [self pickerViewLoaded:tmpRowDivisor forComponent:tmpComponent];
                
                // reset day to 1
                pickerDay = 1;
                pickerSelectedRowDay = pickerSelectedRowDay+3;
            }else {
                [self helperDisableRowsBasedOnDayMonthYear:COMPONENT_DAY forRow:pickerSelectedRowDay forColor:[UIColor lightGrayColor] forDays:pickerDay checkYear:TRUE checkFeb:TRUE];
                [self pickerViewLoaded:tmpRowDivisor forComponent:tmpComponent];
                
            }
            break;
            
        case 30:
            if(pickerSelectedRowDay == 0)
            {
                // this is the first time, user has selected this
                // lets just add 91 more e.g. user changes to feb 31 from jan 31
                // hacky fix to give the impression its a circular queue
                pickerSelectedRowDay = pickerSelectedRowDay + 90;
            }
            // increment 2 rows
            [self.datepicker selectRow:pickerSelectedRowDay+2
                           inComponent:COMPONENT_DAY animated:FALSE];
            [self helperDisableRowsBasedOnDayMonthYear:COMPONENT_DAY forRow:pickerSelectedRowDay forColor:[UIColor lightGrayColor] forDays:pickerDay checkYear:TRUE checkFeb:TRUE];
            [self pickerViewLoaded:tmpRowDivisor forComponent:tmpComponent];
            
            // reset day to 1
            pickerDay = 1;
            pickerSelectedRowDay = pickerSelectedRowDay+2;
            break;
            
        case 31:
            if(pickerSelectedRowDay == 0)
            {
                // this is the first time, user has selected this
                // lets just add 91 more e.g. user changes to feb 31 from jan 31
                // hacky fix to give the impression its a circular queue
                pickerSelectedRowDay = pickerSelectedRowDay + 93;
            }
            // increment 1 row
            [self.datepicker selectRow:pickerSelectedRowDay+1 inComponent:COMPONENT_DAY animated:FALSE];
            
            [self pickerViewLoaded:tmpRowDivisor forComponent:tmpComponent];
            [self helperDisableRowsBasedOnDayMonthYear:COMPONENT_DAY forRow:pickerSelectedRowDay forColor:[UIColor lightGrayColor] forDays:pickerDay checkYear:TRUE checkFeb:TRUE];
            // reset day to 1
            pickerDay = 1;
            pickerSelectedRowDay = pickerSelectedRowDay+1;
            break;
            
        default:
            break;
            
    }
    
    [self checkForValidilityAndSetDelegate];
}

// reusing this method to make the calendar component independent
- (NSString *) helperMonthNameForMonthNumber:(int)monthNumber {
    NSString *month = @"January";
    
    switch (monthNumber) {
        case 1:
            month = @"January";
            break;
            
        case 2:
            month = @"February";
            break;
            
        case 3:
            month = @"March";
            break;
            
        case 4:
            month = @"April";
            break;
            
        case 5:
            month = @"May";
            break;
            
        case 6:
            month = @"June";
            break;
            
        case 7:
            month = @"July";
            break;
            
        case 8:
            month = @"August";
            break;
            
        case 9:
            month = @"September";
            break;
            
        case 10:
            month = @"October";
            break;
            
        case 11:
            month = @"November";
            break;
            
        case 12:
            month = @"December";
            break;
            
        default:
            month = @"January";
            break;
    }
    
    return month;
}

// fast scrolling
-(void) helperValidateSelectedMonthAndDay
{
    // check if the rows is correctly set
    // need to gray it
    
    NSInteger tmpval = [self.datepicker selectedRowInComponent:0];
    UIView *tmpview = [self.datepicker viewForRow:tmpval forComponent:0];
    UILabel *tmplabel = (id)tmpview;
    
    // select the month needed by the user
    if (![tmplabel.text isEqualToString:[self helperMonthNameForMonthNumber:pickerMonth]]) {
        // set the year to what the date component is pointing to
        NSInteger tmpindex = [months indexOfObject:tmplabel.text];
        if(tmpindex != NSNotFound)
            // displayed month, is not equal to whats shown in the global pickerMonth
            // this issues happens when the components are scrolled very fast
            pickerMonth = tmpindex+1;
    }
    
    // check if the selected day is equal to the text label
    tmpval = [self.datepicker selectedRowInComponent:1];
    tmpview = [self.datepicker viewForRow:tmpval forComponent:1];
    tmplabel = (id)tmpview;
    
    // select the day needed by the user
    if (![tmplabel.text isEqualToString:[NSString stringWithFormat:@"%d", pickerDay]]) {
        // set the year to what the date component is pointing to
        pickerDay = [tmplabel.text intValue];
    }
    
    // check if the selected day is equal to the text label
    tmpval = [self.datepicker selectedRowInComponent:2];
    tmpview = [self.datepicker viewForRow:tmpval forComponent:2];
    tmplabel = (id)tmpview;
    
    // select the year needed by the user
    if (![tmplabel.text isEqualToString:[NSString stringWithFormat:@"%d", pickerYear]]) {
        if([tmplabel.text isEqualToString:DASHDASH])
        {
            // set picker year to current year + 1, i.e. no clue
            pickerYear = [ currentDate year] + 1;
        }else {
            // set the year to what the date component is pointing to
            pickerYear = [tmplabel.text intValue];
        }
    }
}

-(void) helperSelectDaysAndMonth:(BOOL) tmpCheckMonth
{
    [self helperValidateSelectedMonthAndDay];
    switch (pickerMonth) {
        case 4: // apr
        case 6: // jun
        case 9: // sep
        case 11: // nov
            
            if(pickerDay > 30)
            {
                // this check needed only for months
                if(tmpCheckMonth){
                    
                    if(pickerSelectedRowDay == 0)
                    {
                        // this is the first time user has opened the calendar for edition
                        // e.g. jan 31 user changes to feb 1
                        // e.g. Oct 31 user changes to nov 1
                        // we don't want any blank queues
                        // hacky fix to give the impression its a circular queue
                        pickerSelectedRowDay = pickerSelectedRowDay + 92;
                    }
                }
                
                // select the picker day
                [self.datepicker selectRow:pickerSelectedRowDay+1 inComponent:COMPONENT_DAY animated:FALSE];
                
                // disable the row and reset it to gray
                [self helperDisableRowsBasedOnDayMonthYear:COMPONENT_DAY forRow:pickerSelectedRowDay forColor:[UIColor lightGrayColor] forDays:pickerDay checkYear:FALSE checkFeb:FALSE];
                
                // check for month or day
                if(tmpCheckMonth)
                    // select the row for months
                    [self pickerViewLoaded:12 forComponent:COMPONENT_MONTH];
                else {
                    [self pickerViewLoaded:31 forComponent:COMPONENT_DAY];
                }
                
                // reset day to 1
                // reset the wheel to 1
                pickerDay = 1;
                pickerSelectedRowDay = pickerSelectedRowDay+1;
            }else if(pickerDay == 1 || pickerDay ==2 || pickerDay == 30 || pickerDay == 29){
                
                
                if(tmpCheckMonth)
                {
                    // select the row for months
                    [self pickerViewLoaded:12 forComponent:COMPONENT_MONTH];
                }else {
                    [self.datepicker selectRow:pickerSelectedRowDay inComponent:COMPONENT_DAY animated:FALSE];
                }
                
                [self helperDisableRowsBasedOnDayMonthYear:COMPONENT_DAY forRow:pickerSelectedRowDay forColor:[UIColor lightGrayColor] forDays:pickerDay checkYear:FALSE checkFeb:FALSE];
                
            }else {
                if(tmpCheckMonth == FALSE)
                {
                    // for days 1 - 28
                    [self.datepicker selectRow:pickerSelectedRowDay inComponent:COMPONENT_DAY animated:FALSE];
                }
            }
            
            if(tmpCheckMonth == FALSE)
                [self pickerViewLoaded:31 forComponent:COMPONENT_DAY];
            
            // we can return here successfully
            [self checkForValidilityAndSetDelegate];
            break;
            
        case 2:
            // handle february separately
            if(tmpCheckMonth)
                [self helperSetLeapYearDays:COMPONENT_MONTH forDivisor:12];
            else {
                [self helperSetLeapYearDays:COMPONENT_DAY forDivisor:31];
            }
            break;
        default:
            if(tmpCheckMonth)
                [self helperRedoViewsBasedOnColor:COMPONENT_DAY forColor:[UIColor blackColor]];
            break;
    }
    
}

@end

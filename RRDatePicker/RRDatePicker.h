
/**
 * RRDatePicker 
 * ------------------------
 *
 * This component is similar to the apple date picker component. This has been implemented
 * using a UIView and UIPickerView. We went this approach because we wanted the ability to
 * custom data source e.g. no clue. 
 * To receive the date set by the user, you would need to implement the setDate delegate in 
 * your source.
 * 
 * If you dont plan on using the delegate you can use the getter/setter methods to set and get
 * the date from the UIPickerView.
 *
 * Some of the code can be modularised even more, but I have kept it this way, since its easy to
 * read and going forward if we find any test case ( there are tons of combinations possible for dates )
 * we can fix this easily, as per the test case.
 * 
 * EXAMPLE USAGE
 * -------------
 * Note: All of the following example code assumes that it is being called from within another UIView.
 *
 * RRDatePicker *tpd = [[RRDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.frame.size.width, TP_CALENDARVIEW_HEIGHT):tempDate];
 * [[self view] addSubview:tpd];
 * tpd.userSelectedDateDelegate = self;
 *
 */

#import <UIKit/UIKit.h>
#define COMPONENT_MONTH_WIDTH   140
#define COMPONENT_DAY_WIDTH     43
#define COMPONENT_YEAR_WIDTH    78
#define COMPONENT_FONT_SIZE     24
#define COMPONENT_FONT          @"Arial-BoldMT"
#define COMPONENT_MONTH         0
#define COMPONENT_DAY           1
#define COMPONENT_YEAR          2
#define NUMBER_OF_ROWS          16384
#define MIN_YEAR                1892
#define DASHDASH                @"No Clue"

@protocol RRDatePickerDelegate <NSObject>
// method to set the date given by the user
-(void)setDate:(NSInteger)day forMonth: (NSInteger)month forYear: (NSInteger)year;
@end

@interface RRDatePicker : UIView<UIPickerViewDelegate, UIPickerViewDataSource>
{
    // stores the difference in years between 1892 and current year
    NSInteger diffyears;
    UIPickerView *datepicker;
    
    // data source for months and days
    NSMutableArray *months;
    NSMutableArray *days;
    
    // delegate to notify when the user sets the date
    id <RRDatePickerDelegate> __weak userSelectedDateDelegate;
    
    // variables to check if the user has
    // explcitly clicked any date.
    NSInteger pickerYear;
    NSInteger pickerMonth;
    NSInteger pickerDay;
    
    // the rows selected by the user
    NSInteger pickerSelectedRowDay;
    NSInteger pickerSelectedRowYear;

    // variable exclusively related to the picker view
    // when user selects a day, month and year
    NSDate *pickerDate;
    NSCalendar *pickerCalendar;
    NSDateComponents *pickerDateComponents;
    
    // variable to check if picker year has been set or not
    NSInteger maxYear;
    
    // variable to store the color
    UIColor *rowTextColor;
    
    // array to store the disabled days
    NSMutableArray *disabledRows;
    NSDateComponents *currentDate;
    
    // variable to store the date format
    NSString *dateformat;
}

@property (nonatomic, strong) UIPickerView *datepicker;
@property (nonatomic, weak) id <RRDatePickerDelegate> userSelectedDateDelegate;

/**
 * initial method to setup the data and disabled rows
 */
-(void) setup;
/**
 * Rewrite all the views/rows in a component with blackColor
 * @param tmpComponent
 *          component to recolor
 * @param tmpColor
 *          color 
 */
-(void)helperRedoViewsBasedOnColor:(NSInteger)tmpComponent forColor:(UIColor*) tmpColor;
/**
 * Rewrite all the views/rows in a component with color based on a row and component
 * @param tmpComponent
 *          component to recolor
 * @param tmpColor
 *          color 
 */
-(void)helperRedoViewsBasedOnDates:(NSInteger)tmpRow forComponent:(NSInteger)tmpComponent forColor:(UIColor*) tmpColor;

/**
 * sets the date format
 * @param tmpFormat
 */
-(void) setDateFormat:(NSString*)tmpFormat;
/**
 * will return the date format set by the user
 * @return return date format
 */
-(NSString*) getDateFormat;

/**
 * method to initialize the uiview with just the frame dimensions
 */
- (id)initWithFrame:(CGRect)frame;

/**
 * method to initialize the frame with year, month and day
 * @param tmpYear
 * @param tmpMonth
 * @param tmpDay
 * @param set this to nil, if you don't know. default format is "yyyy-MM-dd"
 */
-(id)initWithFrame:(CGRect)frame forYear:(NSString*)tmpYear forMonth:(NSString*)tmpMonth forDay:(NSString*)tmpDay forDateFormat:(NSString*)tmpDateFormat;

/**
 * checks for leap year and the days in the month of feb
 * given the component and number of rows divisor
 * @param tmpComponent component
 * @param tmpRowDivisor 12 or 31 based on the component
 */
-(void) helperSetLeapYearDays:(NSInteger)tmpComponent forDivisor:(NSInteger) tmpRowDivisor;
/**
 * sets the difference between current year and MIN_YEAR
 */
-(void) helperSetDiffYears;
/**
 * set the uipickerview to current date
 * @param tmpdate
 *          date specified by the user
 */
-(void) initDatePickerToCurrentDate;
/**
 * set the uipickerview to date
 * @param tmpdate
 *          date specified by the user
 */
-(void) setPickerDate:(NSDate*) tmpdate;

/**
 * will return the date currently on the picker
 * will return nil, incase of invalid dates
 * user needs to check for invalid dates
 * @return date returned by the user
 */
-(NSDate*) getPickerDate;
/*
 * setup the data values needed for UIPicker
 * sets the days and months for UIPicker
 */
-(void) setupDatavalueForPicker;
/**
 * Check if a year is a leap year or not
 * @param tmpYear
 *          input year to check for leap year
 */
-(BOOL) helperCheckLeapYear:(NSInteger)tmpyear;
/**
 * Helper method to validate date. Check for the months and handle leap year issues
 * @param tmpPickerComponents input with NSDataComponents given by the user
 * @return TRUE/FALSE based on the date validity
 */
-(BOOL) helperValidateDate:(NSDateComponents*) tmpPickerComponents;
/**
 * check if the date is valid
 * @param year
 * @param month
 * @param day
 * @return true/false
 */

- (BOOL)helperDateExistsYear:(NSInteger)tmpyear month:(NSInteger)tmpmonth day:(NSInteger)tmpday;
/**
 * method to check for validity of a given date
 * and set the delegate. This method also handles the "no clue" value 
 * when year has not been set by the user or not available
 */
-(void) checkForValidilityAndSetDelegate;
/** 
 * will select the row based on the inputs provided for a picker view
 * @param divisor based on the component, 12 - months 31 - days 
 * @param tmpComponent input the component
 */
-(void)pickerViewLoaded: (NSInteger)divisor forComponent:(NSInteger)tmpComponent;
/** 
 * will set the row based on the inputs provided for a picker view
 * @param divisor based on the component, 12 - months 31 - days 
 * @param tmpComponent input the component
 */
-(NSInteger)pickerViewLoadedReturnRow: (NSInteger)divisor forComponent:(NSInteger)tmpComponent;
/**
 * method to add the number of days to the global disable array to disable/gray depending on the leap year, day and month
 * @param tmcomponent
 * @param tmprow
 * @param tmpColor
 * @param tmpDays       will specify the day 30, 31, 1, 2
 * @param tmpLeapYear   will be set if its a leap year true/false
 * @param tmpFeb        will be set if its february true/false
 */
-(void)helperDisableRowsBasedOnDayMonthYear:(NSInteger)tmpComponent forRow:(NSInteger)tmpRow forColor:(UIColor*) tmpColor forDays:(NSInteger)tmpDays checkYear:(BOOL)tmpLeapYear checkFeb:(BOOL) tmpFeb;
/**
 * This is the most important method in the entire class. It handles the logic for selecting and 
 * displaying the months, year and days based on the user selection. We handle the user selections based on the components
 * for month, year and days. For e.g. if a user selects an invalid date Feb 29, 2011, we automatically set the date to Feb 1st 2011. Once the date has been validated the delegated it called out.  
 * As per the component, we add the days to gray/disable in a array and then reload the views associated 
 * with that component.
 * @param row selected row
 * @param component selected component
 */

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
/**
 * will set the months and days if the days contain 30 days
 * @param tmpCheckMonth     variable to see if its a day or month component
 */
-(void) helperSelectDaysAndMonth:(BOOL) tmpCheckMonth;
/**
 * will return the month name given a month number
 * @param monthNumber 
 * @return monthNumber as a string
 */
- (NSString *) helperMonthNameForMonthNumber:(int)monthNumber;
/**
 * method to verify if the date displayed in the gui is the same
 * as the variable set by the code .. pickerDay, pickerMonth
 */
-(void) helperValidateSelectedMonthAndDay;
@end

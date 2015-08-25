//
//  DJDatePickerView.m
//
//  Created by Lihaifeng on 11-11-22, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import "IDJDatePickerView.h"
#import "IDJCalendarUtil.h"


@interface IDJDatePickerView (Private)
- (void)_setYears;
- (void)_setMonthsInYear:(NSUInteger)_year;
- (void)_setDaysInMonth:(NSString *)_month year:(NSUInteger)_year;
- (void)changeMonths;
- (void)changeDays;

@end

@implementation IDJDatePickerView
@synthesize delegate;

#pragma mark -init method-
- (id)initWithFrame:(CGRect)frame type:(int)_type offset:(CGFloat)height displayDate:(NSDate *)displayDete;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // pickerview 和 toolBar 放到一个view上面
        UIView *view = [[UIView alloc] initWithFrame:self.frame]; // 外部设置frame
        
        // 解决 ：服务器返回错误数据时候，超出范围导致的崩溃问题
        int currentY = [[[NSDate new]stringFromDateY:displayDete] intValue];
        if (currentY >= 1901 && currentY <= 2049) {
            _showDate = displayDete;
        }else{
            _showDate = [NSDate date];
        }
        
        type=_type;
        if (type==Gregorian1) {
            cal=[[IDJCalendar alloc]initWithYearStart:YEAR_START end:YEAR_END displayDate:_showDate];
        } else {
            cal=[[IDJChineseCalendar alloc]initWithYearStart:YEAR_START end:YEAR_END displayDate:_showDate];
        }
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
        
        [self _setYears];
        [self _setMonthsInYear:[cal.year intValue]];
        [self _setDaysInMonth:cal.month year:[cal.year intValue]];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        // 透明关闭按钮
        closeButton.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - PICKER_HEIGHT - height);
        [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        // 定义toolBar位置大小背景色
        UIToolbar *toolBar =[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - PICKER_HEIGHT - height, self.bounds.size.width, TOOLBAR_HEIGHT)];
        toolBar.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        // segment
        NSArray *segmentItems = [NSArray arrayWithObjects:@"公历",@"农历", nil];
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:segmentItems];
        segment.frame = CGRectMake(SEGMENT_X, SEGMENT_Y, SEGMENT_WIDTH, TOOLBAR_HEIGHT- 2*SEGMENT_Y);
        
        // 根据是否农历显示
        if (type == Chinese1) {
            segment.selectedSegmentIndex = 1;
        }else{
            segment.selectedSegmentIndex = 0;
        }
        
        
        // 添加事件
        [segment addTarget:self action:@selector(chinese_Gregorian1:) forControlEvents:UIControlEventValueChanged];
        
        // 自定义按钮
        UIBarButtonItem *sureButton  = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target: self action: @selector(sureAction:)];
        
        UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
        NSArray *array = [[NSArray alloc] initWithObjects:fixedButton,fixedButton,sureButton, nil];
        [toolBar setItems:array];
        [toolBar addSubview:segment];
        
        // view
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - PICKER_HEIGHT -height+TOOLBAR_HEIGHT, view.bounds.size.width, PICKER_HEIGHT - TOOLBAR_HEIGHT)];
        picker.backgroundColor = [UIColor colorWithWhite:0.965 alpha:1.000];
        
        // 代理
        picker.delegate = self;
        picker.dataSource = self;
        
        
        //程序启动后，我们需要让三个滚轮显示为当前的日期
        if (type==Gregorian1) {
            
            [picker selectRow:[years indexOfObject:cal.year] inComponent:0 animated:YES];
            [picker selectRow:[months indexOfObject:cal.month] inComponent:1 animated:YES];
            [picker selectRow:[days indexOfObject:cal.day] inComponent:2 animated:YES];
            
        } else if (type==Chinese1) {
            
            [picker selectRow:[years indexOfObject:[NSString stringWithFormat:@"%@-%@-%@", cal.era, ((IDJChineseCalendar *)cal).jiazi, cal.year]] inComponent:0 animated:YES];
            [picker selectRow:[months indexOfObject:cal.month] inComponent:1 animated:YES];
            [picker selectRow:[days indexOfObject:cal.day] inComponent:2 animated:YES];
        }
        
        // 通知方法
        [delegate notifyNewCalendar:cal];
        
        
        [view addSubview:toolBar];
        [view addSubview:picker];
        
        
        //添加下滑关闭手势
        UITapGestureRecognizer *swipe = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandler:)];
        swipe.numberOfTouchesRequired = 1;
        swipe.numberOfTapsRequired = 1;
        [self addGestureRecognizer:swipe];
        
        // 添加所有
        [self addSubview:view];
//        view.alpha = 0;
//        // 设置动画
//        [UIView animateWithDuration:0.4 animations:^{
//            view.alpha = 1;
//        }];
        
    }
    return self;
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)swipe
{
    // 获取值 确保不选择也显示值
    [delegate notifyNewCalendar:cal];
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
}

//  关闭按钮
- (void)closeButtonClicked:(id)sender
{
    // 获取值 确保不选择也显示值
    [delegate notifyNewCalendar:cal];
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
}

- (void)sureAction:(id)sender
{
    // 获取值 确保不选择也显示值
    [delegate notifyNewCalendar:cal];
    // 关闭pickerView
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
}



// 公农历转换
- (void)chinese_Gregorian1:(id)sender
{
    // 获取值 确保不选择也显示值
    [delegate notifyNewCalendar:cal];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSDate *minDate = [[NSDate new] dateFromString:@"1901-01-01"];
    NSDate *maxDate = [[NSDate new] dateFromString:@"2050-01-01"];
    if ([NSDate compareOneDay:_appDelegate.changeDate withAnotherDay:minDate]<0 || [NSDate compareOneDay:_appDelegate.changeDate withAnotherDay:maxDate]>=0) {
        TTAlert(@"转换数据超出范围");
        return;
    }
    
    // 切换公历农历
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    if (segment.selectedSegmentIndex == 0) { // 公历
        // 刷新pickerView
        if (type == Gregorian1) {
            return;
        }
        type = Gregorian1;
        cal=[[IDJCalendar alloc]initWithYearStart:YEAR_START end:YEAR_END displayDate:self.appDelegate.changeDate];

        
    }else { // 农历
        if (type == Chinese1) {
            return;
        }
        // 刷新
        type = Chinese1;
        cal=[[IDJChineseCalendar alloc]initWithYearStart:YEAR_START end:YEAR_END displayDate:self.appDelegate.changeDate];

    }
    

    
    [self _setYears];
    [self _setMonthsInYear:[cal.year intValue]];
    [self _setDaysInMonth:cal.month year:[cal.year intValue]];
    
    
    //程序启动后，我们需要让三个滚轮显示为当前的日期
    if (type==Gregorian1) {
        
        [picker selectRow:[years indexOfObject:cal.year] inComponent:0 animated:YES];
        [picker selectRow:[months indexOfObject:cal.month] inComponent:1 animated:YES];
        [picker selectRow:[days indexOfObject:cal.day] inComponent:2 animated:YES];
        
    } else if (type==Chinese1) {
        
        [picker selectRow:[years indexOfObject:[NSString stringWithFormat:@"%@-%@-%@", cal.era, ((IDJChineseCalendar *)cal).jiazi, cal.year]] inComponent:0 animated:YES];
        [picker selectRow:[months indexOfObject:cal.month] inComponent:1 animated:YES];
        [picker selectRow:[days indexOfObject:cal.day] inComponent:2 animated:YES];
    }
    
    // 刷新
    [picker reloadAllComponents];
}

#pragma mark - pickerView delegate method

// pickerview 的列数
// UIPickerViewDataSource中定义的方法，该方法返回值决定该控件包含多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // 是否忽略年份
    return 3;
    
}

// 每列的数量 区分是否去掉年份
// UIPickerViewDataSource中定义的方法，该方法返回值决定该控件指定列包含多少个列表项
// 为了实现类似循环滚动的效果 都乘以10
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if (0 == component) {
        return years.count * YEAR_LOOP; // 为了循环
    }else if (1 == component){
        return months.count * MONTH_LOOP;
    }else if (2 == component) {
        return days.count * DAY_LOOP;
    }else {
        return 0;
    }
}


// 设置每个cell的宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    
    if (type == Chinese1) {
        switch (component) {
            case 0:
                return self.bounds.size.width * 3/8;
                break;
            case 1:
                return self.bounds.size.width * 2/8;
                break;
            case 2:
                return self.bounds.size.width * 3/8;
                break;
            default:
                return 0;
                break;
        }
    }else {
        switch (component) {
            case 0:
                return self.bounds.size.width * 3/8;
                break;
            case 1:
                return self.bounds.size.width * 2/8;
                break;
            case 2:
                return self.bounds.size.width * 3/8;
                break;
            default:
                return 0;
                break;
        }
    }
    
}


//为指定滚轮上的指定位置的Cell设置内容
// cell上得显示 区分公农历，区分是否去掉
// UIPickerViewDelegate中定义的方法，该方法返回的NSString将作为UIPickerView
// 中指定列、指定列表项的标题文本
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    // 设置个string，用来返回
    NSString *dateAlvin = [[NSString alloc]init];
    
    switch (component) {
        case 0:{
            NSString *str=[years objectAtIndex:row];
            if (type==Chinese1) {
                NSArray *array=[str componentsSeparatedByString:@"-"];
                str=[NSString stringWithFormat:@"%@(%@年)", [array objectAtIndex:2],[((IDJChineseCalendar *)cal).chineseYears objectAtIndex:[[array objectAtIndex:1]intValue]-1]];
                dateAlvin = str;
            }else{
                dateAlvin = [NSString stringWithFormat:@"%@%@", str,@"年"]; // 滚轮1最终显示
            }
            return dateAlvin;
            break;
        }
        case 1:{
            NSString *str=[NSString stringWithFormat:@"%@", [months objectAtIndex:row]];
            if (type==Chinese1) {
                NSArray *array=[str componentsSeparatedByString:@"-"];
                if ([[array objectAtIndex:0]isEqualToString:@"a"]) {
                    dateAlvin=[((IDJChineseCalendar *)cal).chineseMonths objectAtIndex:[[array objectAtIndex:1]intValue]-1];
                } else {
                    dateAlvin=[NSString stringWithFormat:@"%@%@", @"闰", [((IDJChineseCalendar *)cal).chineseMonths objectAtIndex:[[array objectAtIndex:1]intValue]-1]];
                }
            } else {
                dateAlvin=[NSString stringWithFormat:@"%@%@", str, @"月"];
            }
            return dateAlvin;
            break;
        }
        case 2:{
            if (type==Gregorian1) {
                int day=[[days objectAtIndex:row]intValue];
                int weekday=[IDJCalendarUtil weekDayWithSolarYear:[cal.year intValue] month:cal.month day:day];
                dateAlvin=[NSString stringWithFormat:@"%d  %@", day, [cal.weekdays objectAtIndex:weekday]];
            } else {
                NSString *jieqi=[[IDJCalendarUtil jieqiWithYear:[cal.year intValue]]objectForKey:[NSString stringWithFormat:@"%@-%d", cal.month, [[days objectAtIndex:row]intValue]]];
                if (!jieqi) {
                    dateAlvin=[NSString stringWithFormat:@"%@", [((IDJChineseCalendar *)cal).chineseDays objectAtIndex:[[days objectAtIndex:row]intValue]-1]];
                } else {
                    //NSLog(@"%@-%d-%@", cal.month, [[days objectAtIndex:cell]intValue], jieqi);
                    dateAlvin=[NSString stringWithFormat:@"%@(%@)", [((IDJChineseCalendar *)cal).chineseDays objectAtIndex:[[days objectAtIndex:row]intValue]-1],jieqi];
                }
            }
            return dateAlvin;
            break;
        }
        default:
            break;
    }
    return dateAlvin;
}

//设置选中条的位置
- (NSUInteger)selectionPosition {
    return 1;
}

// 选中之后的方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:{
            NSString *str=[years objectAtIndex:row];
            if (type==Chinese1) {
                NSArray *array=[str componentsSeparatedByString:@"-"];
                str=[array objectAtIndex:2];
                NSString *pYear=[cal.year copy];
                cal.era=[array objectAtIndex:0];
                ((IDJChineseCalendar *)cal).jiazi=[array objectAtIndex:1];
                cal.year=str;
                //因为用户可能从2011年滚动，最后放手的时候，滚回了2011年，所以需要判断与上一次选中的年份是否不同，再联动月份的滚轮
                if (![pYear isEqualToString:cal.year]) {
                    [self changeMonths];
                }
            } else {
                cal.year=str;
                //因为公历的每年都是12个月，所以当年份变化的时候，只需要后面的天数联动
                [self changeDays];
            }
            break;
        }
        case 1:{
            NSString *pMonth=[cal.month copy];
            NSString *str=[months objectAtIndex:row];
            cal.month=str;
            if (![pMonth isEqualToString:cal.month]) {
                //联动天数的滚轮
                [self changeDays];
            }
            break;
        }
        case 2:{
            cal.day=[days objectAtIndex:row];
            break;
        }
        default:
            break;
    }
    
    if (type==Gregorian1) {
        cal.weekday=[NSString stringWithFormat:@"%d", [IDJCalendarUtil weekDayWithSolarYear:[cal.year intValue] month:cal.month day:[cal.day intValue]]];
    } else {
        cal.weekday=[NSString stringWithFormat:@"%d", [IDJCalendarUtil weekDayWithChineseYear:[cal.year intValue] month:cal.month day:[cal.day intValue]]];
        ((IDJChineseCalendar *)cal).animal=[IDJCalendarUtil animalWithJiazi:[((IDJChineseCalendar *)cal).jiazi intValue]];
    }
    
    
    // 切换数据的时候保存，保证公农历切换的时候时间是一致的
    if ([cal isMemberOfClass:[IDJCalendar class]]) {

//        _showDate = [[NSDate new] dateFromStringYMD:[NSString stringWithFormat:@"%@年%02d月%02d日",cal.year,[cal.month intValue],[cal.day intValue]]];
//        _showDate = [NSDate date];

    } else if ([cal isMemberOfClass:[IDJChineseCalendar class]]) {
//        IDJChineseCalendar *_cal=(IDJChineseCalendar *)cal;

//        NSDateComponents *dateCom = [IDJCalendarUtil toSolarDateWithYear:[cal.year intValue] month:cal.month day:[cal.day intValue]];
//        _showDate = [[NSDate new] dateFromStringYMD:[NSString stringWithFormat:@"%d年%02d月%02d日",dateCom.year,dateCom.month,dateCom.day]];
//        _showDate = [NSDate date];
    }

    
    [delegate notifyNewCalendar:cal];
}

// 修改cell字体
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //创建属性字典
    NSDictionary *attrDict = @{ NSFontAttributeName:[UIFont systemFontOfSize:13],
                                NSForegroundColorAttributeName: [UIColor blackColor] };
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:[self pickerView:pickerView titleForRow:row forComponent:component] attributes:attrDict];
    
    UILabel *label = [[UILabel alloc] init];
    label.attributedText = att;
    label.textAlignment = 1;
    
    return label;
}

#pragma mark -Calendar Data Handle-
//动态改变农历月份列表，因为公历的月份只有12个月，不需要跟随年份滚轮联动
- (void)changeMonths{
    if (type==Chinese1) {
        [self _setMonthsInYear:[cal.year intValue]];
        [picker reloadComponent:1];
        long int cell=[months indexOfObject:cal.month];
        if (cell==NSNotFound) {
            cell=0;
            cal.month=[months objectAtIndex:0];
        }
        [picker selectRow:cell inComponent:1 animated:YES];
        //月份改变之后，天数进行联动
        [self changeDays];
    }
}

//动态改变日期列表
- (void)changeDays{
    [self _setDaysInMonth:cal.month year:[cal.year intValue]];
    [picker reloadComponent:2];
    long int cell=[days indexOfObject:cal.day];
    //假如用户上次选择的是1月31日，当月份变为2月的时候，第三列的滚轮不可能再选中31日，我们设置默认的值为第一个。
    if (cell==NSNotFound) {
        cell=0;
        cal.day=[days objectAtIndex:0];
    }
    [picker selectRow:cell inComponent:2 animated:YES];
}

#pragma mark -Fill init Data-
//填充年份
- (void)_setYears {
    [years release];
    years=[[cal yearsInRange]retain];
}

//填充月份
- (void)_setMonthsInYear:(NSUInteger)_year {
    [months release];
    months=[[cal monthsInYear:_year]retain];
}

//填充天数
- (void)_setDaysInMonth:(NSString *)_month year:(NSUInteger)_year {
    [days release];
    days=[[cal daysInMonth:_month year:_year]retain];
}

#pragma mark -dealloc-
- (void)dealloc{
    [years release];
    [months release];
    [days release];
    [cal release];
    [picker release];
    [super dealloc];
}

@end

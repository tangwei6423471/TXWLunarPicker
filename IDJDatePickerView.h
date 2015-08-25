//
//  日期选择器的视图类
//  IDJDatePickerView.h
//
//  Created by Lihaifeng on 11-11-22, QQ:61673110.
//  Copyright (c) 2011年 www.idianjing.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDJChineseCalendar.h"
//#import "IDJPickerView.h"
#import "AppDelegate.h"
#define YEAR_START 1901//滚轮显示的起始年份
#define YEAR_END 2049//滚轮显示的结束年份

// 手动设置循环的宏-倍数 规则是年月日row数量一致
#define YEAR_LOOP 1
#define MONTH_LOOP 1
#define DAY_LOOP 1

// 联动的row基数，避免会挑到row 0
#define CHANG_BASE_ROWS 0

// toolBar
#define TOOLBAR_HEIGHT 34
#define SEGMENT_WIDTH 80

#define SEGMENT_X 5
#define SEGMENT_Y 6

#define PICKER_HEIGHT 260

@protocol IDJDatePickerViewDelegate;

//日历显示的类型
enum calendarType {
    Gregorian1=1,
    Chinese1
};

@interface IDJDatePickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>{
    int type;
    NSMutableArray *years;//第一列的数据容器
    NSMutableArray *months;//第二列的数据容器
    NSMutableArray *days;//第三列的数据容器
    IDJCalendar *cal;//日期类
    UIPickerView *picker;
    id<IDJDatePickerViewDelegate> delegate;
}
@property (nonatomic, assign) id<IDJDatePickerViewDelegate> delegate;
@property (nonatomic ,strong) NSDate *showDate;
@property (strong, nonatomic) AppDelegate *appDelegate;
- (id)initWithFrame:(CGRect)frame type:(int)_type offset:(CGFloat)height displayDate:(NSDate *)displayDete;
@end

@protocol IDJDatePickerViewDelegate <NSObject>
//通知使用这个控件的类，用户选取的日期
- (void)notifyNewCalendar:(IDJCalendar *)cal;
@end

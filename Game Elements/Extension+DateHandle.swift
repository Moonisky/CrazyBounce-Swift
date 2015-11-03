//
//  Extension+DateHandle.swift
//  日期类扩展
//
//  Created by Semper Idem on 15-11-7.
//  Copyright (c) 2015年 益行人-星夜暮晨. All rights reserved.
//

import Foundation

let D_SECOND = 1
let D_MINUTE = 60
let D_HOUR = 3600
let D_DAY = 86400
let D_WEEK = 604800
let D_YEAR = 31556926

// MARK: String方法转换

public extension String {
    
    /// 根据相应的日期格式化字符将当前日期转换为NSDate，如果转换不成功返回nil
    func toDate(formatString withFormatString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = withFormatString
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter.dateFromString(self)
    }
}

// MARK: 访问日期组成元素

public extension NSDate {
    
    /// 获取年
    var year : Int			{ return components.year }
    /// 获取月
    var month : Int			{ return components.month }
    /// 获取本月周数
    var weekOfMonth: Int	{ return components.weekOfMonth }
    /// 获取本年周数
    var weekOfYear: Int		{ return components.weekOfYear }
    /// 获取当前日期是星期几
    var weekday: Int		{
        let cur = components.weekday - 1
        if cur == 0 {
            return 7
        }
        return cur
    }
    /// 获取当前日期是本月的第几个星期几
    var weekdayOrdinal: Int	{ return components.weekdayOrdinal }
    /// 获取日
    var day: Int			{ return components.day }
    /// 获取时钟
    var hour: Int			{ return components.hour }
    /// 获取分钟
    var minute: Int			{ return components.minute }
    /// 获取秒钟
    var second: Int			{ return components.second }
    // Get the era component of the date
    var era: Int			{ return components.era }
    // Get the current month name based upon current locale
    var monthName: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.autoupdatingCurrentLocale()
        return dateFormatter.monthSymbols[month - 1]
    }
    // Get the current weekday name
    var weekdayName: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.autoupdatingCurrentLocale()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter.stringFromDate(self)
    }
    
    private func firstWeekDate()-> (date : NSDate!, interval: NSTimeInterval) {
        // Sunday 1, Monday 2, Tuesday 3, Wednesday 4, Friday 5, Saturday 6
        let calendar = NSCalendar.currentCalendar()
        calendar.firstWeekday = NSCalendar.currentCalendar().firstWeekday
        var startWeek: NSDate? = nil
        var duration: NSTimeInterval = 0
        
        calendar.rangeOfUnit(NSCalendarUnit.WeekOfYear, startDate: &startWeek, interval: &duration, forDate: self)
        return (startWeek,duration)
    }
    
    /// Return the first day of the current date's week
    var firstDayOfWeek : Int {
        let (date,_) = self.firstWeekDate()
        return (date+1.day).day
    }
    
    /// Return the last day of the week
    var lastDayOfWeek : Int {
        let (startWeek,interval) = self.firstWeekDate()
        let endWeek = startWeek?.dateByAddingTimeInterval(interval-1)
        return (endWeek!+1.day).day
    }
}

// MARK: 日期组成元素创建及操控

public extension NSDate {
    
    /**
    Create a new NSDate instance from passed string with given format
    
    - parameter string: date as string
    - parameter format: parse formate.
    
    - returns: a new instance of the string
    */
    class func date(fromString string: String, format: String) -> NSDate? {
        if string.isEmpty {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(string)
    }
    
    /**
    Create a new NSDate instance based on refDate (if nil uses current date) and set components
    
    - parameter refDate: reference date instance (nil to use NSDate())
    - parameter year:    year component (nil to leave it untouched)
    - parameter month:   month component (nil to leave it untouched)
    - parameter day:     day component (nil to leave it untouched)
    - parameter tz:      time zone component (it's the abbreviation of NSTimeZone, like 'UTC' or 'GMT+2', nil to use current time zone)
    
    - returns: a new NSDate with components changed according to passed params
    */
    class func date(refDate refDate: NSDate?, year: Int?, month: Int?, day: Int?, tz: String?) -> NSDate {
        let referenceDate = refDate ?? NSDate()
        return referenceDate.set(year: year, month: month, day: day, hour: 0, minute: 0, second: 0, tz: tz)
    }
    
    /**
    Create a new NSDate instance based on refDate (if nil uses current date) and set components
    
    - parameter refDate: reference date instance (nil to use NSDate())
    - parameter year:    year component (nil to leave it untouched)
    - parameter month:   month component (nil to leave it untouched)
    - parameter day:     day component (nil to leave it untouched)
    - parameter hour:    hour component (nil to leave it untouched)
    - parameter minute:  minute component (nil to leave it untouched)
    - parameter second:  second component (nil to leave it untouched)
    - parameter tz:      time zone component (it's the abbreviation of NSTimeZone, like 'UTC' or 'GMT+2', nil to use current time zone)
    
    - returns: a new NSDate with components changed according to passed params
    */
    class func date(refDate refDate: NSDate?, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, tz: String?) -> NSDate {
        let referenceDate = refDate ?? NSDate()
        return referenceDate.set(year: year, month: month, day: day, hour: hour, minute: minute, second: second, tz: tz)
    }
    
    /**
    Return a new NSDate instance with the current date and time set to 00:00:00
    
    - parameter tz: optional timezone abbreviation
    
    - returns: a new NSDate instance of the today's date
    */
    class func today(tz: String? = nil) -> NSDate! {
        let nowDate = NSDate()
        return NSDate.date(refDate: nowDate, year: nowDate.year, month: nowDate.month, day: nowDate.day, tz: tz)
    }
    
    /**
    Return a new NSDate istance with the current date minus one day
    
    - parameter tz: optional timezone abbreviation
    
    - returns: a new NSDate instance which represent yesterday's date
    */
    class func yesterday(tz: String? = nil) -> NSDate! {
        return today(tz)-1.day
    }
    
    /**
    Return a new NSDate istance with the current date plus one day
    
    - parameter tz: optional timezone abbreviation
    
    - returns: a new NSDate instance which represent tomorrow's date
    */
    class func tomorrow(tz: String? = nil) -> NSDate! {
        return today(tz)+1.day
    }
    
    /**
    Individual set single component of the current date instance
    
    - parameter year:   a non-nil value to change the year component of the instance
    - parameter month:  a non-nil value to change the month component of the instance
    - parameter day:    a non-nil value to change the day component of the instance
    - parameter hour:   a non-nil value to change the hour component of the instance
    - parameter minute: a non-nil value to change the minute component of the instance
    - parameter second: a non-nil value to change the second component of the instance
    - parameter tz:     a non-nil value (timezone abbreviation string as for NSTimeZone) to change the timezone component of the instance
    
    - returns: a new NSDate instance with changed values
    */
    func set(year year: Int?, month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?, tz: String?) -> NSDate! {
        let components = self.components
        components.year = year ?? self.year
        components.month = month ?? self.month
        components.day = day ?? self.day
        components.hour = hour ?? self.hour
        components.minute = minute ?? self.minute
        components.second = second ?? self.second
        components.timeZone = (tz != nil ? NSTimeZone(abbreviation: tz!) : NSTimeZone.defaultTimeZone())
        return NSCalendar.currentCalendar().dateFromComponents(components)
    }
    
    /**
    Allows you to set individual date components by passing an array of components name and associated values
    
    - parameter componentsDict: components dict. Accepted keys are year,month,day,hour,minute,second
    
    - returns: a new date instance with altered components according to passed dictionary
    */
    @available(iOS 8.0, *)
    func set(componentsDict componentsDict: [String:Int]!) -> NSDate? {
        if componentsDict.count == 0 {
            return self
        }
        let components = self.components
        for (thisComponent,value) in componentsDict {
            let unit : NSCalendarUnit = thisComponent._sdToCalendarUnit()!
            components.setValue(value, forComponent: unit);
        }
        return NSCalendar.currentCalendar().dateFromComponents(components)
    }
    
    /**
    Allows you to set a single component by passing it's name (year,month,day,hour,minute,second are accepted).
    Please note: this method return a new immutable NSDate instance (NSDate are immutable, damn!). So while you
    can chain multiple set calls, if you need to alter more than one component see the method above which accept
    different params.
    
    - parameter name:  the name of the component to alter (year,month,day,hour,minute,second are accepted)
    - parameter value: the value of the component
    
    - returns: a new date instance
    */
    @available(iOS 8.0, *)
    func set(name : String!, value : Int!) -> NSDate? {
        let unit : NSCalendarUnit = name._sdToCalendarUnit()!
        if unit == [] {
            return nil
        }
        let components = self.components
        components.setValue(value, forComponent: unit);
        return NSCalendar.currentCalendar().dateFromComponents(components)
    }
    
    /**
    Add or subtract (via negative values) components from current date instance
    
    - parameter years:   nil or +/- years to add or subtract from date
    - parameter months:  nil or +/- months to add or subtract from date
    - parameter weeks:   nil or +/- weeks to add or subtract from date
    - parameter days:    nil or +/- days to add or subtract from date
    - parameter hours:   nil or +/- hours to add or subtract from date
    - parameter minutes: nil or +/- minutes to add or subtract from date
    - parameter seconds: nil or +/- seconds to add or subtract from date
    
    - returns: a new NSDate instance with changed values
    */
    func add(years years: Int?, months: Int?, weeks: Int?, days: Int?,hours: Int?,minutes: Int?,seconds: Int?) -> NSDate {
        let components = NSDateComponents()
        components.year = years ?? 0
        components.month = months ?? 0
        components.weekOfYear = weeks ?? 0
        components.day = days ?? 0
        components.hour = hours ?? 0
        components.minute = minutes ?? 0
        components.second = seconds ?? 0
        return self.addComponents(components)
    }
    
    /**
    Add/substract (based on sign) specified component with value
    
    - parameter name:  component name (year,month,day,hour,minute,second)
    - parameter value: value of the component
    
    - returns: new date with altered component
    */
    @available(iOS 8.0, *)
    func add(name : String!, value : Int!) -> NSDate? {
        let unit : NSCalendarUnit = name._sdToCalendarUnit()!
        if unit == [] {
            return nil
        }
        let components = NSDateComponents()
        components.setValue(value, forComponent: unit);
        return self.addComponents(components)
    }
    
    /**
    Add value specified by components in passed dictionary to the current date
    
    - parameter componentsDict: dictionary of the component to alter with value (year,month,day,hour,minute,second)
    
    - returns: new date with altered components
    */
    @available(iOS 8.0, *)
    func add(componentsDict componentsDict: [String:Int]!) -> NSDate? {
        if componentsDict.count == 0 {
            return self
        }
        let components = NSDateComponents()
        for (thisComponent,value) in componentsDict {
            let unit : NSCalendarUnit = thisComponent._sdToCalendarUnit()!
            components.setValue(value, forComponent: unit);
        }
        return self.addComponents(components)
    }
}

//MARK: TIMEZONE UTILITIES

public extension NSDate {
    /**
    Return a new NSDate in UTC format from the current system timezone
    
    - returns: a new NSDate instance
    */
    func toUTC() -> NSDate {
        let tz : NSTimeZone = NSTimeZone.localTimeZone()
        let secs : Int = tz.secondsFromGMTForDate(self)
        return NSDate(timeInterval: NSTimeInterval(secs), sinceDate: self)
    }
    
    /**
    Convert an UTC NSDate instance to a local time NSDate (note: NSDate object does not contains info about the timezone!)
    
    - returns: a new NSDate instance
    */
    func toLocalTime() -> NSDate {
        let tz : NSTimeZone = NSTimeZone.localTimeZone()
        let secs : Int = -tz.secondsFromGMTForDate(self)
        return NSDate(timeInterval: NSTimeInterval(secs), sinceDate: self)
    }
    
    /**
    Convert an UTC NSDate instance to passed timezone (note: NSDate object does not contains info about the timezone!)
    
    - parameter abbreviation: abbreviation of the time zone
    
    - returns: a new NSDate instance
    */
    func toTimezone(abbreviation : String!) -> NSDate? {
        let tz : NSTimeZone? = NSTimeZone(abbreviation: abbreviation)
        if tz == nil {
            return nil
        }
        let secs : Int = tz!.secondsFromGMTForDate(self)
        return NSDate(timeInterval: NSTimeInterval(secs), sinceDate: self)
    }
}

//MARK: COMPARE DATES

public extension NSDate {
    
    func secondsAfterDate(date: NSDate) -> Int {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval)
    }
    
    func secondsBeforeDate(date: NSDate) -> Int {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval)
    }
    
    /**
    Return the number of minutes between two dates.
    
    - parameter date: comparing date
    
    - returns: number of minutes
    */
    func minutesAfterDate(date: NSDate) -> Int {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / NSTimeInterval(D_MINUTE))
    }
    
    func minutesBeforeDate(date: NSDate) -> Int {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / NSTimeInterval(D_MINUTE))
    }
    
    func hoursAfterDate(date: NSDate) -> Int {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / NSTimeInterval(D_HOUR))
    }
    
    func hoursBeforeDate(date: NSDate) -> Int {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / NSTimeInterval(D_HOUR))
    }
    
    func daysAfterDate(date: NSDate) -> Int {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / NSTimeInterval(D_DAY))
    }
    
    func daysBeforeDate(date: NSDate) -> Int {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / NSTimeInterval(D_DAY))
    }
    
    /**
    Compare two dates and return true if they are equals
    
    - parameter date:       date to compare with
    - parameter ignoreTime: true to ignore time of the date
    
    - returns: true if two dates are equals
    */
    func isEqualToDate(date: NSDate, ignoreTime: Bool) -> Bool {
        if ignoreTime {
            let comp1 = NSDate.components(fromDate: self)
            let comp2 = NSDate.components(fromDate: date)
            return ((comp1.year == comp2.year) && (comp1.month == comp2.month) && (comp1.day == comp2.day))
        } else {
            return self.isEqualToDate(date)
        }
    }
    
    /**
    Return true if given date's time in passed range
    
    - parameter minTime: min time interval (by default format is "HH:mm", but you can specify your own format in format parameter)
    - parameter maxTime: max time interval (by default format is "HH:mm", but you can specify your own format in format parameter)
    - parameter format:  nil or a valid format string used to parse minTime and maxTime from their string representation (when nil HH:mm is used)
    
    - returns: true if date's time component falls into given range
    */
    func isInTimeRange(minTime: String!, maxTime: String!, format: String?) -> Bool {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format ?? "HH:mm"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let minTimeDate = dateFormatter.dateFromString(minTime)
        let maxTimeDate = dateFormatter.dateFromString(maxTime)
        if minTimeDate == nil || maxTimeDate == nil {
            return false
        }
        let inBetween = (self.compare(minTimeDate!) == NSComparisonResult.OrderedDescending &&
            self.compare(maxTimeDate!) == NSComparisonResult.OrderedAscending)
        return inBetween
    }
    
    /**
    Return true if the date's year is a leap year
    
    - returns: true if date's year is a leap year
    */
    func isLeapYear() -> Bool {
        let year = self.year
        return year % 400 == 0 ? true : ((year % 4 == 0) && (year % 100 != 0))
    }
    
    /**
    Return the number of days in current date's month
    
    - returns: number of days of the month
    */
    func monthDays () -> Int {
        return NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: self).length
    }
    
    /**
    True if the date is the current date
    
    - returns: true if date is today
    */
    func isToday() -> Bool {
        return self.isEqualToDate(NSDate(), ignoreTime: true)
    }
    
    /**
    True if the date is the current date plus one day (tomorrow)
    
    - returns: true if date is tomorrow
    */
    func isTomorrow() -> Bool {
        return self.isEqualToDate(NSDate()+1.day, ignoreTime:true)
    }
    
    /**
    True if the date is the current date minus one day (yesterday)
    
    - returns: true if date is yesterday
    */
    func isYesterday() -> Bool {
        return self.isEqualToDate(NSDate()-1.day, ignoreTime:true)
    }
    
    /**
    Return true if the date falls into the current week
    
    - returns: true if date is inside the current week days range
    */
    func isThisWeek() -> Bool {
        return self.isSameWeekOf(NSDate())
    }
    
    /**
    Return true if the date is in the same week of passed date
    
    - parameter date: date to compare with
    
    - returns: true if both dates falls in the same week
    */
    func isSameWeekOf(date: NSDate) -> Bool {
        let comp1 = NSDate.components(fromDate: self)
        let comp2 = NSDate.components(fromDate: date)
        // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
        if comp1.weekOfYear != comp2.weekOfYear {
            return false
        }
        // Must have a time interval under 1 week
        let weekInSeconds = NSTimeInterval(D_WEEK)
        return abs(self.timeIntervalSinceDate(date)) < weekInSeconds
    }
    
    /**
    Return the first day of the passed date's week (Sunday)
    
    - returns: NSDate with the date of the first day of the week
    */
    func dateAtWeekStart() -> NSDate {
        let flags : NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Weekday]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: self)
        components.weekday = 1 // Sunday
        components.hour = 0
        components.minute = 0
        components.second = 0
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
    
    /// Return a date which represent the beginning of the current day (at 00:00:00)
    var beginningOfDay: NSDate {
        return set(year: nil, month: nil, day: nil, hour: 0, minute: 0, second: 0, tz: nil)
    }
    
    /// Return a date which represent the end of the current day (at 23:59:59)
    var endOfDay: NSDate {
        return set(year: nil, month: nil, day: nil, hour: 23, minute: 59, second: 59, tz: nil)
    }
    
    /// Return the first day of the month of the current date
    var beginningOfMonth: NSDate {
        return set(year: nil, month: nil, day: 1, hour: 0, minute: 0, second: 0, tz: nil)
    }
    
    /// Return the last day of the month of the current date
    var endOfMonth: NSDate {
        let lastDay = NSCalendar.currentCalendar().rangeOfUnit(.Day, inUnit: .Month, forDate: self).length
        return set(year: nil, month: nil, day: lastDay, hour: 23, minute: 59, second: 59, tz: nil)
    }
    
    /// Return the first day of the year of the current date
    var beginningOfYear: NSDate {
        return set(year: nil, month: 1, day: 1, hour: 0, minute: 0, second: 0, tz: nil)
    }
    
    /// Return the last day of the year of the current date
    var endOfYear: NSDate {
        return set(year: nil, month: 12, day: 31, hour: 23, minute: 59, second: 59, tz: nil)
    }
    
    /**
    Return true if current date's day is not a weekend day
    
    - returns: true if date's day is a week day, not a weekend day
    */
    func isWeekday() -> Bool {
        return !self.isWeekend()
    }
    
    /**
    Return true if the date is the weekend
    
    - returns: true or false
    */
    func isWeekend() -> Bool {
        let range = NSCalendar.currentCalendar().maximumRangeOfUnit(NSCalendarUnit.Weekday)
        return (self.weekday == range.location || self.weekday == range.length)
    }
    
}

//MARK: CONVERTING DATE TO STRING

public extension NSDate {
    
    /**
    Return a formatted string with passed style for date and time
    
    - parameter dateStyle:    style of the date component into the output string
    - parameter timeStyle:    style of the time component into the output string
    - parameter relativeDate: true to use relative date style
    
    - returns: string representation of the date
    */
    public func toString(dateStyle dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle, relativeDate: Bool = false) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.doesRelativeDateFormatting = relativeDate
        return dateFormatter.stringFromDate(self)
    }
    
    /**
    Return a new string which represent the NSDate into passed format
    
    - parameter format: format of the output string. Choose one of the available format or use a custom string
    
    - returns: a string with formatted date
    */
    public func toString(format format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
    
    /**
    Return a relative string which represent the date instance
    
    - parameter fromDate:    comparison date (by default is the current NSDate())
    - parameter abbreviated: true to use abbreviated unit forms (ie. "ys" instead of "years")
    - parameter maxUnits:    max detail units to print (ie. "1 hour 47 minutes" is maxUnit=2, "1 hour" is maxUnit=1)
    
    - returns: formatted string
    */
    public func toRelativeString(fromDate: NSDate = NSDate(), abbreviated : Bool = false, maxUnits: Int = 1) -> String {
        let seconds = fromDate.timeIntervalSinceDate(self)
        if fabs(seconds) < 1 {
            return "just now"._sdLocalize
        }
        
        let significantFlags : NSCalendarUnit = NSDate.componentFlags()
        let components = NSCalendar.currentCalendar().components(significantFlags, fromDate: fromDate, toDate: self, options: [])
        
        var string = String()
        var isApproximate:Bool = false
        var numberOfUnits:Int = 0
        let unitList : [String] = ["year", "month", "weekOfYear", "day", "hour", "minute", "second"]
        for unitName in unitList {
            let unit : NSCalendarUnit = unitName._sdToCalendarUnit()!
            if ((significantFlags.rawValue & unit.rawValue) != 0) &&
                (_sdCompareCalendarUnit(NSCalendarUnit.Second, other: unit) != .OrderedDescending) {
                    let number:NSNumber = NSNumber(float: fabsf(components.valueForKey(unitName)!.floatValue))
                    if Bool(number.integerValue) {
                        let singular = (number.unsignedIntegerValue == 1)
                        let suffix = String(format: "%@ %@", arguments: [number, _sdLocalizeStringForValue(singular, unit: unit, abbreviated: abbreviated)])
                        if string.isEmpty {
                            string = suffix
                        } else if numberOfUnits < maxUnits {
                            string += String(format: " %@", arguments: [suffix])
                        } else {
                            isApproximate = true
                        }
                        numberOfUnits += 1
                    }
            }
        }
        
        if string.isEmpty == false {
            if seconds > 0 {
                string = String(format: "%@ %@", arguments: [string, "ago"._sdLocalize])
            } else {
                string = String(format: "%@ %@", arguments: [string, "from now"._sdLocalize])
            }
            
            if (isApproximate) {
                string = String(format: "about %@", arguments: [string])
            }
        }
        return string
    }
    
    /**
    Return a string representation of the date where both date and time are in short style format
    
    - returns: date's string representation
    */
    public func toShortString() -> String {
        return toString(dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
    /**
    Return a string representation of the date where both date and time are in medium style format
    
    - returns: date's string representation
    */
    public func toMediumString() -> String {
        return toString(dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.MediumStyle)
    }
    
    /**
    Return a string representation of the date where both date and time are in long style format
    
    - returns: date's string representation
    */
    public func toLongString() -> String {
        return toString(dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.LongStyle)
    }
    
    /**
    Return a string representation of the date with only the date in short style format (no time)
    
    - returns: date's string representation
    */
    public func toShortDateString() -> String {
        return toString(dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    /**
    Return a string representation of the date with only the time in short style format (no date)
    
    - returns: date's string representation
    */
    public func toShortTimeString() -> String {
        return toString(dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
    /**
    Return a string representation of the date with only the date in medium style format (no date)
    
    - returns: date's string representation
    */
    public func toMediumDateString() -> String {
        return toString(dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    /**
    Return a string representation of the date with only the time in medium style format (no date)
    
    - returns: date's string representation
    */
    public func toMediumTimeString() -> String {
        return toString(dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.MediumStyle)
    }
    
    /**
    Return a string representation of the date with only the date in long style format (no date)
    
    - returns: date's string representation
    */
    public func toLongDateString() -> String {
        return toString(dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    /**
    Return a string representation of the date with only the time in long style format (no date)
    
    - returns: date's string representation
    */
    public func toLongTimeString() -> String {
        return toString(dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.LongStyle)
    }
    
}

//MARK: PRIVATE ACCESSORY METHODS

private extension NSDate {
    
    private class func components(fromDate fromDate: NSDate) -> NSDateComponents! {
        return NSCalendar.currentCalendar().components(NSDate.componentFlags(), fromDate: fromDate)
    }
    
    private func addComponents(components: NSDateComponents) -> NSDate {
        let cal = NSCalendar.currentCalendar()
        return cal.dateByAddingComponents(components, toDate: self, options: [])!
    }
    
    private class func componentFlags() -> NSCalendarUnit {
        return NSCalendarUnit.Year.union(NSCalendarUnit.Month).union(NSCalendarUnit.Day).union(NSCalendarUnit.WeekOfYear).union(NSCalendarUnit.Hour).union(NSCalendarUnit.Minute).union(NSCalendarUnit.Second).union(NSCalendarUnit.Weekday).union(NSCalendarUnit.WeekdayOrdinal).union(NSCalendarUnit.WeekOfMonth).union(NSCalendarUnit.Era)
    }
    
    /// Return the NSDateComponents which represent current date
    private var components: NSDateComponents {
        return  NSCalendar.currentCalendar().components(NSDate.componentFlags(), fromDate: self)
    }
    
    /**
    This function uses NSThread dictionary to store and retrive a thread-local object, creating it if it has not already been created
    
    - parameter key:    identifier of the object context
    - parameter create: create closure that will be invoked to create the object
    
    - returns: a cached instance of the object
    */
    private class func cachedObjectInCurrentThread<T: AnyObject>(key: String, create: () -> T) -> T {
        if let threadDictionary = NSThread.currentThread().threadDictionary as NSMutableDictionary? {
            if let cachedObject = threadDictionary[key] as! T? {
                return cachedObject
            } else {
                let newObject = create()
                threadDictionary[key] = newObject
                return newObject
            }
        } else {
            assert(false, "Current NSThread dictionary is nil. This should never happens, we will return a new instance of the object on each call")
            return create()
        }
    }
}

//MARK: RELATIVE NSDATE CONVERSION PRIVATE METHODS

private extension NSDate {
    func _sdCompareCalendarUnit(unit:NSCalendarUnit, other:NSCalendarUnit) -> NSComparisonResult {
        let nUnit = _sdNormalizedCalendarUnit(unit)
        let nOther = _sdNormalizedCalendarUnit(other)
        
        if (nUnit == NSCalendarUnit.WeekOfYear) != (nOther == NSCalendarUnit.WeekOfYear) {
            if nUnit == NSCalendarUnit.WeekOfYear {
                switch nUnit {
                case NSCalendarUnit.Year, NSCalendarUnit.Month:
                    return .OrderedAscending
                default:
                    return .OrderedDescending
                }
            } else {
                switch nOther {
                case NSCalendarUnit.Year, NSCalendarUnit.Month:
                    return .OrderedDescending
                default:
                    return .OrderedAscending
                }
            }
        } else {
            if nUnit.rawValue > nOther.rawValue {
                return .OrderedAscending
            } else if (nUnit.rawValue < nOther.rawValue) {
                return .OrderedDescending
            } else {
                return .OrderedSame
            }
        }
    }
    
    private func _sdNormalizedCalendarUnit(unit:NSCalendarUnit) -> NSCalendarUnit {
        switch unit {
        case NSCalendarUnit.WeekOfMonth, NSCalendarUnit.WeekOfYear:
            return NSCalendarUnit.WeekOfYear
        case NSCalendarUnit.Weekday, NSCalendarUnit.WeekdayOrdinal:
            return NSCalendarUnit.Day
        default:
            return unit;
        }
    }
    
    
    func _sdLocalizeStringForValue(singular : Bool, unit: NSCalendarUnit, abbreviated: Bool = false) -> String {
        var toTranslate : String = ""
        switch unit {
            
        case NSCalendarUnit.Year where singular:		toTranslate = (abbreviated ? "yr" : "year")
        case NSCalendarUnit.Year where !singular:		toTranslate = (abbreviated ? "yrs" : "years")
            
        case NSCalendarUnit.Month where singular:		toTranslate = (abbreviated ? "mo" : "month")
        case NSCalendarUnit.Month where !singular:		toTranslate = (abbreviated ? "mos" : "months")
            
        case NSCalendarUnit.WeekOfYear where singular:	toTranslate = (abbreviated ? "wk" : "week")
        case NSCalendarUnit.WeekOfYear where !singular: toTranslate = (abbreviated ? "wks" : "weeks")
            
        case NSCalendarUnit.Day where singular:			toTranslate = "day"
        case NSCalendarUnit.Day where !singular:		toTranslate = "days"
            
        case NSCalendarUnit.Hour where singular:		toTranslate = (abbreviated ? "hr" : "hour")
        case NSCalendarUnit.Hour where !singular:		toTranslate = (abbreviated ? "hrs" : "hours")
            
        case NSCalendarUnit.Minute where singular:		toTranslate = (abbreviated ? "min" : "minute")
        case NSCalendarUnit.Minute where !singular:		toTranslate = (abbreviated ? "mins" : "minutes")
            
        case NSCalendarUnit.Second where singular:		toTranslate = (abbreviated ? "s" : "second")
        case NSCalendarUnit.Second where !singular:		toTranslate = (abbreviated ? "s" : "seconds")
            
        default:													toTranslate = ""
        }
        return toTranslate._sdLocalize
    }
    
    func localizedSimpleStringForComponents(components:NSDateComponents) -> String {
        if (components.year == -1) {
            return "last year"._sdLocalize
        } else if (components.month == -1 && components.year == 0) {
            return "last month"._sdLocalize
        } else if (components.weekOfYear == -1 && components.year == 0 && components.month == 0) {
            return "last week"._sdLocalize
        } else if (components.day == -1 && components.year == 0 && components.month == 0 && components.weekOfYear == 0) {
            return "yesterday"._sdLocalize
        } else if (components == 1) {
            return "next year"._sdLocalize
        } else if (components.month == 1 && components.year == 0) {
            return "next month"._sdLocalize
        } else if (components.weekOfYear == 1 && components.year == 0 && components.month == 0) {
            return "next week"._sdLocalize
        } else if (components.day == 1 && components.year == 0 && components.month == 0 && components.weekOfYear == 0) {
            return "tomorrow"._sdLocalize
        }
        return ""
    }
}

//MARK: OPERATIONS WITH DATES (==,!=,<,>,<=,>=)

extension NSDate : Comparable {}

public func == (left: NSDate, right: NSDate) -> Bool {
    return (left.compare(right) == NSComparisonResult.OrderedSame)
}

public func != (left: NSDate, right: NSDate) -> Bool {
    return !(left == right)
}

public func < (left: NSDate, right: NSDate) -> Bool {
    return (left.compare(right) == NSComparisonResult.OrderedAscending)
}

public func > (left: NSDate, right: NSDate) -> Bool {
    return (left.compare(right) == NSComparisonResult.OrderedDescending)
}

public func <= (left: NSDate, right: NSDate) -> Bool {
    return !(left > right)
}

public func >= (left: NSDate, right: NSDate) -> Bool {
    return !(left < right)
}

//MARK: ARITHMETIC OPERATIONS WITH DATES (-,-=,+,+=)

public func - (left : NSDate, right: NSTimeInterval) -> NSDate {
    return left.dateByAddingTimeInterval(-right)
}

public func -= (inout left: NSDate, right: NSTimeInterval) {
    left = left.dateByAddingTimeInterval(-right)
}

public func + (left: NSDate, right: NSTimeInterval) -> NSDate {
    return left.dateByAddingTimeInterval(right)
}

public func += (inout left: NSDate, right: NSTimeInterval) {
    left = left.dateByAddingTimeInterval(right)
}

public func - (left: NSDate, right: CalendarType) -> NSDate {
    let calendarType = right.copy()
    calendarType.amount = -calendarType.amount
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let dateComponents = calendarType.dateComponents()
    let finalDate = calendar.dateByAddingComponents(dateComponents, toDate: left, options: NSCalendarOptions())!
    return finalDate
}

public func -= (inout left: NSDate, right: CalendarType) {
    left = left - right
}

public func + (left: NSDate, right: CalendarType) -> NSDate {
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    return calendar.dateByAddingComponents(right.dateComponents(), toDate: left, options: NSCalendarOptions())!
}

public func += (inout left: NSDate, right: CalendarType) {
    left = left + right
}

//MARK: SUPPORTING STRUCTURES

public class CalendarType {
    var calendarUnit : NSCalendarUnit
    var amount : Int
    
    init(amount : Int) {
        self.calendarUnit = NSCalendarUnit()
        self.amount = amount
    }
    
    init(amount: Int, calendarUnit: NSCalendarUnit) {
        self.calendarUnit = calendarUnit
        self.amount = amount
    }
    
    func dateComponents() -> NSDateComponents {
        return NSDateComponents()
    }
    
    func copy() -> CalendarType {
        return CalendarType(amount: self.amount, calendarUnit: self.calendarUnit)
    }
}

public class MonthCalendarType : CalendarType {
    
    override init(amount : Int) {
        super.init(amount: amount)
        self.calendarUnit = NSCalendarUnit.Month
    }
    
    override func dateComponents() -> NSDateComponents {
        let components = super.dateComponents()
        components.month = self.amount
        return components
    }
    
    override func copy() -> MonthCalendarType {
        let objCopy =  MonthCalendarType(amount: self.amount)
        objCopy.calendarUnit = self.calendarUnit
        return objCopy;
    }
}

public class YearCalendarType : CalendarType {
    
    override init(amount : Int) {
        super.init(amount: amount, calendarUnit: NSCalendarUnit.Year)
    }
    
    override func dateComponents() -> NSDateComponents {
        let components = super.dateComponents()
        components.year = self.amount
        return components
    }
    
    override func copy() -> YearCalendarType {
        let objCopy =  YearCalendarType(amount: self.amount)
        objCopy.calendarUnit = self.calendarUnit
        return objCopy
    }
}

public extension Int {
    var seconds : NSTimeInterval {
        return NSTimeInterval(self)
    }
    var second : NSTimeInterval {
        return (self.seconds)
    }
    var minutes : NSTimeInterval {
        return (self.seconds*60)
    }
    var minute : NSTimeInterval {
        return self.minutes
    }
    var hours : NSTimeInterval {
        return (self.minutes*60)
    }
    var hour : NSTimeInterval {
        return self.hours
    }
    var days : NSTimeInterval {
        return (self.hours*24)
    }
    var day : NSTimeInterval {
        return self.days
    }
    var weeks : NSTimeInterval {
        return (self.days*7)
    }
    var week : NSTimeInterval {
        return self.weeks
    }
    var workWeeks : NSTimeInterval {
        return (self.days*5)
    }
    var workWeek : NSTimeInterval {
        return self.workWeeks
    }
    var months : MonthCalendarType {
        return MonthCalendarType(amount: self)
    }
    var month : MonthCalendarType {
        return self.months
    }
    var years : YearCalendarType {
        return YearCalendarType(amount: self)
    }
    var year : YearCalendarType {
        return self.years
    }
    func weekDayToChinese() -> String {
        switch self {
        case 1:
            return "周一"
        case 2:
            return "周二"
        case 3:
            return "周三"
        case 4:
            return "周四"
        case 5:
            return "周五"
        case 6:
            return "周六"
        case 7:
            return "周日"
        default:
            return ""
        }
    }
}

//MARK: PRIVATE STRING EXTENSION

private extension String {
    
    var _sdLocalize: String {
        return NSBundle.mainBundle().localizedStringForKey(self, value: nil, table: "SwiftDates")
    }
    
    func _sdToCalendarUnit() -> NSCalendarUnit? {
        switch self {
        case "year":
            return NSCalendarUnit.Year
        case "month":
            return NSCalendarUnit.Month
        case "weekOfYear":
            return NSCalendarUnit.WeekOfYear
        case "day":
            return NSCalendarUnit.Day
        case "hour":
            return NSCalendarUnit.Hour
        case "minute":
            return NSCalendarUnit.Minute
        case "second":
            return NSCalendarUnit.Second
        default:
            return nil
        }
    }
}

public extension NSTimeZone {
    
    public func convertOffsetToTimezoneString() -> String {
        let offsetHour = self.secondsFromGMT / 60 / 60
        if offsetHour < 0 {
            if offsetHour <= -10 {
                return "\(offsetHour)00"
            }
            return "-0\(abs(offsetHour))00"
        }
        if offsetHour >= 10 {
            return "+\(offsetHour)00"
        }
        return "+0\(offsetHour)00"
    }
    
}
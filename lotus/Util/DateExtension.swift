//
//  DateExtension.swift
//  AffroppleApp
//
//  Created by Apple on 20/09/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation

extension Date{
    
    func convertToFormat(_ format: String) -> String?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = format
        let date = dateFormatter.string(from: self)
        return date
    }
}

extension Date {
    var startOfWeek: Date {
        let date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        let dslTimeOffset = NSTimeZone.local.daylightSavingTimeOffset(for: date)
        return date.addingTimeInterval(dslTimeOffset)
    }
    
    var endOfWeek: Date {
        return Calendar.current.date(byAdding: .second, value: 604799, to: self.startOfWeek)!
    }
}

extension Date {
    
    var shortTimeDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .short
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var mediumTimeDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .medium
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var longTimeDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .long
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var fullTimeDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .full
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var shortDateTimeDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .short
        
        formater.dateStyle = .short
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var mediumDateTimeDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .medium
        
        formater.dateStyle = .medium
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var longDateTimeDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .long
        
        formater.dateStyle = .long
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var fullDateTimeDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .full
        
        formater.dateStyle = .full
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var shortDateDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .short
        
        formater.dateStyle = .short
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var mediumDateDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .short
        
        formater.dateStyle = .medium
        
        // US English Locale (en_US)
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var longDateDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .short
        
        formater.dateStyle = .long
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var fullDateDisplay:String{
        
        let formater = DateFormatter()
        
        formater.timeStyle = .short
        
        formater.dateStyle = .full
        
        formater.locale = Locale(identifier: "en_US")
        
        return formater.string(from: self)
        
    }
    
    var timeDisplay:String{
        
        get{
            
            let secondAngle = Int(Date().timeIntervalSince(self))
            
            let minute = 60
            
            let hour = 60*minute
            
            let day  = 24*hour
            
            let week = 7*day
            
            let month = 4*week
            
            let year = 12*month
            
            let quatient:Int
            
            let unit:String
            
            if secondAngle<minute {
                
                quatient = secondAngle
                
                unit = "second"
                
            }else if secondAngle<hour {
                
                quatient = secondAngle/minute
                
                unit = "min"
                
            }else if secondAngle<day {
                
                quatient = secondAngle/hour
                
                unit = "hour"
                
            }else if secondAngle<week {
                
                quatient = secondAngle/day
                
                unit = "day"
                
            }else if secondAngle<month {
                
                quatient = secondAngle/week
                
                unit = "week"
                
            }else  if secondAngle<year {
                
                quatient = secondAngle/month
                
                unit = "month"
                
            }else{
                
                quatient = secondAngle/year
                
                unit = "year"
                
            }
            
            return "\(quatient) \(unit)\(quatient == 1 ? "" :"s") ago"
        }
        
    }
    
    var millisecondsSince1970:Int64 {
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        //        dateFormatter.dateFormat = "EEEE dd-MM-yyyy hh:mm a"
        //        let UTCTDate = dateFormatter.date(from: self.dateToString(formater: "EEEE dd-MM-yyyy hh:mm a"))
        //        return Int64((UTCTDate!.timeIntervalSince1970).rounded())
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Int64((Date(timeInterval: seconds, since: self).timeIntervalSince1970).rounded())
        //   return Int64(-TimeInterval(timezone.secondsFromGMT(for: self)).rounded())
    }
    
    init(milliseconds:Int) {
        let UTCDate = Date(timeIntervalSince1970: TimeInterval(milliseconds))
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for:UTCDate ))
        self = Date(timeInterval: seconds, since: UTCDate)
        // self = Date(timeIntervalSince1970: TimeInterval(milliseconds))
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    // convert Date to string date
    
    func dateToString(formater:String = "yyyy-MM-dd HH:mm:ss") -> String
    {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = formater //yyyy-MM-dd///this is you want to convert format
        
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //.current  //
        
        let dateStamp = dateFormatter.string(from: self)
        
        return dateStamp
        
    }
    
    func dateFormat(dateStyle:DateFormatter.Style = .medium,timeStyle:DateFormatter.Style = .short) -> String
    {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = dateStyle
        
        dateFormatter.timeStyle = timeStyle
        
        // US English Locale (en_US)
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let dateStamp = dateFormatter.string(from: self)
        
        return dateStamp
        
    }
    
    func changeDateFormate(formater:String = "yyyy-MM-dd HH:mm:ss") -> Date
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = formater //yyyy-MM-dd///this is you want to convert format
        
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dateStamp = dateFormatter.string(from: self)
        
        let newdate = dateFormatter.date(from: dateStamp)
        
        return newdate!
        
    }
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == .orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isGreaterThanEqualDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        //Compare Values
        if self.compare(dateToCompare) == .orderedDescending {
            isGreater = true
        }else if self.compare(dateToCompare) == .orderedSame {
            isGreater = true
        }else if self.compare(dateToCompare) == .orderedAscending {
            isGreater = false
        }
        
        //Return Result
        return isGreater
    }
    
    func isEqualDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqual = false
        
        //Compare Values
        if self.compare(dateToCompare) == .orderedSame {
            isEqual = true
        }
        
        //Return Result
        return isEqual
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == .orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func isLessThanEqaulDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }else if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isLess = true
        }else if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isLess = false
        }
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    // convert Date to string date
    
    func addDays(_ daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    
}
extension Date {
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))year ago"   }
        if months(from: date)  > 0 { return "\(months(from: date))month ago"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))week ago"   }
        if days(from: date)    > 0 { return "\(days(from: date))day ago"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))hour ago"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))min ago" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))sec ago" }
        if seconds(from: date) == 0 { return "just now" }
        return ""
    }
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
    
    
    func timeBetweenDates(toDate: Date) -> String{
        let calendar = NSCalendar.current
        //        let midnight = calendar.startOfDay(for: Date())
        let timeinterval = toDate.timeIntervalSinceNow
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: timeinterval)!
    }
    
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self) ?? ""
    }
    
}

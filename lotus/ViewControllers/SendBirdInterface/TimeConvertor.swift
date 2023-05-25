

//
//  TimeConvertor.swift
//  Face2Face
//
//  Created by apple on 10/04/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import SendBirdSDK

class TimeConvertor: NSObject {

    //MARK:- Custom methods
   class func getTimeString(created : Int64) -> String{
        let objectTimestamp: TimeInterval = Double(created) / 1000.0
        let currentTimeStamp: TimeInterval = Date().timeIntervalSince1970
    
    
    let timeDifference = Int(currentTimeStamp - objectTimestamp)
        let noMinutes: Int = timeDifference / 60
        var showString = ""
        if noMinutes < 60 {
            if noMinutes == 1 {
                showString = "\(noMinutes) minutes ago"
            } else if noMinutes <= 0 {
                showString = "Just now"
            } else {
                showString = "\(noMinutes) minutes ago"
            }
        } else {
            let nohours: Int = noMinutes / 60
            if nohours < 24 {
                if noMinutes == 1 {
                    showString = "\(nohours) hour ago"
                } else {
                    showString = "\(nohours) hours ago"
                }
            } else {
                let noDays: Int = nohours / 24
                if noDays == 1 {
                    showString = "\(noDays) day ago"
                } else {
                    //                    let noMonths : Int = noDays / 30
                    showString = "\(noDays) days ago"
                }
            }
        }
        return showString
        //        cell.timeLBL.text = showString
    }
    
    
    class func getTimesAgo(created : String, format: String) -> String{
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
        let createdDate = dateFormatter.date(from: created) ?? Date()
        let objectTimestamp: TimeInterval = createdDate.timeIntervalSince1970
        let currentTimeStamp: TimeInterval = Date().timeIntervalSince1970
        
        
        let timeDifference = Int(currentTimeStamp - objectTimestamp)
        let noMinutes: Int = timeDifference / 60
        var showString = ""
        if noMinutes < 60 {
            if noMinutes == 1 {
                showString = "\(noMinutes) minutes ago"
            } else if noMinutes <= 0 {
                showString = "Just now"
            } else {
                showString = "\(noMinutes) minutes ago"
            }
        } else {
            let nohours: Int = noMinutes / 60
            if nohours < 24 {
                if noMinutes == 1 {
                    showString = "\(nohours) hour ago"
                } else {
                    showString = "\(nohours) hours ago"
                }
            } else {
                let noDays: Int = nohours / 24
                if noDays == 1 {
                    showString = "\(noDays) day ago"
                } else {
                    //                    let noMonths : Int = noDays / 30
                    showString = "\(noDays) days ago"
                }
            }
        }
        return showString
        //        cell.timeLBL.text = showString
    }
    
    
    class func dateChanged(prevDate: Date, dateToday: Date, completion: @escaping(Bool,String)-> Void){
        // Day Changed
        let prevMessageDate = prevDate
        let currMessageDate = dateToday
        let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
        let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
        
        if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
            // Show date seperator.
            
            let messageTimestamp = dateToday.timeIntervalSince1970
            let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)
            
            // Seperator Date
            //                let seperatorDateFormatter = DateFormatter()
            //                seperatorDateFormatter.dateStyle = DateFormatter.Style.medium
            
            completion(true, self.dayDifference(date: messageCreatedDate as Date))
        }
        else {
            // Hide date seperator.
            completion(false, "")
        }
    }
    
   class func dayDifference(date : Date) -> String
    {
        let calendar = Calendar.current
        if calendar.isDateInYesterday(date) { return "YESTERDAY" }
        else if calendar.isDateInToday(date) { return "TODAY" }
        else {
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            let dateStr = formatter.string(from: date)
            return dateStr
        }
    }
    
    
    class  func convertToTime(dateInt: Int64 )-> String{
        
        let messageTimestamp: TimeInterval = Double(dateInt) / 1000.0
        let dateFormatter: DateFormatter = DateFormatter()
       
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
    
        let messageCreateDate: Date = NSDate.init(timeIntervalSince1970: messageTimestamp) as Date
        //        let messageDateString = dateFormatter.string(from: messageCreateDate)
        if messageCreateDate.daysBetweenDate(toDate: Date()) == 0{
             dateFormatter.dateFormat = "hh:mm a"
            
            return dateFormatter.string(from: messageCreateDate)
        } else{
             dateFormatter.dateFormat = "M/dd/yy"
            return dateFormatter.string(from: messageCreateDate)
        }
    }
    
    
    class func dateChanged(prevMessage: SBDBaseMessage?, message: SBDBaseMessage, completion: @escaping(Bool,String)-> Void){
        if prevMessage != nil {
            // Day Changed
            let prevMessageDate = NSDate(timeIntervalSince1970: Double((prevMessage?.createdAt)!) / 1000.0)
            let currMessageDate = NSDate(timeIntervalSince1970: Double(message.createdAt) / 1000.0)
            let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
            let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
            
            if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                // Show date seperator.
                
                let messageTimestamp = Double(message.createdAt) / 1000.0
                let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)
                
                // Seperator Date
                let seperatorDateFormatter = DateFormatter()
                    seperatorDateFormatter.dateFormat = "dd MMM, yyyy"
                completion(true, seperatorDateFormatter.string(from: messageCreatedDate as Date))
            }
            else {
                // Hide date seperator.
                completion(false, "")
                
            }
        }
        else {
            // Show date seperator.
            completion(false, "")
        }
    }
    
}

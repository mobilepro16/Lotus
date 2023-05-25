//
//  Store.swift
//  Fiterit
//
//  Created by Apple on 18/08/18.
//  Copyright © 2018 Gurindercql. All rights reserved.
//

import Foundation

class Store {
    
    class var authKey: String?
    {
        set{
            Store.saveValue(newValue, .authKey)
        }get{
            return Store.getValue(.authKey) as? String
        }
    }
    class var profilePic: String?
    {
        set{
            Store.saveValue(newValue, .profileImg)
        }get{
            return Store.getValue(.profileImg) as? String
        }
    }
    
    class var name: String?
    {
        set{
            Store.saveValue(newValue, .name)
        }get{
            return Store.getValue(.name) as? String
        }
    }
//    class var userDetails: UserResponseModel?
//    {
//        set{
//            Store.saveUserDetails(newValue, .userDetails)
//            Store.authKey = newValue?.body?.authKey
//            Store.name = newValue?.body?.username
//            Store.profilePic = newValue?.body?.profileImg
//        }get{
//            return Store.getUserDetails(.userDetails)
//        }
//    }
    
    class var autoLogin: Bool
    {
        set{
            Store.saveValue(newValue, .autoLogin)
        }get{
            return Store.getValue(.autoLogin) as? Bool ?? false
        }
    }
    class var profilecompleted: Int
    {
        set{
            Store.saveValue(newValue, .profileCompleted)
        }get{
            return Store.getValue(.profileCompleted) as? Int ?? 0
        }
    }
    class var deviceToken: String?
    {
        set{
            Store.saveValue(newValue, .deviceToken)
        }
        get{
            return Store.getValue(.deviceToken) as? String 
        }
    }
    class var seekVal: Int?
    {
        set{
            Store.saveValue(newValue, .seek)
        }get{
            return Store.getValue(.seek) as? Int
        }
    }
    static var remove: DefaultKeys!{
        didSet{
            Store.removeKey(remove)
        }
    }
    
//MARK:-  Private Functions
    
    private class func removeKey(_ key: DefaultKeys){
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        if key == .userDetails{
            UserDefaults.standard.removeObject(forKey: DefaultKeys.authKey.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
    private class func saveValue(_ value: Any? ,_ key:DefaultKeys){
        var data: Data?
        if let value = value{
            data = NSKeyedArchiver.archivedData(withRootObject: value)
        }
        UserDefaults.standard.set(data, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    private class func saveUserDetails<T: Codable>(_ value: T?, _ key: DefaultKeys){
        var data: Data?
        if let value = value{
            data = try? PropertyListEncoder().encode(value)
        }
        Store.saveValue(data, key)
    }
    
    private class func getUserDetails<T: Codable>(_ key: DefaultKeys) -> T?{
        if let data = self.getValue(key) as? Data{
            let loginModel = try? PropertyListDecoder().decode(T.self, from: data)
            return loginModel
        }
        return nil
    }
    
    private class func getValue(_ key: DefaultKeys) -> Any{
        if let data = UserDefaults.standard.value(forKey: key.rawValue) as? Data{
            if let value = NSKeyedUnarchiver.unarchiveObject(with: data){
                return value
            }else{
                return ""
            }
        }else{
            return ""
        }
    }
}

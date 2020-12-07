//
//  UserData.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-10-18.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import Foundation

class UserData {
    
    var userDataDict: Dictionary<String, String> = [:]
    
    init() {
        if let data = UserDefaults.standard.object(forKey: "UserData") {
            self.userDataDict = data as! Dictionary<String, String>
            return
        }
    }
    
    func save() {
        UserDefaults.standard.set(self.userDataDict, forKey: "UserData")
    }
    
    func add(key: String, value: String) {
        self.userDataDict[key] = value
        
        self.save()
    }
    
    func get() -> Dictionary<String, String> {
        return self.userDataDict
    }
    
    func get(key: String) -> String {
        if let value = self.userDataDict[key] {
            return value
        }

        return ""
    }
    
    func getBase64EncodedAuth() -> String {
        let username = self.get(key: "username")
        let password = self.get(key: "password")

        return "\(username):\(password)".toBase64()
    }
}

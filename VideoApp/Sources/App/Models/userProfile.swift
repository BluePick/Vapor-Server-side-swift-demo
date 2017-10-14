//
//  userProfile.swift
//  videoAppPackageDescription
//
//  Created by indianic on 06/10/17.
//

import Foundation
import Vapor
import FluentProvider
import HTTP

struct userModel {
    var name:       String
    var age:        Int
    var profilePic: String
    var username:   String
    var password:   String
}


final class userProfile: Model, ResponseRepresentable {
    
    var aUser: userModel
    var time:   Int
    let storage = Storage()

    func makeRow() throws -> Row { return Row() }
    
    init(row: Row) throws {
       aUser = try row.get("aUser")
        time = try row.get("time")
    }
    
    init(user: userModel, time: Int) {
        self.aUser  = user
        self.time   = time
    }
    
    convenience init(user: userModel) {
        let date = Date()
        self.init(user: user, time: Int(date.timeIntervalSince1970))
    }
    
    
    func makeResponse() throws -> Response {
        let json = try JSON(node:[
            "name":       self.aUser.name,
            "age":        self.aUser.age,
            "profilePic": self.aUser.profilePic,
            "username":   self.aUser.username,
            "password":   self.aUser.password])
        return try json.makeResponse()
    }
    

    
}



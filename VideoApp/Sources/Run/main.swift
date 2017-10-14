// Author: Darshit Shah
// API List
// *\tables     - To list available all tables -- TYPE : GET
// *\version    - To get database version -- TYPE : GET
// *\allUser    - To get all users from userTbl -- TYPE : GET
// *\addUser    - Add user with name, age, profilePic, username, password -- TYPE : POST
// *\login      - Login with username, password -- TYPE : POST


import App
import Vapor
import SQLite
import Foundation

let config = try Config()
try config.setup()

let drop = try Droplet(config)
try drop.setup()


/**
  Create user table with name, age, profilePic, username, password
 */
try drop.database?.driver.raw("CREATE TABLE `userTbl` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT, `age` TEXT, `profilePic` TEXT, `username` TEXT, `password` TEXT )")
//-----------------------


/**
     To list available all tables
     TYPE : GET
 */
drop.get("tables") { request in
    let tables = try drop.assertDatabase().raw("SELECT * FROM sqlite_master WHERE type='table';")
     return JSON(node: tables)
}
//-----------------------


/**
     To get database version
     TYPE : GET
 */
drop.get("version") { request in
    let result = try drop.database?.driver.raw("Select sqlite_version()")
    return try JSON(node: result)
}
//-----------------------


/**
	To get all users from userTbl
     TYPE : GET
 */
drop.get("allUser") { request in
    
    let tables = try drop.assertDatabase().raw("SELECT * FROM userTbl")
    return JSON(node: tables)
}
//-----------------------


/**
     Add user with name, age, profilePic, username, password
     TYPE : POST
 
 - Parameter name       : User's full name.
 - Parameter age        : User's age
 - Parameter profilePic : User's profile picture file - Database entry - Picture URL
 - Parameter username   : User's Username to login
 - Parameter password   : User's Password - Not encryption/decription applied
 
 */
drop.post("addUser") { request in
    
    guard let name = request.data["name"]?.string! else {
        return try JSON(node :["error":"Please include name."])
    }
    if name.isEmpty {
        return try JSON(node :["error":"Please enter name."])
    }
    
    guard let age = request.data["age"]?.string!.int else {
        return try JSON(node :["error": "Please enter age."])
    }
    if !(18...100 ~= age) {
        return try JSON(node :["error": "Please enter valid age."])
    }
    
    guard let username = request.data["username"]?.string! else {
        return try JSON(node :["error": "Please include username."])
    }
    if username.isEmpty {
        return try JSON(node :["error": "Please enter username."])
    }
    
    guard let password = request.data["password"]?.string! else {
        return try JSON(node :["error": "Please include password."])
    }
    if password.isEmpty {
        return try JSON(node :["error": "Please enter password."])
    }
    
    guard let image = request.data["profilePic"]?.bytes else {
            throw Abort(.badRequest, reason: "Fields 'filename' and/or 'file' is invalid")
    }
    let data = Data(bytes: (image))
    try data.write(to: URL(fileURLWithPath: "/Volumes/DATA/Darshit/Vapor/\(Int(NSDate().timeIntervalSince1970)).png"))
    //-------
    //Check file write success and add dynamic url in 'profilePic' in database
    //-------
    print("Name : \(name)\n age: \(age)\n username: \(username)\n password: \(password)")
    
    let queryString = "Insert into userTbl(name,age,username,password) values ('\(name)', \(age), '\(username)', '\(password)')"
    try drop.database?.driver.raw(queryString)
    
    let tables = try drop.assertDatabase().raw("SELECT * FROM userTbl")
    
    return try JSON(node :["success":true, "data":tables])
}
//-----------------------


/**
 Login with username, password
 TYPE : POST
 
 - Parameter username   : User's Username to login
 - Parameter password   : User's Password - Not encryption/decription applied
 
 */
drop.post("login") { request in
    
    guard let username = request.data["username"]?.string,
        let password = request.data["password"]?.string else {
            return try JSON(node :["error": "Missing username or password"])
    }
    
    let queryString = "Select * from userTbl where username = '\(username)' and password = '\(password)'"
    
     let userData = try drop.assertDatabase().raw(queryString)
     
     if userData.wrapped.array?.count == 0{
        return try JSON(node :["success":false, "message":"Please check your username and password."])
    }
    else{
        return try JSON(node :["success":true, "data":userData.wrapped.array![0]])
    }
}
//-----------------------


try drop.run()

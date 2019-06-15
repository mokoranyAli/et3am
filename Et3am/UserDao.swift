//
//  UserDao.swift
//  Et3am
//
//  Created by Jets39 on 5/15/19.
//  Copyright © 2019 Ahmed M. Hassan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum APIResponse {
    case success(Int)
    case failure(Error)
}

class UserDao{
    
    public static let shared = UserDao()
    
    let userDefaults = UserDefaults.standard
    
    private init() {
        
    }
    
    var user = User()
    
//    public  func addUser(parameters : [String:String],completionHandler:@escaping (Bool)->Void) {
//        var isRegistered:Bool = false
//        Alamofire.request(Et3amAPI.baseUserUrlString+UserURLQueries.add.rawValue,
//                          method: .post,
//                          parameters: parameters,
//                          encoding: JSONEncoding.default,
//                          headers: nil).responseJSON {
//                            response in
//                            switch response.result {
//                            case .success:
//                                let sucessDataValue = response.result.value
//                                let returnedData = sucessDataValue as! NSDictionary
//                                let userDataDictionary:NSDictionary =  returnedData.value(forKey: "user") as! NSDictionary
//                                
//                                self.user.userID=userDataDictionary.value(forKey: "userId") as! String?
//                                self.user.userName=userDataDictionary.value(forKey: "userName") as! String?
//                                self.user.email=userDataDictionary.value(forKey: "userEmail") as! String?
//                                self.user.password=userDataDictionary.value(forKey: "password") as! String?
//                                self.user.verified=false
//                                isRegistered = true
//                                
//                                helper.addUserObjectIntoUserDefault(userObject: self.user)
//                                completionHandler(isRegistered)
//                                
//                            case .failure(let error):
//                                print(error)
//                                isRegistered = false
//                                completionHandler(isRegistered)
//                                
//                            }
//     
//}
  // }
    

    
    func validateEmail(email:String,completionHandler:@escaping (Bool)->Void) {
        Alamofire.request(Et3amAPI.baseUserUrlString+UserURLQueries.validateEmail.rawValue+email).validate().responseJSON{
            response in
            
            var isEmailFound: Bool?
            
            switch response.result {
            case .success:
                let sucessDataValue = response.result.value
                let returnedData = sucessDataValue as! NSDictionary
                let code = returnedData.value(forKey: "code")! as! Int
                if(code == 0){
                    isEmailFound = false
                } else {
                    isEmailFound = true
                }
                
            case .failure:
                isEmailFound = false
            }
            
            completionHandler(isEmailFound!)
            
        }
    }
    
    func validateLogin(userEmail:String, password:String, completionHandler:@escaping (APIResponse)->Void) {
        
        var urlComponents = URLComponents(string: Et3amAPI.baseUserUrlString+UserURLQueries.loginValidation.rawValue)
        
        urlComponents?.queryItems = [URLQueryItem(name: UserURLQueries.emailQuery.rawValue, value:userEmail), URLQueryItem(name: UserURLQueries.passwordQuery.rawValue, value:password)]
        
        Alamofire.request((urlComponents?.url!)!).validate(statusCode: 200..<500).responseJSON{
            response in
            
            switch response.result {
            case .success:
                
                let json = JSON(response.result.value!)
                guard let code: Int =  json["code"].int else {
                    return
                }
                
                print(json)
                
                if code == 1 {
                    
                    let userJSON = json["user"]
                    
                    //Parse user json
                    self.user = UserHelper.parseUser(json: userJSON)
                    
                    //Add user to user defaults
                    self.addToUserDefaults(self.user)
                    
                } else {
                    
                    print("Username/ password doesn't match or user doesn't exist!")
                    
                }
                
                completionHandler(.success(code))
                
            case .failure(let error):
                print("Connection error: \(error)")
                completionHandler(.failure(error))
            }
            
        }
    }
    
    func addToUserDefaults(_ user: User) {
        
        userDefaults.set(user.userID, forKey: UserProperties.userId.rawValue)
        userDefaults.set(user.userName, forKey: UserProperties.userName.rawValue)
        userDefaults.set(user.email, forKey: UserProperties.userEmail.rawValue)
        userDefaults.set(user.password, forKey: UserProperties.password.rawValue)
        userDefaults.set(user.verified, forKey: UserProperties.verified.rawValue)
        userDefaults.set(user.userStatus, forKey: UserProperties.userStatus.rawValue)
        
        userDefaults.set(user.mobileNumber, forKey: UserProperties.mobileNumber.rawValue)
        userDefaults.set(user.profileImage, forKey: UserProperties.profileImage.rawValue)
        userDefaults.set(user.nationalID, forKey: UserProperties.nationalIdFront.rawValue)
        userDefaults.set(user.job, forKey: UserProperties.job.rawValue)
        userDefaults.set(user.nationalID_Front, forKey: UserProperties.nationalIdFront.rawValue)
        userDefaults.set(user.nationalID_Back, forKey: UserProperties.nationalIdBack.rawValue)
        userDefaults.set(user.birthdate, forKey: UserProperties.birthdate.rawValue)
    }
    
    func removeUserFromUserDefaults() {
        
        userDefaults.removeObject(forKey: UserProperties.userId.rawValue)
        userDefaults.removeObject(forKey: UserProperties.userName.rawValue)
        userDefaults.removeObject(forKey: UserProperties.userEmail.rawValue)
        userDefaults.removeObject(forKey: UserProperties.password.rawValue)
        userDefaults.removeObject(forKey: UserProperties.verified.rawValue)
        userDefaults.removeObject(forKey: UserProperties.userStatus.rawValue)
        
        userDefaults.removeObject(forKey: UserProperties.mobileNumber.rawValue)
        userDefaults.removeObject(forKey: UserProperties.profileImage.rawValue)
        userDefaults.removeObject(forKey: UserProperties.nationalIdFront.rawValue)
        userDefaults.removeObject(forKey: UserProperties.job.rawValue)
        userDefaults.removeObject(forKey: UserProperties.nationalIdFront.rawValue)
        userDefaults.removeObject(forKey: UserProperties.nationalIdBack.rawValue)
        userDefaults.removeObject(forKey: UserProperties.birthdate.rawValue)
    }
}

//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 09/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

import Foundation

class UdacityClient : NSObject{
    
    
    // shared session
    var session = URLSession.shared
    
    // configuration object
    //var config = TMDBConfig()
    
    // authentication state
    var sessionID : String? = nil
    var accountKey: String? = nil
    
    //user info
    var firstName: String!
    var lastName: String!
    
    func createSesion(username: String, password: String, completitionHandler:@escaping (_ success: Bool, _ error: String?)-> Void){
        let request = NSMutableURLRequest(url: URL(string: UdacityClient.Constants.UdacityApiUrl + UdacityClient.UdacityApiMethods.getSessionMethod)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        print(request.url)
        
        let task = session.dataTask(with: request as URLRequest){
            
            data, response, error in
            if error != nil {
                completitionHandler(false,"Login Failed (\(error?.localizedDescription))")
                return
            }
            
            guard let data = data else {
                completitionHandler(false,"Login Failed (No response from server)")
                return
            }
            
            //found this solution on the udacity forum
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r)) /* subset response data! */
            
            var parsedResult: AnyObject
            let parsedErrorString = "Login Failed (Wrong response from server)"
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                completitionHandler(false,parsedErrorString)
                return
            }
            
            guard let accountDict = parsedResult[UdacityClient.JSONResponseKeys.Account] as? [String: AnyObject] else {
                completitionHandler(false, parsedErrorString)
                return
            }
            
            guard let accountKey = accountDict[UdacityClient.JSONResponseKeys.Key] as? String else {
                completitionHandler(false, parsedErrorString)
                return
            }
            guard let sessionDict = parsedResult[UdacityClient.JSONResponseKeys.Session] as? [String: AnyObject] else {
                completitionHandler(false, parsedErrorString)
                return
            }
            
            guard let sessionId = sessionDict[UdacityClient.JSONResponseKeys.Id] as? String else {
                completitionHandler(false, parsedErrorString)
                return
            }
            self.accountKey = accountKey
            self.sessionID = sessionId
            completitionHandler(true, nil)
            
        }
        task.resume()
    }
    
    func deleteSession( _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void ){
        let request = NSMutableURLRequest(url: NSURL(string: UdacityClient.Constants.UdacityApiUrl + UdacityClient.UdacityApiMethods.getSessionMethod)! as URL)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            
            data, response, error in
            if error != nil {
                completionHandler(false,"Logout Failed (\(error?.localizedDescription))")
                return
            }
            
            guard let data = data else {
                completionHandler(false,"Logout Failed (NO Data from server)")
                return
            }
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r)) /* subset response data! */
            var parsedResult: AnyObject!
            let parsedErrorString = "Logout Failed (Wrong response from server)"
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                completionHandler(false, parsedErrorString)
                return
            }
            guard let _ = parsedResult[UdacityClient.JSONResponseKeys.Session] as? [String: AnyObject] else {
                completionHandler(false, parsedErrorString)
                return
            }
            self.accountKey = ""
            self.sessionID = ""
            
            completionHandler(true, nil)
        }
        task.resume()
    }
    
    func getUserData(completionHandlerForUserData: @escaping (_ result: [Student]?, _ error: String?) -> Void){
        
        let request = NSMutableURLRequest(url: NSURL(string: UdacityClient.Constants.UdacityParseApiUrl+"?"+UdacityClient.UdacityParseApiMethodsParameters.limit100+"&"+UdacityClient.UdacityParseApiMethodsParameters.orderUpdateAt)! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if let error = error {
                completionHandlerForUserData(nil, "Get Students Failed \(error.localizedDescription))")
            } else {
                guard let data = data else {
                    completionHandlerForUserData(nil, "Get Students Failed (NO Data from server)")
                    return
                }
                var parsedResult: AnyObject!
                let parsedErrorString = "Get Students Failed (Wrong response from server)"
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as AnyObject!
                } catch {
                    completionHandlerForUserData(nil, parsedErrorString)
                }
                if let results = parsedResult["results"] as? [[String:AnyObject]] {
                    let students = Student.studentsFromResult(results: results)
                    completionHandlerForUserData(students, nil)
                } else {
                    completionHandlerForUserData(nil,parsedErrorString)
                }
            }
        }
        task.resume()
        
    }
    
    func getUdacityUserData(_ accountKey: String!, completionHandlerForUdacityUserData: @escaping (_ success: Bool, _ error: String?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: UdacityClient.Constants.UdacityApiUrl + UdacityClient.UdacityApiMethods.getPublicUserDataUrl + accountKey)!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            
            data, response, error in
            if error != nil { // Handle error…
                completionHandlerForUdacityUserData(false, "Getting Public User Info Failed (\(error?.localizedDescription))")
                return
            }
            
            guard let data = data else {
                completionHandlerForUdacityUserData(false, "Getting Public User Info Failed (NO Data from server)")
                return
            }
            
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r)) /* subset response data! */
            
            var parsedResult: AnyObject!
            let parsedErrorString = "Getting Public User Info Failed (Wrong response from server)"
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                completionHandlerForUdacityUserData(false, parsedErrorString)
                return
            }
            
            guard let user = parsedResult["user"] as? [String: AnyObject] else {
                completionHandlerForUdacityUserData(false, parsedErrorString)
                return
            }
    
            guard let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String else {
                completionHandlerForUdacityUserData(false, parsedErrorString)
                return
            }
            
            self.firstName = firstName
            self.lastName = lastName
            
            completionHandlerForUdacityUserData(true, nil)
            
        }
        
        task.resume()

        
    }
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (_ result: Any?, _ error: String?) -> Void) {
        
        var parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
        } catch {
            completionHandlerForConvertData(nil, "Could not parse the data as JSON")
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    
    func postStudentPin(_ mapPin: MapPin, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void ){
        let request = NSMutableURLRequest(url: NSURL(string: UdacityClient.Constants.UdacityParseApiUrl)! as URL)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let httpBodyString = "{\"uniqueKey\": \"\(self.accountKey!)\", \"firstName\": \"\(self.firstName!)\", \"lastName\": \"\(self.lastName!)\",\"mapString\": \"\(mapPin.locationName!))\", \"mediaURL\": \"\(mapPin.mediaURL!)\",\"latitude\": \(mapPin.latitude), \"longitude\": \(mapPin.longitude)}"
        request.httpBody = httpBodyString.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        print(request.httpBody)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandler(false, "Submitting failed \(error?.localizedDescription)")
                return
            }
            guard let data = data else {
                completionHandler(false, "Submitting failed (No response from server)")
                return
            }
            
            var parsedResult: AnyObject!
            let parsedErrorString = "Submitting failed (Wrong response from server"
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch {
                completionHandler(false, parsedErrorString)
                return
            }
            print(parsedResult)
            guard let errorMessage = parsedResult["error"] , errorMessage == nil else {
                let errorMessage = parsedResult["error"] as! String
                completionHandler(false, "Submitting failed \(errorMessage)")
                return
            }
            
            guard let _ = parsedResult["objectId"] as? String else {
                completionHandler(false, parsedErrorString)
                return
            }
            
            completionHandler(true, nil)
        }
        task.resume()
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}

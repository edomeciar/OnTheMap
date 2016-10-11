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
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        print(request.url)
        
        let task = session.dataTask(with: request as URLRequest){
            
            data, response, error in
            if error != nil {
                completitionHandler(false,"Log in Failed (Session Id Data Error)")
                return
            }
            
            
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r)) /* subset response data! */
            var parsedResult: AnyObject
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                print("Could not parse the data as JSON: '\(newData)'")
                
                return
            }
            
            guard let accountDict = parsedResult["account"] as? [String: AnyObject] else {
                print("Can't find key 'account' in \(parsedResult)")
                completitionHandler(false, "Login Failed (Wrong response from server")
                return
            }
            
            guard let accountKey = accountDict["key"] as? String else {
                print("Can't find key 'account[key]' in \(parsedResult)")
                completitionHandler(false, "Login Failed (Wrong response from server")
                return
            }
            
            
            print("accountKey:\(accountKey)")
            
            guard let sessionDict = parsedResult["session"] as? [String: AnyObject] else {
                print("Can't find key 'session' in \(parsedResult)")
                completitionHandler(false, "Login Failed (Wrong response from server")
                return
            }
            
            guard let sessionId = sessionDict["id"] as? String else {
                print("Can't find key 'session[id]' in \(parsedResult)")
                completitionHandler(false, "Login Failed (Wrong response from server")
                return
            }
            self.accountKey = accountKey
            self.sessionID = sessionId
            completitionHandler(true, nil)
            
        }
        task.resume()
    }
    
    func deleteSession( _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void ){
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
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
                completionHandler(false,"Logout Failed (Session Id Data Error)")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r)) /* subset response data! */
            var parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                print("Could not parse the data as JSON: '\(newData)'")
                completionHandler(false, "Logout Failed (Wrong response from server")
                return
            }
            guard let _ = parsedResult["session"] as? [String: AnyObject] else {
                print("Can't find key 'session' in \(parsedResult)")
                completionHandler(false, "Logout Failed (Wrong response from server")
                return
            }
            self.accountKey = ""
            self.sessionID = ""
            
            completionHandler(true, nil)
        }
        task.resume()
    }
    
    func getUserData(completionHandlerForUserData: @escaping (_ result: [Student]?, _ error: NSError?) -> Void){
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if let error = error {
                completionHandlerForUserData(nil, error as NSError?)
            } else {
                var parsedResult: AnyObject!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as AnyObject!
                } catch {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                    completionHandlerForUserData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
                }
                
                if let results = parsedResult["results"] as? [[String:AnyObject]] {
                    
                    let movies = Student.studentsFromResult(results: results)
                    completionHandlerForUserData(movies, nil)
                } else {
                    completionHandlerForUserData(nil, NSError(domain: "getUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse UserData"]))
                }
            }
        }
        task.resume()
        
    }
    
    func getUdacityUserData(_ accountKey: String!, completionHandlerForUdacityUserData: @escaping (_ success: Bool, _ error: String?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: UdacityClient.UdacityApiMethods.getPublicUserDataUrl + accountKey)!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            
            data, response, error in
            if error != nil { // Handle error…
                completionHandlerForUdacityUserData(false, "Getting Public User Data failed \(accountKey)")
                return
            }
            
            guard let data = data else {
                print("Data are empty")
                completionHandlerForUdacityUserData(false, "Data are empty")
                return
            }
            
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r)) /* subset response data! */
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                print("Could not parse the data as JSON: '\(newData)'")
                completionHandlerForUdacityUserData(false, "Public User Data (Wrong response from server")
                return
            }
            
            guard let user = parsedResult["user"] as? [String: AnyObject] else {
                print("Can't find key 'user' in \(parsedResult)")
                completionHandlerForUdacityUserData(false, "Public User Data (Wrong response from server")
                return
            }
            
            guard let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String else {
                print("Can't find key 'first_name' or 'last_name' in \(user)")
                completionHandlerForUdacityUserData(false, "Public User Data (Wrong response from server")
                return
            }
            
            self.firstName = firstName
            self.lastName = lastName
            print("Udacity User:\(firstName) \(lastName)")
            
            completionHandlerForUdacityUserData(true, nil)
            
        }
        
        task.resume()

        
    }
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (_ result: Any?, _ error: NSError?) -> Void) {
        
        var parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    
    // create a URL from parameters
    private func udacityURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]() as [URLQueryItem]?
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem as URLQueryItem)
        }
        
        return components.url! as NSURL
    }
    
    func postStudentPin(_ mapPin: MapPin, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void ){
        
        print("account key\(self.accountKey)")
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")! as URL)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(self.accountKey)\", \"firstName\": \"\(self.firstName)\", \"lastName\": \"\(self.lastName)\",\"mapString\": \"\(mapPin.locationName!))\", \"mediaURL\": \"\(mapPin.mediaURL!)\",\"latitude\": \(mapPin.latitude), \"longitude\": \(mapPin.longitude)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
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
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch {
                completionHandler(false, "Submitting failed (Wrong response from server")
                return
            }
            print(parsedResult)
            guard let errorMessage = parsedResult["error"] , errorMessage == nil else {
                let errorMessage = parsedResult["error"] as! String
                completionHandler(false, "Submitting failed \(errorMessage)")
                return
            }
            
            guard let _ = parsedResult["objectId"] as? String else {
                print("Can't find key 'objectId' in \(parsedResult)")
                completionHandler(false, "Submitting Failed (Wrong response from server")
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

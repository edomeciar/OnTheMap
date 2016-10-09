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
            if error != nil { // Handle error…
                return
            }
            
            
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            print("not subdata")
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            print("no encoding")
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r)) /* subset response data! */
           
            print("subdata print")
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue))
            print("no encoding")
            print(newData)

            
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
            
            self.accountKey = accountKey
            
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
            
            self.sessionID = sessionId
            
            self.getUserData()
            
            completitionHandler(true, nil)
            
        }
        task.resume()
    }
    
    
    func getUserData(){
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
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
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}

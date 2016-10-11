//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 09/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

extension UdacityClient{
    
    struct Constants{
        static let ApiKey : String = "Udacity app key"
        static let ApiScheme = "https"
        static let ApiHost = "???"
        static let ApiPath = "???"
    }
    
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
    }
    
    struct UdacityApiMethods {
        static let getPublicUserDataUrl = "https://www.udacity.com/api/users/"
    }
    
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
    }
}

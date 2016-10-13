//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 09/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

extension UdacityClient{
    
    struct Constants{
        static let UdacityApiUrl = "https://www.udacity.com/api/"
        static let UdacityParseApiUrl = "https://parse.udacity.com/parse/classes/StudentLocation"
    }
    
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
    }
    
    struct UdacityApiMethods {
        static let getPublicUserDataUrl = "users/"
        static let getSessionMethod = "session"
        static let getPublicUserDataMethod = "users"
    }
    
    struct UdacityParseApiMethodsParameters{
        static let limit100 = "limit=100"
        static let orderUpdateAt = "order=-updatedAt"
    }
    
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Account = "account"
        static let Session = "session"
        static let Key = "key"
        static let Id = "id"
    }
}

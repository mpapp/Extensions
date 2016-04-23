//
//  NSURLRequest+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

typealias HTTPStatusCode = Int

enum SynchronousRequestError: ErrorType {
    case NoData(NSURLRequest)
    case NoStatus(NSURLRequest)
}

extension NSURLConnection {
    static func sendSynchronousRequest(request:NSURLRequest) throws -> (data:NSData, statusCode:HTTPStatusCode) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        var responseData:NSData? = nil
        var responseCode:HTTPStatusCode? = nil
        var responseError:NSError? = nil
        
        let group = dispatch_group_create()
        dispatch_group_enter(group)
        
        session.dataTaskWithRequest(request, completionHandler: {(data, response, err) in
            if let httpResponse = response as? NSHTTPURLResponse {
                responseCode = httpResponse.statusCode
                responseData = data
            }
            
            responseError = err
            dispatch_group_leave(group)
        }).resume()
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        
        if let responseError = responseError {
            throw responseError
        }
        
        guard let data = responseData else {
            throw SynchronousRequestError.NoData(request)
        }
        
        guard let code = responseCode else {
            throw SynchronousRequestError.NoStatus(request)
        }
        
        return (data, code)
    }
}
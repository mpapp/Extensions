//
//  NSURLRequest+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import MPRateLimiter

typealias HTTPStatusCode = Int

enum SynchronousRequestError: ErrorType {
    case NoData(NSURLRequest)
    case NoStatus(NSURLRequest)
}

typealias ResponseTuple = (data:NSData, statusCode:HTTPStatusCode)

extension NSURLConnection {
    static func sendSynchronousRequest(request:NSURLRequest) throws -> ResponseTuple {
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
    
    private static let rateLimiter:RateLimiter = RateLimiter()
    
    static func sendRateLimitedSynchronousRequest(request:NSURLRequest, rateLimitLabel:String, rateLimit:NSTimeInterval) throws -> (data:NSData, statusCode:HTTPStatusCode) {
        var response:ResponseTuple?
        var err:ErrorType?
        
        var executed = false
        
        rateLimiter.execute(key: rateLimitLabel, rateLimit: rateLimit) { 
            executed = true
            do {
                response = try self.sendSynchronousRequest(request)
            }
            catch {
                err = error
            }
        }
        
        if let err = err {
            throw err
        }
        
        guard let resp = response else {
            preconditionFailure("Response tuple is unexpectedly nil (executed: \(executed)")
        }
        
        return resp
    }
}
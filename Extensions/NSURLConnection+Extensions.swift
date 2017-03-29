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

enum SynchronousRequestError: Error {
    case noData(URLRequest)
    case noStatus(URLRequest)
}

typealias ResponseTuple = (data:Data, statusCode:HTTPStatusCode)

extension NSURLConnection {
    static func sendSynchronousRequest(_ request:URLRequest) throws -> ResponseTuple {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        var responseData:Data? = nil
        var responseCode:HTTPStatusCode? = nil
        var responseError:NSError? = nil
        
        let group = DispatchGroup()
        group.enter()
        
        session.dataTask(with: request, completionHandler: {(data, response, err) in
            if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
                responseData = data
            }
            
            responseError = err as NSError?
            group.leave()
        }).resume()
        
        _ = group.wait(timeout: DispatchTime.distantFuture)
        
        if let responseError = responseError {
            throw responseError
        }
        
        guard let data = responseData else {
            throw SynchronousRequestError.noData(request)
        }
        
        guard let code = responseCode else {
            throw SynchronousRequestError.noStatus(request)
        }
        
        return (data, code)
    }
    
    fileprivate static let rateLimiter:RateLimiter = RateLimiter()
    
    static func sendRateLimitedSynchronousRequest(_ request:URLRequest, rateLimitLabel:String, rateLimit:TimeInterval) throws -> (data:Data, statusCode:HTTPStatusCode) {
        var response:ResponseTuple?
        var err:Error?
        
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

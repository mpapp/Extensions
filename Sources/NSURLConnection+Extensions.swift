//
//  NSURLRequest+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//
//  ---------------------------------------------------------------------------
//
//  © 2019 Atypon Systems LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
        var responseError:Swift.Error? = nil
        
        let group = DispatchGroup()
        group.enter()
        
        session.dataTask(with: request, completionHandler: {(data, response, err) in
            if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
                responseData = data
            }
            
            responseError = err
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

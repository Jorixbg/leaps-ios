//
//  NetworkManager.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import Alamofire

enum LeapsError: Error {
    case noData
    case badRequest
    case serverError
    case deserializing
    case noInternet
    case missingToken
    case missingLoginData
    case missingForgottenPassEmail
    case missingID
    case unauthorized
    case other(Error)
}

extension LeapsError: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: LeapsError, rhs: LeapsError) -> Bool {
        return String(stringInterpolationSegment: lhs) == String(stringInterpolationSegment: rhs)
    }
}

enum Result<T> {
    case success(T)
    case error(Error)
}

class NetworkManager {
    
    private let baseURL: String
    
    init(baseURL: String = Constants.baseURL) {
        self.baseURL = baseURL
    }
    
    func get(path: String, params: [String: Any]? = nil, headers: [String: String]? = nil, completion: ((Result<Any>) -> Void)? = nil) {
        let url = "\(baseURL)\(path)"
        requestJSON(toUrl: url, usingMethod: .get, withParams: params, withHeaders: headers, completion: completion)
    }
    
    func post(path: String, params: [String: Any]? = nil, headers: [String: String]? = nil, completion: ((Result<Any>) -> Void)? = nil) {
        let url = "\(baseURL)\(path)"
        requestJSON(toUrl: url, usingMethod: .post, withParams: params, withHeaders: headers, completion: completion)
    }
    
    func delete(path: String, params: [String: Any]? = nil, headers: [String: String]? = nil, completion: ((Result<Any>) -> Void)? = nil) {
        let url = "\(baseURL)\(path)"
        requestJSON(toUrl: url, usingMethod: .delete, withParams: params, withHeaders: headers, completion: completion)
    }

    func put(path: String, params: [String: Any]? = nil, headers: [String: String]? = nil, completion: ((Result<Any>) -> Void)? = nil) {
        let url = "\(baseURL)\(path)"
        requestJSON(toUrl: url, usingMethod: .put, withParams: params, withHeaders: headers, completion: completion)
    }
    
    //still initial stage
    func upload(manager: SessionManager = Alamofire.SessionManager.default,
                imageData: Data,
                toUrl url: String,
                usingMethod method: HTTPMethod,
                withParams params: [String: String]? = nil,
                withHeaders headers: [String: String]? = nil) {
        
        let fullURL = "\(baseURL)\(url)"
        
        guard let url = URL(string: fullURL) else {
            return
        }
        
        print("saterted uploading")
        manager.upload(multipartFormData: { (multipartFormData) in
//            for imageData in imagesData {
                multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpg")
//            }
            
            if let params = params {
                for (key, value) in params {
                    guard let paramAsData = value.data(using: .utf8, allowLossyConversion: false) else {
                        continue
                    }
                    
                    multipartFormData.append(paramAsData , withName: key)
                }
            }
            
        }, to: url,
           method: .put,
           headers: headers) { (result) in
            switch result {
            case .success(let request, streamingFromDisk: _, streamFileURL: _):
                request.responseJSON { response in
                    print("ended uploading")
                    NotificationCenter.default.post(name: .refreshOnImageUpload, object: nil)
                }
                //TODO: not sure if this should be here
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func requestJSON(manager: SessionManager = Alamofire.SessionManager.default,
                     toUrl url: String,
                     usingMethod method: HTTPMethod,
                     withParams params: [String: Any]? = nil,
                     withHeaders headers: [String: String]? = nil,
                     completion: ((Result<Any>) -> Void)?) {
        
        //fix for alamofire issue with setting json body in post request
        let encoding: ParameterEncoding
        if headers?["Content-Type"] == "application/json" {
            encoding = JSONEncoding.default
        } else {
            encoding = URLEncoding.default
        }
        
        manager.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { [weak self] (response) in
                //handle sign in from here
                print("======== RESULT = \(response.result)")
                print("======== request URL = \(String(describing: response.request?.url))=======\n")
                print("======== headers = \(String(describing: headers))=======\n")
                print("======== params =\(String(describing: params))=======\n")
                print("======== status code =\(String(describing: response.response?.statusCode))")
//                print("response result = \(response.result.debugDescription)")
                if let token = response.response?.allHeaderFields["Authorization"] as? String {
                    UserManager.shared.setToken(authToken: token)
                }
                
                self?.handleJSONResponse(response: response, completion: completion)
        }
    }
    
    private func handleJSONResponse(response: DataResponse<Any>, completion: ((Result<Any>) -> Void)?) {
        switch response.result {
        case .success(let json):
            completion?(.success(json))
        case .failure(let error):
            let responseCode: Int
            // needed as -1009 is not returned as AFError
            if let afError = error as? AFError, let code = afError.responseCode {
                responseCode = code
            } else {
                responseCode = error.code
            }
            
            let errorToReport: Error
            switch responseCode {
            case 400:
                errorToReport = LeapsError.badRequest
            case 401:
                errorToReport = LeapsError.unauthorized
                UserManager.shared.logout()
            case 500..<600:
                errorToReport = LeapsError.serverError
            case -1009:
                errorToReport = LeapsError.noInternet
            default:
                errorToReport = error
                break
            }
            
            completion?(.error(errorToReport))
        }
    }
}


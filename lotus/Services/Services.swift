//
//  Services.swift
//  lotus
//
//  Created by Robert Grube on 1/30/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import Alamofire


func nocheck_httpRequest(_ requestPath: String, method: HTTPMethod = .post, params: Parameters?, shouldSendAuth: Bool = true, sendErrorNotification : Bool = true, suppressResponseLog : Bool = false, completion: @escaping (AFDataResponse<Data?>) -> Void) {
    
    let request = AF.request(requestPath, method: method, parameters: params, encoding: JSONEncoding.default, headers: shouldSendAuth ? defaultHeaders : defaultHeadersNoAuth)

    request.response { response in
        guard let data = response.data else { return }
        print("URL:       \(requestPath)")
        print("METHOD:    \(method.rawValue)")
        print("PARAMETERS:\(params?.debugDescription ?? "nil")")
        if(!suppressResponseLog){
            data.printDebug()
        }
        do {
            let decoder = LotusJSONDecoder()
            let error = try decoder.decode(LotusError.self, from: data)
            guard let token = Globals.sharedInstance.token else { completion(response); return }
            if(error.expiredToken){
                // if token is expired, call the refresh, then recall the original call
                
                if(requestPath.contains("refresh")){
                    Globals.sharedInstance.semaphore.signal()
                    NotificationCenter.default.post(name: .navigateToLogin, object: nil)
                    return
                }
                        
                Alamofire.Session.default.cancelAllRequests(completingOnQueue: .main) {
                    AuthServices.refresh(token: token.refreshToken) { (token, error) in
                        httpRequest(requestPath, method: method, params: params, shouldSendAuth: shouldSendAuth) { (response) in
                            completion(response)
                        }
                    }
                }
                
                
            } else if(error.expiredSpotifyToken){
                if let token = SpotifyToken.load() {
                    print("SPOTIFY TOKEN LOADED : REFRESHING")
                    ContentServices.refreshSpotifyToken(token: token.accessToken, refreshToken: token.refreshToken) { (newToken, error) in
                        if newToken != nil {
                            httpRequest(requestPath, method: method, params: params, shouldSendAuth: shouldSendAuth) { (response) in
                                completion(response)
                            }
                        }
                    }
                } else {
                    if(sendErrorNotification){
                        NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: ["error":error])
                        completion(response)
                    }
                }
            } else {
                NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: ["error":error])
                completion(response)
            }
        } catch {
            completion(response)
        }
    }
    
}

func httpRequest(_ requestPath: String, method: HTTPMethod = .post, params: Parameters?, shouldSendAuth: Bool = true, sendErrorNotification : Bool = true, suppressResponseLog : Bool = false, completion: @escaping (AFDataResponse<Data?>) -> Void) {
    
    Globals.sharedInstance.semaphore.wait()
    
    let request = AF.request(requestPath, method: method, parameters: params, encoding: JSONEncoding.default, headers: shouldSendAuth ? defaultHeaders : defaultHeadersNoAuth)

    request.response { response in
        guard let data = response.data else { return }
        print("URL:       \(requestPath)")
        print("METHOD:    \(method.rawValue)")
        print("PARAMETERS:\(params?.debugDescription ?? "nil")")
        if(!suppressResponseLog){
            data.printDebug()
        }
        do {
            let decoder = LotusJSONDecoder()
            let error = try decoder.decode(LotusError.self, from: data)
            guard let token = Globals.sharedInstance.token else {
                completion(response)
                return
            }
            if(error.expiredToken){
                // if token is expired, call the refresh, then recall the original call
                        
                Alamofire.Session.default.cancelAllRequests(completingOnQueue: .main) {
                    AuthServices.refresh(token: token.refreshToken) { (token, error) in
                        nocheck_httpRequest(requestPath, method: method, params: params, shouldSendAuth: shouldSendAuth) { (response) in
                            completion(response)
                        }
                    }
                }
            } else if(error.expiredSpotifyToken){
                if let token = SpotifyToken.load() {
                    print("SPOTIFY TOKEN LOADED : REFRESHING")
                    ContentServices.refreshSpotifyToken(token: token.accessToken, refreshToken: token.refreshToken) { (newToken, error) in
                        if newToken != nil {
                            nocheck_httpRequest(requestPath, method: method, params: params, shouldSendAuth: shouldSendAuth) { (response) in
                                completion(response)
                            }
                        } else {
                            let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .userReadRecentlyPlayed, .userReadPrivate, .userModifyPlaybackState, .userReadPlaybackState]
                            Globals.sharedInstance.sessionManager.initiateSession(with: scope, options: .clientOnly)
                            completion(response)
                        }
                    }
                } else {
                    if(sendErrorNotification){
                        NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: ["error":error])
                        completion(response)
                    }
                }
            } else {
                NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: ["error":error])
                completion(response)
            }
        } catch {
            completion(response)
        }
    }
    
    Globals.sharedInstance.semaphore.signal()
}

func uploadRequest(_ requestPath: String, data: Data, dataName: String, sendErrorNotification : Bool = true, completion: @escaping (AFDataResponse<Data?>) -> Void) {
    
    let request = AF.upload(multipartFormData: { multipartFormData in
        multipartFormData.append(data, withName: dataName, fileName: "photo.jpg", mimeType: "image/jpeg")
    }, to: requestPath, method: .post, headers: defaultHeaders)
            
    request.response { response in
        guard let data = response.data else { return }
        print("URL:       \(requestPath)")
        print("METHOD:    UPLOAD")
        print("DATA NAME: \(dataName)")
        if let h = request.request?.headers {
            print("HEADERS:   \(h)")
        } else {
            print("NO HEADERS")
        }
        
        data.printDebug()
        do {
            let decoder = LotusJSONDecoder()
            let error = try decoder.decode(LotusError.self, from: data)
            guard let token = Globals.sharedInstance.token else { return }
            if(error.expiredToken){
                // if token is expired, call the refresh, then recall the original call
                AuthServices.refresh(token: token.refreshToken) { (token, error) in
                    uploadRequest(requestPath, data: data, dataName: dataName) { (response) in
                        completion(response)
                    }
                }
            } else {
                if(sendErrorNotification){
                    NotificationCenter.default.post(name: .didReceiveError, object: nil, userInfo: ["error":error])
                }
            }
        } catch {
            completion(response)
        }
    }
    
    
}

extension Data {
    func printDebug(){
        if let str = String(data: self, encoding: .utf8){
            print(str)
        } else {
            print("ERROR DECODING JSON")
        }
    }
}

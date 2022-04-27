//
//  DataFetcher.swift
//  Wormholy-Demo-iOS
//
//  Created by Paolo Musolino on 18/01/18.
//  Copyright © 2018 Wormholy. All rights reserved.
//

import Foundation
import Wormholy

class SessionDelegate: NSObject, URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        Wormholy.eventMonitor.didReceive(dataTask, response: response)
        completionHandler(.allow)
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Wormholy.eventMonitor.didReceive(task, error: error)
    }
}

class WormholySession {
    let session: URLSession
    init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {
        session = .init(configuration: configuration, delegate: delegate, delegateQueue: queue)
    }
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        var expectedTask: URLSessionDataTask?
        let newHandler: (Data?, URLResponse?, Error?) -> Void = {
            if let expectedTask = expectedTask {
                Wormholy.eventMonitor.didReceive(expectedTask, data: $0, response: $1, error: $2)
            }
            completionHandler($0, $1, $2)
        }
        let task = session.dataTask(with: request, completionHandler: newHandler)
        expectedTask = task
        Wormholy.eventMonitor.didStart(task, session: session)
        return task
    }
}

class DataFetcher: NSObject {

    var session : WormholySession? //Session manager
    var delegate: SessionDelegate?
    
    //MARK: Singleton
    static let sharedInstance = DataFetcher(managerCachePolicy: .reloadIgnoringLocalCacheData)
    
    //MARK: Init
    override init() {
        super.init()
    }
    
    init(managerCachePolicy:NSURLRequest.CachePolicy){
        super.init()
        self.configure(cachePolicy: managerCachePolicy)
    }
    
    //MARK: Session Configuration
    func configure(cachePolicy:NSURLRequest.CachePolicy?){
        let sessionConfiguration = URLSessionConfiguration.default //URLSessionConfiguration()
        sessionConfiguration.timeoutIntervalForRequest = 10.0
        sessionConfiguration.requestCachePolicy = cachePolicy != nil ? cachePolicy! : .reloadIgnoringLocalCacheData
        sessionConfiguration.httpAdditionalHeaders = ["Accept-Language": "en"]
        delegate = .init()
        self.session = WormholySession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: nil)
    }
    
    
    //MARK: API Track
    func getPost(id: Int, completion: @escaping () -> Void, failure:@escaping (Error) -> Void){
        var urlRequest = Routing.Post(id).urlRequest
        urlRequest.httpMethod = "GET"
        
        let task = session?.dataTask(with: urlRequest) {
            (
            data, response, error) in
            
            guard response?.validate() == nil else{
                failure(response!.validate()!)
                return
            }
            DispatchQueue.main.async {
                completion()
            }
        }

        task?.resume()
    }
    
    func newPost(userId: Int, title: String, body: String, completion: @escaping () -> Void, failure:@escaping (Error) -> Void){
        var urlRequest = Routing.NewPost(userId: userId, title: title, body: body).urlRequest
        urlRequest.httpMethod = "POST"
        
        let task = session?.dataTask(with: urlRequest) {
            (
            data, response, error) in
            
            guard response?.validate() == nil else{
                failure(response!.validate()!)
                return
            }
            DispatchQueue.main.async {
                completion()
            }
        }

        task?.resume()
    }
    
    func getWrongURL(completion: @escaping () -> Void, failure:@escaping (Error) -> Void){
        var urlRequest = Routing.WrongURL(()).urlRequest
        urlRequest.httpMethod = "GET"
        
        let task = session?.dataTask(with: urlRequest) {
            (
            data, response, error) in
            
            guard response?.validate() == nil else{
                failure(response!.validate()!)
                return
            }
            DispatchQueue.main.async {
                completion()
            }
        }

        task?.resume()
    }
    
    func getPhotosList(completion: @escaping () -> Void, failure:@escaping (Error) -> Void){
        var urlRequest = Routing.Photos(()).urlRequest
        urlRequest.httpMethod = "GET"
        
        let task = session?.dataTask(with: urlRequest) {
            (
            data, response, error) in
            
            guard response?.validate() == nil else{
                failure(response!.validate()!)
                return
            }
            DispatchQueue.main.async {
                completion()
            }
        }

        task?.resume()
    }
}


//
//  Storage.swift
//  Wormholy-SDK-iOS
//
//  Created by Paolo Musolino on 04/02/18.
//  Copyright © 2018 Wormholy. All rights reserved.
//

import Foundation

open class Storage: NSObject {

    public static let shared: Storage = Storage()
  
    public static var limit: NSNumber? = nil

    public static var defaultFilter: String? = nil
    
    open var requests: [RequestModel] = []
    
    func saveRequest(request: RequestModel?){
        guard request != nil else {
            return
        }
        
        if let index = requests.firstIndex(where: { (req) -> Bool in
            return request?.id == req.id ? true : false
        }){
            requests[index] = request!
        }else{
            requests.insert(request!, at: 0)
        }

        if let limit = Self.limit?.intValue {
            requests = Array(requests.prefix(limit))
        }
        NotificationCenter.default.post(name: newRequestNotification, object: nil)
    }

    func clearRequests() {
        requests.removeAll()
    }
}

extension Storage: WormholyEventMonitorType {

    public func updateRequest(_ task: URLSessionTask, request: URLRequest) {
        guard let model = getRequest(for: task) else { return }
        model.httpBody = body(from: request)
        updateDuration(in: model)
        saveRequest(request: model)
    }

    public func didStart(_ task: URLSessionTask, session: URLSession?) {
        guard let request = task.currentRequest else { return }
        let model = RequestModel(id: getId(for: task), request: request as NSURLRequest, session: session)
        saveRequest(request: model)
    }

    public func didReceive(_ task: URLSessionTask, data: Data?, response: URLResponse?, error: Error?) {
        if let response = response {
            didReceive(task, response: response)
        }
        if let data = data {
            didReceive(task, data: data)
        }
        if let error = error {
            didReceive(task, error: error)
        }
    }

    public func didReceive(_ task: URLSessionTask, data: Data) {
        guard let request = getRequest(for: task) else { return }
        if request.dataResponse == nil {
            request.dataResponse = data
        } else {
            request.dataResponse?.append(data)
        }
        updateDuration(in: request)
        saveRequest(request: request)
    }

    public func didReceive(_ task: URLSessionTask, response: URLResponse) {
        guard let request = getRequest(for: task) else { return }
        request.initResponse(response: response)
        updateDuration(in: request)
        saveRequest(request: request)
    }

    public func didReceive(_ task: URLSessionTask, error: Error?) {
        guard let request = getRequest(for: task) else { return }
        request.errorClientDescription = error?.localizedDescription
        updateDuration(in: request)
        saveRequest(request: request)
    }

}

private extension Storage {

    func body(from request: URLRequest?) -> Data? {
        /// The receiver will have either an HTTP body or an HTTP body stream only one may be set for a request.
        /// A HTTP body stream is preserved when copying an NSURLRequest object,
        /// but is lost when a request is archived using the NSCoding protocol.
        return request?.httpBody ?? request?.httpBodyStream?.readfully()
    }

    func updateDuration(in request: RequestModel) {
        let startDate = request.date
        request.duration = fabs(startDate.timeIntervalSinceNow) * 1000 //Find elapsed time and convert to milliseconds
    }

    func getRequest(for task: URLSessionTask) -> RequestModel? {
        requests.first(where: { $0.id == getId(for: task) })
    }

    func getId(for task: URLSessionTask) -> String {
        task.description
    }
    
}

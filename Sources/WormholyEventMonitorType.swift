//
//  WormholyEventMonitorType.swift
//  Wormholy-iOS
//
//  Created by Вильян Яумбаев on 26.04.2022.
//  Copyright © 2022 Wormholy. All rights reserved.
//

import Foundation

public protocol WormholyEventMonitorType {
    func didStart(_ task: URLSessionTask, session: URLSession?)
    func updateRequest(_ task: URLSessionTask, request: URLRequest)
    func didReceive(_ task: URLSessionTask, data: Data?, response: URLResponse?, error: Error?)
    func didReceive(_ task: URLSessionTask, data: Data)
    func didReceive(_ task: URLSessionTask, response: URLResponse)
    func didReceive(_ task: URLSessionTask, error: Error?)
}

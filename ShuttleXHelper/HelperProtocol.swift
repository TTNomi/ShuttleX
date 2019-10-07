//
//  RemoteProcessProtocol.swift
//  ProcessRunnerExample
//
//  Created by Suolapeikko
//

import Foundation

struct HelperConstants {
    static let machServiceName = "top.sipt.ShuttleXHelper"
}

/// Protocol with inter process method invocation methods that ProcessHelper supports
/// Because communication over XPC is asynchronous, all methods in the protocol must have a return type of void
@objc protocol HelperProtocol {
    func getVersion(reply: @escaping (String) -> Void)
    func runCommand(path: String, reply: @escaping (String) -> Void)
    func setProxySettings(proxies: [NSObject: AnyObject])
    func getProxySettings(reply: @escaping ([NSObject: AnyObject])-> Void)
}

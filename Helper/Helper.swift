//
//  Helper.swift
//  shuttleX
//
//  Created by sipt on 2019/9/24.
//  Copyright © 2019 sipt. All rights reserved.
//

import Foundation

@objc protocol PShuttleXHelper{
    func EnableProxy(_ settings: [NSObject : AnyObject])
    func DisableProxy()
    func ProxyChanged(_ reply: (Bool) -> Void)
    func Exit()
}

class ShuttleXHelper: NSObject, NSXPCListenerDelegate, PShuttleXHelper {
    
    static let HelperServiceName = "top.sipt.ShuttleX.Helper"
    
    var listener: NSXPCListener
    var proxySettings: ProxySettings = ProxySettings()
    var exit: Bool = false
    
    override init() {
        listener = NSXPCListener(machServiceName: ShuttleXHelper.HelperServiceName)
        super.init()
        listener.delegate = self
    }
    
    func run() {
        listener.resume()
        while !self.exit {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 2.0))
        }
    }
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        connection.exportedInterface = NSXPCInterface(with: PShuttleXHelper.self)
        connection.exportedObject = self
        connection.resume()
        return true
    }

    func EnableProxy(_ settings: [NSObject : AnyObject]){
        self.proxySettings.EnableProxy(settings: settings)
    }

    func DisableProxy(){
        self.proxySettings.DisableProxy()
    }

    func ProxyChanged(_ reply: (Bool) -> Void) {
        
    }
    
    func Exit() {
        self.exit = true
    }
}

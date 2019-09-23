//
//  Helper.swift
//  shuttleX
//
//  Created by sipt on 2019/9/24.
//  Copyright © 2019 sipt. All rights reserved.
//

import Foundation

@objc protocol PShuttleXHelper{
    func EnableProxy(_ settings: ProxySetting)
    func DisableProxy()
    func ProxyChanged(_ reply: (Bool) -> Void)
}

class ShuttleXHelper: NSObject, NSXPCListenerDelegate, PShuttleXHelper {
    
    static let HelperServiceName = "top.sipt.ShuttleX.Helper"
    
    var listener: NSXPCListener
    var proxySettings: ProxySettings = ProxySettings()
    
    override init() {
        listener = NSXPCListener(machServiceName: ShuttleXHelper.HelperServiceName)
        super.init()
        listener.delegate = self
    }
    
    func run() {
        listener.resume()
        RunLoop.current.run()
    }
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: PShuttleXHelper.self)
        newConnection.exportedObject = self
        newConnection.resume()
        return true
    }

    func EnableProxy(_ settings: ProxySetting){
        self.proxySettings.EnableProxy(settings: settings)
    }

    func DisableProxy(){
        self.proxySettings.DisableProxy()
    }

    func ProxyChanged(_ reply: (Bool) -> Void) {
        
    }
}

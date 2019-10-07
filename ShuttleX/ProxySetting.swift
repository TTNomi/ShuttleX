//
//  ProxySetting.swift
//  ShuttleX
//
//  Created by xinyan wu on 2019/10/2.
//  Copyright © 2019 sipt. All rights reserved.
//

import Foundation

class ProxySetting{
    var oldSettings: [NSObject: AnyObject]?
    var currentSettings: [NSObject: AnyObject]?
    init(){
        
    }
    
    func enableProxy(delegate: HelperProtocol, proxies: [NSObject: AnyObject]){
        if oldSettings == nil {
            delegate.getProxySettings { (settings) in
                self.oldSettings = settings
                NSLog("old network settings: \(self.oldSettings!)")
            }
        }
        self.currentSettings = proxies
        delegate.setProxySettings(proxies: self.currentSettings!)
    }
    
    func enableProxy(delegate: HelperProtocol, proxies: ProxySettings){
        self.enableProxy(delegate: delegate, proxies: proxies.toDictionary())
    }
    
    func disableProxy(delegate: HelperProtocol){
        if oldSettings == nil {
            return
        }
        NSLog("set to old network settings: \(self.oldSettings!)")
        delegate.setProxySettings(proxies: self.oldSettings!)
//        self.oldSettings = nil
//        self.currentSettings = nil
    }
}

class ProxySettings: NSObject{
    var httpHost: String?
    var httpPort: Int?
    var httpEnable: Int?
    var httpsHost: String?
    var httpsPort: Int?
    var httpsEnable: Int?
    var socksHost: String?
    var socksPort: Int?
    var socksEnable: Int?
    
    func toDictionary() -> [NSObject: AnyObject] {
        var dic = [NSObject: AnyObject]()
        if httpHost != nil {
            dic[kCFNetworkProxiesHTTPProxy] = self.httpHost as AnyObject?
        }
        if httpPort != nil {
            dic[kCFNetworkProxiesHTTPPort] = self.httpPort! as NSNumber
        }
        if httpEnable != nil {
            dic[kCFNetworkProxiesHTTPEnable] = self.httpEnable! as NSNumber
        }
        if httpsHost != nil {
            dic[kCFNetworkProxiesHTTPSProxy] = self.httpsHost! as AnyObject?
        }
        if httpsPort != nil {
            dic[kCFNetworkProxiesHTTPSPort] = self.httpsPort! as NSNumber
        }
        if httpsEnable != nil {
            dic[kCFNetworkProxiesHTTPSEnable] = self.httpsEnable! as NSNumber
        }
        if socksHost != nil {
            dic[kCFNetworkProxiesSOCKSProxy] = self.socksHost! as AnyObject?
        }
        if socksPort != nil {
            dic[kCFNetworkProxiesSOCKSPort] = self.socksPort! as NSNumber
        }
        if socksEnable != nil {
            dic[kCFNetworkProxiesSOCKSEnable] = self.socksEnable! as NSNumber
        }
        return dic
    }
}


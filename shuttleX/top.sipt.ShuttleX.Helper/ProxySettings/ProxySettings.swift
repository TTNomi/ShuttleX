//
//  ProxySettings.swift
//  shuttleX
//
//  Created by sipt on 2019/9/24.
//  Copyright © 2019 sipt. All rights reserved.
//

import SystemConfiguration
import Cocoa


@objc class ProxySetting{
    var httpHost: String
    var httpPort: Int
    var httpEnable: Int
    var httpsHost: String
    var httpsPort: Int
    var httpsEnable: Int
    var socksHost: String
    var socksPort: Int
    var socksEnable: Int
}

class ProxySettings {
    
    var oldSettings: [NSObject: AnyObject]?
    var authRef : AuthorizationRef?
    var prefRef : SCPreferences
    
    init(){
        var environment = AuthorizationEnvironment()
        let err = AuthorizationCreate(nil, &environment, [.interactionAllowed, .extendRights, .destroyRights], &authRef)
        assert(err == errAuthorizationSuccess)
        prefRef = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, "ShuttleX" as CFString, nil, authRef)!
        LoadSystemProxySettings()
    }
    
    func EnableProxy(settings: ProxySetting) {
        let settings = [
            kCFNetworkProxiesHTTPProxy : settings.httpHost as AnyObject?,
            kCFNetworkProxiesHTTPPort : settings.httpPort as NSNumber,
            kCFNetworkProxiesHTTPEnable : settings.httpEnable as NSNumber,
            kCFNetworkProxiesHTTPSProxy : settings.httpsHost as AnyObject?,
            kCFNetworkProxiesHTTPSPort : settings.httpsPort as NSNumber,
            kCFNetworkProxiesHTTPSEnable : settings.httpsEnable as NSNumber,
            kCFNetworkProxiesSOCKSProxy : settings.socksHost as AnyObject?,
            kCFNetworkProxiesSOCKSPort : settings.socksPort as NSNumber,
            kCFNetworkProxiesSOCKSEnable : settings.socksEnable as NSNumber,
            ] as [NSObject : AnyObject]
        setProxy(proxies: settings!)
    }
    
    func DisableProxy() {
        setProxy(proxies: self.oldSettings!)
    }
    
    func LoadSystemProxySettings(){
        if let store = SCDynamicStoreCreateWithOptions(nil, "ShuttleX" as CFString, nil, nil, nil) {
            if let osxProxySettings: NSDictionary = SCDynamicStoreCopyProxies(store) {
                oldSettings = [
                    kCFNetworkProxiesHTTPProxy : osxProxySettings[kCFNetworkProxiesHTTPProxy],
                    kCFNetworkProxiesHTTPPort : osxProxySettings[kCFNetworkProxiesHTTPPort],
                    kCFNetworkProxiesHTTPEnable : osxProxySettings[kCFNetworkProxiesHTTPEnable],
                    kCFNetworkProxiesHTTPSProxy : osxProxySettings[kCFNetworkProxiesHTTPSProxy],
                    kCFNetworkProxiesHTTPSPort : osxProxySettings[kCFNetworkProxiesHTTPSPort],
                    kCFNetworkProxiesHTTPSEnable : osxProxySettings[kCFNetworkProxiesHTTPSEnable],
                    kCFNetworkProxiesSOCKSProxy : osxProxySettings[kCFNetworkProxiesSOCKSProxy],
                    kCFNetworkProxiesSOCKSPort : osxProxySettings[kCFNetworkProxiesSOCKSPort],
                    kCFNetworkProxiesSOCKSEnable : osxProxySettings[kCFNetworkProxiesSOCKSEnable],
                    ] as [NSObject : AnyObject]
            }
        }
    }
    
    private func setProxy(proxies: [NSObject: AnyObject]){
//        var authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)
//        var authRights = AuthorizationRights(count: 1, items: &authItem)
        
        
        let sets = SCPreferencesGetValue(prefRef, kSCPrefNetworkServices)!
        
        sets.allKeys!.forEach { (key) in
            let dict = sets.object(forKey: key)!
            let hardware = (dict as AnyObject).value(forKeyPath: "Interface.Hardware")
            
            if hardware != nil && ["AirPort","Wi-Fi","Ethernet"].contains(hardware as! String) {
                SCPreferencesPathSetValue(prefRef, "/\(kSCPrefNetworkServices)/\(key)/\(kSCEntNetProxies)" as CFString, proxies as CFDictionary)
            }
        }
        
        SCPreferencesCommitChanges(prefRef)
        SCPreferencesApplyChanges(prefRef)
        SCPreferencesSynchronize(prefRef)

    }
}

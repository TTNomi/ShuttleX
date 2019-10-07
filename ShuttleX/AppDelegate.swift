//
//  AppDelegate.swift
//  ShuttleX
//
//  Created by sipt on 2019/9/28.
//  Copyright © 2019 sipt. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    let proxySetting = ProxySetting()
    let helperController = HelperController()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        constructMenu()
        registerObserver()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        removeObserver()
    }
    
    func constructMenu() {
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Install Helper...", action: #selector(install), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Call Helper...", action:  #selector(callHelper), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Choose Config...", action: nil, keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Start", action: nil, keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Stop", action: nil, keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Set As System Proxies", action: #selector(setAsSystemProxy), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Unset As System Proxies", action: #selector(unsetAsSystemProxy), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: nil, keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.button?.title = "ShuttleX"
    }
    @objc func install(){
       
    }
    
    @objc func callHelper() {
    }
    
    @objc func setAsSystemProxy() {
        if let helper = self.helperController.GetHelperProtocol() {
            self.proxySetting.enableProxy(delegate: helper, proxies: ProxySettings(
                httpHost: "127.0.0.1",
                httpPort: 8081,
                httpEnable: 1,
                httpsHost: "127.0.0.1",
                httpsPort: 8081,
                httpsEnable: 1,
                socksHost: "127.0.0.1",
                socksPort: 8082,
                socksEnable: 1
            ))
        }
        
    }
    
    @objc func unsetAsSystemProxy() {
        if let helper = self.helperController.GetHelperProtocol() {
            self.proxySetting.disableProxy(delegate: helper)
        }
    }
    
    
    func registerObserver() {
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
            observer, // observer
            { (nc, observer, name, ptr, _) -> Swift.Void in
                if let _ = observer, let name = name {
                if(name.rawValue as String == "com.apple.system.config.proxy_change")
                {
                    print("proxy changed")
                    // TODO: check proxy
                }
            } }, // callback
            "com.apple.system.config.proxy_change" as CFString, // event name
            nil, // object
            .deliverImmediately);
    }
    
    func removeObserver() {
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), observer, nil, nil)
    }
}


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
    
   


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
        menu.addItem(NSMenuItem(title: "Set As System Proxies", action: nil, keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Unset As System Proxies", action: nil, keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: nil, keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.button?.title = "ShuttleX"
    }
    @objc func install(){
       
    }
    
    @objc func callHelper() {
    }
}


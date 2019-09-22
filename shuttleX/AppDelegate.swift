//
//  AppDelegate.swift
//  shuttleX
//
//  Created by sipt on 2019/9/18.
//  Copyright © 2019 sipt. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let panel = NSOpenPanel()
    var configPath: String = ""
    var pluginsDir: String = ""
    let geoipPath = Bundle.main.bundlePath + "/Contents/Resources/GeoLite2-Country.mmdb"

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.title = "ShuttleX"
        }
        print(Bundle.main.bundlePath)
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func constructMenu() {
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.resolvesAliases = true
        panel.allowsMultipleSelection = false
        panel.showsHiddenFiles = false
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Choose Config...", action: #selector(chooseFile), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Start", action: #selector(start), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Stop", action: #selector(stop), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: nil, keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    
    
    @objc func chooseFile() {
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.begin { (result) in
            guard result == NSApplication.ModalResponse.OK, self.panel.urls.isEmpty == false, let url = self.panel.urls.first else {
                return
            }
            self.configPath = url.relativePath
            print(self.configPath)
        }
    }
    
    @objc func start(){
        let reply = String(cString: start_shuttle(makeCString(from: configPath), makeCString(from: geoipPath)))
        print(reply)
    }
    
    @objc func stop(){
        let reply = String(cString: stop_shuttle())
        print(reply)
    }
    
    func makeCString(from str: String) -> UnsafeMutablePointer<Int8> {
        let count = str.utf8.count + 1
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: count)
        str.withCString { (baseAddress) in
            // func initialize(from: UnsafePointer<Pointee>, count: Int)
            result.initialize(from: baseAddress, count: count)
        }
        return result
    }
}


//
//  AppDelegate.swift
//  ShuttleX
//
//  Created by xinyan wu on 2019/2/12.
//  Copyright © 2019 xinyan wu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        statusItem.button?.title = "ShuttleX"
        statusItem.menu = statusMenu
        readFile()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func startShuttle(_ sender: Any) {
//        let logpath = NSHomeDirectory() + "/logs"
        let confStr = "{}"
        let status = confStr.withCString { cstr in
            Run(GoString(p: cstr, n: strlen(cstr)))
        }
        print(status)
    }
    func readFile() {
        let path = "/Users/xinyanwu/Downloads/logs/test.log"
        do {
//            let text = try String(contentsOfFile:path, encoding:.utf8)
            try path.write(toFile: path, atomically: true, encoding: .utf8)
//            print(text)
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
}

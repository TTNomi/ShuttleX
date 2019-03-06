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
    let conf = Config()
    let shuttle = ShuttleManager()
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        statusItem.button?.title = "ShuttleX"
        statusItem.menu = statusMenu
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func selectConfigFile(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["yaml"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                conf.configPath = path
                print(path)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func startShuttle(_ sender: Any) {
        conf.logMode = "off"
        conf.logPath = NSHomeDirectory() + "/logs"
        shuttle.conf = conf
        print(shuttle.Start())
    }
}

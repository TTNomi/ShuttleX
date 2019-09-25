//
//  AppDelegate.swift
//  shuttleX
//
//  Created by sipt on 2019/9/18.
//  Copyright © 2019 sipt. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let panel = NSOpenPanel()
    
    // Variables
    let geoipPath = Bundle.main.bundlePath + "/Contents/Resources/GeoLite2-Country.mmdb"
    let helperName = "top.sipt.ShuttleXHelper"
    var configPath: String = ""
    var pluginsDir: String = ""
    var ps: ProxySettings?
    private var helperConn: NSXPCConnection?
    var authRef : AuthorizationRef?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        var environment = AuthorizationEnvironment()
        let status = AuthorizationCreate(nil, &environment, [.interactionAllowed, .extendRights, .destroyRights], &authRef)
        if (status != errAuthorizationSuccess) {
            print("AuthorizationCreate failed: \(String(status))")
        }
        
        if let button = statusItem.button {
            button.title = "ShuttleX"
        }
        print(Bundle.main.bundlePath)
        constructMenu()
        loadProxySettings()
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
        menu.addItem(NSMenuItem(title: "Install Helper...", action: #selector(install), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Check Helper...", action: #selector(checkExists), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Choose Config...", action: #selector(chooseFile), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Start", action: #selector(start), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Stop", action: #selector(stop), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Set As System Proxies", action: #selector(enableProxies), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Unset As System Proxies", action: #selector(disableProxies), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func loadProxySettings() {
        ps = ProxySettings()
        print(ps!.oldSettings!)
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func enableProxies(){
        let proxies: ProxySetting = ProxySetting(
            httpHost: "127.0.0.1",
            httpPort: 8081,
            httpEnable: 1,
            httpsHost: "127.0.0.1",
            httpsPort: 8081,
            httpsEnable: 1,
            socksPort: 9000,
            socksHost: "127.0.0.1",
            socksEnable: 1
        )
        let xpcService = connectToHelper()?.remoteObjectProxyWithErrorHandler() { error -> Void in
            print("remoteObjectProxyWithErrorHandler failed: \(error)")
        } as? PShuttleXHelper
//        xpcService?.EnableProxy(proxies.toDict())
        xpcService?.GetVersion{
            version in print(version)
        }
    }
    
    @objc func disableProxies(){
        let xpcService = connectToHelper()?.remoteObjectProxyWithErrorHandler() { error -> Void in
            print("remoteObjectProxyWithErrorHandler failed: \(error)")
            } as? PShuttleXHelper
        xpcService?.DisableProxy()
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
    
    @objc func install() {
        helperInstall()
    }
    @objc func checkExists() {
        print("helper is exists:\(checkHelperExists())")
    }
    func connectToHelper() -> NSXPCConnection? {
        if(helperConn==nil) {
            helperConn = NSXPCConnection(machServiceName: helperName, options: NSXPCConnection.Options.privileged)
            helperConn?.remoteObjectInterface = NSXPCInterface(with: PShuttleXHelper.self)
            helperConn?.invalidationHandler = {
                self.helperConn?.invalidationHandler = nil
                OperationQueue.main.addOperation() {
                    self.helperConn = nil
                    print("XPC Connection Invalidated")
                }
            }
            helperConn?.resume()
        }
        
        return helperConn
    }
    func checkHelperExists() -> Bool {
        var exists = false
        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/\(helperName)")
        let helperBundleInfo = CFBundleCopyInfoDictionaryForURL(helperURL as CFURL?)
        if helperBundleInfo != nil {
            exists = true
        }
        return exists
    }
    
    func helperInstall() -> Bool {
        // Create authorization reference for the user
        var authRef: AuthorizationRef?
        var authStatus = AuthorizationCreate(nil, nil, [], &authRef)
        
        // Check if the reference is valid
        guard authStatus == errAuthorizationSuccess else {
            print("Authorization failed: \(String(authStatus: authStatus))")
            return false
        }
        
        // Ask user for the admin privileges to install the
        var authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)
        var authRights = AuthorizationRights(count: 1, items: &authItem)
        let flags: AuthorizationFlags = [[], .interactionAllowed, .extendRights, .preAuthorize]
        authStatus = AuthorizationCreate(&authRights, nil, flags, &authRef)
        
        // Check if the authorization went succesfully
        guard authStatus == errAuthorizationSuccess else {
            print("Authorization failed: \(String(authStatus: authStatus))")
            return false
        }
        
        var cfError: Unmanaged<CFError>?
        let success = SMJobBless(kSMDomainSystemLaunchd, helperName as CFString, authRef, &cfError)
        if !success {
            print("SMJobBless failed: \(cfError!)")
            return false
        }
        print("SMJobBless suceeded")
        self.helperConn?.invalidate()
        self.helperConn = nil
        
        return true
    }
}

private extension String {
    init(authStatus: OSStatus) {
        
        switch authStatus {
        case errAuthorizationSuccess:
            self = "Success"
            
        case errAuthorizationDenied:
            self = "Denied"
            
        case errAuthorizationCanceled:
            self = "Cancelled"
            
        case errAuthorizationInternal:
            self = "Internal error"
            
        case errAuthorizationBadAddress:
            self = "Bad address"
            
        case errAuthorizationInvalidRef:
            self = "Invalid reference"
            
        case errAuthorizationInvalidSet:
            self = "Invalid set"
            
        case errAuthorizationInvalidTag:
            self = "Invalid tag"
            
        case errAuthorizationInvalidFlags:
            self = "Invalid flags"
            
        case errAuthorizationInvalidPointer:
            self = "Invalid pointer"
            
        case errAuthorizationToolExecuteFailure:
            self = "Tool execution failure"
            
        case errAuthorizationToolEnvironmentError:
            self = "Tool environment error"
            
        case errAuthorizationExternalizeNotAllowed:
            self = "Reference externalization not allowed"
            
        case errAuthorizationInteractionNotAllowed:
            self = "Interaction not allowed"
            
        case errAuthorizationInternalizeNotAllowed:
            self = "Reference internalization not allowed"
            
        default:
            self = "Unknown auth failure"
        }
    }
}

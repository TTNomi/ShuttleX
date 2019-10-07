//
//  HelperController.swift
//  ShuttleX
//
//  Created by sipt on 2019/10/7.
//  Copyright © 2019 sipt. All rights reserved.
//

import Foundation
import Security
import ServiceManagement

class HelperController{
    var connection: NSXPCConnection?
    var authRef: AuthorizationRef?
    
    init() {
        // Create an empty authorization reference
        initAuthorizationRef()
        
        // Check if there's an existing PrivilegedTaskRunnerHelper already installed
        if(!checkIfHelperDaemonExists()) {
            installHelperDaemon()
        }
        else {
            // Update daemon to a newer version if client and daemon versions don't match
            self.checkHelperVersionAndUpdateIfNecessary()
        }
    }
    
    /// Initialize AuthorizationRef, as we need to manage it's lifecycle
    func initAuthorizationRef() {
        // Create an empty AuthorizationRef
        let status = AuthorizationCreate(nil, nil, AuthorizationFlags(), &authRef)
        if (status != OSStatus(errAuthorizationSuccess)) {
            NSLog("AppviewController: AuthorizationCreate failed")
            return
        }
    }
    
    /// Prepare XPC connection for inter process call
    ///
    /// - returns: A reference to the prepared instance variable
    func prepareXPC() -> NSXPCConnection? {
        
        // Check that the connection is valid before trying to do an inter process call to helper
        if(connection==nil) {
            connection = NSXPCConnection(machServiceName: HelperConstants.machServiceName, options: NSXPCConnection.Options.privileged)
            connection?.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
            connection?.invalidationHandler = {
                self.connection?.invalidationHandler = nil
                OperationQueue.main.addOperation() {
                    self.connection = nil
                    NSLog("AppviewController: XPC Connection Invalidated")
                }
            }
            connection?.resume()
        }
        
        return connection
    }
    
    /// Install new helper daemon
    func installHelperDaemon() {
        
        NSLog("AppviewController: Privileged Helper daemon was not found, installing a new one...")
        
        // Create authorization reference for the user
        var authRef: AuthorizationRef?
        var authStatus = AuthorizationCreate(nil, nil, [], &authRef)
        
        // Check if the reference is valid
        guard authStatus == errAuthorizationSuccess else {
            NSLog("AppviewController: Authorization failed: \(authStatus)")
            return
        }
        
        // Ask user for the admin privileges to install the
        var authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)
        var authRights = AuthorizationRights(count: 1, items: &authItem)
        let flags: AuthorizationFlags = [[], .interactionAllowed, .extendRights, .preAuthorize]
        authStatus = AuthorizationCreate(&authRights, nil, flags, &authRef)
        
        // Check if the authorization went succesfully
        guard authStatus == errAuthorizationSuccess else {
            NSLog("AppviewController: Couldn't obtain admin privileges: \(authStatus)")
            return
        }
        
        // Launch the privileged helper using SMJobBless tool
        var error: Unmanaged<CFError>? = nil
        
        if(SMJobBless(kSMDomainSystemLaunchd, HelperConstants.machServiceName as CFString, authRef, &error) == false) {
            let blessError = error!.takeRetainedValue() as Error
            NSLog("AppviewController: Bless Error: \(blessError)")
        } else {
            NSLog("AppviewController: \(HelperConstants.machServiceName) installed successfully")
        }
        
        // Release the Authorization Reference
        AuthorizationFree(authRef!, [])
    }
    
    /// Check if Helper daemon exists
    func checkIfHelperDaemonExists() -> Bool {
        
        let fileManager = FileManager.default
        
        if (!fileManager.fileExists(atPath: "/Library/PrivilegedHelperTools/top.sipt.ShuttleXHelper")) {
            return false
        } else {
            return true
        }
    }
    
    /// Compare app's helper version to installed daemon's version and update if necessary
    func checkHelperVersionAndUpdateIfNecessary() {
        
        // Daemon path
        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/\(HelperConstants.machServiceName)")
        let helperBundleInfo = CFBundleCopyInfoDictionaryForURL(helperURL as CFURL)
        let helperInfo = helperBundleInfo! as NSDictionary
        let helperVersion = helperInfo["CFBundleVersion"] as! String
        
        NSLog("AppviewController: PrivilegedTaskRunner Bundle Version => \(helperVersion)")
        
        // When the connection is valid, do the actual inter process call
        let xpcService = prepareXPC()?.remoteObjectProxyWithErrorHandler() { error -> Void in
            NSLog("XPC error: \(error)")
            } as? HelperProtocol
        
        xpcService?.getVersion(reply: {
            installedVersion in
            NSLog("AppviewController: PrivilegedTaskRunner Helper Installed Version => \(installedVersion)")
            NSLog("AppviewController: PrivilegedTaskRunner Helper Helper Version => \(helperVersion)")
            if(installedVersion != helperVersion) {
                self.installHelperDaemon()
            }
            else {
                NSLog("AppviewController: Bundle version matches privileged helper version, so no need to install")
            }
        })
    }
    
    // Get HelperProtocol
    func GetHelperProtocol() -> HelperProtocol? {
        return prepareXPC()?.remoteObjectProxyWithErrorHandler() { error -> Void in
            NSLog("AppviewController: XPC error: \(error)")
            } as? HelperProtocol
    }
}

//
//  ProcessHelper.swift
//  ProcessRunnerExample
//
//  Created by Suolapeikko
//

import Foundation
import AppKit
import SystemConfiguration

class ProxySettingHelper: NSObject, HelperProtocol, NSXPCListenerDelegate {
    
    var listener:NSXPCListener
    var authRef : AuthorizationRef?
    var prefRef : SCPreferences

    override init() {
        var environment = AuthorizationEnvironment()
        let err = AuthorizationCreate(nil, &environment, [.interactionAllowed, .extendRights, .destroyRights], &authRef)
        assert(err == errAuthorizationSuccess)
        prefRef = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, "ShuttleX" as CFString, nil, authRef)!
        self.listener = NSXPCListener(machServiceName:HelperConstants.machServiceName)
        super.init()
        self.listener.delegate = self
    }
    
    /// Starts the helper daemon
    func run() {
        self.listener.resume()
        
        RunLoop.current.run()
    }
    
    /// Check that code sign certificates match
    func connectionIsValid(connection: NSXPCConnection ) -> Bool {
        
        let checker = CodesignChecker()
        var localCertificates: [SecCertificate] = []
        var remoteCertificates: [SecCertificate] = []
        let pid = connection.processIdentifier
        
        do {
            localCertificates = try checker.getCertificatesSelf()
            remoteCertificates = try checker.getCertificates(forPID: pid)
        }
        catch let error as CodesignCheckerError {
                NSLog(CodesignCheckerError.handle(error: error))
        }
        catch let error {
            NSLog("Something unexpected happened: \(error.localizedDescription)")
        }

        NSLog("Local certificates: \(localCertificates)")
        NSLog("Remote certificates: \(remoteCertificates)")

        let remoteApp = NSRunningApplication.init(processIdentifier: pid)

        // Compare certificates
        if(remoteApp != nil && (localCertificates == remoteCertificates)) {
            NSLog("Certificates match!")
            return true
        }
        
        return false
    }
    
    /// Called when the client connects to the helper daemon
    func listener(_ listener:NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        
        // ----------------------------------------------------------------------------------------------------
        //  Only accept new connections from applications using the same codesigning certificate as the helper
        // ----------------------------------------------------------------------------------------------------
        if (!connectionIsValid(connection: connection)) {
            
            NSLog("Codesign certificate validation failed")
            
            return false
        }
        
        connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.exportedObject = self;
        connection.resume()
        
        return true
    }
    
    /// Functions to run from the main app
    func runCommand(path: String, reply: @escaping (String) -> Void) {
        NSLog("runCommand!!!!")
        
        // Create cli commands that needs to be run chained / piped
        let needsSudoCommand = CliCommand(launchPath: "/bin/ls", arguments: ["/var/db/sudo"])
        
        // Prepare cli command runner
        let command = ProcessHelper(commands: [needsSudoCommand])
        
        // Prepare result tuple
        var commandResult: String?
        
        // Execute cli commands and prepare for exceptions
        do {
            commandResult = try command.execute()
        }
        catch {
            NSLog("PrivilegedTaskRunnerHelper: Failed to run command")
        }
        
        reply(commandResult!)
    }
    
    /// Return daemon's bundle version
    /// Because communication over XPC is asynchronous, all methods in the protocol must have a return type of void
    func getVersion(reply: (String) -> Void) {
        reply(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)
    }
    
    func setProxySettings(proxies: [NSObject: AnyObject]){
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
    
    func getProxySettings(reply: @escaping ([NSObject: AnyObject])-> Void){
        NSLog("run func => getProxySettings")
        if let store = SCDynamicStoreCreateWithOptions(nil, "ShuttleX" as CFString, nil, nil, nil) {
            if let osxProxySettings: NSDictionary = SCDynamicStoreCopyProxies(store) {
                NSLog("=>> \(store)")
                var settings = [
                    kCFNetworkProxiesHTTPEnable : osxProxySettings[kCFNetworkProxiesHTTPEnable],
                    kCFNetworkProxiesHTTPSEnable : osxProxySettings[kCFNetworkProxiesHTTPSEnable],
                    kCFNetworkProxiesSOCKSEnable : osxProxySettings[kCFNetworkProxiesSOCKSEnable],
                    ] as [NSObject : AnyObject]
                if osxProxySettings[kCFNetworkProxiesHTTPProxy] != nil {
                    settings[kCFNetworkProxiesHTTPProxy] = osxProxySettings[kCFNetworkProxiesHTTPProxy]! as AnyObject?
                } 
                if osxProxySettings[kCFNetworkProxiesHTTPPort] != nil {
                    settings[kCFNetworkProxiesHTTPPort] = osxProxySettings[kCFNetworkProxiesHTTPPort]! as! NSNumber
                }
                if osxProxySettings[kCFNetworkProxiesHTTPSProxy] != nil {
                    settings[kCFNetworkProxiesHTTPSProxy] = osxProxySettings[kCFNetworkProxiesHTTPSProxy]! as AnyObject?
                }
                if osxProxySettings[kCFNetworkProxiesHTTPSPort] != nil {
                    settings[kCFNetworkProxiesHTTPSPort] = osxProxySettings[kCFNetworkProxiesHTTPSPort]! as! NSNumber
                }
                if osxProxySettings[kCFNetworkProxiesSOCKSProxy] != nil {
                    settings[kCFNetworkProxiesSOCKSProxy] = osxProxySettings[kCFNetworkProxiesSOCKSProxy] as AnyObject?
                }
                if osxProxySettings[kCFNetworkProxiesSOCKSPort] != nil {
                    settings[kCFNetworkProxiesSOCKSPort] = osxProxySettings[kCFNetworkProxiesSOCKSPort]! as! NSNumber
                }
                reply(settings)
            }
        }
        NSLog("get network settings failed")
    }
}

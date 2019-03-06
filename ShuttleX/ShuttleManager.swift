//
//  ShuttleManager.swift
//  ShuttleX
//
//  Created by xinyan wu on 2019/2/25.
//  Copyright © 2019 xinyan wu. All rights reserved.
//

import Foundation
import SwiftyJSON

class Config {
    var logMode: String = ""
    var logPath: String = ""
    var configPath: String = ""
    
    init() {
        
    }
    
    init(logMode:String, logPath:String, configPath: String) {
        self.logMode = logMode
        self.logPath = logPath
        self.configPath = configPath
    }
    
    func json() -> String{
        let json: JSON =  ["log_mode":logMode, "log_path":logPath, "config_path":configPath]
        return json.rawString()!
    }
}

class ShuttleManager {
    var conf: Config = Config()
    
    init() {
        
    }
    
    init(conf: Config) {
        self.conf = conf
    }
    
    func Start() -> Int64 {
        let confStr = self.conf.json()
        return confStr.withCString{ cstr in
            Run(GoString(p: cstr, n: strlen(confStr)))
        }
    }
}

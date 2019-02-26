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
    let logMode: String
    let logPath: String
    let configPath: String
    
    init(logMode:String, logPath:String, configPath: String) {
        self.logMode = logMode
        self.logPath = logPath
        self.configPath = configPath
    }
}

class ShuttleManager {
    let conf: Config
    init(conf: Config) {
        self.conf = conf
    }
    
    func Start() -> Int64 {
        let jsonObj = JSON.init(self.conf)
        let confStr = jsonObj.rawString()!
        return confStr.withCString{ cstr in
            Run(GoString(p: cstr, n: strlen(confStr)))
        }
    }
}

//
//  MBoxSSH.swift
//  MBoxSSH
//

import Foundation
import MBoxCore

@objc(MBoxSSH)
open class MBoxSSH: NSObject, MBPluginProtocol {
    public static let configDir = MBSetting.globalDir.appending(pathComponent: "ssh.d")

    public static func includeSSHConfig() throws {
        let mboxPath = self.configDir.abbreviatingWithTildeInPath
        let userPath = "~/.ssh/config"
        let userRealPath = userPath.expandingTildeInPath

        let content = (try? String(contentsOfFile: userRealPath)) ?? ""
        var content2 = content.replace(regex: "Include .*mbox.*\n\n") { match in "" }
        content2 = "Include \(mboxPath)/*\n\n\(content2)"
        if content == content2 {
            return
        }
        try UI.log(verbose: "Include `\(mboxPath)` in `\(userPath)`") {
            try? FileManager.default.createDirectory(atPath: userRealPath.deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
            try content2.write(toFile: userRealPath, atomically: true, encoding: .utf8)
            try? FileManager.default.removeItem(atPath: MBSetting.globalDir.appending(pathComponent: "ssh.config"))
        }
    }

    public static func linkSSHConfig(_ path: String) throws {
        try self.includeSSHConfig()
        let symbolPath = self.configDir.appending(pathComponent: self.bundle.name).appending(pathExtension: "config")
        try UI.log(verbose: "Link `\(symbolPath.abbreviatingWithTildeInPath)` -> `\(path)`") {
            try? FileManager.default.createDirectory(atPath: self.configDir, withIntermediateDirectories: true)
            try FileManager.default.createSymbolicLink(atPath: symbolPath, withDestinationPath: path)
        }
    }

    public func registerCommanders() {
    }
}

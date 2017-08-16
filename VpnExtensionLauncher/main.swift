//
//  main.swift
//  VpnExtensionLauncher
//
//  Created by Alberto Lalama on 8/16/17.
//
//

import Foundation
import NetworkExtension

var tunnelManager: NETunnelProviderManager?

// Adds a VPN configuration to the user preferences if no uProxy profile is present. Otherwise
// enables the exisiting configuration.
private func setupVpn(vpnExtensionBundleId: String, completion: @escaping(Error?) -> Void) {
  NETunnelProviderManager.loadAllFromPreferences() { (managers, error) in
    print("aya1")
    if let error = error {
      NSLog("Failed to load VPN configuration: \(error)")
      return completion(error)
    }
    var manager: NETunnelProviderManager!
    if let managers = managers, managers.count > 0 {
      manager  = managers.first
      if manager.isEnabled {
        tunnelManager = manager
        NotificationCenter.default.post(name: .NEVPNConfigurationChange, object: nil)
        return completion(nil)
      }
    } else {
      let config = NETunnelProviderProtocol()
      config.providerBundleIdentifier = vpnExtensionBundleId
      config.serverAddress = "uProxy-test"

      manager = NETunnelProviderManager()
      manager.protocolConfiguration = config
    }
    manager.isEnabled = true
    manager.saveToPreferences() { error in
      if let error = error {
        NSLog("Failed to save VPN configuration: \(error)")
        return completion(error)
      }
      tunnelManager = manager
      NotificationCenter.default.post(name: .NEVPNConfigurationChange, object: nil)
      // See https://forums.developer.apple.com/thread/25928
      tunnelManager?.loadFromPreferences() { error in
        completion(error)
      }
    }
  }
}

private func startVpn(_ config: [String: String]) throws {
  let session: NETunnelProviderSession = tunnelManager?.connection as! NETunnelProviderSession
  try session.startTunnel(options: config)
}

private func stopVpn() {
  let session: NETunnelProviderSession = tunnelManager?.connection as! NETunnelProviderSession
  session.stopTunnel()
//  self.activeConnectionId = nil
}

// TODO: usage, validation
private func getArguments() -> [String: String] {
  var args: [String: String] = [:]
  for i in stride(from: 1, through: CommandLine.arguments.count - 2, by: 2) {
    var arg = CommandLine.arguments[i]
    if arg.hasPrefix("--") {
      arg = arg.substring(from: arg.index(arg.startIndex, offsetBy: 2))
    }
    args[arg] = CommandLine.arguments[i+1]
  }
  return args
}

func main () {
  // TODO: args[1] = start|stop
  let args = getArguments()
  NSLog("VPN extension launcher started")
  setupVpn(vpnExtensionBundleId: args["bundleId"]!) { (error) in
    guard error != nil else {
      return print("Failed to setup VPN: \(error!)")
    }
    do {
      try startVpn(args)
    } catch let error as NSError  {
      return print("Failed to start VPN: \(error)")
    }
  }
}

main();

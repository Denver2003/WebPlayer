//
//  AppDelegate.swift
//

import UIKit
import UserNotifications

import StreamLayer
import StreamLayerVendor

let sdkKey = "29d0c798269575c4335f06a4a38318002e20029c5301f38e222874fa66e712b3"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplication .LaunchOptionsKey: Any]?) -> Bool {
    initiateStreamLayer()

    window = UIWindow()
    window?.makeKeyAndVisible()
    window?.rootViewController = ViewController()

    return true
  }
}

extension AppDelegate {
  func initiateStreamLayer() {
    do {
      try StreamLayer.initSDK(with: sdkKey, isDebug: true, loggerDelegate: self)
    } catch {
      fatalError("failed to init StreamLayer SDK: \(error)")
    }
  }
}

extension AppDelegate: SLROverlayLoggerDelegate {
  func sendLogdata(userInfo: String) {
  }
}

import Flutter
import UIKit
import UserNotifications
import AudioToolbox
import AVFoundation
import Security
#if canImport(WidgetKit)
import WidgetKit
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  static var sharedHapticsChannel: FlutterMethodChannel?
  static var pendingShortcutUri: String?

  private static let appGroupId = "group.com.antigravity.hydroReminder"
  private static let keychainAccessGroups = [
    "BHYTLHA722.com.antigravity.hydroreminder.shared",
    "BHYTLHA722.com.antigravity.hydroreminder.hydroReminder"
  ]
  private static let keychainService = "com.antigravity.hydroreminder.widgetsync"
  private static let keychainAccount = "hydro_widget_state_v1"

  static func handleIncomingUrl(_ url: URL) -> Bool {
    guard url.scheme?.lowercased() == "hydroreminder" else {
      return false
    }
    let uriString = url.absoluteString
    pendingShortcutUri = uriString
    DispatchQueue.main.async {
      sharedHapticsChannel?.invokeMethod("onShortcutUri", arguments: uriString)
    }
    return true
  }

  private static func saveWidgetDataToSharedKeychain(_ dict: [String: Any]) {
    guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
      return
    }

    var savedToAnyGroup = false
    for group in keychainAccessGroups {
      let groupedQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: keychainService,
        kSecAttrAccount as String: keychainAccount,
        kSecAttrAccessGroup as String: group
      ]
      SecItemDelete(groupedQuery as CFDictionary)

      var groupedItem = groupedQuery
      groupedItem[kSecValueData as String] = jsonData
      groupedItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
      let status = SecItemAdd(groupedItem as CFDictionary, nil)
      if status == errSecSuccess {
        savedToAnyGroup = true
      }
    }

    // Also save to default keychain group as fallback
    let fallbackQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: keychainService,
      kSecAttrAccount as String: keychainAccount
    ]
    if !savedToAnyGroup {
      SecItemDelete(fallbackQuery as CFDictionary)
      var fallbackItem = fallbackQuery
      fallbackItem[kSecValueData as String] = jsonData
      fallbackItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
      SecItemAdd(fallbackItem as CFDictionary, nil)
    }
  }

  static func reloadWidgetsNow() {
    if #available(iOS 14.0, *) {
      #if canImport(WidgetKit)
      WidgetCenter.shared.reloadAllTimelines()
      #endif
    }
  }

  private static func syncWidgetPayload(_ args: [String: Any]) {
    // 1. Save to Shared Keychain (guaranteed cross-process sharing on iOS)
    saveWidgetDataToSharedKeychain(args)

    // 2. Also save to App Group UserDefaults if available
    if let prefs = UserDefaults(suiteName: appGroupId) {
      for (key, value) in args {
        prefs.set(value, forKey: key)
      }
      prefs.synchronize()
    }

    // 3. Also save to Standard UserDefaults
    for (key, value) in args {
      UserDefaults.standard.set(value, forKey: "hydro_widget_\(key)")
    }

    // 4. Reload all WidgetKit timelines immediately
    reloadWidgetsNow()
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    if let launchUrl = launchOptions?[.url] as? URL {
      _ = AppDelegate.handleIncomingUrl(launchUrl)
    }

    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let registrar = self.registrar(forPlugin: "HydroWidgetBridgePlugin") {
      setupMethodChannel(with: registrar.messenger())
    } else if let controller = window?.rootViewController as? FlutterViewController {
      setupMethodChannel(with: controller.binaryMessenger)
    }

    return result
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    AppDelegate.reloadWidgetsNow()
    super.applicationWillResignActive(application)
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    AppDelegate.reloadWidgetsNow()
    super.applicationDidEnterBackground(application)
  }

  func setupMethodChannel(with messenger: FlutterBinaryMessenger) {
    let hapticsChannel = FlutterMethodChannel(
      name: "com.antigravity.hydroReminder/alarm_haptics",
      binaryMessenger: messenger
    )
    AppDelegate.sharedHapticsChannel = hapticsChannel

    hapticsChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "vibrateAlarm" {
        if #available(iOS 13.0, *) {
          try? AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        AudioServicesPlaySystemSound(1521)
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.warning)

        let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()

        result(true)
      } else if call.method == "openNotificationSettings" {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        result(true)
      } else if call.method == "consumeInitialShortcutUri" {
        let uri = AppDelegate.pendingShortcutUri
        AppDelegate.pendingShortcutUri = nil
        result(uri)
      } else if call.method == "syncIosWidgetData" {
        if let args = call.arguments as? [String: Any] {
          AppDelegate.syncWidgetPayload(args)
        }
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if AppDelegate.handleIncomingUrl(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}

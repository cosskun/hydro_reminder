import Flutter
import UIKit
import UserNotifications
import AudioToolbox
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    if let controller = window?.rootViewController as? FlutterViewController {
      let hapticsChannel = FlutterMethodChannel(
        name: "com.antigravity.hydroReminder/alarm_haptics",
        binaryMessenger: controller.binaryMessenger
      )
      hapticsChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "vibrateAlarm" {
          if #available(iOS 13.0, *) {
            try? AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
          }
          // Hardware Alert Vibration (works in Silent Mode & Ring Mode)
          AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
          // Triple-pulse Taptic alert vibration
          AudioServicesPlaySystemSound(1521)
          // UIKit Feedback Generators (never suppressed by AVPlayer audio session)
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
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


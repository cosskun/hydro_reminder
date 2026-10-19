import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    if let windowScene = scene as? UIWindowScene,
       let controller = windowScene.windows.first?.rootViewController as? FlutterViewController,
       let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.setupMethodChannel(with: controller.binaryMessenger)
    }

    if let urlContext = connectionOptions.urlContexts.first {
      _ = AppDelegate.handleIncomingUrl(urlContext.url)
    }
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for context in URLContexts {
      if AppDelegate.handleIncomingUrl(context.url) {
        return
      }
    }
    super.scene(scene, openURLContexts: URLContexts)
  }
}

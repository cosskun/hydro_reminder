import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    if AppDelegate.sharedHapticsChannel == nil,
       let windowScene = scene as? UIWindowScene,
       let controller = windowScene.windows.first?.rootViewController as? FlutterViewController,
       let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.setupMethodChannel(with: controller.binaryMessenger)
    }

    if let urlContext = connectionOptions.urlContexts.first {
      _ = AppDelegate.handleIncomingUrl(urlContext.url)
    }
  }

  override func sceneWillResignActive(_ scene: UIScene) {
    AppDelegate.reloadWidgetsNow()
    super.sceneWillResignActive(scene)
  }

  override func sceneDidEnterBackground(_ scene: UIScene) {
    AppDelegate.reloadWidgetsNow()
    super.sceneDidEnterBackground(scene)
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

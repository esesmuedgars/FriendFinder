//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var appFlowCoordinator: Coordinator!
    var window: UIWindow?


    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        AppAppearance.setAppearance()

        window = UIWindow(windowScene: windowScene)

        let navigationController = UINavigationController()
        appFlowCoordinator = AppFlowCoordinator(
            presenter: navigationController,
            factory: AppFlowFactoryImpl()
        )
        appFlowCoordinator.start()

        window?.rootViewController = navigationController

        window?.makeKeyAndVisible()
    }
}


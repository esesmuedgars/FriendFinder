//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
}

final class AppFlowCoordinator: Coordinator {

    private let presenter: UINavigationController
    private let factory: AppFlowFactory

    init(
        presenter: UINavigationController,
        factory: AppFlowFactory
    ) {
        self.presenter = presenter
        self.factory = factory
    }

    func start() {
        // FIXME: Replace with `factory` initialization call
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBlue

        presenter.setViewControllers(
            [viewController],
            animated: false
        )
    }
}

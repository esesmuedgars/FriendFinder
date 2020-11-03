//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import UIKit

// MARK: Coordinator

protocol Coordinator: AnyObject {
    func start()
}

// MARK: AppFlowCoordinator

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
        let viewController = factory.makeFriendMapViewController()

        presenter.setViewControllers(
            [viewController],
            animated: false
        )
    }
}

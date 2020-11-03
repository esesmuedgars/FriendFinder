//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import Foundation

// MARK: AppFlowFactory

protocol AppFlowFactory: AnyObject {
    func makeFriendMapViewController() -> FriendMapViewController
}

// MARK: AppFlowFactoryImpl

final class AppFlowFactoryImpl: AppFlowFactory {

    // MARK: DataTransfer

    private lazy var dataTransferService: DataTransferService = {
        let tcpConnectionService = TCPConnectionServiceImpl(
            credentials: Credentials(
                email: "edgars.vanags1@gmail.com"
            ),
            host: "ios-test.printful.lv",
            port: 6111
        )
        let dataTransferService = DataTransferServiceImpl(
            tcpConnectionService: tcpConnectionService
        )

        return dataTransferService
    }()

    // MARK: FriendMap

    func makeFriendMapViewController() -> FriendMapViewController {
        FriendMapViewController(
            viewModel: makeFriendMapViewModel()
        )
    }

    private func makeFriendMapViewModel() -> FriendMapViewModel {
        FriendMapViewModelImpl(
            repository: makeFriendTrackerRepository()
        )
    }

    // MARK: Repositories

    private func makeFriendTrackerRepository() -> FriendTrackerRepository {
        FriendTrackerRepositoryImpl(
            dataTransferService: dataTransferService
        )
    }
}

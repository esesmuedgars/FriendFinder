//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import Foundation
import CoreLocation

// MARK: FriendTrackerRepository

protocol FriendTrackerRepository: AnyObject {
    func beginTrackingFriends(
        onNextUser: @escaping (User) -> Void,
        onLocationUpdate: @escaping (LocationUpdate) -> Void,
        onError: @escaping (Error) -> Void
    )
}

// MARK: FriendTrackerRepositoryImpl

final class FriendTrackerRepositoryImpl {

    private let dataTransferService: DataTransferService

    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
}

extension FriendTrackerRepositoryImpl: FriendTrackerRepository {
    func beginTrackingFriends(
        onNextUser: @escaping (User) -> Void,
        onLocationUpdate: @escaping (LocationUpdate) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        dataTransferService.connect(
            receivedUserMessage: { message in
                onNextUser(
                    User(
                        id: message.id,
                        fullName: message.fullName,
                        imageURL: message.imageURL,
                        coordinate: CLLocationCoordinate2D(
                            latitude: message.latitude,
                            longitude: message.longitude
                        )
                    )
                )
            },
            receivedUpdateMessage: { message in
                onLocationUpdate(
                    LocationUpdate(
                        id: message.id,
                        coordinate: CLLocationCoordinate2D(
                            latitude: message.latitude,
                            longitude: message.longitude
                        )
                    )
                )
            },
            failedWithError: { error in
                onError(error)
            }
        )
    }
}

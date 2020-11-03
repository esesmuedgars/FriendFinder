//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import Foundation
import CoreLocation

// MARK: FriendMapViewModelInput

protocol FriendMapViewModelInput: AnyObject {
    func beginTrackingFriends(
        onNextUser: @escaping (User) -> Void,
        onLocationUpdate: @escaping (LocationUpdate) -> Void
    )
    func reverseGeocodeLocation(_ annotation: UserAnnotation)
}

// MARK: FriendMapViewModelOutput

protocol FriendMapViewModelOutput: AnyObject { }

// MARK: HomeTabViewModel

protocol FriendMapViewModel: FriendMapViewModelInput, FriendMapViewModelOutput { }

// MARK: FriendMapViewModelImpl

final class FriendMapViewModelImpl: FriendMapViewModel {

    private let geocoderQueue = DispatchQueue(
        label: "CLGeocoderSerialQueue",
        qos: .userInteractive
    )
    private let condition = NSCondition()
    private lazy var geocoder =  CLGeocoder()

    private let repository: FriendTrackerRepository

    init(repository: FriendTrackerRepository) {
        self.repository = repository
    }

    func beginTrackingFriends(
        onNextUser: @escaping (User) -> Void,
        onLocationUpdate: @escaping (LocationUpdate) -> Void
    ) {
        repository.beginTrackingFriends(
            onNextUser: onNextUser,
            onLocationUpdate: onLocationUpdate,
            onError: { error in
                #if DEBUG
                print("⚠️", error)
                #endif
            }
        )
    }

    func reverseGeocodeLocation(_ annotation: UserAnnotation) {
        geocoderQueue.async {
            self.condition.lock()

            while self.geocoder.isGeocoding {
                self.condition.wait()
            }

            self.geocoder.reverseGeocodeLocation(annotation.location) { placemarks, _ in
                if let placemark = placemarks?.first {
                    annotation.subtitle = placemark.name
                }

                self.condition.signal()
                self.condition.unlock()
            }
        }
    }
}

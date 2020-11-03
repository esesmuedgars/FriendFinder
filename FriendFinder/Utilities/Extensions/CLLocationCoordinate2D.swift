//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import CoreLocation

public extension CLLocationCoordinate2D {
    func isEqual(_ coordinate: CLLocationCoordinate2D) -> Bool {
        latitude == coordinate.latitude &&
            longitude == coordinate.longitude
    }
}

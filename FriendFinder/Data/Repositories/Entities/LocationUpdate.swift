//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import Foundation
import CoreLocation

struct LocationUpdate: Identifiable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
}

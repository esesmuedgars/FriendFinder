//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import Foundation
import CoreLocation

struct User: Identifiable {
    let id: Int
    let fullName: String
    let imageURL: URL
    let location: CLLocation
}

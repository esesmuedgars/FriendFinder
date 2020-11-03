//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import MapKit

final class UserAnnotation: NSObject, MKAnnotation, Identifiable {

    let id: Int
    let image: UIImage?
    let title: String?
    @objc dynamic var subtitle: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D

    var location: CLLocation {
        CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }

    init(
        id: Int,
        image: UIImage?,
        title: String?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.image = image
        self.title = title
        self.coordinate = coordinate
    }
}

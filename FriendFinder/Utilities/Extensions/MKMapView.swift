//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import MapKit

public extension MKMapView {
    func dequeueReusableAnnotationView<AnnotationView: MKAnnotationView>(
        ofType type: AnnotationView.Type
    ) -> MKAnnotationView? {
        dequeueReusableAnnotationView(
            withIdentifier: String(
                describing: type
            )
        ) as? AnnotationView
    }
}

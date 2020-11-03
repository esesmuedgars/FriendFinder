//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import UIKit
import MapKit

final class FriendMapViewController: BaseViewController<FriendMapViewModel> {

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self

        return mapView
    }()

    override func loadView() {
        view = mapView
    }

    override func bind(to viewModel: FriendMapViewModel) {
        setRigaRegion()

        viewModel.beginTrackingFriends(
            onNextUser: handleNextUser,
            onLocationUpdate: handleLocationUpdate
        )
    }

    private func setRigaRegion() {
        mapView.setRegion(
            MKCoordinateRegion(
                center: .rigaCoordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.02,
                    longitudeDelta: 0.02
                )
            ),
            animated: false
        )
    }

    private func handleNextUser(_ user: User) {
        let annotation = UserAnnotation(
            id: user.id,
            image: UIImage(url: user.imageURL),
            title: user.fullName,
            coordinate: user.coordinate
        )

        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
        }
    }

    private func handleLocationUpdate(_ locationUpdate: LocationUpdate) {
        guard let annotation = self.mapView.annotations
                .firstWithId(locationUpdate.id),
              !annotation.coordinate.isEqual(locationUpdate.coordinate) else {
            return
        }

        viewModel.reverseGeocodeLocation(annotation)

        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.3,
                delay: .zero,
                options: [.curveLinear, .preferredFramesPerSecond60]
            ) {
                annotation.coordinate = locationUpdate.coordinate
            }
        }
    }
}

// MARK: MKMapViewDelegate

extension FriendMapViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        guard let annotation = annotation as? UserAnnotation else {
            return nil
        }

        viewModel.reverseGeocodeLocation(annotation)

        guard let annotationView = mapView.dequeueReusableAnnotationView(
            ofType: UserAnnotationView.self
        ) else {
            return UserAnnotationView(annotation: annotation)
        }

        annotationView.annotation = annotation

        return annotationView
    }
}

// MARK: CLLocationCoordinate2D

fileprivate extension CLLocationCoordinate2D {
    static var rigaCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: 56.9496,
            longitude: 24.1052
        )
    }
}

// MARK: Sequence

fileprivate extension Sequence where Element: MKAnnotation {
    func firstWithId(_ id: Int) -> UserAnnotation? {
        compactMap { $0 as? UserAnnotation }
            .first { $0.id == id }
    }
}

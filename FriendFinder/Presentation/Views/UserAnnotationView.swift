//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import MapKit

final class UserAnnotationView: MKAnnotationView {

    init(annotation: UserAnnotation) {
        super.init(
            annotation: annotation,
            reuseIdentifier: String(describing: type(of: self))
        )

        setup()
    }

    @available(*, unavailable)
    init() {
        super.init(annotation: nil, reuseIdentifier: nil)
    }

    @available(*, unavailable)
    override init(
        annotation: MKAnnotation?,
        reuseIdentifier: String?
    ) {
        super.init(
            annotation: annotation,
            reuseIdentifier: reuseIdentifier
        )
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setup() {
        canShowCallout = true

        let configuration = UIImage.SymbolConfiguration(scale: .large)
        image = UIImage(systemName: "figure.walk")?
            .applyingSymbolConfiguration(configuration)

        setLeftCalloutImageView()
    }

    private func setLeftCalloutImageView() {
        guard let annotation = annotation as? UserAnnotation else {
            return
        }

        let imageView = UIImageView(
            image: annotation.image?.withSize(
                CGSize(width: 40, height: 40)
            )
        )
        leftCalloutAccessoryView = imageView
    }
}

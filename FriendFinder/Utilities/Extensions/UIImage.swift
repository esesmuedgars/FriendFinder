//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import UIKit

public extension UIImage {
    convenience init?(url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        self.init(data: data)
    }

    func withSize(_ size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { [weak self] _ in
            self?.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

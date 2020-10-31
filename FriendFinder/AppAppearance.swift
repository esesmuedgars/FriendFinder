//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import UIKit

final class AppAppearance {

    final class func setAppearance() {
        UINavigationBar.appearance().setBackgroundImage(
            UIImage(),
            for: .default
        )
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
    }
}


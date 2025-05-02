import UIKit

extension UIScreen {
    var isPhoneSE: Bool {
        // For the scope of this sample project, this is safe and reliable enough
        return nativeBounds.width <= 640
    }
}

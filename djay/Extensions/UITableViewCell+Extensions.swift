import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: type(of: self))
    }
}

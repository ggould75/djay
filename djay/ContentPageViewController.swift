import UIKit

protocol PageContentProtocol {
    var continueButtonTitle: String { get }
}

final class OnboardingWelcomeViewController: UIViewController, PageContentProtocol {
    var continueButtonTitle: String = "Continue"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

final class OnboardingMixFavoriteMusicViewController: UIViewController, PageContentProtocol {
    var continueButtonTitle: String = "Continue"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

final class OnboardingSelectSkillViewController: UIViewController, PageContentProtocol {
    var continueButtonTitle: String = "Let's Go"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

final class OnboardingFinaleViewController: UIViewController, PageContentProtocol {
    var continueButtonTitle: String = "Done"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

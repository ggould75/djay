import UIKit

protocol PageContentProtocol {
    var continueButtonTitle: String { get }
}

final class OnboardingWelcomePageViewController: UIViewController, PageContentProtocol {
    var continueButtonTitle: String = "Continue"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

final class OnboardingMixFavoriteMusicPageViewController: UIViewController, PageContentProtocol {
    var continueButtonTitle: String = "Continue"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

final class OnboardingSelectSkillPageViewController: UIViewController, PageContentProtocol {
    var continueButtonTitle: String = "Let's Go"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

final class OnboardingFinalePageViewController: UIViewController, PageContentProtocol {
    var continueButtonTitle: String = "Done"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

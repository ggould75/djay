import UIKit

protocol OnboardingPageContent {
    var continueButtonTitle: String { get }
}

final class OnboardingWelcomeViewController: UIViewController, OnboardingPageContent {
    var continueButtonTitle: String = "Continue"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

final class OnboardingMixFavoriteMusicViewController: UIViewController, OnboardingPageContent {
    var continueButtonTitle: String = "Continue"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

final class OnboardingSelectSkillViewController: UIViewController, OnboardingPageContent {
    var continueButtonTitle: String = "Let's Go"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

final class OnboardingFinaleViewController: UIViewController, OnboardingPageContent {
    var continueButtonTitle: String = "Done"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

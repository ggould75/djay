import UIKit

protocol OnboardingPageContent {
    var continueButtonTitle: String { get }
}

final class OnboardingWelcomeViewController: UIViewController, OnboardingPageContent {
    var continueButtonTitle: String = "Continue"

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to djay!"
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 2

        let fontMetrics = UIFontMetrics(forTextStyle: .title2)
        let preferredFont = UIFont.systemFont(ofSize: 22)
        label.font = fontMetrics.scaledFont(for: preferredFont, maximumPointSize: 26)
        label.adjustsFontForContentSizeCategory = true

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(welcomeLabel)

        NSLayoutConstraint.activate([
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            welcomeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
        ])
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

import UIKit

final class OnboardingWelcomeViewController: UIViewController, OnboardingPageContent {
    // MARK: OnboardingPageContent

    var navigationButtonTitle: String = "Continue"
    var navigationButtonEnabledCallback: ((Bool) -> Void)?
    
    func navigationButtonTapped(completion: @escaping (OnboardingPageResult) -> Void) {
        completion(.proceed)
    }

    // MARK: Subviews setup

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.image = UIImage(named: "onboarding-djay-logo")

        return imageView
    }()

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.text = "Welcome to djay!"
        label.textAlignment = .center
        label.textColor = .white

        let fontMetrics = UIFontMetrics(forTextStyle: .title2)
        let preferredFont = UIFont.systemFont(ofSize: 22)
        label.font = fontMetrics.scaledFont(for: preferredFont, maximumPointSize: 26)
        label.adjustsFontForContentSizeCategory = true

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(welcomeLabel)
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: welcomeLabel.topAnchor),

            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            welcomeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
        ])
    }
}

import UIKit

final class OnboardingWelcomeViewController: UIViewController, OnboardingPageContent {
    // MARK: OnboardingPageContent

    var navigationButtonTitle: String = "Continue"
    var navigationButtonEnabledCallback: ((Bool) -> Void)?
    
    func navigationButtonTapped(completion: @escaping (OnboardingPageResult) -> Void) {
        completion(.proceed)
    }

    // MARK: Subviews setup

    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "onboarding-djay-logo")

        return imageView
    }()

    let welcomeLabel: UILabel = {
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

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        containerView.addSubview(logoImageView)

        view.addSubview(welcomeLabel)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: welcomeLabel.topAnchor),

            logoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            welcomeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
        ])
    }
}

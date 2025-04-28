import UIKit

final class OnboardingMixFavoriteMusicViewController: UIViewController, OnboardingPageContent {
    private enum Constants {
        static let fontSize: CGFloat = 34
        static let fontMetrics = UIFontMetrics(forTextStyle: .largeTitle)
        static let preferredFont = UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }

    // MARK: OnboardingPageContent
    
    var navigationButtonTitle: String = "Continue"
    var navigationButtonEnabledCallback: ((Bool) -> Void)?
    
    func navigationButtonTapped(completion: @escaping (OnboardingPageResult) -> Void) {
        completion(.proceed)
    }
    
    // MARK: Subviews setup
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.alignment = .center

        return stackView
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        imageView.image = UIImage(named: "onboarding-djay-logo")

        return imageView
    }()

    private let appsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow - 2, for: .vertical)
        imageView.image = UIImage(named: "onboarding-apps")

        return imageView
    }()

    private let favoriteMusicLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Mix Your Favorite Music"
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        return label
    }()

    private let appleAwardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "onboarding-apple-award")
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        return imageView
    }()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            updateUIForCurrentTraitCollection()
        }
    }

    private func updateUIForCurrentTraitCollection() {
        stackView.spacing = preferredStackViewSpacing

        if traitCollection.verticalSizeClass == .regular {
            favoriteMusicLabel.font = Constants.fontMetrics.scaledFont(for: Constants.preferredFont,
                                                                       maximumPointSize: Constants.fontSize)
        } else if traitCollection.verticalSizeClass == .compact {
            favoriteMusicLabel.font = Constants.fontMetrics.scaledFont(for: Constants.preferredFont,
                                                                       maximumPointSize: 15)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUIForCurrentTraitCollection()

        view.addSubview(stackView)

        let topSpacerView = UIView.spacerView()
        let bottomSpacerView = UIView.spacerView()

        stackView.addArrangedSubview(topSpacerView)
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(appsImageView)
        stackView.addArrangedSubview(favoriteMusicLabel)
        stackView.addArrangedSubview(appleAwardImageView)
        stackView.addArrangedSubview(bottomSpacerView)

        stackView.setCustomSpacing(0, after: appleAwardImageView)

        topSpacerView.heightAnchor.constraint(equalTo: bottomSpacerView.heightAnchor).isActive = true

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),

            logoImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            appsImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            appleAwardImageView.heightAnchor.constraint(lessThanOrEqualToConstant: appleAwardImageViewPreferredHeight),
        ])
    }
}

fileprivate extension OnboardingMixFavoriteMusicViewController {
    var preferredStackViewSpacing: CGFloat {
        guard traitCollection.verticalSizeClass == .compact else {
            return 20 // for any iPhone in portrait mode
        }

        return UIScreen.main.nativeBounds.width <= 640
                    ? 5  // for iPhone SE
                    : 10 // for larger iPhones
    }

    var appleAwardImageViewPreferredHeight: CGFloat {
        return UIScreen.main.nativeBounds.width <= 640
            ? traitCollection.verticalSizeClass == .compact ? 40 : 80 // for iPhone SE
            : 80 // for larger iPhones
    }
}

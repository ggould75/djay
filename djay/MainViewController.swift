import UIKit

final class MainViewController: UIViewController {
    var hasSeenOnboarding = false

    private let appTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = "djay"
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        label.isHidden = true

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()


        view.addSubview(appTitleLabel)

        NSLayoutConstraint.activate([
            appTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasSeenOnboarding else {
            appTitleLabel.isHidden = false
            return
        }

        defer {
            hasSeenOnboarding = true
        }

        let onboardingViewController = OnboardingPagesViewController()
        onboardingViewController.modalPresentationStyle = .fullScreen
        present(onboardingViewController, animated: false)
    }
}

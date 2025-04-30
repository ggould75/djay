import UIKit

final class MainViewController: UIViewController {
    var hasSeenOnboarding = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = "djay"
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasSeenOnboarding else { return }

        defer {
            hasSeenOnboarding = true
        }

        let onboardingViewController = OnboardingPagesViewController()
        onboardingViewController.modalPresentationStyle = .fullScreen
        present(onboardingViewController, animated: false)
    }
}

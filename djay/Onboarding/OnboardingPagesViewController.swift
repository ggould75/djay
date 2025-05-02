import UIKit

enum OnboardingPage: Int, CaseIterable {
    case welcome
    case mixFavoriteMusic
    case skills
    case finale
}

extension OnboardingPage {
    var next: OnboardingPage? {
        return OnboardingPage(rawValue: self.rawValue + 1)
    }

    func viewController(_ arguments: Any...) -> UIViewController & OnboardingPageContent {
        switch self {
        case .welcome:
            return OnboardingWelcomeViewController()
        case .mixFavoriteMusic:
            return OnboardingMixFavoriteMusicViewController()
        case .skills:
            return OnboardingSkillsViewController(.init())
        case .finale:
            guard
                let skillsPageResult = arguments.first as? OnboardingPageResult,
                case let .proceedWithSkillLevel(selectedSkillLevel) = skillsPageResult
            else {
                assertionFailure("Unexpected arguments configuration")
                return UIViewController() as! UIViewController & OnboardingPageContent
            }

            return OnboardingFinaleViewController(selectedSkillLevel)
        }
    }
}

// MARK: -

enum OnboardingPageResult {
    case proceed
    case proceedWithSkillLevel(OnboardingSkillLevel)
}

protocol OnboardingPageContent {
    var navigationButtonTitle: String { get }
    var navigationButtonEnabledCallback: ((Bool) -> Void)? { get set }

    func navigationButtonTapped(completion: @escaping (OnboardingPageResult) -> Void)
}

final class OnboardingPagesViewController: UIViewController {
    private var currentPage = OnboardingPage.welcome

    private let customNavigationController = UINavigationController()
    private var currentContentViewController: (UIViewController & OnboardingPageContent)?

    // MARK: Subviews setup

    private let navigationButton: UIButton = {
        let fontMetrics = UIFontMetrics(forTextStyle: .callout)
        let preferredFont = UIFont.systemFont(ofSize: 18, weight: .semibold)

        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .large
        var contentInsets = configuration.contentInsets
        contentInsets.top = 11
        contentInsets.bottom = 11
        contentInsets.leading = 80
        contentInsets.trailing = 80
        configuration.contentInsets = contentInsets
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = fontMetrics.scaledFont(for: preferredFont, maximumPointSize: 24)

            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.init(white: 0.6, alpha: 1), for: .disabled)
        button.configurationUpdateHandler = { button in
            var configuration = button.configuration
            if button.isEnabled {
                configuration?.background.backgroundColor = .systemBlue
            } else {
                configuration?.background.backgroundColor = .systemBlue.withAlphaComponent(0.5)
            }

            button.configuration = configuration
        }

        return button
    }()

    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = .lightGray
        control.isUserInteractionEnabled = false

        return control
    }()

    private func setupGradientBackground() {
        let gradientBackgroundView = GradientBackgroundView()
        gradientBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientBackgroundView)

        NSLayoutConstraint.activate([
            gradientBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupUI() {
        navigationButton.addTarget(self, action: #selector(navigationButtonTapped), for: .touchUpInside)

        view.addSubview(navigationButton)
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            navigationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navigationButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        view.bringSubviewToFront(navigationButton)
        view.bringSubviewToFront(pageControl)

        pageControl.numberOfPages = OnboardingPage.allCases.count
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        setupUI()
        setupNavigationController()
    }

    // MARK: Navigation Controller setup

    private func setupNavigationController() {
        addChild(customNavigationController)
        view.addSubview(customNavigationController.view)
        customNavigationController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
            customNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationController.view.bottomAnchor.constraint(equalTo: navigationButton.topAnchor)
        ])

        customNavigationController.didMove(toParent: self)

        // Configure navigation controller
        customNavigationController.isNavigationBarHidden = true
        customNavigationController.delegate = self

        // Set up first screen
        var firstViewController = currentPage.viewController()
        firstViewController.navigationButtonEnabledCallback = { [weak self] enabled in
            self?.navigationButton.isEnabled = enabled
        }

        currentContentViewController = firstViewController
        customNavigationController.pushViewController(firstViewController, animated: false)
        updateNavigationButtonTitle()
    }

    // MARK: Page navigation

    private func navigateToNextPage(previousPageResult: OnboardingPageResult) {
        guard let nextPage = currentPage.next else {
            dismiss(animated: true)
            return
        }

        currentPage = nextPage
        pageControl.currentPage = currentPage.rawValue

        var nextPageViewController = currentPage.viewController(previousPageResult)
        nextPageViewController.navigationButtonEnabledCallback = { [weak self] enabled in
            self?.navigationButton.isEnabled = enabled
        }

        currentContentViewController = nextPageViewController
        customNavigationController.pushViewController(nextPageViewController, animated: true)

        updateNavigationButtonTitle()
    }

    @objc private func navigationButtonTapped() {
        currentContentViewController?.navigationButtonTapped { [weak self] result in
            self?.navigateToNextPage(previousPageResult: result)
        }
    }

    private func updateNavigationButtonTitle() {
        navigationButton.setTitle(currentContentViewController?.navigationButtonTitle, for: .normal)
    }
}

// MARK: - UINavigationControllerDelegate

extension OnboardingPagesViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromViewController: UIViewController,
                              to toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            if fromViewController is OnboardingWelcomeViewController &&
                toViewController is OnboardingMixFavoriteMusicViewController {
                return OnboardingWelcomeToMixFavoriteMusicTransition()
            }

            return OnboardingStandardTransition()
        }

        return nil
    }
}

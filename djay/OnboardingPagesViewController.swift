import UIKit

protocol OnboardingPageContent {
    var nextPageButtonTitle: String { get }
}

final class OnboardingPagesViewController: UIViewController {
    private var pages = [UIViewController & OnboardingPageContent]()
    private var currentPageIndex = 0
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let gradientBackgroundView = GradientBackgroundView()

    private let nextPageButton: UIButton = {
        let fontMetrics = UIFontMetrics(forTextStyle: .callout)
        let preferredFont = UIFont.systemFont(ofSize: 18, weight: .semibold)

        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .large
        configuration.background.backgroundColor = .systemBlue
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        setupUI()
        setupPages()
        setupPageViewController()
    }

    private func setupGradientBackground() {
        gradientBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientBackgroundView)

        NSLayoutConstraint.activate([
            gradientBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupPages() {
        pages = [
            OnboardingWelcomeViewController(),
            OnboardingMixFavoriteMusicViewController(),
            OnboardingSkillsViewController(.init(), nextPageButtonEnabledChanged: { [weak self] isEnabled in
                self?.nextPageButton.isEnabled = isEnabled
            }),
            OnboardingFinaleViewController()
        ]

        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
    }

    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: nextPageButton.topAnchor)
        ])

        pageViewController.didMove(toParent: self)

        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: false, completion: nil)
            updateNextPageButtonTitle()
        }
    }

    private func setupUI() {
        nextPageButton.addTarget(self, action: #selector(nextPageButtonTapped), for: .touchUpInside)

        view.addSubview(nextPageButton)
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            nextPageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextPageButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        view.bringSubviewToFront(nextPageButton)
        view.bringSubviewToFront(pageControl)
    }

    @objc private func nextPageButtonTapped() {
        guard currentPageIndex < pages.count - 1 else {
            print("Reached finale page. TODO")
            return
        }

        currentPageIndex += 1
        pageControl.currentPage = currentPageIndex

        pageViewController.setViewControllers(
            [pages[currentPageIndex]],
            direction: .forward,
            animated: true,
            completion: nil
        )

        updateNextPageButtonTitle()
    }

    private func updateNextPageButtonTitle() {
        let currentPage = pages[currentPageIndex]
        nextPageButton.setTitle(currentPage.nextPageButtonTitle, for: .normal)
    }
}

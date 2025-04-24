import UIKit

final class OnboardingPagesViewController: UIViewController {
    private var pages = [UIViewController & OnboardingPageContent]()
    private var currentPageIndex = 0
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let gradientBackgroundView = GradientBackgroundView()

    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        let fontMetrics = UIFontMetrics(forTextStyle: .callout)
        let preferredFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.titleLabel?.font = fontMetrics.scaledFont(for: preferredFont, maximumPointSize: 24)
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10

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
        setupPages()
        setupPageViewController()
        setupUI()
    }

    private func setupGradientBackground() {
        gradientBackgroundView.frame = view.bounds
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
        pages = [OnboardingWelcomeViewController(),
                 OnboardingMixFavoriteMusicViewController(),
                 OnboardingSelectSkillViewController(),
                 OnboardingFinaleViewController()]

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
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        pageViewController.didMove(toParent: self)

        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: false, completion: nil)
            updateContinueButtonTitle()
        }
    }

    private func setupUI() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)

        view.addSubview(continueButton)
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            continueButton.widthAnchor.constraint(equalToConstant: 200),
            continueButton.heightAnchor.constraint(equalToConstant: 44),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        view.bringSubviewToFront(continueButton)
        view.bringSubviewToFront(pageControl)
    }

    @objc private func continueButtonTapped() {
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

        updateContinueButtonTitle()
    }

    private func updateContinueButtonTitle() {
        let currentPage = pages[currentPageIndex]
        continueButton.setTitle(currentPage.continueButtonTitle, for: .normal)
    }
}

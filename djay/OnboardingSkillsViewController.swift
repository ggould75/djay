import UIKit

final class OnboardingSkillCell: UITableViewCell {
    private enum Constants {
        static let fontMetrics = UIFontMetrics(forTextStyle: .body)
        static let preferredFont = UIFont.systemFont(ofSize: 17)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        var contentConfiguration: UIListContentConfiguration = defaultContentConfiguration()
        contentConfiguration.textProperties.color = .white
        contentConfiguration.textProperties.font = Constants.fontMetrics.scaledFont(for: Constants.preferredFont,
                                                                                    maximumPointSize: 25)
        self.contentConfiguration = contentConfiguration

        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.cornerRadius = 12
        backgroundConfiguration.strokeWidth = 2
        self.backgroundConfiguration = backgroundConfiguration
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Managing the state

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)

        let isSelected = state.isSelected

        var newBackgroundConfiguration = backgroundConfiguration?.updated(for: state)
        newBackgroundConfiguration?.backgroundColor = .init(white: 1, alpha: state.isHighlighted ? 0.25 : 0.1)
        newBackgroundConfiguration?.strokeColor = isSelected ? .tintColor : .clear

        var newContentConfiguration = contentConfiguration as! UIListContentConfiguration
        let imageSystemName = state.isSelected ? "checkmark.circle.fill" : "circle"
        let paletteColors: [UIColor] = isSelected ? [.white, .systemBlue] : [.init(white: 0.45, alpha: 1), .systemBlue]
        let symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: paletteColors)
            .applying(UIImage.SymbolConfiguration(scale: .large))
            .applying(UIImage.SymbolConfiguration(weight: .semibold))
        newContentConfiguration.imageProperties.preferredSymbolConfiguration = symbolConfiguration
        newContentConfiguration.image = UIImage(systemName: imageSystemName)

        UIView.animate(withDuration: 0.2) {
            self.backgroundConfiguration = newBackgroundConfiguration
            self.contentConfiguration = newContentConfiguration
        }
    }

    // MARK: UI updates

    fileprivate func updateUI(for traitCollection: UITraitCollection) {
        var newContentConfiguration = contentConfiguration as! UIListContentConfiguration

        if traitCollection.verticalSizeClass == .regular {
            newContentConfiguration.textProperties.font = Constants.fontMetrics.scaledFont(for: Constants.preferredFont,
                                                                                           maximumPointSize: 25)
        } else if traitCollection.verticalSizeClass == .compact {
            let maximumPointSize: CGFloat = UIScreen.main.nativeBounds.width <= 640
                                                ? 17 // for iPhone SE
                                                : 20 // for larger iPhones
            let preferredFontSize: CGFloat = UIScreen.main.nativeBounds.width <= 640
                                                ? 10 // for iPhone SE
                                                : 15 // for larger iPhones
            newContentConfiguration.textProperties.font = Constants.fontMetrics.scaledFont(for: UIFont.systemFont(ofSize: preferredFontSize),
                                                                                           maximumPointSize: maximumPointSize)
        }

        self.contentConfiguration = newContentConfiguration
    }
}

// MARK: - OnboardingSkillsViewController

final class OnboardingSkillsViewController: UIViewController, OnboardingPageContent {
    private enum Constants {
        static let titleFontSize: CGFloat = 34
        static let titleFontMetrics = UIFontMetrics(forTextStyle: .largeTitle)
        static let titlePreferredFont = UIFont.systemFont(ofSize: titleFontSize, weight: .bold)

        static let subtitleFontSize: CGFloat = 22
        static let subtitleFontMetrics = UIFontMetrics(forTextStyle: .title2)
        static let subtitlePreferredFont = UIFont.systemFont(ofSize: subtitleFontSize, weight: .regular)
    }

    // MARK: OnboardingPageContent

    var navigationButtonTitle: String = "Let's Go"
    var navigationButtonEnabledCallback: ((Bool) -> Void)?
    
    func navigationButtonTapped(completion: @escaping (OnboardingPageResult) -> Void) {
        navigationButtonEnabledCallback?(false)
        prepareSubviewsForTransition { [weak self] in
            guard let self, let selectedSkillLevel = self.viewModel.selectedSkillLevel else {
                return
            }

            completion(.proceedWithSkillLevel(selectedSkillLevel))
            self.navigationButtonEnabledCallback?(true)
        }
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

    private let listeningEmojiImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow - 2, for: .vertical)
        imageView.image = UIImage(named: "onboarding-listening-emoji")

        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome DJ"
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "What’s your DJ skill level?"
        label.textAlignment = .center
        label.textColor = .init(white: 0.7, alpha: 1)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        return label
    }()

    private lazy var skillsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(OnboardingSkillCell.self, forCellReuseIdentifier: OnboardingSkillCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.sectionFooterHeight = 0
        tableView.setContentHuggingPriority(.defaultLow, for: .vertical)
        tableView.setContentCompressionResistancePriority(.required, for: .vertical)

        return tableView
    }()

    private var skillsTableViewLeadingConstraint: NSLayoutConstraint?
    private var skillsTableViewTrailingConstraint: NSLayoutConstraint?

    // MARK: Initialization

    let viewModel: OnboardingSkillsViewModel

    init(_ viewModel: OnboardingSkillsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationButtonEnabledCallback?(false)

        view.addSubview(stackView)

        let topSpacerView = UIView.spacerView()
        let bottomSpacerView = UIView.spacerView()

        stackView.addArrangedSubview(topSpacerView)
        stackView.addArrangedSubview(listeningEmojiImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(skillsTableView)
        stackView.addArrangedSubview(bottomSpacerView)

        stackView.setCustomSpacing(3, after: titleLabel)

        topSpacerView.heightAnchor.constraint(equalTo: bottomSpacerView.heightAnchor).isActive = true

        updateUIForCurrentTraitCollection()

        let tableHeightConstraint = skillsTableView.heightAnchor.constraint(equalToConstant: 180)
        tableHeightConstraint.isActive = true
        tableHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),

            listeningEmojiImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            updateUIForCurrentTraitCollection()
        }
    }

    private func updateUIForCurrentTraitCollection() {
        stackView.spacing = preferredStackViewSpacing

        skillsTableView.reloadData()
        if let selectedIndexPath = viewModel.selectedIndexPath {
            skillsTableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
        }

        let tableViewConstant: CGFloat = traitCollection.verticalSizeClass == .regular ? 0 : 70
        if let skillsTableViewLeadingConstraint {
            skillsTableViewLeadingConstraint.constant = tableViewConstant
        } else {
            skillsTableViewLeadingConstraint = skillsTableView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,
                                                                                        constant: tableViewConstant)
            skillsTableViewLeadingConstraint?.isActive = true
        }

        if let skillsTableViewTrailingConstraint {
            skillsTableViewTrailingConstraint.constant = -tableViewConstant
        } else {
            skillsTableViewTrailingConstraint = skillsTableView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor,
                                                                                          constant: -tableViewConstant)
            skillsTableViewTrailingConstraint?.isActive = true
        }

        // TODO: should be 30 on portrait (any phone), but <= 20 in landscape (probably even less on SE)
        //stackView.setCustomSpacing(30, after: subtitleLabel)

        if traitCollection.verticalSizeClass == .regular {
            titleLabel.font = Constants.titleFontMetrics.scaledFont(for: Constants.titlePreferredFont,
                                                                    maximumPointSize: Constants.titleFontSize)
            subtitleLabel.font = Constants.subtitleFontMetrics.scaledFont(for: Constants.subtitlePreferredFont,
                                                                          maximumPointSize: Constants.subtitleFontSize)
            skillsTableView.rowHeight = 48
        } else if traitCollection.verticalSizeClass == .compact {
            titleLabel.font = Constants.titleFontMetrics.scaledFont(for: Constants.titlePreferredFont,
                                                                    maximumPointSize: 15)
            subtitleLabel.font = Constants.subtitleFontMetrics.scaledFont(for: Constants.subtitlePreferredFont,
                                                                          maximumPointSize: 10)
            skillsTableView.rowHeight = UIScreen.main.nativeBounds.width <= 640
                                            ? 36  // for iPhone SE
                                            : 42  // for larger iPhones
        }
    }
}

// MARK: - UITableViewDataSource

extension OnboardingSkillsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.skillCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: OnboardingSkillCell.identifier, for: indexPath) as? OnboardingSkillCell,
            var contentConfiguration: UIListContentConfiguration = cell.contentConfiguration as? UIListContentConfiguration
        else {
            fatalError("Incorrect cell or content configuration")
        }

        let skillLevel = viewModel.skillLevel(at: indexPath)
        contentConfiguration.text = skillLevel.rawValue
        cell.contentConfiguration = contentConfiguration
        cell.updateUI(for: traitCollection)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension OnboardingSkillsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if traitCollection.verticalSizeClass == .regular {
            return 12
        }

        return UIScreen.main.nativeBounds.width <= 640
                    ? 3  // for iPhone SE
                    : 5  // for larger iPhones
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedIndexPath = indexPath
        navigationButtonEnabledCallback?(true)
    }

    // MARK: Animate views before transitiong to the next page

    private func prepareSubviewsForTransition(_ completion: @escaping () -> Void) {
        let tableViewCells = skillsTableView.visibleCells
        let tableViewWidth = skillsTableView.bounds.width

        let imageDuration = 0.4
        let cellDuration = 0.22
        let cellDelay = 0.12
        let totalDuration = max(imageDuration, cellDuration + cellDelay * Double(tableViewCells.count - 1))

        UIView.animateKeyframes(
            withDuration: totalDuration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: imageDuration / totalDuration) {
                    self.listeningEmojiImageView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
                    self.listeningEmojiImageView.alpha = 0
                    self.titleLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                    self.titleLabel.alpha = 0
                    self.subtitleLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                    self.subtitleLabel.alpha = 0
                }

                for (index, cell) in tableViewCells.enumerated() {
                    let startTime = Double(index) * cellDelay / totalDuration
                    UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: cellDuration / totalDuration) {
                        cell.transform = CGAffineTransform(translationX: -tableViewWidth, y: 0)
                    }
                }
            },
            completion: { _ in
                completion()
            }
        )
    }
}

// MARK: - Helpers

fileprivate extension OnboardingSkillsViewController {
    var preferredStackViewSpacing: CGFloat {
        guard traitCollection.verticalSizeClass == .compact else {
            return 20 // for any iPhone in portrait mode
        }

        return UIScreen.main.nativeBounds.width <= 640
                    ? 5  // for iPhone SE
                    : 10 // for larger iPhones
    }
}

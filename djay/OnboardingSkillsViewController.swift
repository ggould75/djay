import UIKit

final class OnboardingSkillCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        let preferredFont = UIFont.systemFont(ofSize: 17)

        var contentConfiguration: UIListContentConfiguration = defaultContentConfiguration()
        contentConfiguration.textProperties.color = .label
        contentConfiguration.textProperties.font = fontMetrics.scaledFont(for: preferredFont, maximumPointSize: 25)
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
        newBackgroundConfiguration?.backgroundColor = .init(white: 1, alpha: state.isHighlighted ? 0.3 : 0.1)
        newBackgroundConfiguration?.strokeColor = isSelected ? .tintColor : .clear

        var newContentConfiguration = contentConfiguration as! UIListContentConfiguration
        let imageSystemName = state.isSelected ? "checkmark.circle.fill" : "circle"
        let paletteColors: [UIColor] = isSelected ? [.white, .systemBlue] : [.secondaryLabel, .systemBlue]
        let symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: paletteColors)
            .applying(UIImage.SymbolConfiguration(scale: .large))
            .applying(UIImage.SymbolConfiguration(weight: .bold))
        newContentConfiguration.imageProperties.preferredSymbolConfiguration = symbolConfiguration
        newContentConfiguration.image = UIImage(systemName: imageSystemName)

        UIView.animate(withDuration: 0.2) {
            self.backgroundConfiguration = newBackgroundConfiguration
            self.contentConfiguration = newContentConfiguration
        }
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

    var continueButtonTitle: String = "Let's Go"

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
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
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
        label.textColor = .secondaryLabel
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

        updateUIForCurrentTraitCollection()

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

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),

            listeningEmojiImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),

            skillsTableView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            skillsTableView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            skillsTableView.heightAnchor.constraint(equalToConstant: 180),
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

        if traitCollection.verticalSizeClass == .regular {
            titleLabel.font = Constants.titleFontMetrics.scaledFont(for: Constants.titlePreferredFont,
                                                                    maximumPointSize: Constants.titleFontSize)
            subtitleLabel.font = Constants.subtitleFontMetrics.scaledFont(for: Constants.subtitlePreferredFont,
                                                                          maximumPointSize: Constants.subtitleFontSize)
        } else if traitCollection.verticalSizeClass == .compact {
            titleLabel.font = Constants.titleFontMetrics.scaledFont(for: Constants.titlePreferredFont,
                                                                    maximumPointSize: 15)
            subtitleLabel.font = Constants.subtitleFontMetrics.scaledFont(for: Constants.subtitlePreferredFont,
                                                                          maximumPointSize: 10)
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

        return cell
    }
}

// MARK: - UITableViewDelegate

extension OnboardingSkillsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 12
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

    // TODO: do I need this?
    var listeningEmojiImageViewPreferredHeight: CGFloat {
        return UIScreen.main.nativeBounds.width <= 640
            ? traitCollection.verticalSizeClass == .compact ? 40 : 80 // for iPhone SE
            : 80 // for larger iPhones
    }
}

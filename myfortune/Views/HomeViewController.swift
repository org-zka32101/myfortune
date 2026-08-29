import UIKit
import AppTrackingTransparency

class HomeViewController: UIViewController {

    /// A fixed mystical night-sky palette, independent of system light/dark
    /// mode — a fortune-telling app reads best with one deliberate
    /// atmosphere rather than switching to a stark white background.
    private enum Theme {
        static let background = UIColor(red: 0x1A / 255, green: 0x12 / 255, blue: 0x35 / 255, alpha: 1)
        static let accent = UIColor(red: 0xD4 / 255, green: 0xAF / 255, blue: 0x6A / 255, alpha: 1)
        static let textPrimary = UIColor.white
        static let textSecondary = UIColor(white: 1, alpha: 0.7)
    }

    private static var hasRequestedTrackingAuthorization = false

    private var startButton: UIButton!
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        AdManager.shared.preloadInterstitial()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestTrackingAuthorizationIfNeeded()
    }

    /// Requests App Tracking Transparency authorization once per launch.
    /// AdMob can still serve non-personalized ads if the user declines.
    private func requestTrackingAuthorizationIfNeeded() {
        guard #available(iOS 14, *), !Self.hasRequestedTrackingAuthorization else { return }
        Self.hasRequestedTrackingAuthorization = true

        ATTrackingManager.requestTrackingAuthorization { _ in }
    }

    private func setupUI() {
        view.backgroundColor = Theme.background

        // Navigation Bar
        title = "今日の占い"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.overrideUserInterfaceStyle = .dark
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = Theme.background
        navBarAppearance.titleTextAttributes = [.foregroundColor: Theme.textPrimary]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: Theme.textPrimary]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.tintColor = Theme.accent

        // Main Content
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
        ])

        // Welcome Label
        let welcomeLabel = UILabel()
        welcomeLabel.text = "あなただけの、今日の運勢"
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        welcomeLabel.textColor = Theme.textPrimary
        welcomeLabel.textAlignment = .center
        welcomeLabel.numberOfLines = 0
        stackView.addArrangedSubview(welcomeLabel)

        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "AIがあなたの記録をもとに占います"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = Theme.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        stackView.addArrangedSubview(subtitleLabel)

        // Start Button
        let startButton = UIButton(type: .system)
        startButton.setTitle("占いを見る", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        startButton.backgroundColor = Theme.accent
        startButton.setTitleColor(Theme.background, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(startButton)
        self.startButton = startButton

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = Theme.accent
        stackView.addArrangedSubview(activityIndicator)
    }

    @objc private func startButtonTapped() {
        setLoading(true)

        FortuneService.shared.fetchFortune { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case .success(let fortune):
                self.showFortune(fortune)
            case .failure:
                self.showFortune(text: "占いの取得に失敗しました。もう一度お試しください。")
            }
        }
    }

    /// The fortune now comes from a network call (Cloud Function), so guard
    /// against double taps and give the user something to look at while it
    /// loads — this used to be instant when it was a local placeholder.
    private func setLoading(_ isLoading: Bool) {
        startButton.isEnabled = !isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    private func showFortune(_ fortune: Fortune) {
        showFortune(text: fortune.text)
    }

    private func showFortune(text: String) {
        let alert = UIAlertController(title: "今日の占い", message: text, preferredStyle: .alert)
        alert.view.tintColor = Theme.accent
        alert.addAction(UIAlertAction(title: "閉じる", style: .default) { [weak self] _ in
            self?.showAdIfNeeded()
        })
        present(alert, animated: true)
    }

    /// Free users see an interstitial ad right after viewing their fortune
    /// result. Premium users (see `PremiumManager`) never see it.
    private func showAdIfNeeded() {
        guard !PremiumManager.shared.isPremium else { return }
        AdManager.shared.showInterstitial(from: self)
    }
}

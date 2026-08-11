import UIKit
import AppTrackingTransparency

class HomeViewController: UIViewController {

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
        view.backgroundColor = .systemBackground

        // Navigation Bar
        title = "myfortune"
        navigationController?.navigationBar.prefersLargeTitles = true

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
        ])

        // Welcome Label
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome to myfortune"
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        welcomeLabel.textAlignment = .center
        stackView.addArrangedSubview(welcomeLabel)

        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Discover your daily fortune"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        stackView.addArrangedSubview(subtitleLabel)

        // Start Button
        let startButton = UIButton(type: .system)
        startButton.setTitle("Get Your Fortune", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(startButton)
        self.startButton = startButton

        activityIndicator.hidesWhenStopped = true
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
                self.showFortune(text: "Something went wrong. Please try again.")
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
        let alert = UIAlertController(title: "Fortune", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
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

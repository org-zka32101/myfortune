import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
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
    }

    @objc private func startButtonTapped() {
        let alert = UIAlertController(title: "Fortune", message: "Your fortune awaits!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

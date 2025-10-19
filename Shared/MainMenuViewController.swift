//
//  MainMenuViewController.swift
//  ApplePicking
//
//  Created by Eli Zhang on 5/15/25.
//

import UIKit
import SnapKit

class MainMenuViewController: UIViewController {
    private var appleView: UIView!
    private var titleLabel: UILabel!
    private var startGameButton: UIButton!
    private var dailySeedButton: UIButton!
    private var optionsButton: UIButton!
    
    // Options overlay properties
    private var musicToggle: UISwitch!
    private var musicLabel: UILabel!
    private var vibrationToggle: UISwitch!
    private var vibrationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        // Set background color
        view.backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
        
        // Create title label
        titleLabel = UILabel()
        titleLabel.text = "apple picking"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
      titleLabel.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.7)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(50)
        }
        
        // Create large apple view
        let appleSize: CGFloat = 200
        appleView = createAppleImage(size: CGSize(width: appleSize, height: appleSize))
        view.addSubview(appleView)
        appleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.size.equalTo(appleSize)
        }
        
        // Create start game button
        startGameButton = createButton(title: "Start Game", backgroundColor: UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.7))
        startGameButton.addTarget(self, action: #selector(startGameTapped), for: .touchUpInside)
        view.addSubview(startGameButton)
        startGameButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(appleView.snp.bottom).offset(60)
            make.width.equalTo(250)
            make.height.equalTo(60)
        }
        
        // Create daily seed button
        dailySeedButton = createButton(title: "Daily Seed", backgroundColor: UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.7))
        dailySeedButton.addTarget(self, action: #selector(dailySeedTapped), for: .touchUpInside)
        view.addSubview(dailySeedButton)
        dailySeedButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(startGameButton.snp.bottom).offset(30)
            make.width.equalTo(250)
            make.height.equalTo(60)
        }
        
        // Create options button
        optionsButton = createButton(title: "Options", backgroundColor: UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.7))
        optionsButton.addTarget(self, action: #selector(optionsTapped), for: .touchUpInside)
        view.addSubview(optionsButton)
        optionsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dailySeedButton.snp.bottom).offset(30)
            make.width.equalTo(250)
            make.height.equalTo(60)
        }
    }
    
    private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 15
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        return button
    }
    
    private func createAppleImage(size: CGSize) -> UIView {
        let appleView = UIView(frame: CGRect(origin: .zero, size: size))
        
        // Use the new Apple asset
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Apple")
        imageView.contentMode = .scaleAspectFit
        appleView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return appleView
    }
    
    @objc private func startGameTapped() {
        // Haptic feedback
        let vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        if vibrationEnabled {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Push GameViewController
        let gameVC = GameViewController()
        navigationController?.pushViewController(gameVC, animated: false)
    }
    
    @objc private func dailySeedTapped() {
        // Haptic feedback
        let vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        if vibrationEnabled {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Push GameViewController with daily seed
        let gameVC = GameViewController()
        gameVC.isDailySeedMode = true
        navigationController?.pushViewController(gameVC, animated: false)
    }
    
    @objc private func optionsTapped() {
        // Haptic feedback
        let vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        if vibrationEnabled {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Show options overlay (similar to high scores)
        showOptionsOverlay()
    }
    
    private func showOptionsOverlay() {
        // Create options overlay view
        let optionsView = UIView()
        optionsView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        optionsView.alpha = 0
        view.addSubview(optionsView)
        optionsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Container view
        let containerView = UIView()
        containerView.backgroundColor = UIColor(white: 1, alpha: 0.95)
        containerView.layer.cornerRadius = 20
        containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        optionsView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(300)
        }
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Options"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1.0)
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        // Music toggle section
        let musicStackView = createToggleSection(
            title: "Background Music",
            toggle: &musicToggle,
            label: &musicLabel
        )
        containerView.addSubview(musicStackView)
        musicStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // Vibration toggle section
        let vibrationStackView = createToggleSection(
            title: "Vibrations",
            toggle: &vibrationToggle,
            label: &vibrationLabel
        )
        containerView.addSubview(vibrationStackView)
        vibrationStackView.snp.makeConstraints { make in
            make.top.equalTo(musicStackView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // Close button
        let closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.7)
        closeButton.layer.cornerRadius = 15
        closeButton.addTarget(self, action: #selector(closeOptionsOverlay(_:)), for: .touchUpInside)
        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        
        // Load settings
        loadOptionsSettings()
        
        // Animate the appearance
        UIView.animate(withDuration: 0.3, animations: {
            optionsView.alpha = 1
            containerView.transform = CGAffineTransform.identity
        })
    }
    
    private func createToggleSection(title: String, toggle: inout UISwitch!, label: inout UILabel!) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 15
        
        // Label
        label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1.0)
        stackView.addArrangedSubview(label)
        
        // Toggle switch
        toggle = UISwitch()
        toggle.onTintColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1.0)
        toggle.addTarget(self, action: #selector(optionsToggleChanged(_:)), for: .valueChanged)
        stackView.addArrangedSubview(toggle)
        
        return stackView
    }
    
    private func loadOptionsSettings() {
        // Load music setting (default to true)
        let musicEnabled = UserDefaults.standard.object(forKey: "backgroundMusicEnabled") as? Bool ?? true
        musicToggle.isOn = musicEnabled
        
        // Load vibration setting (default to true)
        let vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        vibrationToggle.isOn = vibrationEnabled
    }
    
    @objc private func optionsToggleChanged(_ sender: UISwitch) {
        // Save the setting first
        if sender == musicToggle {
            UserDefaults.standard.set(sender.isOn, forKey: "backgroundMusicEnabled")
            print("Music setting saved: \(sender.isOn)")
        } else if sender == vibrationToggle {
            UserDefaults.standard.set(sender.isOn, forKey: "vibrationEnabled")
            print("Vibration setting saved: \(sender.isOn)")
        }
        
        // Synchronize UserDefaults to ensure the setting is saved immediately
        UserDefaults.standard.synchronize()
        
        // Only provide haptic feedback if vibrations are enabled
        let vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        if vibrationEnabled {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
    }
    
    @objc private func closeOptionsOverlay(_ sender: UIButton) {
        // Haptic feedback
        let vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        if vibrationEnabled {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Remove options view
        if let optionsView = sender.superview?.superview {
            UIView.animate(withDuration: 0.3, animations: {
                optionsView.alpha = 0
            }, completion: { _ in
                optionsView.removeFromSuperview()
            })
        }
    }
}


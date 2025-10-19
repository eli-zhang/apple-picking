//
//  OptionsViewController.swift
//  ApplePicking
//
//  Created by Eli Zhang on 5/15/25.
//

import UIKit
import SnapKit

class OptionsViewController: UIViewController {
    private var backgroundView: UIView!
    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var musicToggle: UISwitch!
    private var musicLabel: UILabel!
    private var vibrationToggle: UISwitch!
    private var vibrationLabel: UILabel!
    private var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadSettings()
    }
    
    private func setupView() {
        // Set up background
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        // Create container view
        containerView = UIView()
        containerView.backgroundColor = UIColor(white: 1, alpha: 0.95)
        containerView.layer.cornerRadius = 20
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(300)
        }
        
        // Create title
        titleLabel = UILabel()
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
        closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.7)
        closeButton.layer.cornerRadius = 15
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        
        // Add tap gesture to dismiss when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView = UIView()
        backgroundView.addGestureRecognizer(tapGesture)
        view.insertSubview(backgroundView, at: 0)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        stackView.addArrangedSubview(toggle)
        
        return stackView
    }
    
    private func loadSettings() {
        // Load music setting (default to true)
        let musicEnabled = UserDefaults.standard.object(forKey: "backgroundMusicEnabled") as? Bool ?? true
        musicToggle.isOn = musicEnabled
        
        // Load vibration setting (default to true)
        let vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        vibrationToggle.isOn = vibrationEnabled
    }
    
    @objc private func toggleChanged(_ sender: UISwitch) {
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
    
    @objc private func closeTapped() {
        // Haptic feedback
        let vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        if vibrationEnabled {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
}

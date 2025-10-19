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
    private var optionsButton: UIButton!
    
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
        
        // Create options button
        optionsButton = createButton(title: "Options", backgroundColor: UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.7))
        optionsButton.addTarget(self, action: #selector(optionsTapped), for: .touchUpInside)
        view.addSubview(optionsButton)
        optionsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(startGameButton.snp.bottom).offset(30)
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
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let appleImage = renderer.image { ctx in
            // Draw apple shape
            let rect = CGRect(x: size.width * 0.1,
                             y: size.height * 0.1,
                             width: size.width * 0.8,
                             height: size.height * 0.8)
            
            let path = UIBezierPath(ovalIn: rect)
            UIColor.red.setFill()
            path.fill()
            
            // Draw stem
            let stemPath = UIBezierPath()
            stemPath.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.1))
            stemPath.addLine(to: CGPoint(x: size.width * 0.55, y: 0))
            UIColor.brown.setStroke()
            stemPath.lineWidth = 6
            stemPath.stroke()
        }
        
        let imageView = UIImageView(image: appleImage)
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
    
    @objc private func optionsTapped() {
        // Haptic feedback
        let vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        if vibrationEnabled {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Present options view controller
        let optionsVC = OptionsViewController()
        present(optionsVC, animated: true)
    }
}


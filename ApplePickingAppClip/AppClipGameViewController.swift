import UIKit
import SpriteKit
import AVFoundation
import SnapKit

class AppClipGameViewController: GameViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add App Clip specific UI - "Get the full game" button
        setupAppClipUI()
        
        // Modify for a quicker experience
        timeRemaining = 120
        initialTime = 120
    }
    
    func setupAppClipUI() {
        // Add "Get Full Game" button
        let getFullAppButton = UIButton()
        getFullAppButton.setTitle("Get Full Game", for: .normal)
        getFullAppButton.backgroundColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1)
        getFullAppButton.layer.cornerRadius = 10
        getFullAppButton.addTarget(self, action: #selector(getFullApp), for: .touchUpInside)
        view.addSubview(getFullAppButton)
        
        getFullAppButton.snp.makeConstraints { make in
          make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
          make.right.equalToSuperview().offset(-20)
          make.width.equalTo(150)
          make.height.equalTo(40)
        }
    }
    
    @objc func getFullApp() {
//        // Direct users to download the full app
//        if let appClipURL = URL(string: "https://appclip.example.com/get-app") {
//            let appStoreOverlay = SKOverlay(configuration:
//                SKOverlay.AppClipConfiguration(position: .bottom, appClipBundleIdentifier: Bundle.main.bundleIdentifier!))
//            appStoreOverlay.present(in: view.window!)
//        }
    }
    
    // Override some methods to provide a simplified experience
    override func showHighScoresList() {
        // In App Clip, show an upsell instead of full leaderboard
        let alert = UIAlertController(
            title: "Leaderboards",
            message: "Download the full app to access global leaderboards and save your high scores!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Get Full App", style: .default) { _ in
            self.getFullApp()
        })
        alert.addAction(UIAlertAction(title: "Later", style: .cancel))
        present(alert, animated: true)
    }
    
    override func showGlobalLeaderboard() {
        // Prompt to download full app
        showHighScoresList()
    }
    
    override func endGame() {
        super.endGame()
        
        // Add "Get Full App" button to game over screen
        if let gameOverView = gameOverView,
           let containerView = gameOverView.subviews.first(where: { $0.layer.cornerRadius == 20 }) {
            
            let getFullAppButton = UIButton()
            getFullAppButton.setTitle("Get Full Game", for: .normal)
            getFullAppButton.backgroundColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
            getFullAppButton.layer.cornerRadius = 10
            getFullAppButton.addTarget(self, action: #selector(getFullApp), for: .touchUpInside)
            containerView.addSubview(getFullAppButton)
            
            getFullAppButton.snp.makeConstraints { make in
                make.bottom.equalTo(containerView.snp.bottom).offset(-100)
                make.centerX.equalToSuperview()
                make.width.equalTo(200)
                make.height.equalTo(40)
            }
        }
    }
}

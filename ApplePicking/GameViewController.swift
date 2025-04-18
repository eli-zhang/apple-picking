import UIKit
import SpriteKit
import AVFoundation
import SnapKit

class GameViewController: UIViewController {
    var gameView: GameView!
    var timer: Timer?
    var timeRemaining: Int = 120
    var score: Int = 0
    var highScore: Int = 0
    var timerBar: UIProgressView!
    var initialTime: Int = 120
    var audioPlayer: AVAudioPlayer?
    var gameOverView: UIView?
    
    // UI Elements
    private var scoreLabel: UILabel!
    private var highScoreLabel: UILabel!
    private var resetButton: UIButton!
    
    // High scores array
    private var highScores: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
        setupBackgroundMusic()
        // Load high score from UserDefaults
        highScore = UserDefaults.standard.integer(forKey: "highScore")
        // Load high scores array
        if let savedHighScores = UserDefaults.standard.array(forKey: "highScoresArray") as? [Int] {
            highScores = savedHighScores
        }
        highScoreLabel.text = "High Score: \(highScore)"
    }
    
    func setupGame() {
        // Initialize game view
        gameView = GameView(frame: .zero)
        view.addSubview(gameView)
        gameView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Set up UI elements
        setupUIElements()
        
        // Start game timer
        startTimer()
        
        // Initialize the apple grid
        gameView.initializeGrid()
    }
    
    func setupUIElements() {
        // Score Label
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.textColor = .white
        scoreLabel.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.7)
        scoreLabel.textAlignment = .center
        scoreLabel.layer.cornerRadius = 10
        scoreLabel.clipsToBounds = true
        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        // High Score Label with tap gesture
        highScoreLabel = UILabel()
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.textColor = .white
        highScoreLabel.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.7)
        highScoreLabel.textAlignment = .center
        highScoreLabel.layer.cornerRadius = 10
        highScoreLabel.clipsToBounds = true
        highScoreLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showHighScoresList))
        highScoreLabel.addGestureRecognizer(tapGesture)
        view.addSubview(highScoreLabel)
        highScoreLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        // Timer Bar
        timerBar = UIProgressView(progressViewStyle: .bar)
        timerBar.progressTintColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.8)
        timerBar.trackTintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        timerBar.progress = 1.0
        timerBar.transform = timerBar.transform.scaledBy(x: 1.0, y: 2.0) // Make the bar taller
        view.addSubview(timerBar)
        
        // The timer bar will be positioned once the grid layout is finalized in GameView
        // We'll update its constraints after the grid is set up
        
        // Reset Button
        resetButton = UIButton()
        resetButton.setTitle("Reset", for: .normal)
        resetButton.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.7)
        resetButton.layer.cornerRadius = 10
        resetButton.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        view.addSubview(resetButton)
        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
    }
    
    func updateTimerBarLayout() {
        timerBar.snp.makeConstraints { make in
            make.left.equalTo(gameView.gridContainer.snp.left)
            make.right.equalTo(gameView.gridContainer.snp.right)
            make.bottom.equalTo(gameView.gridContainer.snp.top).offset(-10)
            make.height.equalTo(4) // Original height will be doubled by the transform
        }
    }
    
    func startTimer() {
        initialTime = timeRemaining
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 1
            
            // Update timer bar
            let progress = Float(self.timeRemaining) / Float(self.initialTime)
            self.timerBar.progress = progress
            
            // Game over condition
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }
    }
    
    func setupBackgroundMusic() {
        if let path = Bundle.main.path(forResource: "apple picking tunes retro", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Infinite loop
                audioPlayer?.volume = 0.5 // Adjust volume as needed
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Couldn't load audio file: \(error)")
            }
        }
    }
    
    func restartBackgroundMusic() {
        // Stop any current playback
        audioPlayer?.stop()
        
        // Reset to beginning and play again
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    @objc func resetGame() {
        // Haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        // Remove game over view if it exists
        gameOverView?.removeFromSuperview()
        gameOverView = nil
        
        // Reset timer and score
        timeRemaining = 120
        initialTime = timeRemaining
        score = 0
        
        // Update score label
        scoreLabel.text = "Score: 0"
        
        timerBar.progress = 1.0
        
        // Reset game grid
        gameView.initializeGrid()
        
        // Restart timer
        timer?.invalidate()
        startTimer()
        
        // Restart background music
        restartBackgroundMusic()
    }
    
    func endGame() {
        timer?.invalidate()
        
        // Add score to high scores array
        highScores.append(score)
        
        // Sort high scores in descending order
        highScores.sort(by: >)
        
        // Keep only top 10 scores
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
        
        // Save high scores array
        UserDefaults.standard.set(highScores, forKey: "highScoresArray")
        
        // Check for high score
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "highScore")
            UserDefaults.standard.synchronize()
            
            // Update high score label
            highScoreLabel.text = "High Score: \(highScore)"
        }
        
        // Show custom game over screen
        showGameOverScreen()
    }
    
    @objc func showHighScoresList() {
        // Haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        // Create high scores view
        let highScoresView = UIView()
        highScoresView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        view.addSubview(highScoresView)
        highScoresView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Container view
        let containerView = UIView()
        containerView.backgroundColor = UIColor(white: 1, alpha: 0.95)
        containerView.layer.cornerRadius = 20
        highScoresView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(400)
        }
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Top 10 High Scores"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1.0)
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        // High scores list
        let scoresStackView = UIStackView()
        scoresStackView.axis = .vertical
        scoresStackView.spacing = 10
        scoresStackView.distribution = .fillEqually
        containerView.addSubview(scoresStackView)
        scoresStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-100)
        }
        
        // Add score labels
        for (index, score) in highScores.prefix(10).enumerated() {
            let rankLabel = UILabel()
            rankLabel.text = "\(index + 1). \(score)"
            rankLabel.textAlignment = .left
            rankLabel.font = UIFont.systemFont(ofSize: 18)
            rankLabel.textColor = .black
            scoresStackView.addArrangedSubview(rankLabel)
        }
        
        // If we have fewer than 10 scores, add placeholders
        for _ in highScores.count..<10 {
            let placeholder = UILabel()
            placeholder.text = "---"
            placeholder.textAlignment = .left
            placeholder.font = UIFont.systemFont(ofSize: 18)
            placeholder.textColor = .lightGray
            scoresStackView.addArrangedSubview(placeholder)
        }
        
        // Close button
        let closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1.0)
        closeButton.layer.cornerRadius = 10
        closeButton.addTarget(self, action: #selector(closeHighScoresList(_:)), for: .touchUpInside)
        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        // Animate appearance
        containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {
            containerView.transform = .identity
        })
    }
    
    @objc func closeHighScoresList(_ sender: UIButton) {
        // Haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        // Remove high scores view
        if let highScoresView = sender.superview?.superview {
            UIView.animate(withDuration: 0.3, animations: {
                highScoresView.alpha = 0
            }, completion: { _ in
                highScoresView.removeFromSuperview()
            })
        }
    }
    
    func showGameOverScreen() {
        // Create game over view
        gameOverView = UIView()
        gameOverView!.backgroundColor = UIColor(white: 0, alpha: 0.7)
        view.addSubview(gameOverView!)
        gameOverView!.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Container view
        let containerView = UIView()
        containerView.backgroundColor = UIColor(white: 1, alpha: 0.95)
        containerView.layer.cornerRadius = 20
        gameOverView!.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(400)
        }
        
        // Large apple image
        let appleSize: CGFloat = 200
        let appleView = createAppleImage(size: CGSize(width: appleSize, height: appleSize))
        containerView.addSubview(appleView)
        appleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.size.equalTo(appleSize)
        }
        
        // Score inside apple
        let scoreLabel = UILabel()
        scoreLabel.text = "\(score)"
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 48)
        scoreLabel.textColor = .white
        containerView.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.center.equalTo(appleView)
            make.width.equalTo(200)
            make.height.equalTo(100)
        }
        
        // Play again button
        let playAgainButton = UIButton()
        playAgainButton.setTitle("Play Again", for: .normal)
        playAgainButton.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1.0)
        playAgainButton.layer.cornerRadius = 10
        playAgainButton.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        containerView.addSubview(playAgainButton)
        playAgainButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        // Animate appearance
        containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {
            containerView.transform = .identity
        })
    }
    
    func createAppleImage(size: CGSize) -> UIView {
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
            stemPath.lineWidth = 4
            stemPath.stroke()
        }
        
        let imageView = UIImageView(image: appleImage)
        appleView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return appleView
    }
    
    func updateScore(points: Int) {
        score += points
        
        // Update score label
        scoreLabel.text = "Score: \(score)"
    }
}


class GameView: UIView {
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    let gridWidth = 10 // 10 columns
    let gridHeight = 17 // 17 rows
    var cellSize: CGFloat = 0
    var grid: [[AppleCell]] = []
    
    // Grid positioning (we'll still need these for selection calculations)
    var gridOffsetX: CGFloat = 0
    var gridOffsetY: CGFloat = 0
    
    // Grid container to hold all apple cells
    public var gridContainer: UIView!

    // Selection variables
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var selectionLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
        
        setupGridContainer()
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGridContainer() {
        // Create a container for the grid
        gridContainer = UIView()
        addSubview(gridContainer)
        
        // Position the grid with constraints
      gridContainer.snp.makeConstraints { make in
          make.centerX.equalToSuperview()
          make.top.equalTo(self.safeAreaLayoutGuide).offset(90)
          // Ensure enough space for the reset button
          make.bottom.lessThanOrEqualTo(self.safeAreaLayoutGuide).offset(-100).priority(.high)
      }
        
        // We'll calculate actual cell size and grid offset after layout
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Calculate cell size only if it hasn't been set yet
        if cellSize == 0 {
            calculateGridDimensions()
            
            // Update the timer bar in GameViewController
            if let gameVC = findViewController() as? GameViewController {
                gameVC.updateTimerBarLayout()
            }
        }
    }
    
    func calculateGridDimensions() {
        // Calculate available space
        let horizontalPadding: CGFloat = 20
        let topPadding: CGFloat = 120 // Space from top safe area
        let bottomPadding: CGFloat = 90 // Space from bottom safe area
        
        let availableWidth = bounds.width - (horizontalPadding * 2)
        let availableHeight = bounds.height - topPadding - bottomPadding
        
        // Calculate cell size to fit grid (prioritize filling width)
        let cellWidthByWidth = availableWidth / CGFloat(gridWidth)
        let cellHeightByHeight = availableHeight / CGFloat(gridHeight)
        
        // Use the smaller dimension to ensure the grid fits
        cellSize = min(cellWidthByWidth, cellHeightByHeight)
        
        // Update grid container constraints with actual dimensions
      gridContainer.snp.remakeConstraints { make in
          make.centerX.equalToSuperview()
          make.top.equalTo(self.safeAreaLayoutGuide).offset(90)
          make.bottom.lessThanOrEqualTo(self.safeAreaLayoutGuide).offset(-90).priority(.high)
          make.width.equalTo(cellSize * CGFloat(gridWidth))
          make.height.equalTo(cellSize * CGFloat(gridHeight))
      }
        
        // Save grid offsets for selection calculations
        let frame = gridContainer.frame
        gridOffsetX = frame.origin.x
        gridOffsetY = frame.origin.y
    }
    
    func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
      
        // Initialize the feedback generator
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator?.prepare()
    }
    
  func pointToGridPosition(_ point: CGPoint) -> (row: Int, col: Int)? {
      // Convert point to gridContainer's coordinate space
      let pointInGrid = convert(point, to: gridContainer)
      
      // Check if point is within grid bounds
      if pointInGrid.x < 0 || pointInGrid.y < 0 ||
         pointInGrid.x > gridContainer.bounds.width ||
         pointInGrid.y > gridContainer.bounds.height {
          return nil
      }
      
      let col = Int(pointInGrid.x / cellSize)
      let row = Int(pointInGrid.y / cellSize)
      
      // Ensure within grid boundaries
      if col >= 0 && col < gridWidth && row >= 0 && row < gridHeight {
          return (row, col)
      }
      
      return nil
  }

  func gridPositionToPoint(row: Int, col: Int) -> CGPoint {
      // Get position in grid container coordinates
      let pointInGrid = CGPoint(
          x: CGFloat(col) * cellSize,
          y: CGFloat(row) * cellSize
      )
      
      // Convert to view coordinates
      return gridContainer.convert(pointInGrid, to: self)
  }
    
    func initializeGrid() {
        // Wait for layout if cell size hasn't been calculated yet
        if cellSize == 0 {
            // Schedule this to run after layout
            DispatchQueue.main.async {
                self.initializeGrid()
            }
            return
        }
        
        // Remove existing cells
        gridContainer.subviews.forEach { $0.removeFromSuperview() }
        
        // Create new grid
        grid = []
        
        for row in 0..<gridHeight {
            var rowCells: [AppleCell] = []
            
            for col in 0..<gridWidth {
                let cell = AppleCell()
                cell.row = row
                cell.col = col
                cell.setValue(Int.random(in: 1...9)) // Random number 1-9
                
                gridContainer.addSubview(cell)
                cell.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(CGFloat(col) * cellSize)
                    make.top.equalToSuperview().offset(CGFloat(row) * cellSize)
                    make.width.height.equalTo(cellSize)
                }
                
                rowCells.append(cell)
            }
            
            grid.append(rowCells)
        }
    }
    
  @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
      let location = gesture.location(in: self)
      
      switch gesture.state {
      case .began:
          // Start drawing selection with light feedback
          startPoint = location
          createSelectionLayer()
          // Light impact when starting selection
          let lightFeedback = UIImpactFeedbackGenerator(style: .light)
          lightFeedback.impactOccurred()
          
      case .changed:
          // Update selection
          endPoint = location
          updateSelectionLayer()
          
      case .ended:
          // Cap the end point to grid boundaries if needed
          if let cappedEndPoint = capPointToGridBoundaries(location) {
              endPoint = cappedEndPoint
              updateSelectionLayer() // Update selection with capped coordinates
          }
          
          // Process the selection
          let selectionWasSuccessful = processSelection()
          
          // Different feedback based on selection success
          if selectionWasSuccessful {
              // Rigid impact for successful selection
              let rigidFeedback = UIImpactFeedbackGenerator(style: .rigid)
              rigidFeedback.impactOccurred()
          } else {
              // Medium impact for unsuccessful selection
              let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)
              mediumFeedback.impactOccurred(intensity: 0.4)
          }
          
          // Clear the selection
          selectionLayer?.removeFromSuperlayer()
          selectionLayer = nil
          startPoint = nil
          endPoint = nil
          
      default:
          break
      }
  }
  
  func capPointToGridBoundaries(_ point: CGPoint) -> CGPoint? {
      // First check if point is already within grid
      if let _ = pointToGridPosition(point) {
          return point // Already in grid, no need to cap
      }
      
      // Convert to grid container coordinates
      let pointInGrid = convert(point, to: gridContainer)
      
      // Get grid container bounds
      let gridWidth = CGFloat(gridWidth) * cellSize
      let gridHeight = CGFloat(gridHeight) * cellSize
      
      // Cap X coordinate
      var cappedX = pointInGrid.x
      if cappedX < 0 {
          cappedX = 0
      } else if cappedX > gridWidth {
          cappedX = gridWidth - 0.1 // Slightly inside to ensure it maps to last cell
      }
      
      // Cap Y coordinate
      var cappedY = pointInGrid.y
      if cappedY < 0 {
          cappedY = 0
      } else if cappedY > gridHeight {
          cappedY = gridHeight - 0.1 // Slightly inside to ensure it maps to last cell
      }
      
      // Create capped point in grid coordinates
      let cappedPointInGrid = CGPoint(x: cappedX, y: cappedY)
      
      // Convert back to view coordinates
      return gridContainer.convert(cappedPointInGrid, to: self)
  }
    
    func createSelectionLayer() {
        selectionLayer = CAShapeLayer()
        selectionLayer?.fillColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 0.2).cgColor
        selectionLayer?.strokeColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 0.8).cgColor
        selectionLayer?.lineWidth = 2.0
        layer.addSublayer(selectionLayer!)
    }
    
  func updateSelectionLayer() {
      guard let start = startPoint, let end = endPoint, let layer = selectionLayer else { return }
      
      // Convert touch points to grid positions
      guard let startGridPos = pointToGridPosition(start),
            let endGridPos = pointToGridPosition(end) else {
          return
      }
      
      // Calculate min and max coordinates to support selection in any direction
      let minRow = min(startGridPos.row, endGridPos.row)
      let maxRow = max(startGridPos.row, endGridPos.row)
      let minCol = min(startGridPos.col, endGridPos.col)
      let maxCol = max(startGridPos.col, endGridPos.col)
      
      // Get the top-left and bottom-right corners in screen coordinates
      let topLeft = gridPositionToPoint(row: minRow, col: minCol)
      let bottomRight = gridPositionToPoint(row: maxRow+1, col: maxCol+1)  // +1 to include full cell
      
      // Create a rectangle that encompasses all cells in the selection
      let rect = CGRect(
          x: topLeft.x,
          y: topLeft.y,
          width: bottomRight.x - topLeft.x,
          height: bottomRight.y - topLeft.y
      )
      
      let path = UIBezierPath(rect: rect)
      layer.path = path.cgPath
  }
    
  func processSelection() -> Bool {
      guard let start = startPoint, let end = endPoint else { return false }
      
      // Convert touch points to grid positions
      guard let startGridPos = pointToGridPosition(start),
            let endGridPos = pointToGridPosition(end) else {
          return false
      }
      
      // Calculate min and max coordinates to support selection in any direction
      let minRow = min(startGridPos.row, endGridPos.row)
      let maxRow = max(startGridPos.row, endGridPos.row)
      let minCol = min(startGridPos.col, endGridPos.col)
      let maxCol = max(startGridPos.col, endGridPos.col)
      
      // Get all cells in selection
      var selectedCells: [AppleCell] = []
      var sum = 0
      
      for row in minRow...maxRow {
          for col in minCol...maxCol {
              let cell = grid[row][col]
              if cell.value > 0 {
                  selectedCells.append(cell)
                  sum += cell.value
              }
          }
      }
      
      // Check if sum is 10
      if sum == 10 {
          // Valid selection, remove apples
          for cell in selectedCells {
              animateRemoveApple(cell)
          }
          
          // Update score (more points for larger groups)
          if let gameVC = findViewController() as? GameViewController {
              gameVC.updateScore(points: selectedCells.count)
          }
          return true
      } else {
          // Invalid selection, show feedback
          flashSelection(startRow: minRow, startCol: minCol, endRow: maxRow, endCol: maxCol)
          return false
      }
  }
    
    func animateRemoveApple(_ cell: AppleCell) {
        UIView.animate(withDuration: 0.3, animations: {
            cell.alpha = 0
            cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { _ in
            cell.removeFromSuperview()
            // Mark cell as empty
            self.grid[cell.row][cell.col].value = 0
            self.grid[cell.row][cell.col].isEmpty = true
        })
    }
    
    func flashSelection(startRow: Int, startCol: Int, endRow: Int, endCol: Int) {
        // Visual feedback for invalid selection
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2).cgColor
        selectionLayer.strokeColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8).cgColor
        selectionLayer.lineWidth = 2.0
        
        let startPoint = gridPositionToPoint(row: startRow, col: startCol)
        let endPoint = gridPositionToPoint(row: endRow, col: endCol)
        
        let rect = CGRect(
            x: startPoint.x,
            y: startPoint.y,
            width: (endPoint.x - startPoint.x) + cellSize,
            height: (endPoint.y - startPoint.y) + cellSize
        )
        
        let path = UIBezierPath(rect: rect)
        selectionLayer.path = path.cgPath
        
        layer.addSublayer(selectionLayer)
        
        // Flash animation
        UIView.animate(withDuration: 0.3, animations: {
            selectionLayer.opacity = 0
        }, completion: { _ in
            selectionLayer.removeFromSuperlayer()
        })
    }
    
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
}

class AppleCell: UIView {
    var value: Int = 0
    var row: Int = 0
    var col: Int = 0
    var isEmpty: Bool = false
    
    private let appleImageView = UIImageView()
    private let numberLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Apple background
        appleImageView.contentMode = .scaleAspectFit
        addSubview(appleImageView)
        appleImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Number label
        numberLabel.textAlignment = .center
        numberLabel.textColor = .white
        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // The apple image will be created when the frame is known
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create apple image once we know our size
        if !bounds.isEmpty && appleImageView.image == nil {
            createAppleImage()
        }
        
        // Update font size based on cell size
        numberLabel.font = UIFont.boldSystemFont(ofSize: min(bounds.width, bounds.height) * 0.5)
    }
    
    private func createAppleImage() {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let appleImage = renderer.image { ctx in
            // Draw apple shape
            let rect = CGRect(x: bounds.width * 0.1,
                             y: bounds.height * 0.1,
                             width: bounds.width * 0.8,
                             height: bounds.height * 0.8)
            
            let path = UIBezierPath(ovalIn: rect)
            UIColor.red.setFill()
            path.fill()
            
            // Draw stem
            let stemPath = UIBezierPath()
            stemPath.move(to: CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.1))
            stemPath.addLine(to: CGPoint(x: bounds.width * 0.55, y: 0))
            UIColor.brown.setStroke()
            stemPath.lineWidth = 2
            stemPath.stroke()
        }
        
        appleImageView.image = appleImage
    }
    
    func setValue(_ newValue: Int) {
        value = newValue
        numberLabel.text = "\(newValue)"
        isEmpty = false
    }
}

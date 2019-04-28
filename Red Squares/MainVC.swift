//
//  MainVC.swift
//  Red Squares
//
//  Created by Kamil Wrobel on 4/27/19.
//  Copyright © 2019 Kamil Wrobel. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var tapButton: UIButton!
    
    //MARK: - Properties
    var tapCount: Int = 0 {
        didSet {
            if self.tapCount == 1 {
                countLabel.text = "\(self.tapCount) tap."
            } else {
                countLabel.text = "\(self.tapCount) taps."
            }
        }
    }
    
    var squareSide : CGFloat = 0
    var possiblePoints : [CGPoint] = []
    var placedSquarePoints : [CGPoint] = []
    var randomPoint = CGPoint()
    var allSquares = [UIView]()
    var animationStratingPoint = CGPoint()
    var fullScreen = false
    var methodCalledAgain = false
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        squareSide = self.view.frame.width / 4
        print("✅\(squareSide)")
        getPossiblePoints()
        print(possiblePoints.count)
        print(possiblePoints)
        randomPoint = grabRandomPoint()
        countLabel.text = "\(tapCount) taps."
    }
    
    
    //MARK: - Actions
    @IBAction func centerButtonTapped(_ sender: Any) {
        tapCount += 1
        placeSquareInRandomSpot()
        self.view.bringSubviewToFront(tapButton)
        self.view.bringSubviewToFront(countLabel)
        
    }
    
    
    //MARK: - Methods
    func placeSquareInRandomSpot(){
        randomPoint = grabRandomPoint()
        
        if !methodCalledAgain {
            animationStratingPoint = randomPoint
        }
        
        if tapCount >= 32 {
            fullScreen = true
            tapButton.isEnabled = false
        }
        print("🤩 random point: \(randomPoint)  animation statrting point:\(animationStratingPoint)")
        
        func wasThePointUsed(randomPoint: CGPoint) -> Bool {
            for point in placedSquarePoints {
                if point == randomPoint {
                    return true
                }
            }
            return false
        }
        if placedSquarePoints.isEmpty {
            placedSquarePoints.append(randomPoint)
            drawSquareWith(xPosition: randomPoint.x, yPosition: randomPoint.y, squareSide: squareSide, showAlert: fullScreen)
        } else {
            if wasThePointUsed(randomPoint: randomPoint) {
                animationStratingPoint = randomPoint
                randomPoint = grabRandomPoint()
                
                placeSquareInRandomSpot()
                methodCalledAgain = true
            } else {
                drawSquareWith(xPosition: randomPoint.x, yPosition: randomPoint.y, squareSide: squareSide, showAlert: fullScreen)
                methodCalledAgain = false
                placedSquarePoints.append(randomPoint)
            }
        }
    }
    
    
    
    func grabRandomPoint() -> CGPoint {
        let randomIndex = Int.random(in: 0...(possiblePoints.count - 1))
        return possiblePoints[randomIndex]
    }
    
    
    
    func getPossiblePoints(){
        var initialPoint = CGPoint(x: 0, y: 0)
        
        for _ in 0...3 {
            for _ in 0...7 {
                let newPoint = CGPoint(x: initialPoint.x, y: initialPoint.y)
                possiblePoints.append(newPoint)
                initialPoint.y += squareSide
            }
            initialPoint.x += squareSide
            initialPoint.y = 0
        }
    }
    
    
    func drawSquareWith(xPosition: CGFloat, yPosition: CGFloat, squareSide: CGFloat, showAlert: Bool){
        let square = UIView(frame: CGRect(x: self.view.bounds.midX - squareSide/2, y: self.view.bounds.midY - squareSide/2, width: squareSide, height: squareSide))
        square.backgroundColor = randomColor()
        self.view.addSubview(square)
        allSquares.append(square)
        
        UIView.animate(withDuration: 2.0, animations: {
            square.frame.origin.x = self.animationStratingPoint.x
            square.frame.origin.y = self.animationStratingPoint.y
        }) { (_) in
            UIView.animate(withDuration: 1.0, animations: {
                square.frame.origin.x = xPosition
                square.frame.origin.y = yPosition
            }) { (_) in
                if showAlert == true {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Screen is full of squares", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Start Over", style: .default, handler: { (_) in
                            self.tapCount = 0
                            self.placedSquarePoints = []
                            self.fullScreen = false
                            self.tapButton.isEnabled = true
                            for square in self.allSquares {
                                square.removeFromSuperview()
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    func randomColor() -> UIColor {
        return UIColor(displayP3Red: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
}


//MARK: - CGFloat Extension
//needed for random color picker.
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

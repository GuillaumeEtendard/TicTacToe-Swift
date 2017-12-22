//
//  ViewController.swift
//  TicTacToe
//
//  Created by Guillaume Etendard on 25/10/2017.
//  Copyright © 2017 Guillaume Etendard. All rights reserved.
//

import UIKit


extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}


class PlayOfflineViewController: UIViewController {

    @IBOutlet weak var gamesPlayed: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            let lastkill = UserDefaults.standard.array(forKey: "lastkill") as? Array<[String: String]> ?? Array<[String: String]>()
            
            self.gamesPlayed.text = "\(lastkill.count) Games Played"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
       
    }
    @IBAction func clearCache(_ sender: UIButton) {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey:"lastkill")
        let alert = UIAlertController(title: "Cache", message: "Cache cleared", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.gamesPlayed.text = "0 Games Played"
    }
    @IBAction func playButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ShowModal", sender: nil)
    }
}


class OfflineModalViewController: UIViewController{
    var playerTurn: Int = 1
    
    var turns: [String: [Int]] = [:]
    var cases = [Int](repeating: 0, count: 9)

    let winningCombos = [[0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]]
    
    var finalResult = 0
    
    @IBOutlet weak var playerTurnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setPlayerTurnLabel("It's Player \(self.playerTurn) turn")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            if hitView is PlayView{
                self.play(playView: hitView as! PlayView)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func play(playView: PlayView){
        if(playView.subviews.count != 0 || self.finalResult != 0) {
            return
        }
        
        
        let userDefaults = UserDefaults.standard
        var lastkill = userDefaults.array(forKey: "lastkill") as? Array<[String: String]> ?? Array<[String: String]>()
        cases[playView.tag] = self.playerTurn

        
        let image = UIImage(named: "\(self.playerTurn == 1 ? "x" : "o").png")
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 0, width: playView.frame.size.width, height: playView.frame.size.height)
        playView.addSubview(imageView)
        
        let winner: Int = checkWin()

        if(winner != 0){
            self.finalResult = winner
            lastkill.append(winner == 1 ? ["dead": "Player 2", "winner": "Player 1"] : ["dead": "Player 1", "winner": "Player 2"])
            userDefaults.set(lastkill, forKey: "lastkill")
            alertResult("And the winner is ...", "Player \(winner)")
            setPlayerTurnLabel("Player \(winner) wins")
            return
        }

        if(cases.contains(0) == false){
            lastkill.append(["draw": "Player 1 and 2"])
            userDefaults.set(lastkill, forKey: "lastkill")
            setPlayerTurnLabel("Draw")
            alertResult("And the winner is ...", "Nobody")
            self.finalResult = 3
            return
        }

        if(self.playerTurn == 1){
            self.playerTurn = 2
        }else{
            self.playerTurn = 1
        }
    
        
        setPlayerTurnLabel("It's Player \(self.playerTurn) turn")
    }
    
    public func checkWin() -> Int {
        for combo in winningCombos {
            let comboWithCasesValues = combo.map { cases[$0] }
            if(comboWithCasesValues[0] != 0){
                if Set(comboWithCasesValues).count == 1 {
                    return comboWithCasesValues[0]
                }
            }
        }
        return 0
    }
    public func getPlayerTurn() -> Int{
        return self.playerTurn
    }
    
    public func setPlayerTurnLabel(_ string: String){
            playerTurnLabel.text = string
    }
    
    public func alertResult(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

class PlayView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        addTicTacToeBorders()
    }
    
    
    func addTicTacToeBorders(){
        let color = UIColor.init(red: 236, green: 240, blue: 241, alpha: 1)
        
        switch self.tag {
        case 1:
            self.layer.addBorders(edges: [.right, .left], color: color, thickness: 2)
            break
        case 3:
            self.layer.addBorders(edges: [.top, .bottom], color: color, thickness: 2)
            break
        case 4:
            self.layer.addBorders(edges: [.all], color: color, thickness: 2)
            break
        case 5:
            self.layer.addBorders(edges: [.top, .bottom], color: color, thickness: 2)
            break
        case 7:
            self.layer.addBorders(edges: [.right, .left], color: color, thickness: 2)
            break
        default:
            break
        }
    
    }
}


extension CALayer {
    func addBorders(edges: [UIRectEdge], color: UIColor, thickness: CGFloat) {
        
        
        if edges.contains(.top) || edges.contains(.all){
            let border = CALayer()
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)

            border.backgroundColor = color.cgColor
            
            self.addSublayer(border)
        }
        
        if edges.contains(.right) || edges.contains(.all){
            let border = CALayer()
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            
            border.backgroundColor = color.cgColor
            
            self.addSublayer(border)
        }
        if edges.contains(.bottom) || edges.contains(.all){
            let border = CALayer()
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            
            border.backgroundColor = color.cgColor
            
            self.addSublayer(border)
        }
        if edges.contains(.left) || edges.contains(.all){
            let border = CALayer()
           border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            
            border.backgroundColor = color.cgColor
            
            self.addSublayer(border)
        }
        
    }
}


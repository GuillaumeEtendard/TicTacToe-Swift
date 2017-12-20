//
//  OnlineViewController.swift
//  TicTacToe
//
//  Created by Guillaume Etendard on 27/11/2017.
//  Copyright © 2017 Guillaume Etendard. All rights reserved.
//

import UIKit

class OnlineViewController: UIViewController{
    var data : [Any]?
    
    @IBOutlet weak var playerTurn: UILabel!
    
    var players = [String: Any]()
    
    var movement: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle first data
        if let item = self.data?.first as? [String: Any],
            let currentTurn = item["currentTurn"] as? String{
            if let playerO = item["playerO"] as? String,
                let playerX = item["playerX"] as? String{
                self.players = ["o" : playerO, "x" : playerX]
            }
            self.playerTurn.text = "It's \(self.players[currentTurn] as! String) turn"
        }
        TTTSocket.sharedInstance.socket.on("movement") {data, ack in
          
            
            if let item = data.first as? [String: Any]{
                if let playerPlay = item["player_play"] as? String,
                    let playerPlayed = item["player_played"] as? String{
                    self.movement =  self.movement + 1

                    
                    if(item["win"] as? Bool != false){
                            self.playerTurn.text = "\(self.players[playerPlayed] as! String) wins"
                            self.alertResult("And the winner is ...", self.players[playerPlayed] as! String)
                    }else{
                        self.playerTurn.text = "It's \(self.players[playerPlay] as! String) turn"
                    }
                
                    if(self.movement == 9){
                        self.playerTurn.text = "Draw"
                        self.alertResult("And the winner is ...", "Nobody")
                    }
                    
                    
                    let UIView = self.view.viewWithTag((item["index"] as? Int)!)!
                    
                        let image = UIImage(named: "\(playerPlayed).png")
                        let imageView = UIImageView(image: image)
                        imageView.frame = CGRect(x: 0, y: 0, width: UIView.frame.size.width, height: UIView.frame.size.height)
                        UIView.addSubview(imageView)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            if hitView is PlayView{
                if let playView = hitView as? PlayView {
                    TTTSocket.sharedInstance.socket.emit("movement", playView.tag)
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    public func alertResult(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Share result", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in
            
            let shareText = "\(message) won a very good game on Tic Tac Toe"
            let textToShare = [ shareText ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            }))
        DispatchQueue.main.async{
            self.present(alert, animated: true, completion: nil)
        }
    }
}

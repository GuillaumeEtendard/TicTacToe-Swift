//
//  OnlineViewController.swift
//  TicTacToe
//
//  Created by Guillaume Etendard on 27/11/2017.
//  Copyright © 2017 Guillaume Etendard. All rights reserved.
//

import UIKit


class PlayOnlineViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func playOnlineButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Choose an username", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let spinnerView = UIViewController.displaySpinner(onView: self.view)
            
            let username = alertController.textFields![0] as UITextField
            
            TTTSocket.sharedInstance.join_queue(username: username.text!)
            
            // Ecouter join_game, une fois que join game renvoie une donnée, faire perform segue
            TTTSocket.sharedInstance.socket.on("join_game") {data, ack in
                self.performSegue(withIdentifier: "ShowOnlineModal", sender: data)
                UIViewController.removeSpinner(spinner: spinnerView)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Username"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowOnlineModal"{
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! OnlineModalViewController
            targetController.data = sender as? [Any]
        }
    }
}

class OnlineModalViewController: UIViewController{
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
            
            let shareText = "\(message) wins a very good game on Tic Tac Toe"
            let textToShare = [ shareText ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async{
            self.present(alert, animated: true, completion: nil)
        }
    }
}

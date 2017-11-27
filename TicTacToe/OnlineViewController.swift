//
//  OnlineViewController.swift
//  TicTacToe
//
//  Created by Guillaume Etendard on 27/11/2017.
//  Copyright © 2017 Guillaume Etendard. All rights reserved.
//

import UIKit

class OnlineViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

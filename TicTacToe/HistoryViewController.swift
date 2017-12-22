//
//  HistoryViewController.swift
//  TicTacToe
//
//  Created by Guillaume Etendard on 22/12/2017.
//  Copyright © 2017 Guillaume Etendard. All rights reserved.
//

import UIKit


class HistoryViewController : UIViewController {
    @IBOutlet weak var textView: UITextView!
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
}

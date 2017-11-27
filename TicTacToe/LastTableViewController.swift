//
//  LastTableViewController.swift
//  TicTacToe
//
//  Created by Guillaume Etendard on 06/11/2017.
//  Copyright © 2017 Guillaume Etendard. All rights reserved.
//

import UIKit

class LastTableViewController: UITableViewController{
    
    var data = Array<[String: String]>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = UserDefaults.standard
        
        if let lastkill = userDefaults.array(forKey: "lastkill") as? Array<[String: String]>{
            self.data = lastkill
            self.tableView.reloadData()
        }else{
            self.data = Array<[String: String]>()
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LastCell", for: indexPath)
        
        let stat = data[indexPath.row]
        if let winner = stat["winner"], let dead = stat["dead"] {
            cell.textLabel?.text = "\(winner) killed \(dead)"
        }
        if let draw = stat["draw"] {
            cell.textLabel?.text = "Draw for \(draw)"
        }
        return cell
    }
    
}

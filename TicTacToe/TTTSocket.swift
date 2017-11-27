//
//  TTTSocket.swift
//  TicTacToe
//
//  Created by Guillaume Etendard on 13/11/2017.
//  Copyright © 2017 Guillaume Etendard. All rights reserved.
//

import Foundation
import SocketIO

class TTTSocket{
    public static let sharedInstance = TTTSocket()
    
    let socket = SocketIOClient(socketURL: URL(string: "http://51.254.112.146:5666")!)

    
    init(){
        
    }
    
    func establishConnection(){
        self.socket.connect()
    }
    
    func closeConnection(){
        self.socket.disconnect()
    }
    
    func join_queue(){
        self.socket.emit("join_queue", "dude")
    }
    
    func join_game(){
        socket.on("join_game") {data, ack in
            print("data \(data)")
        }
    }
}

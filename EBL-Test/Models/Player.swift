//
//  Player.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/14/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation
import Firebase

class Player {
    let dbManager = DatabaseManager()
    
    var firstName : String
    var lastName : String
    var nickname : String
    var height : Int
    var weight : Int
    var jerseyNo : String
    var hometown : String
    var nationality : String
    var primaryPosition : Int
    var secondaryPosition : Int
    var dateOfBirth : Date
    
    var age : Int
    var positionName : String
    
    let positions : [String] = ["PG","SG","SF","PF","C"]
    
    var playerTotalStats : PlayerTotalStats
    
    
    init(playerDocument : DocumentSnapshot, playerStatsDocument : DocumentSnapshot) {
        
        firstName = playerDocument.get("firstName") as! String
        lastName = playerDocument.get("lastName") as! String
        nickname = playerDocument.get("nickname") as! String
        height = playerDocument.get("height") as! Int
        weight = playerDocument.get("weight") as! Int
        jerseyNo = playerDocument.get("jerseyNo") as! String
        hometown = playerDocument.get("hometown") as! String
        nationality = playerDocument.get("nationality") as! String
        primaryPosition = playerDocument.get("primaryPosition") as! Int
        secondaryPosition = playerDocument.get("secondaryPosition") as! Int
        dateOfBirth = (playerDocument.get("dateOfBirth") as! Timestamp).dateValue()
        
        age = (Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date())).year!
        
        positionName = positions[primaryPosition-1] + (secondaryPosition > 0 ? "/\(positions[secondaryPosition-1])" : "")
        
        playerTotalStats = PlayerTotalStats(statsDocument: playerStatsDocument)
        
    }
}

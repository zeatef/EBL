//
//  TeamGameStats.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 4/14/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation
import Firebase

class TeamGameStats {
    
    let dbManager = DatabaseManager()
    
    var date : Date
    var home : Bool
    var opponentName : String
    var opponentAbb : String
    
    var total3FGA : Int
    var total3FGM : Int
    var avg3FGP : Double
    
    var total2FGA : Int
    var total2FGM : Int
    var avg2FGP: Double
    
    var totalFGA : Int
    var totalFGM : Int
    var avgFGP : Double
    
    var totalFTA : Int
    var totalFTM : Int
    var avgFTP : Double
    
    var PTS : Int
    var opponentPTS : Int
    var ORB : Int
    var DRB : Int
    var REB : Int
    var AST : Int
    var BLK : Int
    var TO : Int
    var STL : Int
    var FOL : Int
    
    
    init(statsDocument : DocumentSnapshot) {
        
        date = (statsDocument.get("date") as! Timestamp).dateValue()
        home = statsDocument.get("home") as! Bool
        opponentName = statsDocument.get("opponentName") as! String
        opponentAbb = statsDocument.get("opponentAbb") as! String
        
        total3FGA = statsDocument.get("3FGA") as! Int
        total3FGM = statsDocument.get("3FGM") as! Int
        avg3FGP = Double(round(100*(statsDocument.get("3FG%") as! Double))/100)
        
        total2FGA = statsDocument.get("2FGA") as! Int
        total2FGM = statsDocument.get("2FGM") as! Int
        avg2FGP = Double(round(100*(statsDocument.get("2FG%") as! Double))/100)
        
        totalFGA = statsDocument.get("FGA") as! Int
        totalFGM = statsDocument.get("FGM") as! Int
        avgFGP = Double(round(100*(statsDocument.get("FG%") as! Double))/100)
        
        totalFTA = statsDocument.get("FTA") as! Int
        totalFTM = statsDocument.get("FTM") as! Int
        avgFTP = Double(round(100*(statsDocument.get("FT%") as! Double))/100)
        
        PTS = statsDocument.get("PTS") as! Int
        opponentPTS = statsDocument.get("opponentPTS") as! Int
        
        ORB = statsDocument.get("ORB") as! Int
        
        DRB = statsDocument.get("DRB") as! Int
        
        REB = statsDocument.get("TREB") as! Int
        
        AST = statsDocument.get("AST") as! Int
        
        BLK = statsDocument.get("BLK") as! Int
        
        TO = statsDocument.get("TO") as! Int
        
        STL = statsDocument.get("STL") as! Int
        
        FOL = statsDocument.get("FOL") as! Int
        
    }
}


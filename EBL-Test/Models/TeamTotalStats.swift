//
//  TeamTotalStats.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/17/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation
import Firebase

class TeamTotalStats {
    
    let dbManager = DatabaseManager()
    
    var gamesPlayed : Int
    
    var total3FGA : Int
    var total3FGM : Int
    var avg3FGA : Double
    var avg3FGM : Double
    var avg3FGP : Double
    
    var total2FGA : Int
    var total2FGM : Int
    var avg2FGA : Double
    var avg2FGM : Double
    var avg2FGP: Double
    
    var totalFGA : Int
    var totalFGM : Int
    var avgFGA : Double
    var avgFGM : Double
    var avgFGP : Double
    
    var totalFTA : Int
    var totalFTM : Int
    var avgFTA : Double
    var avgFTM : Double
    var avgFTP : Double
    
    var totalPTS : Int
    var avgPTS : Double

    var totalORB : Int
    var avgORB : Double

    var totalDRB : Int
    var avgDRB : Double

    var totalREB : Int
    var avgTREB : Double

    var totalAST : Int
    var avgAST : Double

    var totalBLK : Int
    var avgBLK : Double

    var totalTO : Int
    var avgTO : Double

    var totalSTL : Int
    var avgSTL : Double

    var totalFOL : Int
    var avgFOL : Double

    
    init(statsDocument : DocumentSnapshot) {
        
        gamesPlayed = statsDocument.get("gamesPlayed") as! Int
        
        total3FGA = statsDocument.get("3FGA") as! Int
        total3FGM = statsDocument.get("3FGM") as! Int
        avg3FGA = gamesPlayed == 0 ? 0.0 : Double(total3FGA)/Double(gamesPlayed)
        avg3FGM = gamesPlayed == 0 ? 0.0 : Double(total3FGM)/Double(gamesPlayed)
        avg3FGP = Double(round(100*(statsDocument.get("3FG%") as! Double))/100)
        
        total2FGA = statsDocument.get("2FGA") as! Int
        total2FGM = statsDocument.get("2FGM") as! Int
        avg2FGA = gamesPlayed == 0 ? 0.0 : Double(total2FGA)/Double(gamesPlayed)
        avg2FGM = gamesPlayed == 0 ? 0.0 : Double(total2FGM)/Double(gamesPlayed)
        avg2FGP = Double(round(100*(statsDocument.get("2FG%") as! Double))/100)

        totalFGA = statsDocument.get("FGA") as! Int
        totalFGM = statsDocument.get("FGM") as! Int
        avgFGA = gamesPlayed == 0 ? 0.0 : Double(totalFGA)/Double(gamesPlayed)
        avgFGM = gamesPlayed == 0 ? 0.0 : Double(totalFGM)/Double(gamesPlayed)
        avgFGP = Double(round(100*(statsDocument.get("FG%") as! Double))/100)
        
        totalFTA = statsDocument.get("FTA") as! Int
        totalFTM = statsDocument.get("FTM") as! Int
        avgFTA = gamesPlayed == 0 ? 0.0 : Double(totalFTA)/Double(gamesPlayed)
        avgFTM = gamesPlayed == 0 ? 0.0 : Double(totalFTM)/Double(gamesPlayed)
        avgFTP = Double(round(100*(statsDocument.get("FT%") as! Double))/100)
        
        totalPTS = statsDocument.get("PTS") as! Int
        avgPTS = gamesPlayed == 0 ? 0.0 : Double(totalPTS)/Double(gamesPlayed)
        
        totalORB = statsDocument.get("ORB") as! Int
        avgORB = gamesPlayed == 0 ? 0.0 : Double(totalORB)/Double(gamesPlayed)
        
        totalDRB = statsDocument.get("DRB") as! Int
        avgDRB = gamesPlayed == 0 ? 0.0 : Double(totalDRB)/Double(gamesPlayed)
        
        totalREB = statsDocument.get("TREB") as! Int
        avgTREB = gamesPlayed == 0 ? 0.0 : Double(totalREB)/Double(gamesPlayed)
        
        totalAST = statsDocument.get("AST") as! Int
        avgAST = gamesPlayed == 0 ? 0.0 : Double(totalAST)/Double(gamesPlayed)
        
        totalBLK = statsDocument.get("BLK") as! Int
        avgBLK = gamesPlayed == 0 ? 0.0 : Double(totalBLK)/Double(gamesPlayed)
        
        totalTO = statsDocument.get("TO") as! Int
        avgTO = gamesPlayed == 0 ? 0.0 : Double(totalTO)/Double(gamesPlayed)
        
        totalSTL = statsDocument.get("STL") as! Int
        avgSTL = gamesPlayed == 0 ? 0.0 : Double(totalSTL)/Double(gamesPlayed)
        
        totalFOL = statsDocument.get("FOL") as! Int
        avgFOL = gamesPlayed == 0 ? 0.0 : Double(totalFOL)/Double(gamesPlayed)
        
    }
}

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
    
    struct KnownAs {
        let first : String
        let last : String
    }
    
    let dbManager = DatabaseManager()
    
    var firstName : String
    var lastName : String
    var knownAs : KnownAs
    var height : Int
    var weight : Int
    var jerseyNo : String
    var hometown : String
    var nationality : String
    var primaryPosition : Int
    var secondaryPosition : Int
    var dateOfBirth : Date
    var currentTeam : String
    
    var age : Int
    var positionName : String
    
    let positions : [String] = ["PG","SG","SF","PF","C"]
    
    var statistics : AverageStatistics?
    
    init(playerDocument : DocumentSnapshot) {
        
        firstName = playerDocument.get("name.first") as! String
        lastName = playerDocument.get("name.last") as! String
        knownAs = KnownAs(
            first: (playerDocument.get("name.nickname.first") as? String) == nil ? firstName : ((playerDocument.get("name.nickname.first") as? String)!),
            last: (playerDocument.get("name.nickname.last") as? String) == nil ? lastName : ((playerDocument.get("name.nickname.last") as? String)!)
        )

        height = playerDocument.get("biometrics.height") as! Int
        weight = playerDocument.get("biometrics.weight") as! Int
        jerseyNo = playerDocument.get("jerseyNo") as! String
        hometown = playerDocument.get("hometown") as! String
        nationality = playerDocument.get("nationality") as! String
        
        primaryPosition = playerDocument.get("position.primary") as! Int
        secondaryPosition = playerDocument.get("position.secondary") as? Int == nil ? 0 : playerDocument.get("position.secondary") as! Int
        positionName = positions[primaryPosition-1] + (secondaryPosition > 0 ? "/\(positions[secondaryPosition-1])" : "")

        dateOfBirth = (playerDocument.get("dateOfBirth") as! Timestamp).dateValue()
        age = (Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date())).year!
        
        currentTeam = playerDocument.get("currentTeam") as! String
    }
    
    func setPlayerStatistics(statsDocument : DocumentSnapshot) {
        self.statistics = AverageStatistics(
            gamesPlayed: statsDocument.get("gamesPlayed") as! Int,
            wins: nil,
            losses: nil,
            FG2: PercentageStatistic(
                attempts: statsDocument.get("2FG.attempts") as! Int,
                made: statsDocument.get("2FG.made") as! Int,
                percentage: statsDocument.get("2FG.percentage") as! Double),
            FG3: PercentageStatistic(
                attempts: statsDocument.get("3FG.attempts") as! Int,
                made: statsDocument.get("3FG.made") as! Int,
                percentage: statsDocument.get("3FG.percentage") as! Double),
            FG: PercentageStatistic(
                attempts: statsDocument.get("FG.attempts") as! Int,
                made: statsDocument.get("FG.made") as! Int,
                percentage: statsDocument.get("FG.percentage") as! Double),
            FT: PercentageStatistic(
                attempts: statsDocument.get("FT.attempts") as! Int,
                made: statsDocument.get("FT.made") as! Int,
                percentage: statsDocument.get("FT.percentage") as! Double),
            PTS: TotalandPerGameStatistic(
                total: statsDocument.get("PTS.total") as! Double,
                perGame: round(100*(statsDocument.get("PTS.perGame") as! Double))/100),
            AST: TotalandPerGameStatistic(
                total: statsDocument.get("AST.total") as! Double,
                perGame: round(100*(statsDocument.get("AST.perGame") as! Double))/100),
            DREB: TotalandPerGameStatistic(
                total: statsDocument.get("REB.defensive.total") as! Double,
                perGame: round(100*(statsDocument.get("REB.defensive.perGame") as! Double))/100),
            OREB: TotalandPerGameStatistic(
                total: statsDocument.get("REB.offensive.total") as! Double,
                perGame: round(100*(statsDocument.get("REB.offensive.perGame") as! Double))/100),
            TREB: TotalandPerGameStatistic(
                total: statsDocument.get("REB.total") as! Double,
                perGame: round(100*(statsDocument.get("REB.perGame") as! Double))/100),
            STL: TotalandPerGameStatistic(
                total: statsDocument.get("STL.total") as! Double,
                perGame: round(100*(statsDocument.get("STL.perGame") as! Double))/100),
            TO: TotalandPerGameStatistic(
                total: statsDocument.get("TO.total") as! Double,
                perGame: round(100*(statsDocument.get("TO.perGame") as! Double))/100),
            BLK: TotalandPerGameStatistic(
                total: statsDocument.get("BLK.total") as! Double,
                perGame: round(100*(statsDocument.get("BLK.perGame") as! Double))/100),
            FOL: TotalandPerGameStatistic(
                total: statsDocument.get("FOL.total") as! Double,
                perGame: round(100*(statsDocument.get("FOL.perGame") as! Double))/100),
            EFF: TotalandPerGameStatistic(
                total: statsDocument.get("EFF.total") as! Double,
                perGame: round(100*(statsDocument.get("EFF.perGame") as! Double))/100),
            MINS: TotalandPerGameStatistic(
                total: statsDocument.get("MINS.total") as! Double,
                perGame: round(100*(statsDocument.get("MINS.perGame") as! Double))/100)
        )
    }

}

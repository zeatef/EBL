//
//  Team.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/14/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation
import Firebase

class Team {
    
    var abb : String
    var teamName : String
    var location : String
    var headCoach : String
    var primaryColor : String
    var secondaryColor : String
    
    var statistics : AverageStatistics?
    var gameStatistics : [SingleGameStatistics]?
    
    var allPlayers : [Player]?
    var top3Players : [Player]?
    
    init(teamDocument : DocumentSnapshot) {
        abb = teamDocument.get("abb") as! String
        teamName = teamDocument.get("teamName") as! String
        location = teamDocument.get("location") as! String
        headCoach = (teamDocument.get("headCoach") as! [String]).last!
        primaryColor = teamDocument.get("primaryColor") as! String
        secondaryColor = teamDocument.get("secondaryColor") as! String
    }
    
    func setAverageStatistics(statsDocument : DocumentSnapshot) {
        self.statistics = AverageStatistics(
            gamesPlayed: statsDocument.get("gamesPlayed") as! Int,
            wins: statsDocument.get("wins") as? Int,
            losses: statsDocument.get("losses") as? Int,
            FG2: PercentageStatistic(
                attempts: statsDocument.get("2FG.attempts") as! Int,
                made: statsDocument.get("2FG.made") as! Int,
                percentage: round(1000*(statsDocument.get("2FG.percentage") as! Double))/1000),
            FG3: PercentageStatistic(
                attempts: statsDocument.get("3FG.attempts") as! Int,
                made: statsDocument.get("3FG.made") as! Int,
                percentage: round(1000*(statsDocument.get("3FG.percentage") as! Double))/1000),
            FG: PercentageStatistic(
                attempts: statsDocument.get("FG.attempts") as! Int,
                made: statsDocument.get("FG.made") as! Int,
                percentage: round(1000*(statsDocument.get("FG.percentage") as! Double))/1000),
            FT: PercentageStatistic(
                attempts: statsDocument.get("FT.attempts") as! Int,
                made: statsDocument.get("FT.made") as! Int,
                percentage: round(1000*(statsDocument.get("FT.percentage") as! Double))/1000),
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
            EFF: nil,
            MINS: nil
        )
    }
    
    func setGameStatistics(gamesDocument : [DocumentSnapshot]) {
        self.gameStatistics = []
        for statsDocument in gamesDocument {
            self.gameStatistics?.append(SingleGameStatistics(
                date: (statsDocument.get("date") as! Timestamp).dateValue(),
                opponentAbb: statsDocument.get("opponentAbb") as! String,
                isHome: statsDocument.get("home") as! Bool,
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
                opponentPTS: statsDocument.get("opponentPTS") as! Int,
                PTS: statsDocument.get("PTS") as! Int,
                AST: statsDocument.get("AST") as! Int,
                DREB: statsDocument.get("REB.defensive") as! Int,
                OREB: statsDocument.get("REB.offensive") as! Int,
                TREB: statsDocument.get("REB.total") as! Int,
                STL: statsDocument.get("STL") as! Int,
                TO: statsDocument.get("TO") as! Int,
                BLK: statsDocument.get("BLK") as! Int,
                FOL: statsDocument.get("FOL") as! Int,
                EFF: nil,
                MINS: nil
            ))
        }
        self.gameStatistics!.sort(by: {$0.date < $1.date})
    }
    
    func setTop3Performers() {
        self.allPlayers?.sort(by: {
            if($0.statistics!.EFF!.perGame == $1.statistics!.EFF!.perGame) {
                return $0.knownAs.first < $1.knownAs.first
            } else {
                return $0.statistics!.EFF!.perGame > $1.statistics!.EFF!.perGame
            }
        })
        
        self.top3Players = Array(allPlayers!.prefix(3))
    }
}

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
    let dbManager = DatabaseManager()
    
    var teamRef : String
    var teamName : String
    var abb : String
    var location : String
    var headCoach : String
    var leagueStanding : Int
    var primaryColor : String
    var secondaryColor : String
    var wins : Int
    var losses : Int
    
    var teamTotalStats : TeamTotalStats
    
    init(teamDocument : DocumentSnapshot, teamStatsDocument : DocumentSnapshot) {
        teamRef = "/Teams/\(teamDocument.documentID)"
        teamName = teamDocument.get("teamName") as! String
        abb = teamDocument.get("abb") as! String
        location = teamDocument.get("location") as! String
        headCoach = (teamDocument.get("headCoach") as! [String]).last!
        leagueStanding = teamDocument.get("leagueStanding") as! Int
        primaryColor = teamDocument.get("primaryColor") as! String
        secondaryColor = teamDocument.get("secondaryColor") as! String
        wins = teamDocument.get("wins") as! Int
        losses = teamDocument.get("losses") as! Int
        
        teamTotalStats = TeamTotalStats(statsDocument: teamStatsDocument)
    }
    
}

//
//  TeamDisplayData.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 3/14/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation
import Firebase

class TeamDisplayData {
    
    var teamID : String
    var teamRef : String
    var teamName : String
    var primaryColor : String
    var secondaryColor : String
    var currentStanding : Int?
    var previousStanding: Int?
    var wins : Int?
    var losses : Int?
    var scoreDifference : Int?
    
    init(teamDocument : DocumentSnapshot) {
        teamID = teamDocument.documentID
        teamRef = "/Teams/\(teamDocument.documentID)"
        teamName = teamDocument.get("teamName") as! String
        primaryColor = teamDocument.get("primaryColor") as! String
        secondaryColor = teamDocument.get("secondaryColor") as! String
    }
}


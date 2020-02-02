//
//  Statistics.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 6/16/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation

struct AverageStatistics {
    var gamesPlayed : Int
    var wins : Int?
    var losses : Int?
    
    var FG2 : PercentageStatistic
    var FG3 : PercentageStatistic
    var FG : PercentageStatistic
    var FT : PercentageStatistic
    
    var PTS : TotalandPerGameStatistic
    var AST : TotalandPerGameStatistic
    var DREB : TotalandPerGameStatistic
    var OREB : TotalandPerGameStatistic
    var TREB : TotalandPerGameStatistic
    var STL : TotalandPerGameStatistic
    var TO : TotalandPerGameStatistic
    var BLK : TotalandPerGameStatistic
    var FOL : TotalandPerGameStatistic
    var EFF : TotalandPerGameStatistic?
    var MINS : TotalandPerGameStatistic?
}

struct SingleGameStatistics {
    var date : Date
    var opponentAbb : String
    var isHome : Bool
    
    var FG2 : PercentageStatistic
    var FG3 : PercentageStatistic
    var FG : PercentageStatistic
    var FT : PercentageStatistic
    
    var opponentPTS : Int
    var PTS : Int
    var AST : Int
    var DREB : Int
    var OREB : Int
    var TREB : Int
    var STL : Int
    var TO : Int
    var BLK : Int
    var FOL : Int
    var EFF : Int?
    var MINS : String?
}

struct PercentageStatistic {
    var attempts : Int
    var made : Int
    var percentage : Double
}

struct TotalandPerGameStatistic {
    var total : Double
    var perGame: Double
}

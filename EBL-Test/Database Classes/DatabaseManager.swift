//
//  DatabaseManager.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/17/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation
import Firebase

class DatabaseManager {
    static let sharedInstance = DatabaseManager()

    let database : Firestore
    let storage : Storage
    
    let currentSeason = "18-19"
    var teamsDisplayData : [String:TeamDisplayData] = [:]
    
    init() {
        //Initialize Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        database = Firestore.firestore()
        storage = Storage.storage()
    }
    
    //TODO: - Delete This Function
    func setupApplicationDatabase(completion: @escaping  (Error?, String?) -> Void){
        let start = DispatchTime.now()
        createTeamImagesPlist { (error) in
            if let error = error {
                completion(error, "Code 1")
            } else {
                print("Done with step 1")
                self.downloadTeamImageURLsToLocal { (error) in
                    if let error = error {
                        completion(error, "Code 2")
                    } else {
                        print("Done with step 2")
                        let end = DispatchTime.now()
                        let difference = end.uptimeNanoseconds - start.uptimeNanoseconds
                        print("Completed in \(Double(difference) / 1_000_000_000) seconds.")
                        self.getAllTeamsDisplayData(completion: { (error, teams) in
                            if let error = error {
                                completion(error, "Code 3")
                            } else {
                                for team in teams! {
                                    DatabaseManager.sharedInstance.teamsDisplayData[team.teamID] = team
                                }
                                print("Done with step 3")
                                let end = DispatchTime.now()
                                let difference = end.uptimeNanoseconds - start.uptimeNanoseconds
                                print("Completed in \(Double(difference) / 1_000_000_000) seconds.")
                                completion(nil, nil)
                            }
                        })
                    }
                }
            }
        }
    }
    
    //MARK:- Application Start Functions
    func setupApplication(completion: @escaping (Error?) -> Void) {
        fetchUpToDateData { (error) in
            if let error = error {
                completion(error)
            } else {
                print("1/3: Cache Data Up To Date!")
                self.fetchTeamImagesURLs(completion: { (error) in
                    if let error = error {
                        completion(error)
                    } else {
                        print("2/3: Team Images URLs Updated!")
                        completion(nil)
                    }
                })
            }
        }
    }

    //MARK: Up To Date Team Images
    func fetchTeamImagesURLs(completion: @escaping (Error?) -> Void) {
        createTeamImagesPlist { (error) in
            if let error = error {
                completion(error)
            } else {
                self.downloadTeamImageURLsToLocal(completion: { (error) in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                })
            }
        }
    }
    
    func createTeamImagesPlist(completion: @escaping (Error?) -> Void) {
        let teamImagesPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Images")

        do {
            try FileManager.default.createDirectory(at: teamImagesPath!, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Error Creating Directory, \(error)")
            completion(error)
        }
        
        let path = teamImagesPath!.appendingPathComponent("TeamImages.plist")
        
        if(!FileManager.default.fileExists(atPath: path.path)){
            let data : [String: URL] = [:]
            let dictionary = NSMutableDictionary(dictionary: data)
            dictionary.write(toFile: path.path, atomically: true)
        }
        completion(nil)
    }

    func downloadTeamImageURLsToLocal(completion: @escaping (Error?) -> Void) {
        let teamImagesPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Images")
        
        let path = teamImagesPath!.appendingPathComponent("TeamImages.plist")
        let dictionary = NSMutableDictionary(contentsOfFile: path.path)!
        
        let teamsRef = database.collection("/Teams")
        teamsRef.getDocuments(source: .cache) { (cacheSnapshot, error) in
            if let error = error {
                print("Error getting teams refrences at downloadTeamImageURLsToLocal")
                completion(error)
            } else {
                var count = 0
                for document in cacheSnapshot!.documents {
                    if dictionary[document.documentID] == nil {
                        let imageRef = self.storage.reference().child("TeamImages/\(document.documentID).png")
                        imageRef.downloadURL { url, error in
                            if let error = error {
                                count += 1
                                print(error)
                                if(count == cacheSnapshot!.count) {
                                    dictionary.write(toFile: path.path, atomically: true)
                                    completion(nil)
                                }
                            } else {
                                dictionary.setValue(url!.absoluteString, forKey: document.documentID)
                                count += 1
                                if(count == cacheSnapshot!.count) {
                                    dictionary.write(toFile: path.path, atomically: true)
                                    completion(nil)
                                }
                            }
                        }
                    } else {
                        count += 1
                        if(count == cacheSnapshot!.count) {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }

    func emptyTeamImagesDirectory(){
        let teamImagesPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Images")
        
        do {
            try FileManager.default.removeItem(at: teamImagesPath!)
        }
        catch let error {
            print("Zodiac \(error)")
        }
    }
    
    //MARK: Up To Date Cache
    
    func fetchUpToDateData(completion: @escaping (Error?) -> Void) {
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        if let cacheResult = UserDefaults.standard.object(forKey: "UpdateStatus") as? [String:Date] {
            var updatedCache = cacheResult
            getLastUpdateFromServer { (serverResult, error) in
                if let error = error {
                    print("Error: Could Not Get Last Update From Server")
                    completion(error)
                } else {
                    var count = 0
                    for serverValue in serverResult! {
                        if let cacheValue = cacheResult[serverValue.key] {
                            if(serverValue.value > cacheValue) {
                                print("\(serverValue.key): Not Up To Date")
                                self.syncServerWithCache(forCollection: serverValue.key, completion: { (error) in
                                    if let error = error {
                                        print("Error: \(serverValue.key) NOT UPDATED! \n\(error)")
                                        if(self.fetchUpToDateHelper(count: count, total: serverResult!.count, updatedCache: updatedCache)) {
                                            completion(nil)
                                        } else {
                                            count += 1
                                        }
                                    } else {
                                        updatedCache[serverValue.key] = Date()
                                        if(self.fetchUpToDateHelper(count: count, total: serverResult!.count, updatedCache: updatedCache)) {
                                            completion(nil)
                                        } else {
                                            count += 1
                                        }
                                    }
                                })
                            }
                            else {
                                print("\(serverValue.key): Up To Date")
                                if(self.fetchUpToDateHelper(count: count, total: serverResult!.count, updatedCache: updatedCache)) {
                                    completion(nil)
                                } else {
                                    count += 1
                                }
                            }
                        }
                        else {
                            print("\(serverValue.key): Not Up To Date (Not Synced Before)")
                            self.syncServerWithCache(forCollection: serverValue.key, completion: { (error) in
                                if let error = error {
                                    print("Error: \(serverValue.key) NOT SYNCED! \n\(error)")
                                    if(self.fetchUpToDateHelper(count: count, total: serverResult!.count, updatedCache: updatedCache)) {
                                        completion(nil)
                                    } else {
                                        count += 1
                                    }
                                } else {
                                    updatedCache[serverValue.key] = Date()
                                    if(self.fetchUpToDateHelper(count: count, total: serverResult!.count, updatedCache: updatedCache)) {
                                        completion(nil)
                                    } else {
                                        count += 1
                                    }
                                }
                            })
                        }
                    }
                }
            }
        } else {
            print("Cache Not Synced Before")
            var updatedCache : [String:Date] = [:]
            var count = 0
            getLastUpdateFromServer { (serverResult, error) in
                if let error = error {
                    print("Error: Could Not Get Last Update From Server")
                    completion(error)
                } else {
                    for serverValue in serverResult! {
                        print("\(serverValue.key): Syncing First Time")
                        self.syncServerWithCache(forCollection: serverValue.key, completion: { (error) in
                            if let error = error {
                                print("Error: \(serverValue.key) NOT UPDATED! \n\(error)")
                                if(self.fetchUpToDateHelper(count: count, total: serverResult!.count, updatedCache: updatedCache)) {
                                    completion(nil)
                                } else {
                                    count += 1
                                }
                            } else {
                                updatedCache[serverValue.key] = Date()
                                if(self.fetchUpToDateHelper(count: count, total: serverResult!.count, updatedCache: updatedCache)) {
                                    completion(nil)
                                } else {
                                    count += 1
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func fetchUpToDateHelper(count: Int, total: Int, updatedCache : [String:Date]) -> Bool {
        if(count+1 == total) {
            UserDefaults.standard.set(updatedCache, forKey: "UpdateStatus")
            return true
        } else {
            return false
        }
    }
    
    func syncServerWithCache(forCollection key: String, completion: @escaping (Error?) -> Void) {
        if(key == "Standings") {
            self.fetchCurrentAndPreviousStandings(completion: { (error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            })
        } else {
            self.database.collectionGroup(key).getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    func fetchCurrentAndPreviousStandings(completion: @escaping (Error?) -> Void) {
        let currentQuery = database.collection("Standings")
            .whereField("season", isEqualTo: currentSeason)
            .whereField("isCurrentStage", isEqualTo: true)
            .limit(to: 1)
        
        currentQuery.getDocuments{ (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                let stage = snapshot!.documents[0]
                if(stage.get("isGroup") as! Bool) {
                    stage.reference.collection("TeamsTable").getDocuments(completion: { (teams, error) in
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    })
                }
            }
        }
        let previousQuery = database.collection("Standings")
            .whereField("season", isEqualTo: currentSeason)
            .whereField("isPreviousStage", isEqualTo: true)
            .limit(to: 1)
        
        
        previousQuery.getDocuments{ (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                if(snapshot!.count > 0) {
                    let stage = snapshot!.documents[0]
                    if(stage.get("isGroup") as! Bool) {
                        stage.reference.collection("TeamsTable").getDocuments(completion: { (teams, error) in
                            if let error = error {
                                completion(error)
                            } else {
                                completion(nil)
                            }
                        })
                    }
                }
            }
        }
    }
    
    func getLastUpdateFromServer(completion: @escaping ([String:Date]?, Error?) -> Void) {
        var result : [String:Date] = [:]
        var count = 0
        database.collection("UpdateStatus").getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                for document in snapshot!.documents {
                    result[document.documentID] = (document.get("lastUpdated") as! Timestamp).dateValue()
                    count += 1
                    
                    if(count == snapshot!.count) {
                        completion(result, nil)
                    }
                }
            }
        }
    }
    
    //MARK:- Teams Functions
    func getAllTeams(source: FirestoreSource, completion: @escaping ([Team]?, Error?) -> Void) {
        let query = database.collection("Teams").order(by: "teamName")
        query.getDocuments(source: source) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var result : [Team] = []
                for team in snapshot!.documents {
                    result.append(Team(teamDocument: team))
                }
                completion(result, nil)
            }
        }
    }
    
    func getTeam(teamID: String, source: FirestoreSource, completion: @escaping (Team?, Error?) -> Void) {
        database.collection("Teams").document(teamID).getDocument(source: source) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let result = Team(teamDocument: snapshot!)
                self.database.collection("Teams/\(teamID)/TeamStats").document(self.currentSeason).getDocument(source: source, completion: { (stats, error) in
                    if let error = error {
                        completion(nil, error)
                    } else {
                        result.setAverageStatistics(statsDocument: stats!)
                        completion(result, nil)
                    }
                })
            }
        }
    }

    func getTeamStats(forTeam team: Team, source: FirestoreSource, completion: @escaping (Error?) -> Void) {
        database.collection("Teams/\(team.abb)/TeamStats").document(currentSeason).getDocument(source: source) { (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                team.setAverageStatistics(statsDocument: snapshot!)
                completion(nil)
            }
        }
    }
    
    func getTeamGameStats(forTeam team: Team, completion: @escaping (Error?) -> Void) {
        database.collection("Teams/\(team.abb)/TeamGameStats").getDocuments { (teamGamesSnapshot, error) in
            if let error = error {
                completion(error)
            } else {
                team.setGameStatistics(gamesDocument: teamGamesSnapshot!.documents)
                completion(nil)
            }
        }
    }
    
    func getLeagueAverages(completion: @escaping (AverageStatistics?, Error?) -> Void) {
        var result = AverageStatistics(
            gamesPlayed: 0, wins: 0, losses: 0,
            FG2: PercentageStatistic(attempts: 0, made: 0, percentage: 0),
            FG3: PercentageStatistic(attempts: 0, made: 0, percentage: 0),
            FG: PercentageStatistic(attempts: 0, made: 0, percentage: 0),
            FT: PercentageStatistic(attempts: 0, made: 0, percentage: 0),
            PTS: TotalandPerGameStatistic(total: 0, perGame: 0),
            AST: TotalandPerGameStatistic(total: 0, perGame: 0),
            DREB: TotalandPerGameStatistic(total: 0, perGame: 0),
            OREB: TotalandPerGameStatistic(total: 0, perGame: 0),
            TREB: TotalandPerGameStatistic(total: 0, perGame: 0),
            STL: TotalandPerGameStatistic(total: 0, perGame: 0),
            TO: TotalandPerGameStatistic(total: 0, perGame: 0),
            BLK: TotalandPerGameStatistic(total: 0, perGame: 0),
            FOL: TotalandPerGameStatistic(total: 0, perGame: 0),
            EFF: nil, MINS: nil)
        
        database.collectionGroup("TeamStats").whereField("season", isEqualTo: currentSeason).getDocuments(source: .cache) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                for document in snapshot!.documents {
                    result.gamesPlayed += document.get("gamesPlayed") as! Int
                    result.FG2.attempts = result.FG2.attempts + (document.get("2FG.attempts") as! Int)
                    result.FG2.made = result.FG2.made + (document.get("2FG.made") as! Int)
                    
                    result.FG3.attempts = result.FG3.attempts + (document.get("3FG.attempts") as! Int)
                    result.FG3.made = result.FG3.made + (document.get("3FG.made") as! Int)

                    result.FT.attempts = result.FT.attempts + (document.get("FT.attempts") as! Int)
                    result.FT.made = result.FT.made + (document.get("FT.made") as! Int)
                    
                    result.PTS.total = result.PTS.total + (document.get("PTS.total") as! Double)
                    result.AST.total = result.AST.total + (document.get("AST.total") as! Double)
                    result.TREB.total = result.TREB.total + (document.get("REB.total") as! Double)
                    result.STL.total = result.STL.total + (document.get("STL.total") as! Double)
                    result.TO.total = result.TO.total + (document.get("TO.total") as! Double)
                }
                
                result.FG2.percentage = Double(result.FG2.made) / Double(result.FG2.attempts)
                result.FG3.percentage = Double(result.FG3.made) / Double(result.FG3.attempts)
                
                result.FG.made = result.FG2.made + result.FG3.made
                result.FG.attempts = result.FG2.attempts + result.FG3.attempts
                result.FG.percentage = Double(result.FG.made) / Double(result.FG.attempts)
                
                result.FT.percentage = Double(result.FT.made) / Double(result.FT.attempts)
                
                result.PTS.perGame = result.PTS.total / Double(result.gamesPlayed)
                result.AST.perGame = result.AST.total / Double(result.gamesPlayed)
                result.TREB.perGame = result.TREB.total / Double(result.gamesPlayed)
                result.STL.perGame = result.STL.total / Double(result.gamesPlayed)
                result.TO.perGame = result.TO.total / Double(result.gamesPlayed)
                
                completion(result, nil)
            }
        }
    }
    
    func getTeamLeagueLeaders(source: FirestoreSource, statistic: String, completion: @escaping (Error?,[Team]?) -> Void) {
        let query = database.collectionGroup("TeamStats")
            .order(by: statistic, descending: true)
            .limit(to: 10)
        
        var count = 0
        query.getDocuments(source: source) { (stats, error) in
            if let error = error {
                completion(error, nil)
            } else {
                var result : [Team] = []
                for stat in stats!.documents {
                    stat.reference.parent.parent!.getDocument(source: source, completion: { (teamDocument, error) in
                        if let error = error {
                            completion(error, nil)
                        } else {
                            let team = Team(teamDocument: teamDocument!)
                            team.setAverageStatistics(statsDocument: stat)
                            result.append(team)
                            count += 1
                            if(count == 10) {
                                completion(nil, result)
                            }
                        }
                    })
                }
            }
        }
    }
    
    //MARK:- Players Functions
    func getAllPlayersInfo(source: FirestoreSource, completion: @escaping ([Player]?, Error?) -> Void) {
        var count = 0
        let query = database.collection("Players")
            .order(by: "name.first")
            .order(by: "name.last")
        
        query.getDocuments(source: source) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var result : [Player] = []
                for document in snapshot!.documents {
                    result.append(Player(playerDocument: document))
                    count += 1
                    if(count == snapshot!.count) {
                        completion(result, nil)
                    }
                }
            }
        }
    }

    
    func getAllPlayers(forTeam teamID: String, source: FirestoreSource, completion: @escaping ([Player]?, Error?) -> Void) {
        
        let query = database.collection("Players")
            .whereField("currentTeam", isEqualTo: teamID)
        
        var count = 0
        query.getDocuments(source: source) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var result : [Player] = []
                for document in snapshot!.documents {
                    let player = Player(playerDocument: document)
                    self.database.collection("Players/\(document.documentID)/PlayerStats").document(self.currentSeason).getDocument(source: source, completion: { (stats, error) in
                        if let error = error {
                            completion(nil, error)
                        } else {
                            player.setPlayerStatistics(statsDocument: stats!)
                            result.append(player)
                            count += 1
                            if(count == snapshot!.count) {
                                completion(result, nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func getPlayerLeagueLeaders(source: FirestoreSource, statistic: String, completion: @escaping (Error?,[Player]?) -> Void) {
        
        let query = database.collectionGroup("PlayerStats")
            .order(by: statistic, descending: true)
        
        var count = 0
        query.getDocuments(source: source) { (stats, error) in
            if let error = error {
                completion(error, nil)
            } else {
                var result : [Player] = []
                for stat in stats!.documents {
                    stat.reference.parent.parent!.getDocument(source: source, completion: { (playerDocument, error) in
                        if let error = error {
                            completion(error, nil)
                        } else {
                            switch statistic {
                            case "FG.percentage":
                                let fgm = stat.get("FG.made") as! Int
                                let games = stat.get("teamGamesPlayed") as! Int
                                let minimum = self.getStatisticalMinimumFGMade(games: games)
                                if(fgm >= minimum) {
                                    let player = Player(playerDocument: playerDocument!)
                                    player.setPlayerStatistics(statsDocument: stat)
                                    result.append(player)
                                    count += 1
                                    if(count == 10) {
                                        completion(nil, result)
                                    }
                                }
                            case "FT.percentage":
                                let ftm = stat.get("FT.made") as! Int
                                let games = stat.get("teamGamesPlayed") as! Int
                                let minimum = self.getStatisticalMinimumFTMade(games: games)
                                if(ftm >= minimum) {
                                    let player = Player(playerDocument: playerDocument!)
                                    player.setPlayerStatistics(statsDocument: stat)
                                    result.append(player)
                                    count += 1
                                    if(count == 10) {
                                        completion(nil, result)
                                    }
                                }
                            case "3FG.percentage":
                                let fgm = stat.get("3FG.made") as! Int
                                let games = stat.get("teamGamesPlayed") as! Int
                                if(fgm >= games) {
                                    let player = Player(playerDocument: playerDocument!)
                                    player.setPlayerStatistics(statsDocument: stat)
                                    result.append(player)
                                    count += 1
                                    if(count == 10) {
                                        completion(nil, result)
                                    }
                                }
                            default:
                                let playerGames = stat.get("gamesPlayed") as! Int
                                let teamGames = stat.get("teamGamesPlayed") as! Int
                                let minimumGames = self.getStatisticalMinimumGames(games: teamGames)
                                
                                if(playerGames >= minimumGames && minimumGames != 0) {
                                    let player = Player(playerDocument: playerDocument!)
                                    player.setPlayerStatistics(statsDocument: stat)
                                    result.append(player)
                                    count += 1
                                    if(count == 10) {
                                        completion(nil, result)
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    func getStatisticalMinimumGames(games : Int) -> Int {
        var constraint = 0
        var negativeValue = 1
        if(games == 0) {
            return 0
        }
        for i in 1...games {
            if(i == 1 || i == 2) {
                constraint += 1
            } else if((i-negativeValue)%3 != 0) {
                constraint += 1
                if((i-2)%10 == 0) {
                    negativeValue += 1
                    if(negativeValue == 3){
                        negativeValue = 0
                    }
                }
            }
        }
        return constraint
    }
    
    func getStatisticalMinimumFGMade(games : Int) -> Int {
        var result = 0
        if(games == 0) {
            return 0
        }
        for i in 1...games {
            if(i%3 == 0) {
                result += 3
            } else {
                result += 4
            }
        }
        return result
    }
    
    func getStatisticalMinimumFTMade(games : Int) -> Int {
        if(games == 0) {
            return 0
        }
        
        var result = 0
        var addTwoOnEven = true
        var constraint = 1
        
        for i in 1...games {
            if((i-constraint)%20 == 0 && i > constraint) {
                addTwoOnEven = !addTwoOnEven
            }
            
            if(i%2 == 0 || i == 1) {
                result += addTwoOnEven ? 2 : 1
            } else {
                result += addTwoOnEven ? 1 : 2
            }
            
            if(i%20 == 0 && i > 20) {
                constraint += 1
            }
        }
        return result
    }
    
    //MARK:- Standings Functions
    func getStanding(source: FirestoreSource, documentID: String,completion: @escaping (Error?) -> Void) {
        database.collection("Standings").document(documentID).getDocument(source: source) { (document, error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    //MARK:- Old Functions
    func AddWinsLossesForAllTeams(completion: @escaping (Error?) -> Void) {
        var totalCount = 0
        var count = 0
        database.collection("Teams").getDocuments { (teams, error) in
            if let error = error {
                completion(error)
            } else {
                for team in teams!.documents {
                    var wins = 0
                    var losses = 0
                    team.reference.collection("TeamGameStats").getDocuments(completion: { (gameStats, error) in
                        if let error = error {
                            completion(error)
                        } else {
                            totalCount += gameStats!.count
                            for game in gameStats!.documents {
                                if((game.get("PTS") as! Int) >= (game.get("opponentPTS") as! Int)) {
                                    wins += 1
                                } else {
                                    losses += 1
                                }
                            }
                            team.reference.collection("TeamStats").document("18-19").updateData(["wins":wins, "losses":losses], completion: { (error) in
                                if let error = error {
                                    completion(error)
                                } else {
                                    count += 1
                                    print("Updated Team Stats For Team \(team.documentID)")
                                    if(count == totalCount) {
                                        completion(nil)
                                    }
                                }
                            })
                        }
                    })
                }
            }
        }
    }
        
    func AddTeamToPlayerStats(completion: @escaping (Error?) -> Void) {
        var count = 0
        database.collectionGroup("PlayerStats").getDocuments { (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                for document in snapshot!.documents {
                    var data = document.data()
                    let playerRef = String(document.reference.path.split(separator: "/")[1])
                    if(playerRef.count > 3) {
                        self.database.collection("Players").document(playerRef).getDocument(completion: { (player, error) in
                            if let error = error {
                                completion(error)
                            } else {
                                data["team"] = player!.get("currentTeam") as! String
                                document.reference.updateData(data, completion: { (error) in
                                    if let error = error {
                                        completion(error)
                                    } else {
                                        count += 1
                                        if(count == snapshot!.count) {
                                            completion(nil)
                                        }
                                    }
                                })
                            }
                        })
                    }
                }
            }
        }
    }
    
    func AddPlayoffRounds(completion: @escaping (Error?) -> Void) {
        for i in 1...8 {
            var origin1 = ""
            var origin2 = ""
            switch i {
            case 1:
                origin1 = "A1"
                origin2 = "D4"
            case 2:
                origin1 = "B2"
                origin2 = "C3"
            case 3:
                origin1 = "D2"
                origin2 = "A3"
            case 4:
                origin1 = "C1"
                origin2 = "B4"
            case 5:
                origin1 = "A2"
                origin2 = "D3"
            case 6:
                origin1 = "B1"
                origin2 = "C4"
            case 7:
                origin1 = "D1"
                origin2 = "A4"
            case 8:
                origin1 = "C2"
                origin2 = "B3"
            default:
                origin1 = ""
            }
            let data : [String:Any] = [
                "gameID" : i,
                "teamA" : [
                    "abb" : "TBA",
                    "origin" : origin1,
                    "men" : [
                        "wins" : 0,
                        "losses" : 0,
                        "scoreDifference" : 0
                    ],
                    "u16" : [
                        "wins" : 0,
                        "losses" : 0,
                        "scoreDifference" : 0
                    ]
                ],
                "teamB" : [
                    "abb" : "TBA",
                    "origin" : origin2,
                    "men" : [
                        "wins" : 0,
                        "losses" : 0,
                        "scoreDifference" : 0
                    ],
                    "u16" : [
                        "wins" : 0,
                        "losses" : 0,
                        "scoreDifference" : 0
                    ]
                ],
                "winner" : NSNull(),
                "loser" : NSNull()
            ]
            database.collection("/Standings/U1GW71m8VQUg8icYAH5g/PlayoffsTree").addDocument(data: data) { (error) in
                if let error = error {
                    completion(error)
                } else {
                    print("Added Playoff Round \(i)")
                    if i == 8 {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func updateTeamStats(completion: @escaping (Error?) -> Void) {
        var count = 0
        database.collectionGroup("TeamStats").getDocuments { (stats, error) in
            if let error = error {
                completion(error)
            } else {
                for stat in stats!.documents {
                    var data = stat.data()
                    
                    data["team"] = (stat.reference.parent.parent!.documentID)
                    
                    stat.reference.setData(data, completion: { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            count += 1
                            if(count == stats!.count) {
                                completion(nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func removeFieldFromTeam(completion: @escaping (Error?) -> Void) {
        var count = 0
        database.collection("Teams").getDocuments { (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                for team in snapshot!.documents {
                    var data = team.data()
                    data.removeValue(forKey: "wins")
                    data.removeValue(forKey: "losses")
                    data.removeValue(forKey: "leagueStanding")
                    
                    self.database.collection("Teams").document(team.documentID).setData(data, completion: { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            count += 1
                            if(count == snapshot!.count) {
                                completion(nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func deletePlayerNicknameField(completion: @escaping (Error?) -> Void) {
        var totalCount = 0
        var completed = 0
        
        database.collection("Players").getDocuments { (players, error) in
            if let error = error {
                completion(error)
            } else {
                totalCount = players!.count
                for player in players!.documents {
                    self.database.collection("Players").document(player.documentID).updateData(["avatar" : FieldValue.delete()], completion: { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            completed += 1
                            print("Deleted Avatar from Player \(completed)/\(totalCount)")
                            if(completed == totalCount) {
                                completion(nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func addAssociatedLeagueStandings(completion: @escaping (Error?) -> Void) {
        let round = ["Group Stage", "Round of 16", "Quarter Finals", "Semi Finals", "Final Round"]
        var count = 0
        for i in 1...round.count {
            let data : [String:Any] = [
                "isCurrentStage" : i == 1 ? true : false,
                "isPreviousStage" : false,
                "isGroupStage" : i == 1 || i == round.count ? true : false,
                "isPlayoffRound" : i != 1 && i != round.count ? true : false,
                "stage" : i,
                "stageName" : round[i-1],
                "league" : "Associated League"
            ]
            database.collection("Standings").addDocument(data: data) { (error) in
                if let error = error {
                    completion(error)
                } else {
                    count += 1
                    print("Add Round: \(round[i-1])")
                    if count == round.count {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func addTeamStandings(completion: @escaping (Error?) -> Void) {
        var count = 0
        database.collection("Teams").getDocuments(source: .cache) { (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                for team in snapshot!.documents {
                    var group = 0
                    var current = 0
                    let abb = team.get("abb") as! String
                    switch abb {
                    case "ZAM":
                        group = 0
                        current = 1
                    case "INS":
                        group = 0
                        current = 2
                    case "TAN":
                        group = 0
                        current = 3
                    case "GEZ":
                        group = 1
                        current = 1
                    case "SMO":
                        group = 1
                        current = 2
                    case "TEL":
                        group = 1
                        current = 3
                    case "ITT":
                        group = 2
                        current = 1
                    case "ARM":
                        group = 2
                        current = 2
                    case "OLY":
                        group = 2
                        current = 3
                    case "SHA":
                        group = 2
                        current = 4
                    case "AHL":
                        group = 3
                        current = 1
                    case "ASC":
                        group = 3
                        current = 2
                    case "HOC":
                        group = 3
                        current = 3
                    case "SUE":
                        group = 3
                        current = 4
                    default:
                        group = current
                    }
                    let data : [String:Any] = [
                        "PTS" : [
                            "men" : 0,
                            "u16" : 0,
                            "total" : 0
                        ],
                        "group" : group,
                        "wins" : 0,
                        "losses" : 0,
                        "ranking" : [
                            "current" : current,
                            "previous" : current
                        ],
                        "scoreDifference" : [
                            "men" : 0,
                            "u16" : 0
                        ]
                    ]
                    self.database.collection("Standings/vP3dKvS20HuQMERQpqz9/GroupStandings").document(team.documentID).setData(data, completion: { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            print("Added \(team.documentID) Standings!")
                            count += 1
                            if(count == snapshot!.count) {
                                completion(nil)
                            }
                        }
                    })

                }
            }
        }
    }
    
    func testCollectionGroup(completion: @escaping (Error?) -> Void) {
        let query = database.collectionGroup("PlayerStats")
            .whereField("season", isEqualTo: currentSeason)
            .order(by: "PTS.perGame", descending: true)
//            .limit(to: 60)
        
        let start = DispatchTime.now()
        var count = 0
        query.getDocuments { (statistics, error) in
            if let error = error {
                completion(error)
            } else {
                for stat in statistics!.documents {
                    let playerRef = String(stat.reference.path.split(separator: "/")[1])
                    self.database.collection("Players").document(playerRef).getDocument(source: .cache, completion: { (player, error) in
                        if let error = error {
                            completion(error)
                        } else {
                            let firstName = player!.get("name.first") as! String
                            let secondName = player!.get("name.last") as! String
                            let points = stat.get("PTS.perGame") as! Double
                            
                            print()
                            print("\(firstName) \(secondName): \(points)")
                            count += 1
                            
                            if count == statistics!.count {
                                let end = DispatchTime.now()
                                let difference = end.uptimeNanoseconds - start.uptimeNanoseconds
                                print("Completed in \(Double(difference) / 1_000_000_000) seconds.")
                                completion(nil)
                            }
                        }
                    })
                }
                completion(nil)
            }
        }
    }
    
    func addPlayerStatsCollection(completion: @escaping (Error?) -> Void) {
        var totalCount = 0
        var completed = 0
        let teamsRef = database.collection("Teams")
        teamsRef.getDocuments { (teams, error) in
            if let error = error {
                completion(error)
            } else {
                for team in teams!.documents {
                    let playersRef = team.reference.collection("Players")
                    playersRef.getDocuments(completion: { (players, error) in
                        if let error = error {
                            completion(error)
                        } else {
                            totalCount += players!.count
                            for player in players!.documents {
                                let statsRef = player.reference.collection("PlayerStats")
                                statsRef.document("18-19").getDocument(completion: { (statsDocument, error) in
                                    if let error = error {
                                        completion(error)
                                    } else {
                                       let resultRef = self.database.collection("Players/\(player.documentID)/PlayerStats")
                                        var data = statsDocument!.data()
                                        data!["season"] = "18-19"
                                        data!["2FG"] = [
                                            "attempts" : data!["2FGA"],
                                            "made" : data!["2FGM"],
                                            "percentage" : data!["2FG%"]
                                        ]
                                        data!.removeValue(forKey: "2FGA")
                                        data!.removeValue(forKey: "2FGM")
                                        data!.removeValue(forKey: "2FG%")
                                        data!["3FG"] = [
                                            "attempts" : data!["3FGA"],
                                            "made" : data!["3FGM"],
                                            "percentage" : data!["3FG%"]
                                        ]
                                        data!.removeValue(forKey: "3FGA")
                                        data!.removeValue(forKey: "3FGM")
                                        data!.removeValue(forKey: "3FG%")
                                        data!["FG"] = [
                                            "attempts" : data!["FGA"],
                                            "made" : data!["FGM"],
                                            "percentage" : data!["FG%"]
                                        ]
                                        data!.removeValue(forKey: "FGA")
                                        data!.removeValue(forKey: "FGM")
                                        data!.removeValue(forKey: "FG%")
                                        data!["FT"] = [
                                            "attempts" : data!["FTA"],
                                            "made" : data!["FTM"],
                                            "percentage" : data!["FT%"]
                                        ]
                                        data!.removeValue(forKey: "FTA")
                                        data!.removeValue(forKey: "FTM")
                                        data!.removeValue(forKey: "FT%")
                                        
                                        data!["REB"] = [
                                            "offensive" : [
                                                "total" : data!["ORB"],
                                                "perGame" : ((data!["ORB"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["ORB"] as! Double)/(data!["gamesPlayed"] as! Double))
                                            ],
                                            "defensive" : [
                                                "total" : data!["DRB"],
                                                "perGame" : ((data!["DRB"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["DRB"] as! Double)/(data!["gamesPlayed"] as! Double))
                                            ],
                                            "total" : data!["TREB"],
                                            "perGame" : ((data!["TREB"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["TREB"] as! Double)/(data!["gamesPlayed"] as! Double))
                                        ]
                                        data!.removeValue(forKey: "ORB")
                                        data!.removeValue(forKey: "DRB")
                                        data!.removeValue(forKey: "TREB")
                                        
                                        data!["PTS"] = [
                                            "total" : data!["PTS"],
                                            "perGame" : ((data!["PTS"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["PTS"] as! Double)/(data!["gamesPlayed"] as! Double))
                                        ]
                                        
                                        data!["AST"] = [
                                            "total" : data!["AST"],
                                            "perGame" : ((data!["AST"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["AST"] as! Double)/(data!["gamesPlayed"] as! Double))
                                        ]
                                        
                                        data!["STL"] = [
                                            "total" : data!["STL"],
                                            "perGame" : ((data!["STL"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["STL"] as! Double)/(data!["gamesPlayed"] as! Double))
                                        ]
                                        
                                        data!["TO"] = [
                                            "total" : data!["TO"],
                                            "perGame" : ((data!["TO"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["TO"] as! Double)/(data!["gamesPlayed"] as! Double))
                                        ]
                                        
                                        data!["BLK"] = [
                                            "total" : data!["BLK"],
                                            "perGame" : ((data!["BLK"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["BLK"] as! Double)/(data!["gamesPlayed"] as! Double))
                                        ]
                                        
                                        data!["EFF"] = [
                                            "total" : data!["EFF"],
                                            "perGame" : ((data!["EFF"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["EFF"] as! Double)/(data!["gamesPlayed"] as! Double))
                                        ]
                                        
                                        data!["MINS"] = [
                                            "total" : data!["MINS"],
                                            "perGame" : ((data!["MINS"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["MINS"] as! Double)/(data!["gamesPlayed"] as! Double))
                                        ]
                                        
                                        data!["FOL"] = [
                                            "total" : data!["FOL"],
                                            "perGame" : ((data!["FOL"] as! Double)/(data!["gamesPlayed"] as! Double)).isNaN ? 0.0 : ((data!["FOL"] as! Double)/(data!["gamesPlayed"] as! Double))
                                        ]
                                        
                                        resultRef.document("18-19").setData(data!, completion: { (error) in
                                            if let error = error {
                                                completion(error)
                                            } else {
                                                completed += 1
                                                print("Added Player Stats \(completed)/\(totalCount)")
                                                if(completed == totalCount) {
                                                    completion(nil)
                                                }
                                            }
                                        })
//                                        resultRef.document("18-19").delete(completion: { (error) in
//                                            if let error = error {
//                                                completion(error)
//                                            } else {
//                                                completed += 1
//                                                print("Deleted Player Stats \(completed)/\(totalCount)")
//                                                if(completed == totalCount) {
//                                                    completion(nil)
//                                                }
//                                            }
//                                        })
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    
    func createAllPlayersCollection(completion: @escaping (Error?) -> Void) {
        var totalCount = 0
        var completed = 0
        database.collection("Teams").getDocuments { (teams, error) in
            if let error = error {
                completion(error)
            } else {
                for team in teams!.documents {
                    self.database.collection("Teams/\(team.documentID)/Players").getDocuments(completion: { (players, error) in
                        if let error = error {
                            completion(error)
                        } else {
                            totalCount += players!.count
                            for player in players!.documents {
                                var data = player.data()
                                data["currentTeam"] = team.get("abb") as! String
                                let secondary : Any = (data["secondaryPosition"] as! Int) == 0 ? NSNull() : data["secondaryPosition"] as! Int
                                data["postion"] = [
                                    "primary" : data["primaryPosition"] as! Int,
                                    "secondary" : secondary
                                ]
                                data["name"] = [
                                    "first" : data["firstName"] as! String,
                                    "last" : data["lastName"] as! String,
                                    "nickname" : [
                                        "first" : NSNull(),
                                        "last" : NSNull()
                                    ]
                                ]
                                data["biometrics"] = [
                                    "height" : data["height"] as! Int,
                                    "weight" : data["weight"] as! Int
                                ]
                                data.removeValue(forKey: "primaryPosition")
                                data.removeValue(forKey: "secondaryPosition")
                                data.removeValue(forKey: "avatar")
                                data.removeValue(forKey: "firstName")
                                data.removeValue(forKey: "lastName")
                                data.removeValue(forKey: "height")
                                data.removeValue(forKey: "weight")
                                data.removeValue(forKey: "nickname")
                                self.database.collection("Players").document(player.documentID).setData(data, completion: { (error) in
                                    if let error = error {
                                        completion(error)
                                    } else {
                                        completed += 1
                                        print("Added Player \(completed)/\(totalCount)")
                                        if(completed == totalCount) {
                                            completion(nil)
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    
    func getTeamInfo(forTeamRef: String, completion: @escaping (Error?, Team?) -> Void) {
        database.document(forTeamRef).getDocument { (TeamSnapshot, error) in
            if let error = error {
                completion(error, nil)
            } else {
                self.database.document(forTeamRef + "/TeamStats/" + self.currentSeason).getDocument(completion: { (TeamStatsSnapshot, error) in
                    if let error = error {
                        completion(error, nil)
                    } else {
                        let team = Team(teamDocument: TeamSnapshot!)
                        completion(nil, team)
                    }
                })
            }
        }
    }
    
    
    
    func getStandings(completion: @escaping  (Error?, [String:[TeamDisplayData]]?) -> Void) {
        let dbTeams = DatabaseManager.sharedInstance.teamsDisplayData
        var result : [String : [TeamDisplayData]] = [:]
        
        database.document("Standings/\(currentSeason)").getDocument { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            } else {
                let stage = snapshot!.get("currentStage") as! String
                snapshot!.reference.collection("Stages/\(stage)/Groups").getDocuments(completion: { (groups, error) in
                    if let error = error {
                        completion(error, nil)
                    } else {
                        for group in groups!.documents {
                            let groupName = group.get("groupName") as! String
                            group.reference.collection("Teams").getDocuments(completion: { (teams, error) in
                                if let error = error {
                                    completion(error, nil)
                                } else {
                                    var teamsResult : [TeamDisplayData] = []
                                    for team in teams!.documents {
                                        dbTeams[team.documentID]!.currentStanding = (team.get("current") as! Int)
                                        dbTeams[team.documentID]!.previousStanding = (team.get("previous") as! Int)
                                        dbTeams[team.documentID]!.wins = (team.get("win") as! Int)
                                        dbTeams[team.documentID]!.losses = (team.get("loss") as! Int)
                                        dbTeams[team.documentID]!.scoreDifference = (team.get("scoreDifference") as! Int)
                                        teamsResult.append(dbTeams[team.documentID]!)
                                    }
                                    result[groupName] = teamsResult
                                    if(result.count == groups!.count) {
                                        completion(nil, result)
                                    }
                                }
                            })
                        }
                    }
                })
                
            }
        }
    }
    
    func getTeamImageURL(teamID : String) -> URL {
        let teamImagesPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Images")

        let path = teamImagesPath!.appendingPathComponent("TeamImages.plist")
        let dictionary = NSMutableDictionary(contentsOfFile: path.path)!
        let URLString = dictionary.value(forKey: teamID) as! String
        return URL(string: URLString)!
    }
    
    func getAllTeamsDisplayData(completion: @escaping (Error?, [TeamDisplayData]?) -> Void) {
        var teams = [TeamDisplayData]()
        
        let teamsRef = database.collection("/Teams").order(by: "teamName")
        
        teamsRef.getDocuments(source: .cache) { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            } else {
                if (snapshot!.count == 0) {
                    teamsRef.getDocuments { (teamQuerySnapshot, error) in
                        if let error = error {
                            completion(error, nil)
                        } else {
                            for teamDocument in teamQuerySnapshot!.documents {
                                let team = TeamDisplayData(teamDocument: teamDocument)
                                teams.append(team)
                            }
                            completion(nil, teams)
                        }
                    }
                } else {
                    for teamDocument in snapshot!.documents {
                        let team = TeamDisplayData(teamDocument: teamDocument)
                        teams.append(team)
                    }
                    completion(nil, teams)
                }
            }
        }
    }
    
    func editPlayerPosition(completion: @escaping (Error?) -> Void) {
        var count = 0
        database.collection("Players").getDocuments { (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                for document in snapshot!.documents {
                    var data = document.data()
                    let position : [String:Any] = data["postion"] as! [String:Any]
                    data.removeValue(forKey: "postion")
                    data["position"] = position
                    self.database.collection("Players").document(document.documentID).setData(data, completion: { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            count += 1
                            if(count == snapshot!.count) {
                                completion(nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func adjustTeamGameStats(completion: @escaping (Error?) -> Void) {
        var count = 0
        database.collectionGroup("TeamGameStats").getDocuments { (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                for document in snapshot!.documents {
                    var data = document.data()
                    data["season"] = "18-19"
                    data["2FG"] = [
                        "attempts" : data["2FGA"],
                        "made" : data["2FGM"],
                        "percentage" : data["2FG%"]
                    ]
                    data.removeValue(forKey: "2FGA")
                    data.removeValue(forKey: "2FGM")
                    data.removeValue(forKey: "2FG%")
                    data["3FG"] = [
                        "attempts" : data["3FGA"],
                        "made" : data["3FGM"],
                        "percentage" : data["3FG%"]
                    ]
                    data.removeValue(forKey: "3FGA")
                    data.removeValue(forKey: "3FGM")
                    data.removeValue(forKey: "3FG%")
                    data["FG"] = [
                        "attempts" : data["FGA"],
                        "made" : data["FGM"],
                        "percentage" : data["FG%"]
                    ]
                    data.removeValue(forKey: "FGA")
                    data.removeValue(forKey: "FGM")
                    data.removeValue(forKey: "FG%")
                    data["FT"] = [
                        "attempts" : data["FTA"],
                        "made" : data["FTM"],
                        "percentage" : data["FT%"]
                    ]
                    data.removeValue(forKey: "FTA")
                    data.removeValue(forKey: "FTM")
                    data.removeValue(forKey: "FT%")
                    
                    data["REB"] = [
                        "offensive" : data["ORB"],
                        "defensive" : data["DRB"],
                        "total" : data["TREB"]
                    ]
                    data.removeValue(forKey: "ORB")
                    data.removeValue(forKey: "DRB")
                    data.removeValue(forKey: "TREB")
                    
                    document.reference.setData(data, completion: { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            print("\(document.documentID) Completed")
                            count += 1
                            if (count == snapshot!.count) {
                                completion(nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func deletePlayerStats(completion: @escaping (Error?) -> Void) {
        var totalcount = 0
        var count = 0
        database.collectionGroup("Teams").getDocuments { (teams, error) in
            if let error = error {
                completion(error)
            } else {
                for team in teams!.documents {
                    team.reference.collection("Players").getDocuments(completion: { (players, error) in
                        if let error = error {
                            completion(error)
                        } else {
                            for player in players!.documents {
                                player.reference.collection("PlayerStats").getDocuments(completion: { (stats, error) in
                                    if let error = error {
                                        completion(error)
                                    } else {
                                        for stat in stats!.documents {
                                            totalcount += stats!.count
                                            stat.reference.delete(completion: { (error) in
                                                if let error = error {
                                                    completion(error)
                                                } else {
                                                    count += 1
                                                    if(count == totalcount) {
                                                        completion(nil)
                                                    }
                                                }
                                            })
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
    }    
}

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
    
    let teamImagesPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Images")
    
    let currentSeason = "18-19"
    var teamsDisplayData : [TeamDisplayData] = [TeamDisplayData]()
    
    init() {
        //Initialize Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        database = Firestore.firestore()
        storage = Storage.storage()
    }
    
    func setupApplicationDatabase(completion: @escaping  (Error?, String?) -> Void){
        let start = DispatchTime.now()
        createPlistFiles { (error) in
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
                                DatabaseManager.sharedInstance.teamsDisplayData = teams!
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
    
    func AddTeamToDatabase(completion: @escaping  (Error?) -> Void) {
        print("Adding data to database")
        var documentsToWrite = 0
        var completedDocuments = 0
        
        let teamData : [String : Any] = [
            "teamName" : "Horse Owners Club",
            "abb" : "HOC",
            "location" : "Alexandria, Egypt",
            "image" : "",
            "headCoach" : ["Wessam Gaber"],
            "leagueStanding" : 9
        ]
        
        documentsToWrite += 1
        database.collection("Teams").document(teamData["abb"] as! String).setData(teamData) { error in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        let teamDocumentID = "Teams/\(teamData["abb"] as! String)"
        
        let teamStatsData : [String : Any] = [
            "gamesPlayed" : 1,
            "3FGA" : 18,
            "3FGM" : 8,
            "3FG%" : 0.44,
            "2FGA" : 43,
            "2FGM" : 21,
            "2FG%" : 0.49,
            "FGA" : 61,
            "FGM" : 29,
            "FG%" : 0.48,
            "FTA" : 23,
            "FTM" : 13,
            "FT%" : 0.57,
            "PTS" : 79,
            "ORB" : 10,
            "DRB" : 21,
            "TREB" : 31,
            "AST" : 20,
            "BLK" : 1,
            "TO" : 14,
            "STL" : 9,
            "FOL" : 20
        ]
        
        documentsToWrite += 1
        database.collection("\(teamDocumentID)/TeamStats").document("\(currentSeason)").setData(teamStatsData) { error in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        let teamStatsDocumentID = "\(teamDocumentID)/TeamStats/\(currentSeason)"
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(teamStatsDocumentID)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        let teamGameStatsID = "\(teamDocumentID)/TeamGameStats"

        let gameStatsData : [String : Any] = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "opponentABB" : "SHA",
            "3FGA" : 18,
            "3FGM" : 8,
            "3FG%" : 0.44,
            "2FGA" : 43,
            "2FGM" : 21,
            "2FG%" : 0.49,
            "FGA" : 61,
            "FGM" : 29,
            "FG%" : 0.48,
            "FTA" : 23,
            "FTM" : 13,
            "FT%" : 0.57,
            "PTS" : 79,
            "ORB" : 10,
            "DRB" : 21,
            "TREB" : 31,
            "AST" : 20,
            "BLK" : 1,
            "TO" : 14,
            "STL" : 9,
            "FOL" : 20
        ]
        
        documentsToWrite += 1
        database.collection(teamGameStatsID).document(gameStatsData["gameID"] as! String).setData(gameStatsData) { error in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
                
            }
        }
        
        let gameStatsDocumentID = "\(teamGameStatsID)/\(gameStatsData["gameID"] as! String)"
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            
            documentsToWrite += 1
            database.collection("\(gameStatsDocumentID)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        var playerData : [String : Any] = [
            "firstName" : "Ahmed",
            "lastName" : "Khaled",
            "nickname" : "Ahmed Khaled",
            "primaryPosition" : 1,
            "secondaryPosition" : 0,
            "jerseyNo" : "7",
            "height" : 180,
            "weight" : 78,
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1996")!),
            "nationality" : "Egyptian",
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        var playersDocumentID = "\(teamDocumentID)/Players"

        documentsToWrite += 1
        var playerRef : DocumentReference? = nil
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        var playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        var playerStatsData : [String : Any] = [
            "gamesPlayed" : 1,
            "3FGA" : 2,
            "3FGM" : 1,
            "3FG%" : 0.5,
            "2FGA" : 5,
            "2FGM" : 3,
            "2FG%" : 0.6,
            "FGA" : 7,
            "FGM" : 4,
            "FG%" : 0.57,
            "FTA" : 1,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 9,
            "ORB" : 0,
            "DRB" : 1,
            "TREB" : 1,
            "AST" : 5,
            "BLK" : 0,
            "TO" : 3,
            "STL" : 5,
            "FOL" : 1,
            "MINS" : 26.03,
            "EFF" : 12
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        var playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        var playerGameStatsData : [String : Any] = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 2,
            "3FGM" : 1,
            "3FG%" : 0.5,
            "2FGA" : 5,
            "2FGM" : 3,
            "2FG%" : 0.6,
            "FGA" : 7,
            "FGM" : 4,
            "FG%" : 0.57,
            "FTA" : 1,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 9,
            "ORB" : 0,
            "DRB" : 1,
            "TREB" : 1,
            "AST" : 5,
            "BLK" : 0,
            "TO" : 3,
            "STL" : 5,
            "FOL" : 1,
            "MINS" : 26.03,
            "EFF" : 12
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Mostafa",
            "lastName" : "Sameh",
            "nickname" : "Mostafa Sameh",
            "primaryPosition" : 1,
            "secondaryPosition" : 0,
            "jerseyNo" : "10",
            "height" : 175,
            "weight" : 70,
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1992")!),
            "nationality" : "Egyptian",
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1

        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 1,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 1,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 2,
            "TREB" : 2,
            "AST" : 1,
            "BLK" : 0,
            "TO" : 1,
            "STL" : 0,
            "FOL" : 2,
            "MINS" : 6.42,
            "EFF" : 1
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 1,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 1,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 2,
            "TREB" : 2,
            "AST" : 1,
            "BLK" : 0,
            "TO" : 1,
            "STL" : 0,
            "FOL" : 2,
            "MINS" : 6.42,
            "EFF" : 1
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Zeyad",
            "lastName" : "Atef",
            "nickname" : "Zeyad Atef",
            "primaryPosition" : 1,
            "secondaryPosition" : 2,
            "jerseyNo" : "9",
            "height" : 182,
            "weight" : 80,
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "19/6/1994")!),
            "nationality" : "Egyptian",
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 2,
            "3FGM" : 1,
            "3FG%" : 0.5,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 2,
            "FGM" : 1,
            "FG%" : 0.5,
            "FTA" : 2,
            "FTM" : 1,
            "FT%" : 0.5,
            "PTS" : 4,
            "ORB" : 0,
            "DRB" : 1,
            "TREB" : 1,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 2,
            "STL" : 3,
            "FOL" : 2,
            "MINS" : 23.0,
            "EFF" : 6
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 2,
            "3FGM" : 1,
            "3FG%" : 0.5,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 2,
            "FGM" : 1,
            "FG%" : 0.5,
            "FTA" : 2,
            "FTM" : 1,
            "FT%" : 0.5,
            "PTS" : 4,
            "ORB" : 0,
            "DRB" : 1,
            "TREB" : 1,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 2,
            "STL" : 3,
            "FOL" : 2,
            "MINS" : 23.0,
            "EFF" : 6
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Omar",
            "lastName" : "Mesha'al",
            "nickname" : "Omar Mesha'al",
            "primaryPosition" : 1,
            "secondaryPosition" : 0,
            "jerseyNo" : "18",
            "height" : 172,
            "weight" : 72,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1998")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 0,
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 0,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 0,
            "TREB" : 0,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 0.0,
            "EFF" : 0
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Nour",
            "lastName" : "Emad",
            "nickname" : "Nour Emad",
            "primaryPosition" : 2,
            "secondaryPosition" : 0,
            "jerseyNo" : "00",
            "height" : 175,
            "weight" : 70,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1983")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 2,
            "3FGM" : 1,
            "3FG%" : 0.5,
            "2FGA" : 4,
            "2FGM" : 2,
            "2FG%" : 0.5,
            "FGA" : 6,
            "FGM" : 3,
            "FG%" : 0.5,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 7,
            "ORB" : 0,
            "DRB" : 3,
            "TREB" : 3,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 1,
            "STL" : 0,
            "FOL" : 3,
            "MINS" : 15.05,
            "EFF" : 8
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 2,
            "3FGM" : 1,
            "3FG%" : 0.5,
            "2FGA" : 4,
            "2FGM" : 2,
            "2FG%" : 0.5,
            "FGA" : 6,
            "FGM" : 3,
            "FG%" : 0.5,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 7,
            "ORB" : 0,
            "DRB" : 3,
            "TREB" : 3,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 1,
            "STL" : 0,
            "FOL" : 3,
            "MINS" : 15.05,
            "EFF" : 8
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Jajuan",
            "lastName" : "Smith",
            "nickname" : "Jaylon Smith",
            "primaryPosition" : 2,
            "secondaryPosition" : 0,
            "jerseyNo" : "2",
            "height" : 185,
            "weight" : 83,
            "nationality" : "American",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1995")!),
            "hometown" : "Memphis, Tennessee",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 7,
            "3FGM" : 4,
            "3FG%" : 0.57,
            "2FGA" : 14,
            "2FGM" : 5,
            "2FG%" : 0.36,
            "FGA" : 21,
            "FGM" : 9,
            "FG%" : 0.43,
            "FTA" : 7,
            "FTM" : 4,
            "FT%" : 0.57,
            "PTS" : 26,
            "ORB" : 2,
            "DRB" : 3,
            "TREB" : 5,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 1,
            "STL" : 2,
            "FOL" : 0,
            "MINS" : 36.07,
            "EFF" : 19
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 7,
            "3FGM" : 4,
            "3FG%" : 0.57,
            "2FGA" : 14,
            "2FGM" : 5,
            "2FG%" : 0.36,
            "FGA" : 21,
            "FGM" : 9,
            "FG%" : 0.43,
            "FTA" : 7,
            "FTM" : 4,
            "FT%" : 0.57,
            "PTS" : 26,
            "ORB" : 2,
            "DRB" : 3,
            "TREB" : 5,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 1,
            "STL" : 2,
            "FOL" : 0,
            "MINS" : 36.07,
            "EFF" : 19
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Abdelrahman",
            "lastName" : "Soliman",
            "nickname" : "Abdelrahman Soliman",
            "primaryPosition" : 2,
            "secondaryPosition" : 0,
            "jerseyNo" : "1",
            "height" : 175,
            "weight" : 72,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1995")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 0,
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 0,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 0,
            "TREB" : 0,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 0.0,
            "EFF" : 0
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Ahmed Khaled",
            "lastName" : "Kandil",
            "nickname" : "Ahmed Kandil",
            "primaryPosition" : 2,
            "secondaryPosition" : 0,
            "jerseyNo" : "6",
            "height" : 175,
            "weight" : 72,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1998")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 0,
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 0,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 0,
            "TREB" : 0,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 0.0,
            "EFF" : 0
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Marwan",
            "lastName" : "El-Shafa'e",
            "nickname" : "Marwan El-Shafa'e",
            "primaryPosition" : 2,
            "secondaryPosition" : 0,
            "jerseyNo" : "66",
            "height" : 183,
            "weight" : 75,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/2000")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 0,
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 0,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 0,
            "TREB" : 0,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 0.0,
            "EFF" : 0
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Amir",
            "lastName" : "Alaa",
            "nickname" : "Amir Alaa",
            "primaryPosition" : 2,
            "secondaryPosition" : 3,
            "jerseyNo" : "11",
            "height" : 185,
            "weight" : 85,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1995")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 1,
            "2FGM" : 1,
            "2FG%" : 1.0,
            "FGA" : 1,
            "FGM" : 1,
            "FG%" : 1.0,
            "FTA" : 1,
            "FTM" : 1,
            "FT%" : 1.0,
            "PTS" : 3,
            "ORB" : 0,
            "DRB" : 1,
            "TREB" : 1,
            "AST" : 1,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 8.02,
            "EFF" : 5
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 1,
            "2FGM" : 1,
            "2FG%" : 1.0,
            "FGA" : 1,
            "FGM" : 1,
            "FG%" : 1.0,
            "FTA" : 1,
            "FTM" : 1,
            "FT%" : 1.0,
            "PTS" : 3,
            "ORB" : 0,
            "DRB" : 1,
            "TREB" : 1,
            "AST" : 1,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 8.02,
            "EFF" : 5
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Anwar",
            "lastName" : "Mohamed",
            "nickname" : "Anwar Gazara",
            "primaryPosition" : 2,
            "secondaryPosition" : 3,
            "jerseyNo" : "22",
            "height" : 187,
            "weight" : 90,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1989")!),
            "hometown" : "Damanhour, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 1,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 1,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 0,
            "TREB" : 0,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 3.2,
            "EFF" : -1
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 1,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 1,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 0,
            "TREB" : 0,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 3.2,
            "EFF" : -1
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Mohamed",
            "lastName" : "Hesham",
            "nickname" : "Mohamed Hesham",
            "primaryPosition" : 4,
            "secondaryPosition" : 3,
            "jerseyNo" : "8",
            "height" : 193,
            "weight" : 98,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1995")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 3,
            "2FGM" : 1,
            "2FG%" : 0.33,
            "FGA" : 3,
            "FGM" : 1,
            "FG%" : 0.33,
            "FTA" : 2,
            "FTM" : 2,
            "FT%" : 1.0,
            "PTS" : 4,
            "ORB" : 0,
            "DRB" : 2,
            "TREB" : 2,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 4,
            "MINS" : 16.07,
            "EFF" : 6
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 3,
            "2FGM" : 1,
            "2FG%" : 0.33,
            "FGA" : 3,
            "FGM" : 1,
            "FG%" : 0.33,
            "FTA" : 2,
            "FTM" : 2,
            "FT%" : 1.0,
            "PTS" : 4,
            "ORB" : 0,
            "DRB" : 2,
            "TREB" : 2,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 4,
            "MINS" : 16.07,
            "EFF" : 6
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Ahmed",
            "lastName" : "Rabei",
            "nickname" : "Ahmed Rabei",
            "primaryPosition" : 4,
            "secondaryPosition" : 0,
            "jerseyNo" : "12",
            "height" : 195,
            "weight" : 92,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1987")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 2,
            "3FGM" : 1,
            "3FG%" : 0.5,
            "2FGA" : 10,
            "2FGM" : 6,
            "2FG%" : 0.6,
            "FGA" : 12,
            "FGM" : 7,
            "FG%" : 0.58,
            "FTA" : 1,
            "FTM" : 1,
            "FT%" : 1.0,
            "PTS" : 16,
            "ORB" : 3,
            "DRB" : 3,
            "TREB" : 6,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 3,
            "STL" : 0,
            "FOL" : 4,
            "MINS" : 34.03,
            "EFF" : 16
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 2,
            "3FGM" : 1,
            "3FG%" : 0.5,
            "2FGA" : 10,
            "2FGM" : 6,
            "2FG%" : 0.6,
            "FGA" : 12,
            "FGM" : 7,
            "FG%" : 0.58,
            "FTA" : 1,
            "FTM" : 1,
            "FT%" : 1.0,
            "PTS" : 16,
            "ORB" : 3,
            "DRB" : 3,
            "TREB" : 6,
            "AST" : 2,
            "BLK" : 0,
            "TO" : 3,
            "STL" : 0,
            "FOL" : 4,
            "MINS" : 34.03,
            "EFF" : 16
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Karim",
            "lastName" : "Shamseya",
            "nickname" : "Karim Shamseya",
            "primaryPosition" : 4,
            "secondaryPosition" : 5,
            "jerseyNo" : "15",
            "height" : 201,
            "weight" : 98,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1983")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 0,
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 0,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 0,
            "TREB" : 0,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 0.0,
            "EFF" : 0
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Mohamed",
            "lastName" : "Younes",
            "nickname" : "Mohamed Younes",
            "primaryPosition" : 5,
            "secondaryPosition" : 4,
            "jerseyNo" : "33",
            "height" : 200,
            "weight" : 99,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1985")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 5,
            "2FGM" : 2,
            "2FG%" : 0.4,
            "FGA" : 5,
            "FGM" : 2,
            "FG%" : 0.4,
            "FTA" : 9,
            "FTM" : 4,
            "FT%" : 0.44,
            "PTS" : 8,
            "ORB" : 3,
            "DRB" : 5,
            "TREB" : 8,
            "AST" : 3,
            "BLK" : 1,
            "TO" : 3,
            "STL" : 0,
            "FOL" : 3,
            "MINS" : 19.03,
            "EFF" : 9
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 5,
            "2FGM" : 2,
            "2FG%" : 0.4,
            "FGA" : 5,
            "FGM" : 2,
            "FG%" : 0.4,
            "FTA" : 9,
            "FTM" : 4,
            "FT%" : 0.44,
            "PTS" : 8,
            "ORB" : 3,
            "DRB" : 5,
            "TREB" : 8,
            "AST" : 3,
            "BLK" : 1,
            "TO" : 3,
            "STL" : 0,
            "FOL" : 3,
            "MINS" : 19.03,
            "EFF" : 9
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Ahmed",
            "lastName" : "Seddik",
            "nickname" : "Ahmed Seddik",
            "primaryPosition" : 5,
            "secondaryPosition" : 0,
            "jerseyNo" : "21",
            "height" : 205,
            "weight" : 104,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1983")!),
            "hometown" : "Alexandria, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 1,
            "3FGA" : 1,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 1,
            "2FGM" : 1,
            "2FG%" : 1.0,
            "FGA" : 2,
            "FGM" : 1,
            "FG%" : 0.5,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 2,
            "ORB" : 2,
            "DRB" : 0,
            "TREB" : 2,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 1,
            "MINS" : 9.4,
            "EFF" : 3
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerGameStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerGameStats"
        
        playerGameStatsData = [
            "gameID" : "HOCvsSUNS_27-2-2019",
            "opponentName" : "Shams",
            "3FGA" : 1,
            "3FGM" : 0,
            "3FG%" : 0.0,
            "2FGA" : 1,
            "2FGM" : 1,
            "2FG%" : 1.0,
            "FGA" : 2,
            "FGM" : 1,
            "FG%" : 0.5,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 2,
            "ORB" : 2,
            "DRB" : 0,
            "TREB" : 2,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 1,
            "MINS" : 9.4,
            "EFF" : 3
        ]
        
        documentsToWrite += 1
        database.collection(playerGameStatsDocumentID).document(playerGameStatsData["gameID"] as! String).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            let playerZoneID = "\(playerGameStatsDocumentID)/\(playerGameStatsData["gameID"] as! String)/StatsPerZone"
            database.collection(playerZoneID).document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                }
            }
        }
        
        playerData = [
            "firstName" : "Mohamed",
            "lastName" : "El-Kony",
            "nickname" : "Mohamed El-Kony",
            "primaryPosition" : 5,
            "secondaryPosition" : 0,
            "jerseyNo" : "14",
            "height" : 205,
            "weight" : 102,
            "nationality" : "Egyptian",
            "dateOfBirth" : Timestamp(date: dateFormatter.date(from: "1/1/1982")!),
            "hometown" : "Damanhour, Egypt",
            "avatar": ""
        ]
        
        playersDocumentID = "\(teamDocumentID)/Players"
        
        documentsToWrite += 1
        
        playerRef = database.collection(playersDocumentID).addDocument(data: playerData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        playerStatsDocumentID = "\(playersDocumentID)/\(playerRef!.documentID)/PlayerStats"
        
        playerStatsData = [
            "gamesPlayed" : 0,
            "3FGA" : 0,
            "3FGM" : 0,
            "3FG%" : 0,
            "2FGA" : 0,
            "2FGM" : 0,
            "2FG%" : 0.0,
            "FGA" : 0,
            "FGM" : 0,
            "FG%" : 0.0,
            "FTA" : 0,
            "FTM" : 0,
            "FT%" : 0.0,
            "PTS" : 0,
            "ORB" : 0,
            "DRB" : 0,
            "TREB" : 0,
            "AST" : 0,
            "BLK" : 0,
            "TO" : 0,
            "STL" : 0,
            "FOL" : 0,
            "MINS" : 0.0,
            "EFF" : 0
        ]
        
        documentsToWrite += 1
        database.collection(playerStatsDocumentID).document(currentSeason).setData(playerStatsData) { (error) in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
                return
            } else {
                completedDocuments += 1
                print("Document successfully written!")
            }
        }
        
        for i in 1...14 {
            let zoneData : [String : Any] = [
                "zoneNumber" : i,
                "FGA" : 0,
                "FGM" : 0,
                "FG%" : 0.0,
                "PTS" : 0
            ]
            
            let zoneName = "Zone-\(i)"
            documentsToWrite += 1
            database.collection("\(playerStatsDocumentID)/\(currentSeason)/StatsPerZone").document(zoneName).setData(zoneData) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    completion(error)
                    return
                } else {
                    completedDocuments += 1
                    print("Document successfully written!")
                    if(completedDocuments == documentsToWrite) {
                        print("Added Documents Successfully: \(completedDocuments)/\(documentsToWrite)")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func getPlayers(forTeam collection : String, completion: @escaping (Error?, [Player]?) -> Void) {
        
        var players = [Player]()
        
        let playersRef = database.collection("\(collection)/Players")
            .order(by: "primaryPosition")
            .order(by: "secondaryPosition")
        
        playersRef.getDocuments { (playerQuerySnapshot, error) in
            if let error = error {
                print("Error Fetching Players: \(error)")
                completion(error, nil)
            } else {
                for playerDocument in playerQuerySnapshot!.documents {
                    let totalStatsRef = self.database.collection("\(collection)/Players/\(playerDocument.documentID)/PlayerStats")
                    totalStatsRef.getDocuments(completion: { (statsQuerySnapshot, error) in
                        if let error = error {
                            completion(error, nil)
                        } else {
                            for statsDocument in statsQuerySnapshot!.documents {
                                let player = Player(playerDocument: playerDocument, playerStatsDocument: statsDocument)
                                players.append(player)
                            }
                            if (players.count == playerQuerySnapshot!.documents.count) {
                                completion(nil, players)
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
                        let team = Team(teamDocument: TeamSnapshot!, teamStatsDocument: TeamStatsSnapshot!)
                        completion(nil, team)
                    }
                })
            }
        }
    }
    
    func getTeamGameStats(forTeamRef teamRef: String, completion: @escaping (Error?, Bool?, [TeamGameStats]?) -> Void) {
        let teamGamesRef = database.collection("\(teamRef)/TeamGameStats")
            .order(by: "date")
        
        teamGamesRef.getDocuments { (teamGamesSnapshot, error) in
            if let error = error {
                completion(error, nil, nil)
            } else {
                var result : [TeamGameStats] = []
                if(teamGamesSnapshot?.count == 0) {
                    completion(nil, false, nil)
                } else {
                    for document in teamGamesSnapshot!.documents {
                        result.append(TeamGameStats(statsDocument: document))
                    }
                    completion(nil, true, result)
                }
            }
        }
    }
    
    //MARK: - Persisting Team Images
    func createPlistFiles(completion: @escaping (Error?) -> Void) {
        
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
        
        let path = teamImagesPath!.appendingPathComponent("TeamImages.plist")
        let dictionary = NSMutableDictionary(contentsOfFile: path.path)!

        let teamsRef = database.collection("/Teams")
        teamsRef.getDocuments(source: .cache) { (cacheSnapshot, error) in
            if let error = error {
                print("Error getting teams refrences")
                completion(error)
            } else {
                if(cacheSnapshot!.count == 0) {
                    teamsRef.getDocuments { (snapshot, error) in
                        if let error = error {
                            print("Error getting teams refrences")
                            completion(error)
                        } else {
                            var count = 0
                            for document in snapshot!.documents {
                                if dictionary[document.documentID] == nil {
                                    let imageRef = self.storage.reference().child("TeamImages/\(document.documentID).png")
                                    imageRef.downloadURL { url, error in
                                        if let error = error {
                                            count += 1
                                            print(error)
                                        } else {
                                            dictionary.setValue(url!.absoluteString, forKey: document.documentID)
                                            count += 1
                                            if(count == snapshot!.count) {
                                                dictionary.write(toFile: path.path, atomically: true)
                                                completion(nil)
                                            }
                                        }
                                    }
                                } else {
                                    count += 1
                                    if(count == snapshot!.count) {
                                        completion(nil)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    var count = 0
                    for document in cacheSnapshot!.documents {
                        if dictionary[document.documentID] == nil {
                            let imageRef = self.storage.reference().child("TeamImages/\(document.documentID).png")
                            imageRef.downloadURL { url, error in
                                if let error = error {
                                    count += 1
                                    print(error)
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
    }
    
    func AddTeamImageURLToLocal(team: String) {
        let path = teamImagesPath!.appendingPathComponent("TeamImages.plist")
        let dictionary = NSMutableDictionary(contentsOfFile: path.path)!
        let imageRef = self.storage.reference().child("TeamImages/\(team).png")
        imageRef.downloadURL { url, error in
            if let error = error {
                print(error)
            } else {
                dictionary.setValue(url!.absoluteString, forKey: team)
                dictionary.write(toFile: path.path, atomically: true)
            }
        }
    }
    
    func getTeamImageURL(teamID : String) -> URL {
        let path = teamImagesPath!.appendingPathComponent("TeamImages.plist")
        let dictionary = NSMutableDictionary(contentsOfFile: path.path)!
        let URLString = dictionary.value(forKey: teamID) as! String
        return URL(string: URLString)!
    }
    
    //MARK: - Get Teams Display Info
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

    //MARK: - Managing Documents Directory
    func emptyImagesDirectory(){
        do {
            try FileManager.default.removeItem(at: teamImagesPath!)
        }
        catch let error {
            print("Zodiac \(error)")
        }
    }
    
    func listDocumentDirectory() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // process files
            print(fileURLs)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }

}

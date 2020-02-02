//
//  DatabaseSetter.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 4/21/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Firebase

class DatabaseSetter {
    
    let manager = DatabaseManager.sharedInstance
    let database : Firestore
    let storage : Storage
    
    let dateFormatter = DateFormatter()
    //Timestamp(date: dateFormatter.date(from: "1/1/1996")!
    
    
//    var teamsDictionary : [String:[[String:Any]]] = [
//        //MARK: - Ahly
//        "Ahly":[
//             ["teamName":"Al-Ahly SC", "abb":"AHL", "leagueStanding":3, "wins":0, "losses":0, "location":"Cairo, Egypt", "headCoach":["Tarek Khairy"], "primaryColor":"CC0A0A", "secondaryColor":"FFFFFF"],
//             //MARK: 1: Tarek El-Ghannam
//            [
//                "firstName" : "Tarek",
//                "lastName" : "El-Ghannam",
//                "nickname" : "Tarek El-Ghannam",
//                "primaryPosition" : 5,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "10",
//                "height" : 210,
//                "weight" : 100,
//                "dateOfBirth" : "1/1/1978",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Seif Samir
//            [
//                "firstName" : "Seif",
//                "lastName" : "Samir",
//                "nickname" : "Seif Samir",
//                "primaryPosition" : 5,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "8",
//                "height" : 208,
//                "weight" : 110,
//                "dateOfBirth" : "1/1/1993",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Mostafa El-Shafa'e
//            [
//                "firstName" : "Mostafa",
//                "lastName" : "El-Shafa'e",
//                "nickname" : "Mostafa El-Shafa'e",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 3,
//                "jerseyNo" : "12",
//                "height" : 198,
//                "weight" : 120,
//                "dateOfBirth" : "1/1/1983",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Mohamed Abo-Elnasr
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "Abo-Elnasr",
//                "nickname" : "Mohamed Abo-Elnasr",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 3,
//                "jerseyNo" : "23",
//                "height" : 190,
//                "weight" : 85,
//                "dateOfBirth" : "1/1/1993",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Mohamed El-Garhi
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "El-Garhi",
//                "nickname" : "Moudy El-Garhy",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "4",
//                "height" : 175,
//                "weight" : 70,
//                "dateOfBirth" : "1/1/1987",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ]
//        ],
//        
//        //MARK: - Zamalek
//        "Zamalek":[
//            ["teamName":"Zamalek SC", "abb":"ZAM", "leagueStanding":2, "wins":0, "losses":0, "location":"Giza, Egypt", "headCoach":["Essam Abd-Elhamid"], "primaryColor":"FFFFFF", "secondaryColor":"CC0A0A"],
//            //MARK: 1: Anas Ossama
//            [
//                "firstName" : "Anas",
//                "lastName" : "Ossama",
//                "nickname" : "Anas Ossama",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 5,
//                "jerseyNo" : "55",
//                "height" : 215,
//                "weight" : 100,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Omar Hesham
//            [
//                "firstName" : "Omar",
//                "lastName" : "Hesham",
//                "nickname" : "Omar Hesham",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "4",
//                "height" : 183,
//                "weight" : 80,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Mostafa Mekkawy
//            [
//                "firstName" : "Mostafa",
//                "lastName" : "Mekkawy",
//                "nickname" : "Mostafa Kejo",
//                "primaryPosition" : 5,
//                "secondaryPosition" : 4,
//                "jerseyNo" : "14",
//                "height" : 200,
//                "weight" : 115,
//                "dateOfBirth" : "1/1/1994",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Terryl Stoglin
//            [
//                "firstName" : "Terryl",
//                "lastName" : "Stoglin",
//                "nickname" : "Terryl Stoglin",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "1",
//                "height" : 179,
//                "weight" : 82,
//                "dateOfBirth" : "1/1/1987",
//                "nationality" : "American",
//                "hometown" : "Maryland, Virginia",
//                "avatar": ""
//            ],
//            //MARK: 5: Adham Essam
//            [
//                "firstName" : "Adham",
//                "lastName" : "Essam",
//                "nickname" : "Adham Essam",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "7",
//                "height" : 185,
//                "weight" : 80,
//                "dateOfBirth" : "1/1/1989",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ]
//        ],
//        
//        //MARK: - Gezira
//        "Gezira":[
//            ["teamName":"Gezira SC", "abb":"GEZ", "leagueStanding":4, "wins":0, "losses":0, "location":"Cairo, Egypt", "headCoach":["Mohamed El-Kerdany"], "primaryColor":"FFEE3D", "secondaryColor":"FFFFFF"],
//            //MARK: 1: Amr El-Gendy
//            [
//                "firstName" : "Amr",
//                "lastName" : "El-Gendy",
//                "nickname" : "Amr El-Gendy",
//                "primaryPosition" : 3,
//                "secondaryPosition" : 4,
//                "jerseyNo" : "5",
//                "height" : 190,
//                "weight" : 105,
//                "dateOfBirth" : "1/1/1990",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Omar Tarek
//            [
//                "firstName" : "Omar",
//                "lastName" : "Tarek",
//                "nickname" : "Omar Hesham",
//                "primaryPosition" : 5,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "4",
//                "height" : 213,
//                "weight" : 120,
//                "dateOfBirth" : "1/1/1990",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Waleed Ahmed
//            [
//                "firstName" : "Waleed",
//                "lastName" : "Ahmed",
//                "nickname" : "Waleed Ahmed",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "7",
//                "height" : 183,
//                "weight" : 80,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Assem El-Gendy
//            [
//                "firstName" : "Assem",
//                "lastName" : "El-Gendy",
//                "nickname" : "Assem El-Gendy",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "13",
//                "height" : 185,
//                "weight" : 82,
//                "dateOfBirth" : "1/1/1993",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Hamdy Bra'a
//            [
//                "firstName" : "Hamdy",
//                "lastName" : "Bra'a",
//                "nickname" : "Hamdy Bra'a",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "11",
//                "height" : 200,
//                "weight" : 95,
//                "dateOfBirth" : "1/1/1987",
//                "nationality" : "Tunisian",
//                "hometown" : "Susa, Tunisia",
//                "avatar": ""
//            ]
//        ],
//        
//        //MARK: - Etahad
//        "Etahad":[
//            ["teamName":"Ittihad Alexandria Club", "abb":"ITT", "leagueStanding":1, "wins":0, "losses":0, "location":"Alexandria, Egypt", "headCoach":["Sherif Azmy"], "primaryColor":"1F6D2A", "secondaryColor":"FFFFFF"],
//            //MARK: 1: Youssef Shousha
//            [
//            "firstName" : "Youssef",
//            "lastName" : "Shousha",
//            "nickname" : "Youssef Shousha",
//            "primaryPosition" : 2,
//            "secondaryPosition" : 3,
//            "jerseyNo" : "8",
//            "height" : 190,
//            "weight" : 89,
//            "dateOfBirth" : "1/1/1993",
//            "nationality" : "Egyptian",
//            "hometown" : "Alexandria, Egypt",
//            "avatar": ""
//            ],
//            //MARK: 2: Haytham Kamal
//            [
//                "firstName" : "Haytham",
//                "lastName" : "Kamal",
//                "nickname" : "Haytham Kamal",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 5,
//                "jerseyNo" : "6",
//                "height" : 204,
//                "weight" : 98,
//                "dateOfBirth" : "1/1/1988",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Moa'men Mubarak
//            [
//                "firstName" : "Moa'men",
//                "lastName" : "Mubarak",
//                "nickname" : "Moa'men Douga",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "10",
//                "height" : 180,
//                "weight" : 75,
//                "dateOfBirth" : "1/1/1991",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Ramon Gallaway
//            [
//                "firstName" : "Ramon",
//                "lastName" : "Gallaway",
//                "nickname" : "Ramon Gallaway",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 1,
//                "jerseyNo" : "1",
//                "height" : 185,
//                "weight" : 82,
//                "dateOfBirth" : "1/1/1989",
//                "nationality" : "American",
//                "hometown" : "Houston, Texas",
//                "avatar": ""
//            ],
//            //MARK: 5: Ahmed Adel
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "Adel",
//                "nickname" : "Ahmed Adel",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "7",
//                "height" : 185,
//                "weight" : 80,
//                "dateOfBirth" : "1/1/1997",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ]
//        ],
//    
//        //MARK: - Tanta
//        "Tanta":[
//            ["teamName":"Tanta SC", "abb":"TAN", "leagueStanding":9, "wins":0, "losses":0, "location":"Gharbia, Egypt", "headCoach":["Ahmed Fawzy"], "primaryColor":"e5cd14", "secondaryColor":"000000"],
//            //MARK: 1: Mohamed Salah
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "Salah",
//                "nickname" : "Mohamed Salah",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 1,
//                "jerseyNo" : "24",
//                "height" : 183,
//                "weight" : 82,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Omar Fathy
//            [
//                "firstName" : "Omar",
//                "lastName" : "Fathy",
//                "nickname" : "Omar Fathy",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "8",
//                "height" : 178,
//                "weight" : 76,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Amr Nabil
//            [
//                "firstName" : "Amr",
//                "lastName" : "Nabil",
//                "nickname" : "Amr Nabil",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 1,
//                "jerseyNo" : "5",
//                "height" : 180,
//                "weight" : 79,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Mohamed Abd-Elnaser
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "Abd-Elnaser",
//                "nickname" : "Mohamed Abd-Elnaser",
//                "primaryPosition" : 5,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "10",
//                "height" : 203,
//                "weight" : 110,
//                "dateOfBirth" : "1/1/1989",
//                "nationality" : "Egyptian",
//                "hometown" : "Gharbia, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Mohamed El-Senousy
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "El-Senousy",
//                "nickname" : "Mohamed El-Senousy",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 5,
//                "jerseyNo" : "15",
//                "height" : 196,
//                "weight" : 94,
//                "dateOfBirth" : "1/1/1984",
//                "nationality" : "Egyptian",
//                "hometown" : "Gharbia, Egypt",
//                "avatar": ""
//            ]
//        ],
//    
//        //MARK: - Smouha
//        "Smouha":[
//            ["teamName":"Smouha SC", "abb":"SMO", "leagueStanding":7, "wins":0, "losses":0, "location":"Alexandria, Egypt", "headCoach":["Ashraf Tawfik"], "primaryColor":"2160f2", "secondaryColor":"000000"],
//            //MARK: 1: Mohamed El-Koussy
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "El-Koussy",
//                "nickname" : "Mohamed El-Koussy",
//                "primaryPosition" : 3,
//                "secondaryPosition" : 4,
//                "jerseyNo" : "14",
//                "height" : 190,
//                "weight" : 89,
//                "dateOfBirth" : "14/7/1994",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Ahmed Azab
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "Azab",
//                "nickname" : "Ahmed Azab",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 1,
//                "jerseyNo" : "10",
//                "height" : 183,
//                "weight" : 80,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Omar Azab
//            [
//                "firstName" : "Omar",
//                "lastName" : "Azab",
//                "nickname" : "Omar Azab",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "5",
//                "height" : 187,
//                "weight" : 83,
//                "dateOfBirth" : "1/1/1998",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: James Justice
//            [
//                "firstName" : "James",
//                "lastName" : "Justice",
//                "nickname" : "James Justice",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "1",
//                "height" : 177,
//                "weight" : 77,
//                "dateOfBirth" : "1/1/1991",
//                "nationality" : "American",
//                "hometown" : "Memphis, Tennessee",
//                "avatar": ""
//            ],
//            //MARK: 5: Sherif El-Diasty
//            [
//                "firstName" : "Sherif",
//                "lastName" : "El-Diasty",
//                "nickname" : "Sherif El-Diasty",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 5,
//                "jerseyNo" : "69",
//                "height" : 203,
//                "weight" : 100,
//                "dateOfBirth" : "1/1/1987",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ]
//        ],
//    
//        //MARK: - Sporting
//        "Sporting":[
//            ["teamName":"Alexandria Sporting Club", "abb":"ASC", "leagueStanding":6, "wins":0, "losses":0, "location":"Alexandria, Egypt", "headCoach":["Sabry Abd-Elnaby"], "primaryColor":"E41B18", "secondaryColor":"00923D"],
//            //MARK: 1: Ahmed Mounir
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "Mounir",
//                "nickname" : "Ahmed Mounir",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 3,
//                "jerseyNo" : "8",
//                "height" : 188,
//                "weight" : 88,
//                "dateOfBirth" : "1/1/1983",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Ezz El-Din Farid
//            [
//                "firstName" : "Ezz El-Din",
//                "lastName" : "Farid",
//                "nickname" : "Ezz El-Din Farid",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "9",
//                "height" : 183,
//                "weight" : 81,
//                "dateOfBirth" : "1/1/1992",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Ahmed Hisham
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "Hisham",
//                "nickname" : "Ahmed Hisham",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "5",
//                "height" : 185,
//                "weight" : 83,
//                "dateOfBirth" : "1/1/1988",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Omar Abdeen
//            [
//                "firstName" : "Omar",
//                "lastName" : "Abdeen",
//                "nickname" : "Omar Abdeen",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "13",
//                "height" : 185,
//                "weight" : 87,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Mohamed Salah
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "Salah",
//                "nickname" : "Mohamed Salah",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 5,
//                "jerseyNo" : "11",
//                "height" : 205,
//                "weight" : 110,
//                "dateOfBirth" : "1/1/1988",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ]
//        ],
//    
//        //MARK: - Insurance
//        "Insurance":[
//            ["teamName":"Misr Insurance Club", "abb":"INS", "leagueStanding":8, "wins":0, "losses":0, "location":"Cairo, Egypt", "headCoach":["Mohamed Abd-Elzaher"], "primaryColor":"d31313", "secondaryColor":"000000"],
//            //MARK: 1: Ahmed El-Sayed
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "El-Sayed",
//                "nickname" : "Ahmed El-Sayed",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "3",
//                "height" : 179,
//                "weight" : 78,
//                "dateOfBirth" : "1/1/1987",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Mohamed Mostafa
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "Mostafa",
//                "nickname" : "Moudy",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "1",
//                "height" : 180,
//                "weight" : 77,
//                "dateOfBirth" : "1/1/1998",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Ibrahim Salah
//            [
//                "firstName" : "Ibrahim",
//                "lastName" : "Salah",
//                "nickname" : "Ibrahim Salah",
//                "primaryPosition" : 3,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "23",
//                "height" : 187,
//                "weight" : 85,
//                "dateOfBirth" : "1/1/1985",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Mohamed El-Bendary
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "El-Bendary",
//                "nickname" : "Mohamed El-Bendary",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "10",
//                "height" : 185,
//                "weight" : 83,
//                "dateOfBirth" : "1/1/1991",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Youssef Sae'ed
//            [
//                "firstName" : "Youssef",
//                "lastName" : "Sae'ed",
//                "nickname" : "Youssef Sae'ed",
//                "primaryPosition" : 5,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "13",
//                "height" : 206,
//                "weight" : 108,
//                "dateOfBirth" : "1/1/1988",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ]
//        ],
//    
//        //MARK: - Suez Canal
//        "Suez":[
//            ["teamName":"Suez Canal Club", "abb":"SUE", "leagueStanding":13, "wins":0, "losses":0, "location":"Ismailia, Egypt", "headCoach":["Mohamed Bahnasy"], "primaryColor":"3470d1", "secondaryColor":"FFFFFF"],
//            //MARK: 1: Ahmed El-Ahmady
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "El-Ahmady",
//                "nickname" : "Ahmed El-Ahmady",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "1",
//                "height" : 186,
//                "weight" : 86,
//                "dateOfBirth" : "1/1/1994",
//                "nationality" : "Egyptian",
//                "hometown" : "Sharkeya, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Mohamed Madbouly
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "Madbouly",
//                "nickname" : "Mohamed Madbouly",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "24",
//                "height" : 187,
//                "weight" : 88,
//                "dateOfBirth" : "1/1/1994",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Ahmed Emara
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "Emara",
//                "nickname" : "Ahmed Emara",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "2",
//                "height" : 184,
//                "weight" : 81,
//                "dateOfBirth" : "1/1/1992",
//                "nationality" : "Egyptian",
//                "hometown" : "Ismailia, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Omar Agogo
//            [
//                "firstName" : "Omar",
//                "lastName" : "Agogo",
//                "nickname" : "Omar Agogo",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "0",
//                "height" : 181,
//                "weight" : 79,
//                "dateOfBirth" : "1/1/1992",
//                "nationality" : "Egyptian",
//                "hometown" : "Ismailia, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Amr Bryant
//            [
//                "firstName" : "Amr",
//                "lastName" : "Bryant",
//                "nickname" : "Amr Bryant",
//                "primaryPosition" : 5,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "12",
//                "height" : 186,
//                "weight" : 86,
//                "dateOfBirth" : "1/1/1991",
//                "nationality" : "Egyptian",
//                "hometown" : "El-Beheira, Egypt",
//                "avatar": ""
//            ]
//        ],
//    
//        //MARK: - Shams
//        "Shams":[
//            ["teamName":"Shams SC", "abb":"SHA", "leagueStanding":14, "wins":0, "losses":0, "location":"Cairo, Egypt", "headCoach":["Mohamed Abd-Elmeguid"], "primaryColor":"ea7d1e", "secondaryColor":"000000"],
//            //MARK: 1: Marwan Abo-Youssef
//            [
//                "firstName" : "Marwan",
//                "lastName" : "Abo-Youssef",
//                "nickname" : "Marwan Abo-Youssef",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "8",
//                "height" : 192,
//                "weight" : 96,
//                "dateOfBirth" : "1/1/1994",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Assem Kassem
//            [
//                "firstName" : "Assem",
//                "lastName" : "Kassem",
//                "nickname" : "Assem Kassem",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 5,
//                "jerseyNo" : "7",
//                "height" : 191,
//                "weight" : 88,
//                "dateOfBirth" : "1/1/1987",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Mohamed Amer
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "Amer",
//                "nickname" : "Mohamed Amer",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "11",
//                "height" : 200,
//                "weight" : 88,
//                "dateOfBirth" : "1/1/1989",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Khaled Moftah
//            [
//                "firstName" : "Khaled",
//                "lastName" : "Moftah",
//                "nickname" : "Khaled Moftah",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "11",
//                "height" : 196,
//                "weight" : 94,
//                "dateOfBirth" : "1/1/1993",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandira, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Ossama Eid
//            [
//                "firstName" : "Ossama",
//                "lastName" : "Eid",
//                "nickname" : "Ossama Eid",
//                "primaryPosition" : 5,
//                "secondaryPosition" : 4,
//                "jerseyNo" : "23",
//                "height" : 203,
//                "weight" : 101,
//                "dateOfBirth" : "1/1/1986",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ]
//        ],
//    
//        //MARK: - Army
//        "Army": [
//            ["teamName":"Tala'e Al-Geish SC", "abb":"ARM", "leagueStanding":5, "wins":0, "losses":0, "location":"Cairo, Egypt", "headCoach":["Fady Hany"], "primaryColor":"000000", "secondaryColor":"1F6D2A"],
//            //MARK: 1: Mohamed Mansour
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "Mansour",
//                "nickname" : "Mohamed Mansour",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "7",
//                "height" : 182,
//                "weight" : 84,
//                "dateOfBirth" : "1/1/1988",
//                "nationality" : "Egyptian",
//                "hometown" : "El-Beheira, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Ayman Chawkat
//            [
//                "firstName" : "Ayman",
//                "lastName" : "Chawkat",
//                "nickname" : "Ayman Chawkat",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 3,
//                "jerseyNo" : "13",
//                "height" : 190,
//                "weight" : 85,
//                "dateOfBirth" : "1/1/1994",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Hady Ossama
//            [
//                "firstName" : "Hady",
//                "lastName" : "Ossama",
//                "nickname" : "Hady Ossama",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "9",
//                "height" : 178,
//                "weight" : 77,
//                "dateOfBirth" : "1/1/1989",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Ahmed Abbas
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "Abbas",
//                "nickname" : "Ahmed Abbas",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 1,
//                "jerseyNo" : "24",
//                "height" : 185,
//                "weight" : 82,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Ahmed Adel
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "Adel",
//                "nickname" : "Ahmed Adel",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 3,
//                "jerseyNo" : "23",
//                "height" : 189,
//                "weight" : 89,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ]
//        ],
//    
//        //MARK: - Telecom
//        "Etisalat":[
//            ["teamName":"Telecom Egypt SC", "abb":"TEL", "leagueStanding":10, "wins":0, "losses":0, "location":"Cairo, Egypt", "headCoach":["Mohamed Soliman"], "primaryColor":"7617ea", "secondaryColor":"ffffff"],
//            //MARK: 1: Ahmed Samy
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "Samy",
//                "nickname" : "Ahmed Samy",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "11",
//                "height" : 180,
//                "weight" : 79,
//                "dateOfBirth" : "1/1/1995",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Mahmoud El-Gazzar
//            [
//                "firstName" : "Mahmoud",
//                "lastName" : "El-Gazzar",
//                "nickname" : "Mahmoud El-Gazzar",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 3,
//                "jerseyNo" : "23",
//                "height" : 188,
//                "weight" : 86,
//                "dateOfBirth" : "1/1/1990",
//                "nationality" : "Egyptian",
//                "hometown" : "Cairo, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Mohamed Salah
//            [
//                "firstName" : "Mohamed",
//                "lastName" : "Salah",
//                "nickname" : "Mohamed Salah",
//                "primaryPosition" : 5,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "22",
//                "height" : 205,
//                "weight" : 98,
//                "dateOfBirth" : "1/1/1993",
//                "nationality" : "Egyptian",
//                "hometown" : "Portsaid, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Amr Abd-Elghany
//            [
//                "firstName" : "Amr",
//                "lastName" : "Abd-Elghany",
//                "nickname" : "Amr Abd-Elghany",
//                "primaryPosition" : 2,
//                "secondaryPosition" : 3,
//                "jerseyNo" : "24",
//                "height" : 185,
//                "weight" : 82,
//                "dateOfBirth" : "1/1/1985",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Ibrahim Abo-Khadra
//            [
//                "firstName" : "Ibrahim",
//                "lastName" : "Abo-Khadra",
//                "nickname" : "Ibrahim Abo-Khadra",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "9",
//                "height" : 189,
//                "weight" : 86,
//                "dateOfBirth" : "1/1/1987",
//                "nationality" : "Egyptian",
//                "hometown" : "El-Beheira, Egypt",
//                "avatar": ""
//            ]
//        ],
//    
//        //MARK: - Olimpy
//        "Olimpy":[
//            ["teamName":"Olympic SC", "abb":"OLY", "leagueStanding":11, "wins":0, "losses":0, "location":"Alexandria, Egypt", "headCoach":["Moa'az Zidan"], "primaryColor":"CC0A0A", "secondaryColor":"ffffff"],
//            //MARK: 1: Essam Gamal
//            [
//                "firstName" : "Essam",
//                "lastName" : "Gamal",
//                "nickname" : "Essam Gamal",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "5",
//                "height" : 182,
//                "weight" : 82,
//                "dateOfBirth" : "1/1/1982",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 2: Ahmed Karkoura
//            [
//                "firstName" : "Ahmed",
//                "lastName" : "Karkoura",
//                "nickname" : "Ahmed Karkoura",
//                "primaryPosition" : 1,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "13",
//                "height" : 181,
//                "weight" : 84,
//                "dateOfBirth" : "1/1/1993",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 3: Marwan Karkoura
//            [
//                "firstName" : "Marwan",
//                "lastName" : "Karkoura",
//                "nickname" : "Marwan Karkoura",
//                "primaryPosition" : 3,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "11",
//                "height" : 189,
//                "weight" : 87,
//                "dateOfBirth" : "1/1/1994",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 4: Ossama Shawky
//            [
//                "firstName" : "Ossama",
//                "lastName" : "Shawky",
//                "nickname" : "Ossama Shawky",
//                "primaryPosition" : 3,
//                "secondaryPosition" : 2,
//                "jerseyNo" : "8",
//                "height" : 187,
//                "weight" : 87,
//                "dateOfBirth" : "1/1/1990",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ],
//            //MARK: 5: Mahmoud Abd-Elaziz
//            [
//                "firstName" : "Mahmoud",
//                "lastName" : "Abd-Elaziz",
//                "nickname" : "Mahmoud Abd-Elaziz",
//                "primaryPosition" : 4,
//                "secondaryPosition" : 0,
//                "jerseyNo" : "55",
//                "height" : 191,
//                "weight" : 88,
//                "dateOfBirth" : "1/1/1987",
//                "nationality" : "Egyptian",
//                "hometown" : "Alexandria, Egypt",
//                "avatar": ""
//            ]
//        ]
//    ]
//    
//    //MARK: - Team Game Stats
//    var gamesDictionary : [String:[[String:Any]]] = [
//        "AHL":[
//            ["gameID" : "AHLvsZAM_1-2-2019", "opponentName" : "Zamalek", "opponentAbb" : "ZAM"],
//            ["gameID" : "AHLvsGEZ_2-2-2019", "opponentName" : "Gezira", "opponentAbb" : "GEZ"],
//            ["gameID" : "ITTvsAHL_3-2-2019", "opponentName" : "Ittihad", "opponentAbb" : "ITT"],
//            ["gameID" : "ASCvsAHL_4-2-2019", "opponentName" : "Sporting", "opponentAbb" : "ASC"],
//            ["gameID" : "AHLvsSMO_5-2-2019", "opponentName" : "Smouha", "opponentAbb" : "SMO"]
//        ],
//        "ZAM":[
//            ["gameID" : "AHLvsZAM_1-2-2019", "opponentName" : "Zamalek", "opponentAbb" : "ZAM"],
//            ["gameID" : "ZAMvsTAN_6-2-2019", "opponentName" : "Tanta", "opponentAbb" : "TAN"],
//            ["gameID" : "ZAMvsTEL_7-2-2019", "opponentName" : "Telecom", "opponentAbb" : "TEL"],
//            ["gameID" : "SUEvsZAM_8-2-2019", "opponentName" : "Suez Canal", "opponentAbb" : "SUE"],
//            ["gameID" : "ZAMvsINS_5-2-2019", "opponentName" : "Insurance", "opponentAbb" : "INS"]
//        ],
//        "ITT":[
//            ["gameID" : "ITTvsAHL_3-2-2019", "opponentName" : "Ahly", "opponentAbb" : "AHL"],
//            ["gameID" : "ITTvsTAN_9-2-2019", "opponentName" : "Tanta", "opponentAbb" : "TAN"],
//            ["gameID" : "ITTvsSMO_10-2-2019", "opponentName" : "Smouha", "opponentAbb" : "SMO"],
//            ["gameID" : "ITTvsGEZ_11-2-2019", "opponentName" : "Gezira", "opponentAbb" : "GEZ"],
//            ["gameID" : "SMOvsITT_12-2-2019", "opponentName" : "Smouha", "opponentAbb" : "SMO"],
//        ],
//        "GEZ":[
//            ["gameID" : "AHLvsGEZ_2-2-2019", "opponentName" : "Ahly", "opponentAbb" : "AHL"],
//            ["gameID" : "ITTvsGEZ_11-2-2019", "opponentName" : "Ittihad", "opponentAbb" : "ITT"],
//        ],
//        "TAN":[
//            ["gameID" : "ZAMvsTAN_6-2-2019", "opponentName" : "Zamalek", "opponentAbb" : "ZAM"],
//            ["gameID" : "ITTvsTAN_9-2-2019", "opponentName" : "Ittihad", "opponentAbb" : "ITT"],
//        ],
//        "TEL":[
//            ["gameID" : "ZAMvsTEL_7-2-2019", "opponentName" : "Zamalek", "opponentAbb" : "ZAM"],
//        ],
//        "SMO":[
//            ["gameID" : "AHLvsSMO_5-2-2019", "opponentName" : "Ahly", "opponentAbb" : "AHL"],
//            ["gameID" : "ITTvsSMO_10-2-2019", "opponentName" : "Ittihad", "opponentAbb" : "ITT"],
//            ["gameID" : "SMOvsITT_12-2-2019", "opponentName" : "Ittihad", "opponentAbb" : "ITT"],
//        ],
//        "ASC":[
//            ["gameID" : "ASCvsAHL_4-2-2019", "opponentName" : "Ahly", "opponentAbb" : "AHL"],
//        ],
//        "INS":[
//            ["gameID" : "ZAMvsINS_5-2-2019", "opponentName" : "Zamalek", "opponentAbb" : "ZAM"]
//        ],
//        "SHA":[
//            ["gameID" : "HOCvsSHA_27-2-2019", "opponentName" : "Horse Owners", "opponentAbb" : "HOC"]
//        ]
//    ]

    
    init() {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        //Initialize Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        database = Firestore.firestore()
        storage = Storage.storage()
        
    }
    
    //MARK:- Standings
    func advanceToNextRound(completion: @escaping (Error?) -> Void) {
        
    }
    
//    func AddTeam(teamData : [String:Any], completion: @escaping  (Error?) -> Void) {
//        database.collection("Teams").document(teamData["abb"] as! String).setData(teamData, merge: true) { (error) in
//            if let error = error {
//                completion(error)
//            } else {
//                completion(nil)
//            }
//        }
//    }
//    
//    func AddAllTeams(completion: @escaping  (Error?) -> Void) {
//        var count = 0
//        for team in teamsDictionary {
//            count += 1
//            AddTeam(teamData: (team.value)[0]) { (error) in
//                if let error = error {
//                    print("Error Adding Team \(((team.value)[0])["teamName"] as! String): \(error)")
//                    completion(error)
//                } else {
//                    print("Added Team \(((team.value)[0])["teamName"]  as! String) Successfully")
//                    if(count == self.teamsDictionary.count) {
//                        completion(nil)
//                    }
//                }
//            }
//        }
//    }
//    
//    func AddPlayer(player playerData: [String:Any], to team: String, completion: @escaping  (Error?) -> Void) {
//        database.collection("Teams/\(team)/Players")
//            .whereField("firstName", isEqualTo: playerData["firstName"] as! String)
//            .whereField("lastName", isEqualTo: playerData["lastName"] as! String)
//            .whereField("jerseyNo", isEqualTo: playerData["jerseyNo"] as! String)
//            .getDocuments { (snapshot, error) in
//                if let error = error {
//                    print(error)
//                } else {
//                    if(snapshot!.count == 1) {
//                        self.database.collection("Teams/\(team)/Players").document(snapshot!.documents[0].documentID).setData(playerData, merge: true, completion: { (error) in
//                            if let error = error {
//                                print("Error Merging Player \(playerData["nickname"] as! String): \(error)")
//                                completion(error)
//                            } else {
//                                print("Merged Player \(playerData["nickname"] as! String) Successfully")
//                                completion(nil)
//                            }
//                        })
//                    } else {
//                        self.database.collection("Teams/\(team)/Players").addDocument(data: playerData) { (error) in
//                            if let error = error {
//                                print("Error Adding Player \(playerData["nickname"] as! String): \(error)")
//                                completion(error)
//                            } else {
//                                print("Added Player \(playerData["nickname"] as! String) Successfully")
//                                completion(nil)
//                            }
//                        }
//                    }
//                }
//            }
//    }
//    
//    func convertPlayerDates(completion: @escaping  (Error?) -> Void) {
//        database.collection("Teams").getDocuments { (teams, error) in
//            if let error = error {
//                print(error)
//                completion(error)
//            } else {
//                for team in teams!.documents {
//                    self.database.collection("/Teams/\(team.documentID)/Players").getDocuments(completion: { (players, error) in
//                        if let error = error {
//                            print(error)
//                            completion(error)
//                        } else {
//                            for player in players!.documents {
//                                print(player.data()["nickname"] as! String)
//                                if let dateAsString = player.data()["dateOfBirth"] as? String {
//                                    let dateAsTimestamp = Timestamp(date: self.dateFormatter.date(from: dateAsString)!)
//                                    player.reference.updateData(["dateOfBirth":dateAsTimestamp])
//                                }                                
//                            }
//                            completion(nil)
//                        }
//                    })
//                }
//            }
//        }
//    }
//    
//    func AddAllPlayers(completion: @escaping (Error?) -> Void) {
//        var count = 0
//        for team in teamsDictionary {
//            for i in 1...5 {
//                AddPlayer(player: (team.value)[i], to: ((team.value)[0])["abb"] as! String) { (error) in
//                    if let error = error {
//                        completion(error)
//                    } else {
//                        count += 1
//                        if(count == self.teamsDictionary.count*5) {
//                            print("Added All Players Successfully")
//                            completion(nil)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func calculateStats(forGame: [String:Any]) -> [String:Any] {
//        var game : [String:Any] = forGame
//        game["3FGA"] = Int.random(in: 0 ... 5)
//        game["2FGA"] = Int.random(in: 0 ... 10)
//        game["FTA"] = Int.random(in: 0 ... 10)
//        game["ORB"] = Int.random(in: 0 ... 5)
//        game["DRB"] = Int.random(in: 0 ... 10)
//        game["AST"] = Int.random(in: 0 ... 7)
//        game["BLK"] = Int.random(in: 0 ... 4)
//        game["TO"] = Int.random(in: 0 ... 6)
//        game["STL"] = Int.random(in: 0 ... 5)
//        game["FOL"] = Int.random(in: 0 ... 5)
//        game["MINS"] = Float.random(in: 15 ... 35)
//        game["3FGM"] = Int.random(in: 0 ... (game["3FGA"] as! Int))
//        game["3FG%"] = (Double(game["3FGM"] as! Int)) / (Double(game["3FGA"] as! Int))
//        game["3FG%"] = (game["3FG%"] as! Double).isNaN ? 0 : game["3FG%"]
//        game["2FGM"] = Int.random(in: 0 ... (game["2FGA"] as! Int))
//        game["2FG%"] = (Double(game["2FGM"] as! Int)) / (Double(game["2FGA"] as! Int))
//        game["2FG%"] = (game["2FG%"] as! Double).isNaN ? 0 : game["2FG%"]
//        game["FGA"] = (game["3FGA"] as! Int) + (game["2FGA"] as! Int)
//        game["FGM"] = (game["3FGM"] as! Int) + (game["2FGM"] as! Int)
//        game["FG%"] = (Double(game["FGM"] as! Int)) / (Double(game["FGA"] as! Int))
//        game["FG%"] = (game["FG%"] as! Double).isNaN ? 0 : game["FG%"]
//        game["FTM"] = Int.random(in: 0 ... (game["FTA"] as! Int))
//        game["FT%"] = (Double(game["FTM"] as! Int)) / (Double(game["FTA"] as! Int))
//        game["FT%"] = (game["FT%"] as! Double).isNaN ? 0 : game["FT%"]
//        game["PTS"] = (game["3FGM"] as! Int * 3) + ((game["2FGM"] as! Int * 2)) + (game["FTM"] as! Int)
//        game["TREB"] = (game["ORB"] as! Int) + (game["DRB"] as! Int)
//        game["EFF"] = (((game["PTS"] as! Int) + (game["TREB"] as! Int) + (game["AST"] as! Int) + (game["STL"] as! Int) + (game["BLK"] as! Int)) - (((game["FGA"] as! Int) - (game["FGM"] as! Int)) + ((game["FTA"] as! Int) - (game["FTM"] as! Int)) + (game["TO"] as! Int)))
//        
//        return game
//    }
//    
//    func AddPlayerGameStats(gameData: [[String:Any]], for team: String, completion: @escaping (Error?) -> Void) {
//        database.collection("Teams/\(team)/Players").getDocuments { (snapshot, error) in
//            if let error = error {
//                completion(error)
//            } else {
//                var count = 0
//                for player in snapshot!.documents {
//                    for game in gameData {
//                        let stats = self.calculateStats(forGame: game)
//                        self.database.collection("Teams/\(team)/Players/\(player.documentID)/PlayerGameStats").document(stats["gameID"] as! String).setData(stats, merge: true, completion: { (error) in
//                            if let error = error {
//                                completion(error)
//                            } else {
//                                print("Added \(stats["gameID"] as! String) for Player: \(player.data()["nickname"] as! String)")
//                                count += 1
//                                if(count == snapshot!.count * gameData.count) {
//                                    completion(nil)
//                                }
//                            }
//                        })
//                    }
//                }
//            }
//        }
//    }
//    
//    func AddAllPlayerGameStats(completion: @escaping (Error?) -> Void) {
//        for team in gamesDictionary {
//            AddPlayerGameStats(gameData: team.value, for: team.key) { (error) in
//                if let error = error {
//                    completion(error)
//                } else {
//                    print("Added All Player Game Stats Successfully")
//                    completion(nil)
//                }
//            }
//        }
//    }
//    
//    func AddStatsPerZone(completion: @escaping (Error?) -> Void) {
//        database.collection("Teams").getDocuments { (teams, error) in
//            if let error = error {
//                completion(error)
//            } else {
//                var count = 0
//                var check = 0
//                for team in teams!.documents {
//                    let playersRef = "Teams/\(team.documentID)/Players"
//                    self.database.collection(playersRef).getDocuments(completion: { (players, error) in
//                        if let error = error {
//                            completion(error)
//                        } else {
//                            for player in players!.documents {
//                                let gamesRef = playersRef + "/\(player.documentID)/PlayerGameStats"
//                                self.database.collection(gamesRef).getDocuments(completion: { (games, error) in
//                                    if let error = error {
//                                        completion(error)
//                                    } else {
//                                        for game in games!.documents {
//                                            for i in 1...14 {
//                                                check += 1
//                                                let zoneData : [String : Any] = [
//                                                    "zoneNumber" : i,
//                                                    "FGA" : 0,
//                                                    "FGM" : 0,
//                                                    "FG%" : 0.0,
//                                                    "PTS" : 0
//                                                ]
//                                                
//                                                let zoneName = "Zone-\(i)"
//                                                let zonesRef = gamesRef + "/\(game.documentID)/StatsPerZone"
//                                                self.database.collection(zonesRef).document(zoneName).setData(zoneData, merge: true, completion: { (error) in
//                                                    if let error = error{
//                                                        completion(error)
//                                                    } else {
//                                                        count+=1
//                                                        print("Added \(zoneName) for player: \(player.data()["nickname"] as! String) - \(team.documentID)")
//                                                        if(count == check) {
//                                                            print("Added All Zones Successfully")
//                                                            completion(nil)
//                                                        }
//                                                    }
//                                                })
//                                            }
//                                        }
//                                    }
//                                })
//                            }
//                        }
//                    })
//                }
//            }
//        }
//    }
//    
//    func AddPlayerTotalStats(for player: String, completion: @escaping (Error?) -> Void) {
//        let gameStatsRef = database.collection(player + "/PlayerGameStats")
//        let totalStatsRef = database.collection(player + "/PlayerStats")
//        
//
//        var totalGameStats : [String : Any] = [
//            "2FG%" : 0,
//            "2FGA" : 0,
//            "2FGM" : 0,
//            "3FG%" : 0,
//            "3FGA" : 0,
//            "3FGM" : 0,
//            "FG%" : 0,
//            "FGA" : 0,
//            "FGM" : 0,
//            "FT%" : 0,
//            "FTA" : 0,
//            "FTM" : 0,
//            "AST" : 0,
//            "BLK" : 0,
//            "ORB" : 0,
//            "DRB" : 0,
//            "TREB" : 0,
//            "STL" : 0,
//            "TO" : 0,
//            "PTS" : 0,
//            "MINS" : 0.0,
//            "EFF" : 0,
//            "FOL" : 0,
//            "gamesPlayed" : 0
//        ]
//        
//        gameStatsRef.getDocuments(completion: { (gameStats, error) in
//            if let error = error {
//                print(error)
//                completion(error)
//            } else {
//                for game in gameStats!.documents {
//                    totalGameStats["gamesPlayed"] = (totalGameStats["gamesPlayed"] as! Int) + 1
//                    totalGameStats["2FGA"] = (totalGameStats["2FGA"] as! Int) + (game.data()["2FGA"] as! Int)
//                    totalGameStats["2FGM"] = (totalGameStats["2FGM"] as! Int) + (game.data()["2FGM"] as! Int)
//                    totalGameStats["3FGA"] = (totalGameStats["3FGA"] as! Int) + (game.data()["3FGA"] as! Int)
//                    totalGameStats["3FGM"] = (totalGameStats["3FGM"] as! Int) + (game.data()["3FGM"] as! Int)
//                    totalGameStats["FTA"] = (totalGameStats["FTA"] as! Int) + (game.data()["FTA"] as! Int)
//                    totalGameStats["FTM"] = (totalGameStats["FTM"] as! Int) + (game.data()["FTM"] as! Int)
//                    totalGameStats["AST"] = (totalGameStats["AST"] as! Int) + (game.data()["AST"] as! Int)
//                    totalGameStats["BLK"] = (totalGameStats["BLK"] as! Int) + (game.data()["BLK"] as! Int)
//                    totalGameStats["ORB"] = (totalGameStats["ORB"] as! Int) + (game.data()["ORB"] as! Int)
//                    totalGameStats["DRB"] = (totalGameStats["DRB"] as! Int) + (game.data()["DRB"] as! Int)
//                    totalGameStats["STL"] = (totalGameStats["STL"] as! Int) + (game.data()["STL"] as! Int)
//                    totalGameStats["TO"] = (totalGameStats["TO"] as! Int) + (game.data()["TO"] as! Int)
//                    totalGameStats["PTS"] = (totalGameStats["PTS"] as! Int) + (game.data()["PTS"] as! Int)
//                    totalGameStats["FOL"] = (totalGameStats["FOL"] as! Int) + (game.data()["FOL"] as! Int)
//                    totalGameStats["EFF"] = (totalGameStats["EFF"] as! Int) + (game.data()["EFF"] as! Int)
//                    totalGameStats["MINS"] = (totalGameStats["MINS"] as! Double) + (game.data()["MINS"] as! Double)
//                }
//                totalGameStats["2FG%"] = (Double(totalGameStats["2FGM"] as! Int)) / (Double(totalGameStats["2FGA"] as! Int))
//                totalGameStats["3FG%"] = Double((totalGameStats["3FGM"] as! Int)) / Double((totalGameStats["3FGA"] as! Int))
//                totalGameStats["FGA"] = (totalGameStats["2FGA"] as! Int) + (totalGameStats["3FGA"] as! Int)
//                totalGameStats["FGM"] = (totalGameStats["2FGM"] as! Int) + (totalGameStats["3FGM"] as! Int)
//                totalGameStats["FG%"] = Double((totalGameStats["FGM"] as! Int)) / Double((totalGameStats["FGA"] as! Int))
//                totalGameStats["FT%"] = Double((totalGameStats["FTM"] as! Int)) / Double((totalGameStats["FTA"] as! Int))
//                totalGameStats["TREB"] = (totalGameStats["ORB"] as! Int) + (totalGameStats["DRB"] as! Int)
//                print(totalGameStats)
//                totalStatsRef.document("18-19").setData(totalGameStats, merge: true, completion: { (error) in
//                    if let error = error {
//                        print(error)
//                        completion(error)
//                    } else {
//                        completion(nil)
//                    }
//                })
//            }
//        })
//    }
//    
//    func AddAllPlayersTotalStats(completion: @escaping (Error?) -> Void) {
//        let teamsRef = database.collection("Teams")
//        
//        teamsRef.getDocuments { (teams, error) in
//            if let error = error {
//                print(error)
//                completion(error)
//            } else {
//                var count = 0
//                var completed = 0
//                for team in teams!.documents {
//                    if(team.documentID != "HOC" && team.documentID != "ARM") {
//                        let playersRef = self.database.collection("Teams/\(team.documentID)/Players")
//                        playersRef.getDocuments(completion: { (players, error) in
//                            if let error = error {
//                                print(error)
//                                completion(error)
//                            } else {
//                                for player in players!.documents {
//                                    count += 1
//                                    self.AddPlayerTotalStats(for: "/Teams/\(team.documentID)/Players/\(player.documentID)", completion: { (error) in
//                                        if let error = error {
//                                            print(error)
//                                            completion(error)
//                                        } else {
//                                            completed += 1
//                                            print("Added Total Stats for Player: \(player.data()["nickname"] as! String)")
//                                            if(completed == count) {
//                                                print("Added All Total Stats Successfully")
//                                                completion(nil)
//                                            }
//                                        }
//                                    })
//                                }
//                            }
//                        })
//                    }
//                }
//            }
//        }
//    }
//    
//    func AddTeamGameStats(team: String, completion: @escaping (Error?) -> Void) {
//        let playersRef = database.collection("/Teams/\(team)/Players")
//        let teamGameStatsRef = database.collection("/Teams/\(team)/TeamGameStats")
//        var count = 0
//        var completed = 0
//        var data : [String:[String:Any]] = [:]
//        
//        playersRef.getDocuments { (players, error) in
//            if let error = error {
//                print(error)
//                completion(error)
//            } else {
//                for player in players!.documents {
//                    let playerGameStatsRef = self.database.collection("/Teams/\(team)/Players/\(player.documentID)/PlayerGameStats")
//                    playerGameStatsRef.getDocuments(completion: { (games, error) in
//                        if let error = error {
//                            print(error)
//                            completion(error)
//                        } else {
//                            for game in games!.documents {
//                                let gameID = game.documentID
//                                let gameDate = (gameID.split(separator: "_").last)?.split(separator: "-")
//                                
//                                if(data[gameID] != nil) {
//                                    data[gameID]!["2FGM"] = (data[gameID]!["2FGM"] as! Int) + (game.data()["2FGM"] as! Int)
//                                    data[gameID]!["2FGA"] = (data[gameID]!["2FGA"] as! Int) + (game.data()["2FGA"] as! Int)
//                                    data[gameID]!["3FGM"] = (data[gameID]!["3FGM"] as! Int) + (game.data()["3FGM"] as! Int)
//                                    data[gameID]!["3FGA"] = (data[gameID]!["3FGA"] as! Int) + (game.data()["3FGA"] as! Int)
//                                    data[gameID]!["FTM"] = (data[gameID]!["FTM"] as! Int) + (game.data()["FTM"] as! Int)
//                                    data[gameID]!["FTA"] = (data[gameID]!["FTA"] as! Int) + (game.data()["FTA"] as! Int)
//                                    data[gameID]!["PTS"] = (data[gameID]!["PTS"] as! Int) + (game.data()["PTS"] as! Int)
//                                    data[gameID]!["AST"] = (data[gameID]!["AST"] as! Int) + (game.data()["AST"] as! Int)
//                                    data[gameID]!["STL"] = (data[gameID]!["STL"] as! Int) + (game.data()["STL"] as! Int)
//                                    data[gameID]!["BLK"] = (data[gameID]!["BLK"] as! Int) + (game.data()["BLK"] as! Int)
//                                    data[gameID]!["ORB"] = (data[gameID]!["ORB"] as! Int) + (game.data()["ORB"] as! Int)
//                                    data[gameID]!["DRB"] = (data[gameID]!["DRB"] as! Int) + (game.data()["DRB"] as! Int)
//                                    data[gameID]!["TO"] = (data[gameID]!["TO"] as! Int) + (game.data()["TO"] as! Int)
//                                    data[gameID]!["FOL"] = (data[gameID]!["FOL"] as! Int) + (game.data()["FOL"] as! Int)
//                                } else {
//                                    data[gameID] = [
//                                        "2FGM" : (game.data()["2FGM"] as! Int),
//                                        "2FGA" : (game.data()["2FGA"] as! Int),
//                                        "3FGM" : (game.data()["3FGM"] as! Int),
//                                        "3FGA" : (game.data()["3FGA"] as! Int),
//                                        "FTM" : (game.data()["FTM"] as! Int),
//                                        "FTA" : (game.data()["FTA"] as! Int),
//                                        "PTS" : (game.data()["PTS"] as! Int),
//                                        "AST" : (game.data()["AST"] as! Int),
//                                        "STL" : (game.data()["STL"] as! Int),
//                                        "BLK" : (game.data()["BLK"] as! Int),
//                                        "ORB" : (game.data()["ORB"] as! Int),
//                                        "DRB" : (game.data()["DRB"] as! Int),
//                                        "TO" : (game.data()["TO"] as! Int),
//                                        "FOL" : (game.data()["FOL"] as! Int),
//                                        "gameID" : (game.data()["gameID"] as! String),
//                                        "opponentAbb" : (game.data()["opponentAbb"] as! String),
//                                        "opponentName" : (game.data()["opponentName"] as! String),
//                                        "home" : gameID.prefix(3) == team,
//                                        "date" : Timestamp(date: self.dateFormatter.date(from: "\(gameDate![0])/\(gameDate![1])/\(gameDate![2])")!)
//                                    ]
//                                }
//                            }
//                            for item in data {
//                                count += 1
//                                teamGameStatsRef.document(item.key).setData(self.calculateAverages(data: item.value), merge: true, completion: { (error) in
//                                    if let error = error {
//                                        print(error)
//                                        completion(error)
//                                    } else {
//                                        completed += 1
//                                        print("Added \(item.key) for team: \(team)")
//                                        if(count == completed) {
//                                            completion(nil)
//                                        }
//                                    }
//                                })
//                            }
//                        }
//                    })
//                }
//            }
//        }
//    }
//    
//    func calculateAverages(data: [String:Any]) -> [String:Any] {
//        var result = data
//        
//        result["2FG%"] = Double(result["2FGM"] as! Int) / Double(result["2FGA"] as! Int)
//        result["3FG%"] = Double(result["3FGM"] as! Int) / Double(result["3FGA"] as! Int)
//        result["FT%"] = Double(result["FTM"] as! Int) / Double(result["FTA"] as! Int)
//        result["FGM"] = (result["2FGM"] as! Int) + (result["3FGM"] as! Int)
//        result["FGA"] = (result["2FGA"] as! Int) + (result["3FGA"] as! Int)
//        result["FG%"] = Double(result["FGM"] as! Int) / Double(result["FGA"] as! Int)
//        result["TREB"] = (result["ORB"] as! Int) + (result["DRB"] as! Int)
//
//        return result
//    }
//    
//    func AddAllTeamGameStats(completion: @escaping (Error?) -> Void) {
//        var count = 0
//        database.collection("/Teams").getDocuments { (teams, error) in
//            if let error = error {
//                print(error)
//                completion(error)
//            } else {
//                for team in teams!.documents {
//                    if(team.documentID != "HOC") {
//                        self.AddTeamGameStats(team: team.documentID, completion: { (error) in
//                            if let error = error {
//                                print(error)
//                                completion(error)
//                            } else {
//                                count += 1
//                                print("Added All Team Game Stats for team: \(team.documentID)")
//                                if(count == teams!.count) {
//                                    print("Added All Team Game Stats")
//                                    completion(nil)
//                                }
//                            }
//                        })
//                    }
//                }
//            }
//        }
//    }
//    
//    func AddTeamTotalStats(for team: String, completion: @escaping (Error?) -> Void) {
//        let gamesRef = database.collection("/Teams/\(team)/TeamGameStats")
//        let teamTotalStats = database.collection("/Teams/\(team)/TeamStats")
//        var data : [String:Any] = [:]
//        
//        data["2FGM"] = 0
//        data["2FGA"] = 0
//        data["3FGM"] = 0
//        data["3FGA"] = 0
//        data["FTM"] = 0
//        data["FTA"] = 0
//        data["PTS"] = 0
//        data["AST"] = 0
//        data["STL"] = 0
//        data["BLK"] = 0
//        data["ORB"] = 0
//        data["DRB"] = 0
//        data["TO"] = 0
//        data["FOL"] = 0
//        
//        gamesRef.getDocuments { (games, error) in
//            if let error = error {
//                print(error)
//                completion(error)
//            } else {
//                data["gamesPlayed"] = games!.count
//                for game in games!.documents {
//                    data["2FGM"] = (data["2FGM"] as! Int) + (game.data()["2FGM"] as! Int)
//                    data["2FGA"] = (data["2FGA"] as! Int) + (game.data()["2FGA"] as! Int)
//                    data["3FGM"] = (data["3FGM"] as! Int) + (game.data()["3FGM"] as! Int)
//                    data["3FGA"] = (data["3FGA"] as! Int) + (game.data()["3FGA"] as! Int)
//                    data["FTM"] = (data["FTM"] as! Int) + (game.data()["FTM"] as! Int)
//                    data["FTA"] = (data["FTA"] as! Int) + (game.data()["FTA"] as! Int)
//                    data["PTS"] = (data["PTS"] as! Int) + (game.data()["PTS"] as! Int)
//                    data["AST"] = (data["AST"] as! Int) + (game.data()["AST"] as! Int)
//                    data["STL"] = (data["STL"] as! Int) + (game.data()["STL"] as! Int)
//                    data["BLK"] = (data["BLK"] as! Int) + (game.data()["BLK"] as! Int)
//                    data["ORB"] = (data["ORB"] as! Int) + (game.data()["ORB"] as! Int)
//                    data["DRB"] = (data["DRB"] as! Int) + (game.data()["DRB"] as! Int)
//                    data["TO"] = (data["TO"] as! Int) + (game.data()["TO"] as! Int)
//                    data["FOL"] = (data["FOL"] as! Int) + (game.data()["FOL"] as! Int)
//                }
//                teamTotalStats.document("18-19").setData(self.calculateAverages(data: data), merge: true, completion: { (error) in
//                    if let error = error {
//                        print(error)
//                        completion(error)
//                    } else {
//                        print("Added Team Total Stats for team: \(team)")
//                        completion(nil)
//                    }
//                })
//            }
//        }
//    }
//    
//    func AddAllTeamTotalStats(completion: @escaping (Error?) -> Void) {
//        var count = 0
//        database.collection("/Teams").getDocuments { (teams, error) in
//            if let error = error {
//                print(error)
//                completion(error)
//            } else {
//                for team in teams!.documents {
//                    if(team.documentID != "HOC") {
//                        self.AddTeamTotalStats(for: team.documentID, completion: { (error) in
//                            if let error = error {
//                                print(error)
//                                completion(error)
//                            } else {
//                                count += 1
//                                print("Added Team Total Stats for team: \(team.documentID)")
//                                if(count == teams!.count) {
//                                    print("Added All Team Total Stats")
//                                    completion(nil)
//                                }
//                            }
//                        })
//                    }
//                }
//            }
//        }
//    }
}

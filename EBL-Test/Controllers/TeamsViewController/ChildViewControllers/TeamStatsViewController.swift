//
//  TeamStatsViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 3/17/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

class TeamStatsViewController: UIViewController {
    
    @IBOutlet weak var teamGameStatsCollectionView: UICollectionView!
    @IBOutlet weak var gridTableLayout: GridTableCustomLayout! {
        didSet {
            gridTableLayout.stickyRowsCount = 1
            gridTableLayout.stickyColumnsCount = 1
        }
    }
    
    let dbManager = DatabaseManager.sharedInstance
    var parentVC : TeamsViewController?
    
    let statTitles = ["PTS", "3FGA", "3FGM", "3FG%", "2FGA", "2FGM", "2FG%", "FGA", "FGM", "FG%", "FTA", "FTM", "FT%", "AST", "ORB", "DRB", "TREB", "STL", "TO", "BLK", "FOL"]
    var teamGameStats : [TeamGameStats] = [TeamGameStats]()
    var fetchCompleted : Bool = false
    var gamesPlayed = 0
    var dataArray : [[String]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerXibFiles()
        fetchData()
        setupDataArray()
        
    }
    
    func registerXibFiles(){
        teamGameStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell1", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell1")
        teamGameStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell2", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell2")
        teamGameStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell3", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell3")
    }
    
    func fetchData() {
        dbManager.getTeamGameStats(forTeamRef: parentVC!.team!.teamRef) { (error, hasData, result) in
            if let error = error {
                print(error)
            } else {
                if(hasData!) {
                    self.teamGameStats = result!
                    self.gamesPlayed = result!.count
                    self.fetchCompleted = true
                    self.setupDataArray()
                }
            }
        }
    }
    
    func setupDataArray() {
        if(fetchCompleted) {
            if(gamesPlayed == 0) {
                teamGameStatsCollectionView.isHidden = true
            } else {
                view.hideSkeleton()
                
                for gameStats in teamGameStats {
                    var tempArray : [String] = []
                    tempArray.append(gameStats.opponentAbb)
                    tempArray.append(gameStats.home ? "(Home)" : "(Away)")
                    tempArray.append("\(gameStats.PTS)")
                    tempArray.append("\(gameStats.total3FGA)")
                    tempArray.append("\(gameStats.total3FGM)")
                    tempArray.append("\(gameStats.avg3FGP)")
                    tempArray.append("\(gameStats.total2FGA)")
                    tempArray.append("\(gameStats.total2FGM)")
                    tempArray.append("\(gameStats.avg2FGP)")
                    tempArray.append("\(gameStats.totalFGA)")
                    tempArray.append("\(gameStats.totalFGM)")
                    tempArray.append("\(gameStats.avgFGP)")
                    tempArray.append("\(gameStats.totalFTA)")
                    tempArray.append("\(gameStats.totalFTM)")
                    tempArray.append("\(gameStats.avgFTP)")
                    tempArray.append("\(gameStats.AST)")
                    tempArray.append("\(gameStats.ORB)")
                    tempArray.append("\(gameStats.DRB)")
                    tempArray.append("\(gameStats.REB)")
                    tempArray.append("\(gameStats.STL)")
                    tempArray.append("\(gameStats.TO)")
                    tempArray.append("\(gameStats.BLK)")
                    tempArray.append("\(gameStats.FOL)")
                    
                    self.dataArray.append(tempArray)
                }
                
                self.teamGameStatsCollectionView.reloadData()
            }
        }
    }
}

// MARK: - Collection view data source and delegate methods
extension TeamStatsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(!fetchCompleted) {
            return 12
        } else {
            return dataArray.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(!fetchCompleted) {
            if(section == 0) {
                return statTitles.count + 1
            } else {
                return 1
            }
        } else {
            return statTitles.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            if(indexPath.section == 0) {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell2", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.titleLabel.text = ""
                cell.backgroundColor = UIColor(hexString: "595959")
                
                return cell
            } else {
                //Player Name
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell1", for: indexPath) as? PlayerNameAndImageCell else {
                    return UICollectionViewCell()
                }
                
                cell.isSkeletonable = true
                
                if (dataArray.count > 0) {
                    cell.playerImage.kf.setImage(with: dbManager.getTeamImageURL(teamID: teamGameStats[indexPath.section-1].opponentAbb))
                    cell.firstName.text = dataArray[indexPath.section - 1][indexPath.row]
                    cell.lastName.text = dataArray[indexPath.section - 1][indexPath.row + 1]
                } else {
                    cell.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
                }
                cell.firstName.font = .systemFont(ofSize: 11)
                cell.lastName.font = .systemFont(ofSize: 9)
                
                cell.backgroundColor = UIColor(hexString: "484848")
                
                return cell
            }
        default:
            if(indexPath.section == 0) {
                //Stat Titles
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell2", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.titleLabel.text = statTitles[indexPath.row - 1]
                
                cell.titleLabel.textColor = UIColor(hexString: "ffffff")
                cell.backgroundColor = UIColor(hexString: "2b2b2b")
                
                return cell
            } else {
                
                //Stat Value
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell3", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.isSkeletonable = true
                
                if(dataArray.count > 0) {
                    cell.titleLabel.text = dataArray[indexPath.section - 1][indexPath.row + 1]
                } else {
                    cell.titleLabel.text = ""
                }
                
                cell.backgroundColor = UIColor(hexString: "2b2b2b", withAlpha: 0.5)
                
                return cell
            }
        }
    }
}
extension TeamStatsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(!fetchCompleted) {
            switch indexPath.section {
            case 0:
                if(indexPath.row == 0) {
                    return CGSize(width: 120, height: 40)
                } else {
                    return CGSize(width: 45, height: 40)
                }
            default:
                let width =  UIScreen.main.bounds.width
                return CGSize(width: width, height: 50)
            }
        } else {
            switch indexPath.row {
            case 0:
                if(indexPath.section == 0) {
                    return CGSize(width: 110, height: 40)
                } else {
                    return CGSize(width: 110, height: 50)
                }
            default:
                if(indexPath.section == 0) {
                    return CGSize(width: 45, height: 40)
                } else {
                    return CGSize(width: 45, height: 50)
                    
                }
            }
        }
        
    }
}

extension TeamStatsViewController : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.row {
        case 0:
            if(indexPath.section == 0) {
                return "StatsCell2"
            } else {
                return "StatsCell1"
            }
        default:
            if(indexPath.section == 0) {
                return "StatsCell2"
            } else {
                return "StatsCell3"
                
            }
        }
    }
}

